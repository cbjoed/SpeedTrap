import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  late Future<Map<String, dynamic>> _statsFuture;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _statsFuture = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    try {
      if (widget.authService.currentUser == null) return {};
      final service = ProfileService(widget.authService);
      _nameController.text = await service.loadDisplayName();
      return await service.loadLifetimeStats();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveName() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await ProfileService(widget.authService)
          .updateDisplayName(_nameController.text);
      setState(() => _message = 'Profilnavnet er gemt.');
    } catch (_) {
      setState(() => _message = 'Profilnavnet kunne ikke gemmes.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Log ind for at se din profil.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('MIN PROFIL')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          final stats = snapshot.data ?? const <String, dynamic>{};
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(user.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              TextField(
                  controller: _nameController,
                  maxLength: 40,
                  decoration: const InputDecoration(labelText: 'Visningsnavn')),
              FilledButton.icon(
                  onPressed: _loading ? null : _saveName,
                  icon: const Icon(Icons.save),
                  label: const Text('Gem navn')),
              if (_message != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_message!)),
              const SizedBox(height: 28),
              const Text('LIVSTIDSSTATISTIK',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _StatTile(label: 'Ture', value: '${stats['trip_count'] ?? 0}'),
              _StatTile(
                  label: 'Distance',
                  value:
                      '${((stats['total_distance_km'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)} km'),
              _StatTile(
                  label: 'Estimerede bøder undgået',
                  value: '${stats['total_fines_avoided'] ?? 0} DKK'),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(label),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)));
}
