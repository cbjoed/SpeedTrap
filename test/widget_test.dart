// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:speed_fine_tracker/models/fine_result.dart';
import 'package:speed_fine_tracker/services/fine_calculator.dart';

void main() {
  test('calculates a fine and penalty point above 30 percent', () {
    const calculator = FineCalculator();

    final result = calculator.calculate(currentSpeed: 65, speedLimit: 50);

    expect(result.amount, 2900);
    expect(result.hasPenaltyPoint, isTrue);
    expect(result, isA<FineResult>());
  });
}
