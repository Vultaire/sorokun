import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/screens/components/labeled_sliding_segment.dart';

class SettingsGearButton extends StatelessWidget {
  const SettingsGearButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, size: 40),
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('アプリ設定')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isPortrait =
              MediaQuery.orientationOf(context) == Orientation.portrait;

          final keypadGroup = Column(
            children: [
              Text('テンキーの配置', style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 360),
                  child: LabeledSlidingSegmentedControl<Handedness>(
                    groupValue: controller.handedness,
                    options: const [
                      (Handedness.left, '左利き'),
                      (Handedness.right, '右利き'),
                    ],
                    onValueChanged: controller.setHandedness,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('キーレイアウト', style: textTheme.headlineLarge),
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
              Text('画面の明るさ', style: textTheme.headlineLarge),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: LabeledSlidingSegmentedControl<ThemeMode>(
                  groupValue: controller.themeMode,
                  options: const [
                    (ThemeMode.light, Icon(Icons.light_mode)),
                    (ThemeMode.dark, Icon(Icons.dark_mode)),
                    (ThemeMode.system, '自動'),
                  ],
                  onValueChanged: controller.setThemeMode,
                ),
              ),
              SizedBox(height: 24),
              ColorWheel(
                schemes: AppController.presetSchemes,
                selected: controller.flexScheme,
                onSelected: controller.setFlexScheme,
              ),
            ],
          );

          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Flex(
                  direction: isPortrait ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    appearanceGroup,
                    SizedBox(
                      width: isPortrait ? 0 : 40,
                      height: isPortrait ? 24 : 0,
                    ),
                    keypadGroup,
                  ],
                ),
              ),
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
                Text('テーマ', style: Theme.of(context).textTheme.headlineLarge),
                Text('カラー', style: Theme.of(context).textTheme.displaySmall),
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
    required this.onTap,
  });
  final List<List<String>> rows;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
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
    );
  }
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
  static const _numberOrderKey = 'keypad_number_order';
  static const _handednessKey = 'handedness';

  FlexScheme _flexScheme = FlexScheme.shadBlue;
  FlexScheme get flexScheme => _flexScheme;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  KeypadNumberOrder _numberOrder = KeypadNumberOrder.standard;
  KeypadNumberOrder get numberOrder => _numberOrder;

  Handedness _handedness = Handedness.right;
  Handedness get handedness => _handedness;

  late final Future<void> ready;

  AppController() {
    ready = _load();
  }

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
