// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:speed_fine_tracker/models/fine_result.dart';
import 'package:speed_fine_tracker/services/fine_calculator.dart';
import 'package:speed_fine_tracker/viewmodels/speedometer_vm.dart';
import 'package:speed_fine_tracker/views/home_screen.dart';

void main() {
  test('calculates a fine and penalty point above 30 percent', () {
    const calculator = FineCalculator();

    final result = calculator.calculate(currentSpeed: 65, speedLimit: 50);

    expect(result.amount, 2900);
    expect(result.hasPenaltyPoint, isTrue);
    expect(result, isA<FineResult>());
  });

  testWidgets('shows red live-speed indicator when above speed limit',
      (tester) async {
    const calculator = FineCalculator();
    final vm = SpeedometerViewModel(fineCalculator: calculator)
      ..speedLimit = 50
      ..currentSpeed = 70
      ..fineResult = calculator.calculate(currentSpeed: 70, speedLimit: 50);

    await tester.pumpWidget(
      ChangeNotifierProvider<SpeedometerViewModel>.value(
        value: vm,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    final speedCard = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = speedCard.decoration! as BoxDecoration;

    expect(decoration.color, const Color(0xffbd342f));
  });

  testWidgets('toggles speeding sound setting', (tester) async {
    final vm = SpeedometerViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider<SpeedometerViewModel>.value(
        value: vm,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(vm.soundEffectsEnabled, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(vm.soundEffectsEnabled, isFalse);
  });
}
