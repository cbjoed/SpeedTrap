import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/fine_calculator.dart';
import 'services/location_service.dart';
import 'services/auth_service.dart';
import 'services/drive_log_service.dart';
import 'viewmodels/speedometer_vm.dart';
import 'views/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthService.create();
  runApp(SpeedFineTrackerApp(authService: authService));
}

class SpeedFineTrackerApp extends StatelessWidget {
  const SpeedFineTrackerApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(
          create: (_) => SpeedometerViewModel(
            locationService: LocationService(),
            fineCalculator: const FineCalculator(),
            driveLogService: DriveLogService(authService),
          )..start(),
        ),
      ],
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
        home: AppShell(authService: authService),
      ),
    );
  }
}
