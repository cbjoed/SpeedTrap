import '../models/fine_result.dart';

class FineCalculator {
  const FineCalculator();

  FineResult calculate(
      {required double currentSpeed,
      required int speedLimit,
      double fineMultiplier = 1}) {
    if (currentSpeed <= speedLimit) {
      return const FineResult(amount: 0, overagePercent: 0, isWarning: true);
    }

    final overagePercent = ((currentSpeed - speedLimit) / speedLimit) * 100;
    if (overagePercent < 20) {
      return FineResult(
        amount: _applyMultiplier(1200, fineMultiplier),
        overagePercent: overagePercent,
      );
    }
    if (overagePercent < 30) {
      return FineResult(
        amount: _applyMultiplier(1800, fineMultiplier),
        overagePercent: overagePercent,
      );
    }
    if (overagePercent < 40) {
      return FineResult(
        amount: _applyMultiplier(2900, fineMultiplier),
        overagePercent: overagePercent,
        hasPenaltyPoint: true,
      );
    }
    if (overagePercent < 50) {
      return FineResult(
        amount: _applyMultiplier(4100, fineMultiplier),
        overagePercent: overagePercent,
        hasPenaltyPoint: true,
      );
    }
    return FineResult(
      amount: _applyMultiplier(4700, fineMultiplier),
      overagePercent: overagePercent,
      hasSuspension: true,
    );
  }

  int _applyMultiplier(int baseAmount, double multiplier) =>
      (baseAmount * multiplier).round();
}
