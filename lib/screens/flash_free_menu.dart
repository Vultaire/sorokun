// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:async';
import 'dart:math';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/problem_generation/flash_set.dart';
import 'package:soroban_app/screens/components/appbar.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';
import 'package:soroban_app/screens/components/incrementer.dart';
import 'package:soroban_app/screens/components/start_button.dart';

class FlashFreeMenuPage extends StatefulWidget {
  const FlashFreeMenuPage({super.key});

  @override
  State<FlashFreeMenuPage> createState() => _FlashFreeMenuPageState();
}

class _FlashFreeMenuPageState extends State<FlashFreeMenuPage> with RouteAware {
  double _secondsPerProblem = 10.0;
  int _kuchi = 15;
  int _digits = 3;
  late final SharedPreferencesWithCache _prefs;
  late final Future<void> _prefsReady;

  static const double _tallScreenThreshold = 700.0;

  @override
  void initState() {
    super.initState();
    _prefsReady = _loadPrefs();
    Incrementer.ensureIncrementSoundLoaded();
  }

  void _playIncrementSound() {
    final sound = Incrementer.incrementSound;
    if (sound != null) {
      SoLoud.instance.play(sound);
    }
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'secondsPerProblem', 'kuchi', 'digits'},
      ),
    );

    final secondsPerProblem = _prefs.getDouble('secondsPerProblem') ?? 10.0;
    final kuchi = _prefs.getInt('kuchi') ?? 15;
    final digits = _prefs.getInt('digits') ?? 3;
    if (!mounted) {
      _secondsPerProblem = secondsPerProblem;
      _kuchi = kuchi;
      _digits = digits;
      return;
    }

    setState(() {
      _secondsPerProblem = secondsPerProblem;
      _kuchi = kuchi;
      _digits = digits;
    });
  }

  void _savePrefs() {
    _prefs.setDouble('secondsPerProblem', _secondsPerProblem);
    _prefs.setInt('kuchi', _kuchi);
    _prefs.setInt('digits', _digits);
  }

  Future<void> _startPractice() async {
    await _prefsReady;
    if (!mounted) return;

    _savePrefs();
    final spec = FlashSingleProblemSpec(
      digits: _digits,
      kuchi: _kuchi,
      secondsPerProblem: _secondsPerProblem,
      builder: mitoriStyle,
    );
    await context.push(
      '/flash-problem',
      extra: {'isSingleProblem': true, 'selectedLevel': spec},
    );
  }

  void _decreaseValue() {
    double newValue;
    if (_secondsPerProblem > CircularSlider.range1End) {
      newValue = _secondsPerProblem - 1.0;
    } else {
      newValue = (_secondsPerProblem * 10 - 1) / 10;
    }
    newValue = newValue.clamp(CircularSlider.minValue, CircularSlider.maxValue);
    if (newValue == _secondsPerProblem) return; // already at min, no change
    _playIncrementSound();
    setState(() => _secondsPerProblem = newValue);
  }

  void _increaseValue() {
    double newValue;
    if (_secondsPerProblem >= CircularSlider.range1End) {
      newValue = _secondsPerProblem + 1.0;
    } else {
      newValue = (_secondsPerProblem * 10 + 1) / 10;
    }
    newValue = newValue.clamp(CircularSlider.minValue, CircularSlider.maxValue);
    if (newValue == _secondsPerProblem) return; // already at max, no change
    _playIncrementSound();
    setState(() => _secondsPerProblem = newValue);
  }

  @override
  void dispose() {
    unawaited(
      _prefsReady.then<void>((_) => _savePrefs(), onError: (Object error) {}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isKana =
        Localizations.localeOf(context).scriptCode?.toLowerCase() == 'kana';
    final int hideDuration = (_secondsPerProblem / (2.5 * _kuchi - 1) * 1000)
        .round();
    final int showDuration = (1.5 * hideDuration).round();

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.flashFreeTitle,
        titleFontSize: isKana ? 22 : null,
        context: context,
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isPortrait = orientation == Orientation.portrait;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isTallScreen =
                        constraints.maxHeight.isFinite &&
                        constraints.maxHeight > _tallScreenThreshold;

                    final incrementers = _IncrementerSection(
                      kuchi: _kuchi,
                      digits: _digits,
                      onKuchiChanged: (val) => setState(() => _kuchi = val),
                      onDigitsChanged: (val) => setState(() => _digits = val),
                    );

                    final slider = _TortoiseHareSlider(
                      secondsPerProblem: _secondsPerProblem,
                      onSliderChanged: (val) =>
                          setState(() => _secondsPerProblem = val),
                      onIncrease: _increaseValue,
                      onDecrease: _decreaseValue,
                    );

                    final durationCards = _DurationCardsSection(
                      showDuration: showDuration,
                      hideDuration: hideDuration,
                      direction: isPortrait
                          ? Axis.horizontal
                          : (isTallScreen ? Axis.horizontal : Axis.vertical),
                      spacing: isPortrait ? 10 : (isTallScreen ? 10 : 40),
                    );

                    final startButton = StartButton(
                      onPressed: () => unawaited(_startPractice()),
                    );

                    if (isPortrait) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 16,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 560,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  spacing: 4,
                                  children: [
                                    incrementers,
                                    slider,
                                    durationCards,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          startButton,
                        ],
                      );
                    }

                    // Landscape Layout
                    final content = isTallScreen
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [incrementers, slider],
                              ),
                              const SizedBox(height: 24),
                              durationCards,
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [incrementers, slider, durationCards],
                          );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 800,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: content,
                            ),
                          ),
                        ),
                        startButton,
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IncrementerSection extends StatelessWidget {
  final int kuchi;
  final int digits;
  final ValueChanged<int> onKuchiChanged;
  final ValueChanged<int> onDigitsChanged;

  const _IncrementerSection({
    required this.kuchi,
    required this.digits,
    required this.onKuchiChanged,
    required this.onDigitsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Incrementer(
          value: kuchi,
          label: AppLocalizations.of(context).flashKuchiLabel,
          onChanged: (newValue) => onKuchiChanged(newValue.toInt()),
          min: 1,
          max: 30,
        ),
        const SizedBox(width: 16),
        Incrementer(
          value: digits,
          label: AppLocalizations.of(context).flashDigitsLabel,
          onChanged: (newValue) => onDigitsChanged(newValue.toInt()),
          min: 1,
          max: 6,
        ),
      ],
    );
  }
}

