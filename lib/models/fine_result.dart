class FineResult {
  const FineResult({
    required this.amount,
    required this.overagePercent,
    this.hasPenaltyPoint = false,
    this.hasSuspension = false,
    this.isWarning = false,
  });

  final int amount;
  final double overagePercent;
  final bool hasPenaltyPoint;
  final bool hasSuspension;
  final bool isWarning;

  bool get hasPenalty => amount > 0;
}
