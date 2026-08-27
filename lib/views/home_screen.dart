import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle_profile.dart';
import '../services/auth_service.dart';
import '../viewmodels/speedometer_vm.dart';
import 'auth_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedometerViewModel>(
      builder: (context, vm, _) {
        final alertColor = _alertColor(vm.fineResult.amount);
        const overLimitColor = Color(0xffbd342f);
        final speedCardColor = vm.isOverSpeeding ? overLimitColor : alertColor;

        return Scaffold(
          appBar: AppBar(
            title: const Text('FARTVAGT',
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            actions: [
              if (authService != null)
                ListenableBuilder(
                  listenable: authService!,
                  builder: (context, _) {
                    final auth = authService!;
                    return auth.currentUser == null
                        ? IconButton(
                            tooltip: 'Log ind',
                            onPressed: () => showAuthDialog(context),
                            icon: const Icon(Icons.account_circle_outlined),
                          )
                        : IconButton(
                            tooltip: 'Log ud',
                            onPressed: auth.signOut,
                            icon: const Icon(Icons.logout),
                          );
                  },
                ),
              IconButton(
                tooltip: 'Opdater GPS-tilladelse',
                onPressed: vm.start,
                icon: const Icon(Icons.gps_fixed),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('LIVE MÅLING',
                      style: TextStyle(
                          color: alertColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3)),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                        color: speedCardColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      scale: vm.isOverSpeeding ? 1.03 : 1,
                      child: Column(
                        children: [
                          Text(vm.currentSpeed.round().toString(),
                              style: const TextStyle(
                                  fontSize: 92,
                                  height: 1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          const Text('KM/T',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Text('FORVENTET BØDE',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('${_formatAmount(vm.fineResult.amount)} DKK',
                            style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: alertColor)),
                        if (vm.fineResult.hasPenaltyPoint ||
                            vm.fineResult.hasSuspension) ...[
                          const SizedBox(height: 8),
                          Text(
                              vm.fineResult.hasSuspension
                                  ? 'BETINGET FRAKENDELSE'
                                  : '1 KLIPPEKORT',
                              style: TextStyle(
                                  color: alertColor,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('KØRETØJSPROFIL',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<VehicleType>(
                        value: vm.vehicleType,
                        isExpanded: true,
                        onChanged: (value) {
                          if (value != null) {
                            vm.setVehicleType(value);
                          }
                        },
                        items: vehicleProfiles.values
                            .map((profile) => DropdownMenuItem<VehicleType>(
                                  value: profile.type,
                                  child: Text(profile.label),
                                ))
                            .toList(growable: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('AUTOMATISK FARTGRÆNSE',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text('${vm.speedLimit} km/t',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: alertColor)),
                  Text(vm.speedLimitSource,
                      style: const TextStyle(color: Color(0xff68706b))),
                  const SizedBox(height: 22),
                  if (vm.isLoading) const LinearProgressIndicator(),
                  if (vm.statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(vm.statusMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xffbd342f))),
                  ],
                  const SizedBox(height: 12),
                  Text(
                      vm.hasPermission
                          ? 'GPS FORBINDELSE AKTIV'
                          : 'GPS AFVENTER TILLADELSE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: alertColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .7)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('LYDADVARSEL VED FARTOVERSKRIDELSE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .5)),
                        ),
                        Switch(
                          value: vm.soundEffectsEnabled,
                          onChanged: vm.setSoundEffectsEnabled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Color _alertColor(int amount) {
    const calm = Color(0xff0d6b5d);
    const warning = Color(0xffd27a16);
    const danger = Color(0xffbd342f);
    if (amount <= 0) return calm;
    if (amount <= 1800) return Color.lerp(calm, warning, amount / 1800)!;
    return Color.lerp(warning, danger, ((amount - 1800) / 2900).clamp(0, 1))!;
  }

  static String _formatAmount(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+$)'), (_) => '.');
}
