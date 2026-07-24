import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final controller = InheritedThemeController.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('テーマカラー設定')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CupertinoSlidingSegmentedControl<ThemeMode>(
                  groupValue: controller.themeMode,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  thumbColor: Theme.of(context).colorScheme.primaryContainer,
                  children: const {
                    ThemeMode.light: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Icon(Icons.light_mode),
                    ),
                    ThemeMode.dark: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Icon(Icons.dark_mode),
                    ),
                    ThemeMode.system: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Icon(Icons.brightness_auto),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value != null) controller.setThemeMode(value);
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: ThemeController.presetSeeds.length,
                  itemBuilder: (context, index) {
                    final entry = ThemeController.presetSeeds[index];
                    final isSelected = controller.seedColor == entry;
                    return GestureDetector(
                      onTap: () => controller.setSeedColor(entry),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: entry,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: _contrastColor(entry),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _contrastColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

class ThemeController extends ChangeNotifier {
  static const List<Color> presetSeeds = [
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.pink,
    Colors.teal,
  ];

  Color _seedColor = Colors.blue;
  Color get seedColor => _seedColor;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  static const _seedColorIndex = 'theme_seed_color';

  late final Future<void> ready;

  ThemeController() {
    ready = _loadSeedColor();
  }

  Future<void> _loadSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getInt(_seedColorIndex);
    if (storedValue != null) {
      _seedColor = Color(storedValue);
      notifyListeners();
    }
  }

  void setSeedColor(Color color) {
    if (_seedColor == color) return;
    _seedColor = color;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: _themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
  );
}

class InheritedThemeController extends InheritedNotifier<ThemeController> {
  const InheritedThemeController({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedThemeController>();
    assert(result != null, 'No InheritedThemeController found in context');
    return result!.notifier!;
  }
}
