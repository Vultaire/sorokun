import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/paper_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Combined Subjects keeps the six regular practice choices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const PaperMenuPage(),
      ),
    );
    await tester.pumpAndSettle();

    var buttons = tester
        .widgetList<PaperStartButton>(find.byType(PaperStartButton))
        .toList();
    expect(
      buttons.map((button) => button.startButtonType).toSet(),
      StartButtonType.values.toSet(),
    );
    expect(buttons.every((button) => !button.isExam), isTrue);
    expect(find.text('練習'), findsOneWidget);
    expect(find.text('検定'), findsOneWidget);
    expect(find.text('ハンズフリー暗算'), findsNothing);
    expect(
      find.byKey(const ValueKey('hands-free-anzan-menu-entry')),
      findsNothing,
    );

    await tester.tap(find.text('検定'));
    await tester.pumpAndSettle();

    buttons = tester
        .widgetList<PaperStartButton>(find.byType(PaperStartButton))
        .toList();
    expect(buttons, hasLength(StartButtonType.values.length));
    expect(buttons.every((button) => button.isExam), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
