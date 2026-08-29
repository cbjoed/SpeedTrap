import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../models/fine_result.dart';
import '../models/drive_stats.dart';
import '../models/vehicle_profile.dart';
import '../services/fine_calculator.dart';
import '../services/drive_log_service.dart';
import '../services/location_service.dart';
import '../services/road_speed_service.dart';
import '../services/vehicle_preference_service.dart';

class SpeedometerViewModel extends ChangeNotifier {
  SpeedometerViewModel({
    LocationService? locationService,
    FineCalculator? fineCalculator,
    RoadSpeedService? roadSpeedService,
    VehiclePreferenceService? vehiclePreferenceService,
    DriveLogService? driveLogService,
  })  : _locationService = locationService ?? LocationService(),
        _fineCalculator = fineCalculator ?? const FineCalculator(),
        _roadSpeedService = roadSpeedService ?? const RoadSpeedService(),
        _vehiclePreferenceService =
            vehiclePreferenceService ?? const VehiclePreferenceService(),
        _driveLogService = driveLogService;

  final LocationService _locationService;
  final FineCalculator _fineCalculator;
  final RoadSpeedService _roadSpeedService;
  final VehiclePreferenceService _vehiclePreferenceService;
  final DriveLogService? _driveLogService;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastRoadLookup;
  int _roadSpeedLimit = 50;
  bool _vehicleTypeLoaded = false;

  double currentSpeed = 0;
  int speedLimit = 50;
  FineResult fineResult =
      const FineResult(amount: 0, overagePercent: 0, isWarning: true);
  bool isLoading = true;
  bool hasPermission = false;
  bool soundEffectsEnabled = true;
  String speedLimitSource = 'Søger vejens fartgrænse...';
  String? statusMessage;
  bool _wasOverSpeeding = false;
  VehicleType vehicleType = VehicleType.car;
  bool isTripActive = false;
  double tripDistanceKm = 0;
  double tripMaxSpeed = 0;
  int tripFinesAvoided = 0;
  DateTime? _tripStartedAt;
  Position? _lastTripPosition;
  int _lastFineAmount = 0;

  bool get isOverSpeeding => currentSpeed > speedLimit;
  VehicleProfile get vehicleProfile => vehicleProfiles[vehicleType]!;

  void setSoundEffectsEnabled(bool enabled) {
    if (soundEffectsEnabled == enabled) return;
    soundEffectsEnabled = enabled;
    notifyListeners();
  }

  Future<void> setVehicleType(VehicleType type) async {
    if (vehicleType == type) return;
    vehicleType = type;
    _applyVehicleSpeedLimit();
    _refreshFineAndWarnings();
    notifyListeners();
    await _vehiclePreferenceService.saveVehicleType(type);
  }

  Future<void> start() async {
    isLoading = true;
    statusMessage = null;
    notifyListeners();

    if (!_vehicleTypeLoaded) {
      vehicleType = await _vehiclePreferenceService.loadVehicleType();
      _vehicleTypeLoaded = true;
      _applyVehicleSpeedLimit();
      _refreshFineAndWarnings();
      notifyListeners();
    }

    hasPermission = await _locationService.ensurePermission();
    if (!hasPermission) {
      isLoading = false;
      statusMessage = 'Lokationstilladelse eller GPS er ikke tilgængelig.';
      notifyListeners();
      return;
    }

    await _positionSubscription?.cancel();
    _positionSubscription =
        _locationService.positionStream.listen(_updatePosition);
    isLoading = false;
    notifyListeners();
  }

  void startTrip() {
    tripDistanceKm = 0;
    tripMaxSpeed = currentSpeed;
    tripFinesAvoided = 0;
    _tripStartedAt = DateTime.now();
    _lastTripPosition = null;
    _lastFineAmount = fineResult.amount;
    isTripActive = true;
    notifyListeners();
  }

  Future<void> endTrip() async {
    if (!isTripActive) return;
    final startedAt = _tripStartedAt;
    isTripActive = false;
    _tripStartedAt = null;
    _lastTripPosition = null;
    notifyListeners();
    if (startedAt == null) return;
    try {
      await _driveLogService?.save(DriveStats(
        maxSpeed: tripMaxSpeed,
        distanceKm: tripDistanceKm,
        finesAvoided: tripFinesAvoided,
        duration: DateTime.now().difference(startedAt),
      ));
      statusMessage = 'Turen er gemt.';
    } catch (_) {
      statusMessage = 'Turen kunne ikke gemmes.';
    }
    notifyListeners();
  }

  void _updatePosition(Position position) {
    currentSpeed = (position.speed * 3.6).clamp(0, 400).toDouble();
    _refreshFineAndWarnings();
    if (isTripActive) {
      if (_lastTripPosition != null) {
        tripDistanceKm += Geolocator.distanceBetween(
              _lastTripPosition!.latitude,
              _lastTripPosition!.longitude,
              position.latitude,
              position.longitude,
            ) /
            1000;
      }
      tripMaxSpeed = tripMaxSpeed > currentSpeed ? tripMaxSpeed : currentSpeed;
      if (!isOverSpeeding && _lastFineAmount > 0) {
        tripFinesAvoided += _lastFineAmount;
      }
      _lastTripPosition = position;
      _lastFineAmount = fineResult.amount;
    }
    notifyListeners();
    _lookupRoadSpeed(position);
  }

  Future<void> _lookupRoadSpeed(Position position) async {
    if (_lastRoadLookup != null &&
        DateTime.now().difference(_lastRoadLookup!) <
            const Duration(seconds: 5)) {
      return;
    }
    _lastRoadLookup = DateTime.now();
    speedLimitSource = 'Opdaterer vejens fartgrænse...';
    notifyListeners();
    try {
      final roadLimit = await _roadSpeedService.lookupSpeedLimit(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (roadLimit != null) {
        _roadSpeedLimit = roadLimit;
        _applyVehicleSpeedLimit();
        speedLimitSource = 'Automatisk fra OpenStreetMap';
      } else {
        _roadSpeedLimit = 50;
        _applyVehicleSpeedLimit();
        speedLimitSource = 'Ingen vejgrænse fundet - viser 50 km/t';
      }
      _refreshFineAndWarnings();
      notifyListeners();
    } catch (_) {
      speedLimitSource = 'Vejgrænse kunne ikke hentes - viser 50 km/t';
      notifyListeners();
    }
  }

  void _refreshFineAndWarnings() {
    final overSpeeding = isOverSpeeding;
    if (overSpeeding && !_wasOverSpeeding && soundEffectsEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    _wasOverSpeeding = overSpeeding;
    fineResult = _fineCalculator.calculate(
      currentSpeed: currentSpeed,
      speedLimit: speedLimit,
      fineMultiplier: vehicleProfile.fineMultiplier,
    );
  }

  void _applyVehicleSpeedLimit() {
    speedLimit = vehicleProfile.applySpeedLimit(_roadSpeedLimit);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
