import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/fine_result.dart';
import '../services/fine_calculator.dart';
import '../services/location_service.dart';

class SpeedometerViewModel extends ChangeNotifier {
  SpeedometerViewModel({
    LocationService? locationService,
    FineCalculator? fineCalculator,
  })  : _locationService = locationService ?? LocationService(),
        _fineCalculator = fineCalculator ?? const FineCalculator();

  final LocationService _locationService;
  final FineCalculator _fineCalculator;
  StreamSubscription<double>? _speedSubscription;

  double currentSpeed = 0;
  int speedLimit = 50;
  FineResult fineResult = const FineResult(amount: 0, overagePercent: 0, isWarning: true);
  bool isLoading = true;
  bool hasPermission = false;
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

    await _speedSubscription?.cancel();
    _speedSubscription = _locationService.speedStream.listen(_updateSpeed);
    isLoading = false;
    notifyListeners();
  }

  void setSpeedLimit(int limit) {
    speedLimit = limit;
    fineResult = _fineCalculator.calculate(
      currentSpeed: currentSpeed,
      speedLimit: speedLimit,
    );
    notifyListeners();
  }

  void _updateSpeed(double speed) {
    currentSpeed = speed;
    fineResult = _fineCalculator.calculate(
      currentSpeed: currentSpeed,
      speedLimit: speedLimit,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _speedSubscription?.cancel();
    super.dispose();
  }
}
