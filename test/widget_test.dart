// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_app/screens/home_page.dart';

void main() {
  testWidgets('home page presents the remaining practice modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('種目を選ぶ'), findsOneWidget);
    expect(find.text('検定'), findsOneWidget);
    expect(find.text('フリー'), findsOneWidget);
  });
}
