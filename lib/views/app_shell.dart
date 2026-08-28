import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  Future<void> _openPortfolio() async {
    await launchUrl(
      Uri.parse('https://cbjoed.com/'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(authService: widget.authService),
      LeaderboardScreen(authService: widget.authService),
      ProfileScreen(authService: widget.authService),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 3) {
            _openPortfolio();
            return;
          }
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.speed), label: 'Måling'),
          NavigationDestination(
              icon: Icon(Icons.emoji_events), label: 'Rangliste'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Portfolio'),
        ],
      ),
    );
  }
}
