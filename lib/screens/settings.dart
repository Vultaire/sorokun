// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';

class SettingsGearButton extends StatelessWidget {
  const SettingsGearButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, size: 40),
      tooltip: AppLocalizations.of(context).settingsTitle,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ColorSchemeSettingsPage(),
          ),
        );
      },
    );
  }
}

class ColorSchemeSettingsPage extends StatelessWidget {
  const ColorSchemeSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = InheritedAppController.of(context);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isPortrait =
              MediaQuery.orientationOf(context) == Orientation.portrait;

          final languageGroup = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.languageLabel, style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: LabeledSlidingSegmentedControl<AppLanguage>(
                  groupValue: controller.language,
                  options: [
                    (AppLanguage.japanese, l10n.japaneseLanguage),
                    (AppLanguage.english, l10n.englishLanguage),
                  ],
                  onValueChanged: controller.setLanguage,
                ),
              ),
            ],
          );

          final keypadGroup = Column(
            children: [
              Text(l10n.keypadPosition, style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 360),
                  child: LabeledSlidingSegmentedControl<Handedness>(
                    groupValue: controller.handedness,
                    options: [
                      (Handedness.left, l10n.leftHanded),
                      (Handedness.right, l10n.rightHanded),
                    ],
                    onValueChanged: controller.setHandedness,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.keypadLayout, style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: KeypadOrderSelector(
                  groupValue: controller.numberOrder,
                  onChanged: controller.setNumberOrder,
                ),
              ),
            ],
          );

          final appearanceGroup = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.screenBrightness, style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: LabeledSlidingSegmentedControl<ThemeMode>(
                  groupValue: controller.themeMode,
                  options: [
                    (ThemeMode.light, Icon(Icons.light_mode)),
                    (ThemeMode.dark, Icon(Icons.dark_mode)),
                    (ThemeMode.system, l10n.automatic),
                  ],
                  onValueChanged: controller.setThemeMode,
                ),
              ),
              SizedBox(height: 24),
              Semantics(
                label: l10n.themeColorWheelSemantics,
                child: ColorWheel(
                  schemes: AppController.presetSchemes,
                  selected: controller.flexScheme,
                  onSelected: controller.setFlexScheme,
                ),
              ),
            ],
          );

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useVerticalLayout =
                    isPortrait || constraints.maxWidth < 760;
                final settingsGroups = Flex(
                  direction: useVerticalLayout
                      ? Axis.vertical
                      : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    appearanceGroup,
                    SizedBox(
                      width: useVerticalLayout ? 0 : 40,
                      height: useVerticalLayout ? 24 : 0,
                    ),
                    keypadGroup,
                  ],
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          languageGroup,
                          const SizedBox(height: 24),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: settingsGroups,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ColorWheel extends StatelessWidget {
  const ColorWheel({
    super.key,
    required this.schemes,
    required this.selected,
    required this.onSelected,
    this.diameter = 240,
    this.swatchSize = 48,
  });

  final List<FlexScheme> schemes;
  final FlexScheme selected;
  final Function(FlexScheme) onSelected;
  final double diameter;
  final double swatchSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = diameter / 2;
    return SizedBox(
      width: diameter + swatchSize,
      height: diameter + swatchSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: .center,
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  l10n.theme,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  l10n.color,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          for (var i = 0; i < schemes.length; i++)
            Builder(
              builder: (context) {
                final angle = (2 * pi * i / schemes.length) - (pi / 2);
                final dx = radius * cos(angle);
                final dy = radius * sin(angle);
                final scheme = schemes[i];
                final isSelected = selected == scheme;
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: GestureDetector(
                    onTap: () => onSelected(scheme),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isSelected ? swatchSize + 8 : swatchSize,
                      height: isSelected ? swatchSize + 8 : swatchSize,
                      decoration: BoxDecoration(
                        color: scheme.colors(.light).primary,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _contrastColor(
                                scheme.colors(.light).primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _contrastColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

class MiniKeypadPainter extends CustomPainter {
  MiniKeypadPainter({
    required this.rows,
    required this.fillColor,
    required this.textColor,
  });

  final List<List<String>> rows;
  final Color fillColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 4.0;
    final cellWidth = (size.width - spacing * 2) / 3;
    final cellHeight = (size.height - spacing * 2) / 3;

    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final left = c * (cellWidth + spacing);
        final top = r * (cellHeight + spacing);
        final rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

        canvas.drawRRect(rrect, Paint()..color = fillColor);

        final textPainter = TextPainter(
          text: TextSpan(
            text: rows[r][c],
            style: TextStyle(
              color: textColor,
              fontSize: cellHeight * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(MiniKeypadPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.textColor != textColor;
  }
}

class KeypadOrderSelector extends StatelessWidget {
  const KeypadOrderSelector({
    super.key,
    required this.groupValue,
    required this.onChanged,
  });

  final KeypadNumberOrder groupValue;
  final ValueChanged<KeypadNumberOrder> onChanged;

  static const Map<KeypadNumberOrder, List<List<String>>> _rowsByOrder = {
    KeypadNumberOrder.standard: [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
    ],
    KeypadNumberOrder.telephone: [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final entry in _rowsByOrder.entries) ...[
          _KeypadOption(
            rows: entry.value,
            isSelected: groupValue == entry.key,
            label: entry.key == KeypadNumberOrder.standard
                ? AppLocalizations.of(context).standardKeypadLayout
                : AppLocalizations.of(context).telephoneKeypadLayout,
            onTap: () => onChanged(entry.key),
          ),
          if (entry.key != _rowsByOrder.keys.last) const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _KeypadOption extends StatelessWidget {
  const _KeypadOption({
    required this.rows,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });
  final List<List<String>> rows;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryFixedDim
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: SizedBox(
            width: 130,
            height: 130,
            child: CustomPaint(
              painter: MiniKeypadPainter(
                rows: rows,
                fillColor: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : colorScheme.surfaceContainer,
                textColor: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppLanguage { japanese, english }

Locale resolveAppLocale(Locale? locale) =>
    locale?.languageCode.toLowerCase() == 'ja'
    ? const Locale('ja')
    : const Locale('en');

AppLanguage resolveInitialLanguage(
  List<Locale> preferredLocales, {
  String? savedLanguage,
}) {
  for (final language in AppLanguage.values) {
    if (language.name == savedLanguage) return language;
  }

  final firstLocale = preferredLocales.isEmpty ? null : preferredLocales.first;
  return firstLocale?.languageCode.toLowerCase() == 'ja'
      ? AppLanguage.japanese
      : AppLanguage.english;
}

enum KeypadNumberOrder { standard, telephone }

enum Handedness { right, left }

class AppController extends ChangeNotifier {
  static const List<FlexScheme> presetSchemes = [
    FlexScheme.shadGreen,
    FlexScheme.shadBlue,
    FlexScheme.shadViolet,
    FlexScheme.shadRose,
    FlexScheme.shadNeutral,
    FlexScheme.shadGray,
    FlexScheme.shadRed,
    FlexScheme.shadOrange,
    FlexScheme.shadYellow,
  ];

  static const _schemeKey = 'theme_flex_scheme';
  static const _themeModeKey = 'theme_mode';
  static const _languageKey = 'ui_language';
  static const _numberOrderKey = 'keypad_number_order';
  static const _handednessKey = 'handedness';
  static const _welcomeSuppressedKey = 'welcome_screen_suppressed';

  FlexScheme _flexScheme = FlexScheme.shadBlue;
  FlexScheme get flexScheme => _flexScheme;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;
  Locale get locale => Locale(language == AppLanguage.japanese ? 'ja' : 'en');

  KeypadNumberOrder _numberOrder = KeypadNumberOrder.standard;
  KeypadNumberOrder get numberOrder => _numberOrder;

  Handedness _handedness = Handedness.right;
  Handedness get handedness => _handedness;

  bool _welcomeSuppressed = false;
  bool _welcomeDismissedThisLaunch = false;
  bool get shouldShowWelcomeScreen =>
      !_welcomeSuppressed && !_welcomeDismissedThisLaunch;

  late final Future<void> ready;

  AppController({List<Locale>? preferredLocales}) {
    _preferredLocales = preferredLocales;
    ready = _load();
  }

  List<Locale>? _preferredLocales;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final storedScheme = prefs.getString(_schemeKey);
    if (storedScheme != null) {
      _flexScheme = FlexScheme.values.firstWhere(
        (e) => e.name == storedScheme,
        orElse: () => FlexScheme.mandyRed,
      );
    }

    final storedThemeMode = prefs.getString(_themeModeKey);
    if (storedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == storedThemeMode,
        orElse: () => ThemeMode.dark,
      );
    }

    final storedLanguage = prefs.getString(_languageKey);
    _language = resolveInitialLanguage(
      _preferredLocales ?? WidgetsBinding.instance.platformDispatcher.locales,
      savedLanguage: storedLanguage,
    );
    _preferredLocales = null;

    _welcomeSuppressed = prefs.getBool(_welcomeSuppressedKey) ?? false;

    final storedOrder = prefs.getString(_numberOrderKey);
    if (storedOrder != null) {
      _numberOrder = KeypadNumberOrder.values.firstWhere(
        (e) => e.name == storedOrder,
        orElse: () => KeypadNumberOrder.standard,
      );
    }

    final storedHandedness = prefs.getString(_handednessKey);
    if (storedHandedness != null) {
      _handedness = Handedness.values.firstWhere(
        (e) => e.name == storedHandedness,
        orElse: () => Handedness.right,
      );
    }

    notifyListeners();
  }

  void setFlexScheme(FlexScheme scheme) {
    if (_flexScheme == scheme) return;
    _flexScheme = scheme;
    notifyListeners();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_schemeKey, scheme.name),
    );
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_themeModeKey, mode.name),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language != language) {
      _language = language;
      notifyListeners();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);
  }

  Future<void> completeWelcome({required bool doNotShowAgain}) async {
    _welcomeDismissedThisLaunch = true;
    if (!doNotShowAgain) return;

    _welcomeSuppressed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeSuppressedKey, true);
  }

  Future<void> setNumberOrder(KeypadNumberOrder order) async {
    if (_numberOrder == order) return;
    _numberOrder = order;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_numberOrderKey, order.name);
  }

  Future<void> setHandedness(Handedness handedness) async {
    if (_handedness == handedness) return;
    _handedness = handedness;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_handednessKey, handedness.name);
  }

  ColorScheme get colorScheme {
    final brightness = _themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;

    final flexTheme = brightness == Brightness.dark
        ? FlexColorScheme.dark(scheme: _flexScheme)
        : FlexColorScheme.light(scheme: _flexScheme);

    return flexTheme.toScheme;
  }

  /// Returns the 9 digit rows (3x3) in the currently selected number order.
  List<List<String>> get numberRows {
    switch (_numberOrder) {
      case KeypadNumberOrder.standard:
        return [
          ['7', '8', '9'],
          ['4', '5', '6'],
          ['1', '2', '3'],
        ];
      case KeypadNumberOrder.telephone:
        return [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ];
    }
  }
}

class InheritedAppController extends InheritedNotifier<AppController> {
  const InheritedAppController({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedAppController>();
    assert(result != null, 'No InheritedAppController found in context');
    return result!.notifier!;
  }
}
