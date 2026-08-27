import 'auth_service.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.totalFinesAvoided,
    required this.totalDistanceKm,
    required this.tripCount,
    required this.safeTripCount,
  });

  final String displayName;
  final int totalFinesAvoided;
  final double totalDistanceKm;
  final int tripCount;
  final int safeTripCount;
}

class LeaderboardService {
  const LeaderboardService(this._authService);

  final AuthService _authService;

  Future<List<LeaderboardEntry>> load({required bool safest}) async {
    final client = _authService.client;
    if (client == null) return const [];

    final rows = await client
        .from('leaderboard')
        .select(
            'display_name, total_fines_avoided, total_distance_km, trip_count, safe_trip_count')
        .order(safest ? 'safe_trip_count' : 'total_fines_avoided',
            ascending: false)
        .order('total_fines_avoided', ascending: !safest)
        .limit(25);
    return rows
        .map((row) => LeaderboardEntry(
              displayName: row['display_name'] as String? ?? 'Anonym bruger',
              totalFinesAvoided:
                  (row['total_fines_avoided'] as num?)?.toInt() ?? 0,
              totalDistanceKm:
                  (row['total_distance_km'] as num?)?.toDouble() ?? 0,
              tripCount: (row['trip_count'] as num?)?.toInt() ?? 0,
              safeTripCount: (row['safe_trip_count'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }
}
