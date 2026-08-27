class DriveStats {
  const DriveStats({
    required this.maxSpeed,
    required this.distanceKm,
    required this.finesAvoided,
    required this.duration,
  });

  final double maxSpeed;
  final double distanceKm;
  final int finesAvoided;
  final Duration duration;
}