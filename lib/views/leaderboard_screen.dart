import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _safest = false;
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LeaderboardService(widget.authService).load(safest: _safest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RANGLISTE')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Flest bøder undgået')),
                ButtonSegment(value: true, label: Text('Sikreste førere')),
              ],
              selected: {_safest},
              onSelectionChanged: (value) => setState(() {
                _safest = value.first;
                _reload();
              }),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Ranglisten kunne ikke hentes.'));
                }
                final entries = snapshot.data ?? const [];
                if (entries.isEmpty) {
                  return const Center(child: Text('Ingen ture er registreret endnu.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(_reload),
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(entry.displayName),
                        subtitle: Text('${entry.tripCount} ture · ${entry.safeTripCount} sikre ture · ${entry.totalDistanceKm.toStringAsFixed(1)} km'),
                        trailing: Text(_safest
                            ? '${entry.totalDistanceKm.toStringAsFixed(1)} km'
                            : '${entry.totalFinesAvoided} DKK'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}