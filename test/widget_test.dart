// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/screens/home_page.dart';
import 'package:soroban_app/screens/settings.dart';

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

  testWidgets(
    'settings expose and persist the Japanese-first language choice',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppController();
      await controller.ready;

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedAppController(
            controller: controller,
            child: const ColorSchemeSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('言語 / Language'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      const translationPendingMessage =
          '英語翻訳はまだ利用できません。 / '
          'English translation is not available yet.';
      expect(find.text(translationPendingMessage), findsNothing);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(controller.language, AppLanguage.english);
      expect(find.text(translationPendingMessage), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ui_language'), 'english');

      final restoredController = AppController();
      await restoredController.ready;
      expect(restoredController.language, AppLanguage.english);

      controller.dispose();
      restoredController.dispose();
    },
  );
}
