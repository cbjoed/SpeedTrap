import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle_profile.dart';

class VehiclePreferenceService {
  const VehiclePreferenceService();

  static const _vehicleTypeKey = 'vehicle_type';

  Future<VehicleType> loadVehicleType() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_vehicleTypeKey);
    return VehicleType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => VehicleType.car,
    );
  }

  Future<void> saveVehicleType(VehicleType type) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_vehicleTypeKey, type.name);
  }
}
