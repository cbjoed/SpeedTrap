import '../models/drive_stats.dart';
import 'auth_service.dart';

class DriveLogService {
  const DriveLogService(this._authService);

  final AuthService _authService;

  Future<void> save(DriveStats stats) async {
    final user = _authService.currentUser;
    final client = _authService.client;
    if (user == null || client == null) return;

    await client.from('drive_logs').insert({
      'user_id': user.id,
      'max_speed': stats.maxSpeed,
      'distance_km': stats.distanceKm,
      'fines_avoided': stats.finesAvoided,
      'duration_seconds': stats.duration.inSeconds,
    });
  }
}