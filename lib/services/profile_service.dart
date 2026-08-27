import 'auth_service.dart';

class ProfileService {
  const ProfileService(this._authService);

  final AuthService _authService;

  Future<String> loadDisplayName() async {
    final user = _authService.currentUser;
    final client = _authService.client;
    if (user == null || client == null) return '';
    final row = await client
        .from('profiles')
        .select('display_name')
        .eq('id', user.id)
        .maybeSingle();
    return row?['display_name'] as String? ?? '';
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _authService.currentUser;
    final client = _authService.client;
    if (user == null || client == null) return;
    await client.from('profiles').upsert({
      'id': user.id,
      'display_name': displayName.trim(),
    });
  }

  Future<Map<String, dynamic>> loadLifetimeStats() async {
    final user = _authService.currentUser;
    final client = _authService.client;
    if (user == null || client == null) {
      return {
        'trip_count': 0,
        'total_distance_km': 0,
        'total_fines_avoided': 0
      };
    }
    final row = await client
        .from('leaderboard')
        .select('trip_count, total_distance_km, total_fines_avoided')
        .eq('id', user.id)
        .maybeSingle();
    return row ??
        {'trip_count': 0, 'total_distance_km': 0, 'total_fines_avoided': 0};
  }
}
