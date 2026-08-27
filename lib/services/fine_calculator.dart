import '../models/fine_result.dart';

class FineCalculator {
  const FineCalculator();

  FineResult calculate(
      {required double currentSpeed, required int speedLimit}) {
    if (currentSpeed <= speedLimit) {
      return const FineResult(amount: 0, overagePercent: 0, isWarning: true);
    }

    final overagePercent = ((currentSpeed - speedLimit) / speedLimit) * 100;
    if (overagePercent < 20) {
      return FineResult(amount: 1200, overagePercent: overagePercent);
    }
    if (overagePercent < 30) {
      return FineResult(amount: 1800, overagePercent: overagePercent);
    }
    if (overagePercent < 40) {
      return FineResult(
        amount: 2900,
        overagePercent: overagePercent,
        hasPenaltyPoint: true,
      );
    }
    if (overagePercent < 50) {
      return FineResult(
        amount: 4100,
        overagePercent: overagePercent,
        hasPenaltyPoint: true,
      );
    }
    return FineResult(
      amount: 4700,
      overagePercent: overagePercent,
      hasSuspension: true,
    );
  }
}