class _TortoiseHareSlider extends StatelessWidget {
  final double secondsPerProblem;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _TortoiseHareSlider({
    required this.secondsPerProblem,
    required this.onSliderChanged,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 400,
      height: 300,
      child: Stack(
        children: [
          CircularSlider(
            initialValue: secondsPerProblem,
            width: 400,
            height: 300,
            onChanged: onSliderChanged,
          ),
          Positioned(
            left: 85,
            bottom: 40,
            child: Semantics(
              button: true,
              label: AppLocalizations.of(context).increaseTime,
              child: SpammableButton(
                onTapDown: onIncrease,
                enableRepeat: true,
                shape: BoxShape.circle,
                child: Container(
                  height: 90,
                  width: 90,
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/tortoise.png',
                    color: colorScheme.onSurface,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 85,
            bottom: 40,
            child: Semantics(
              button: true,
              label: AppLocalizations.of(context).decreaseTime,
              child: SpammableButton(
                onTapDown: onDecrease,
                enableRepeat: true,
                shape: BoxShape.circle,
                child: Container(
                  height: 90,
                  width: 90,
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/hare.png',
                    color: colorScheme.onSurface,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationCardsSection extends StatelessWidget {
  final int showDuration;
  final int hideDuration;
  final Axis direction;
  final double spacing;

  const _DurationCardsSection({
    required this.showDuration,
    required this.hideDuration,
    required this.direction,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: direction,
        spacing: spacing,
        children: [
          _DurationCard(
            title: AppLocalizations.of(context).displayInterval,
            durationMs: showDuration,
          ),
          _DurationCard(
            title: AppLocalizations.of(context).blankInterval,
            durationMs: hideDuration,
          ),
        ],
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final String title;
  final int durationMs;

  const _DurationCard({required this.title, required this.durationMs});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Formats numbers with thousand separators and up to 1 decimal place
    // Examples: 12.3 -> "12.3", 1234.5 -> "1,234.5", 1000 -> "1,000"
    final formatter = NumberFormat(
      '#,##0.#',
      Localizations.localeOf(context).toString(),
    );
    final formattedDuration = formatter.format(durationMs);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: colorScheme.surfaceContainerHigh,
      child: SizedBox(
        width: 210,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          child: Column(
            children: [
              Text(title, style: textTheme.headlineSmall),
              FittedBox(
                fit: .scaleDown,
                child: Text(
                  '~$formattedDuration ${AppLocalizations.of(context).millisecondsShort}',
                  style: textTheme.headlineLarge!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;
  final Color? backgroundColor;
  final double width;
  final double height;

  static const double maxValue = 40.0;
  static const double minValue = 0.9;
  static const double range1End = 10.0;

  const CircularSlider({
    super.key,
    this.initialValue = 10.0,
    this.onChanged,
    this.activeColor,
    this.backgroundColor,
    required this.width,
    required this.height,
  });

  static double valueToProgress(double value) {
    if (value >= range1End) {
      return (maxValue - value) / (maxValue - range1End);
    } else {
      double range2Progress = (range1End - value) / (range1End - minValue);
      return 1.0 + range2Progress;
    }
  }

  static double progressToValue(double progress) {
    if (progress < 1.0) {
      return maxValue - (progress * (maxValue - range1End));
    } else {
      double range2Progress = progress - 1.0;
      return range1End - (range2Progress * (range1End - minValue));
    }
  }

  static double roundValue(double value) {
    if (value >= range1End) {
      return value.roundToDouble();
    } else {
      return (value * 10).round() / 10;
    }
  }

  @override
  State<CircularSlider> createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  late double _value;
  double? _lastAngle;
  double _accumulatedDelta = 0.0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(
      CircularSlider.minValue,
      CircularSlider.maxValue,
    );
  }

  @override
  void didUpdateWidget(CircularSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _value = widget.initialValue.clamp(
        CircularSlider.minValue,
        CircularSlider.maxValue,
      );
    }
  }

  // Use the static methods from the widget class
  double get _progress => CircularSlider.valueToProgress(_value) / 2.0;

  double get _handleAngle {
    const gapSize = 5 * pi / 6;
    const gapStart = pi / 2 - gapSize / 2;
    const startAngle = gapStart + gapSize;
    const totalArc = 2 * pi - gapSize;
    return startAngle + (totalArc * _progress);
  }

  double _calculateAngle(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, 7 * size.height / 10);
    final touchPoint = localPosition - center;
    double angle = atan2(touchPoint.dy, touchPoint.dx);
    if (angle < 0) angle += 2 * pi;
    return angle;
  }

  void _handlePanStart(Offset localPosition, Size size) {
    _lastAngle = _calculateAngle(localPosition, size);
    _accumulatedDelta = 0.0;
  }

  void _handlePanUpdate(Offset localPosition, Size size) {
    final currentAngle = _calculateAngle(localPosition, size);
    if (_lastAngle == null) {
      _lastAngle = currentAngle;
      return;
    }

    double deltaAngle = currentAngle - _lastAngle!;
    if (deltaAngle > pi) {
      deltaAngle -= 2 * pi;
    } else if (deltaAngle < -pi) {
      deltaAngle += 2 * pi;
    }

    const gapSize = 5 * pi / 6;
    const totalArc = 2 * pi - gapSize;
    double deltaProgress = (deltaAngle / totalArc) * 2.0;

    _accumulatedDelta += deltaProgress;
    double currentProgress = CircularSlider.valueToProgress(_value);
    double newProgress = currentProgress + _accumulatedDelta;
    newProgress = newProgress.clamp(0.0, 2.0);

    double newValue = CircularSlider.progressToValue(newProgress);
    double roundedValue = CircularSlider.roundValue(newValue);
    roundedValue = roundedValue.clamp(
      CircularSlider.minValue,
      CircularSlider.maxValue,
    );

    if (roundedValue != _value) {
      double usedProgress =
          CircularSlider.valueToProgress(roundedValue) - currentProgress;
      setState(() {
        _value = roundedValue;
      });
      widget.onChanged?.call(_value);
      _accumulatedDelta -= usedProgress;
    }

    _lastAngle = currentAngle;
  }

  void _handlePanEnd() {
    _lastAngle = null;
    _accumulatedDelta = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.activeColor ?? colorScheme.primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onPanStart: (details) {
          _handlePanStart(
            details.localPosition,
            Size(widget.width, widget.height),
          );
        },
        onPanUpdate: (details) {
          _handlePanUpdate(
            details.localPosition,
            Size(widget.width, widget.height),
          );
        },
        onPanEnd: (details) {
          _handlePanEnd();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: CircularSliderPainter(backgroundColor: primaryColor),
            ),
            Positioned(
              top: 100,
              child: Row(
                mainAxisAlignment: .center,
                crossAxisAlignment: .end,
                children: [
                  Text(
                    _value >= 10
                        ? _value.toStringAsFixed(0)
                        : _value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).secondsUnit,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, widget.height / 5),
              child: Transform.rotate(
                angle: _handleAngle + pi / 2,
                child: Transform.translate(
                  offset: Offset(0, -widget.height * 0.533),
                  child: Icon(
                    Icons.circle,
                    size: 30,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularSliderPainter extends CustomPainter {
  final Color backgroundColor;

  CircularSliderPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 7 * size.height / 10);
    final radius = (size.width * 0.4);

    // Gap size in radians (e.g., 45 degrees = pi/4)
    const gapSize = 5 * pi / 6;
    const gapStart = pi / 2 - gapSize / 2; // Center the gap at bottom

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      gapStart + gapSize,
      2 * pi - gapSize,
      false,
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(CircularSliderPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor;
  }
}
