enum VehicleType { car, trailer, truck }

class VehicleProfile {
  const VehicleProfile({
    required this.type,
    required this.label,
    this.speedLimitCap,
    this.fineMultiplier = 1,
  });

  final VehicleType type;
  final String label;
  final int? speedLimitCap;
  final double fineMultiplier;

  int applySpeedLimit(int roadSpeedLimit) {
    if (speedLimitCap == null) return roadSpeedLimit;
    return roadSpeedLimit > speedLimitCap! ? speedLimitCap! : roadSpeedLimit;
  }
}

const Map<VehicleType, VehicleProfile> vehicleProfiles = {
  VehicleType.car: VehicleProfile(
    type: VehicleType.car,
    label: 'Bil',
  ),
  VehicleType.trailer: VehicleProfile(
    type: VehicleType.trailer,
    label: 'Bil m. trailer',
    speedLimitCap: 80,
    fineMultiplier: 1.25,
  ),
  VehicleType.truck: VehicleProfile(
    type: VehicleType.truck,
    label: 'Lastbil',
    speedLimitCap: 80,
    fineMultiplier: 1.5,
  ),
};
