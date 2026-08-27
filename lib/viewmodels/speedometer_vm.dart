import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/fine_result.dart';
import '../services/fine_calculator.dart';
import '../services/location_service.dart';
import '../services/road_speed_service.dart';

class SpeedometerViewModel extends ChangeNotifier {
  SpeedometerViewModel({
    LocationService? locationService,
    FineCalculator? fineCalculator,
    RoadSpeedService? roadSpeedService,
  })  : _locationService = locationService ?? LocationService(),
        _fineCalculator = fineCalculator ?? const FineCalculator(),
        _roadSpeedService = roadSpeedService ?? const RoadSpeedService();

  final LocationService _locationService;
  final FineCalculator _fineCalculator;
  final RoadSpeedService _roadSpeedService;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastRoadLookup;

  double currentSpeed = 0;
  int speedLimit = 50;
  FineResult fineResult =
      const FineResult(amount: 0, overagePercent: 0, isWarning: true);
  bool isLoading = true;
  bool hasPermission = false;
  String speedLimitSource = 'Søger vejens fartgrænse...';
  String? statusMessage;

  Future<void> start() async {
    isLoading = true;
    statusMessage = null;
    notifyListeners();

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

  void _updatePosition(Position position) {
    currentSpeed = (position.speed * 3.6).clamp(0, 400).toDouble();
    fineResult = _fineCalculator.calculate(
      currentSpeed: currentSpeed,
      speedLimit: speedLimit,
    );
    notifyListeners();
    _lookupRoadSpeed(position);
  }

  Future<void> _lookupRoadSpeed(Position position) async {
    if (_lastRoadLookup != null &&
        DateTime.now().difference(_lastRoadLookup!) <
            const Duration(seconds: 20)) {
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
        speedLimit = roadLimit;
        speedLimitSource = 'Automatisk fra OpenStreetMap';
      } else {
        speedLimitSource = 'Ingen vejgrænse fundet - viser 50 km/t';
      }
      fineResult = _fineCalculator.calculate(
          currentSpeed: currentSpeed, speedLimit: speedLimit);
      notifyListeners();
    } catch (_) {
      speedLimitSource = 'Vejgrænse kunne ikke hentes - viser 50 km/t';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
