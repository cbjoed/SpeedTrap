import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/fine_calculator.dart';
import 'services/location_service.dart';
import 'viewmodels/speedometer_vm.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const SpeedFineTrackerApp());
}

class SpeedFineTrackerApp extends StatelessWidget {
  const SpeedFineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpeedometerViewModel(
        locationService: LocationService(),
        fineCalculator: const FineCalculator(),
      )..start(),
      child: MaterialApp(
        title: 'Fartvagt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff0d6b5d),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xfff4f3ed),
          fontFamily: 'sans',
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
