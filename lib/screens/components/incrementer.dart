// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';

const upArrow = Icon(Icons.keyboard_arrow_up_rounded, size: 40);
const downArrow = Icon(Icons.keyboard_arrow_down_rounded, size: 40);

class Incrementer extends StatefulWidget {
  const Incrementer({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    required this.label,
    this.step,
    this.displayValue,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final int? min;
  final int? max;
  final int? step;
  final String? displayValue;

  static AudioSource? get incrementSound =>
      _IncrementerState._sharedIncrementSound;
  static Future<AudioSource> ensureIncrementSoundLoaded() {
    return _IncrementerState._ensureSoundLoadedStatic();
  }

  @override
  State<Incrementer> createState() => _IncrementerState();
}

class _IncrementerState extends State<Incrementer> {
  static AudioSource? _sharedIncrementSound;
  static Future<AudioSource>? _loadingFuture;

  void _increment() {
    int newValue = widget.value + (widget.step ?? 1);
    if (widget.max != null && newValue > widget.max!) return;
    _playIncrementSound();
    widget.onChanged(newValue);
  }

  void _decrement() {
    int newValue = widget.value - (widget.step ?? 1);
    if (widget.min != null && newValue < widget.min!) return;
    _playIncrementSound();
    widget.onChanged(newValue);
  }

  @override
  void initState() {
    super.initState();
    Incrementer.ensureIncrementSoundLoaded();
  }

  static Future<AudioSource> _ensureSoundLoadedStatic() {
    if (_sharedIncrementSound != null) {
      return Future.value(_sharedIncrementSound);
    }
    _loadingFuture ??= SoLoud.instance.loadAsset('assets/key-tap.wav').then((
      source,
    ) {
      _sharedIncrementSound = source;
      return source;
    });
    return _loadingFuture!;
  }

  void _playIncrementSound() {
    if (_sharedIncrementSound != null) {
      SoLoud.instance.play(_sharedIncrementSound!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: AppLocalizations.of(context).increaseValue,
          child: SpammableButton(
            onTapDown: _increment,
            enableRepeat: true,
            child: SizedBox(
              height: 60,
              width: 80,
              child: Center(child: upArrow),
            ),
          ),
        ),
        SizedBox(height: 8),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 150),
              child: Column(
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    widget.displayValue ?? '${widget.value}',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Semantics(
          button: true,
          label: AppLocalizations.of(context).decreaseValue,
          child: SpammableButton(
            onTapDown: _decrement,
            enableRepeat: true,
            child: SizedBox(
              height: 60,
              width: 80,
              child: Center(child: downArrow),
            ),
          ),
        ),
      ],
    );
  }
}

class RangeIncrementer extends StatefulWidget {
  const RangeIncrementer({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.label,
    this.min,
    this.max,
  });

  final int minValue;
  final int maxValue;
  final ValueChanged<(int, int)> onChanged;
  final String label;
  final int? min;
  final int? max;

  @override
  State<RangeIncrementer> createState() => _RangeIncrementerState();
}

class _RangeIncrementerState extends State<RangeIncrementer> {
  void _incrementMin() {
    int newMin = widget.minValue + 1;
    if (widget.max != null && newMin > widget.max!) return;
    int newMax = widget.maxValue;
    if (newMin > newMax) {
      newMax = newMin;
    }
    _playIncrementSound();
    widget.onChanged((newMin, newMax));
  }

  void _decrementMin() {
    int newMin = widget.minValue - 1;
    if (widget.min != null && newMin < widget.min!) return;
    _playIncrementSound();
    widget.onChanged((newMin, widget.maxValue));
  }

  void _incrementMax() {
    int newMax = widget.maxValue + 1;
    if (widget.max != null && newMax > widget.max!) return;
    _playIncrementSound();
    widget.onChanged((widget.minValue, newMax));
  }

  void _decrementMax() {
    int newMax = widget.maxValue - 1;
    if (widget.min != null && newMax < widget.min!) return;
    int newMin = widget.minValue;
    if (newMax < newMin) {
      newMin = newMax;
    }
    _playIncrementSound();
    widget.onChanged((newMin, newMax));
  }

  void _playIncrementSound() {
    final sound = Incrementer.incrementSound;
    if (sound != null) {
      SoLoud.instance.play(sound);
    }
  }

  @override
  void initState() {
    super.initState();
    Incrementer.ensureIncrementSoundLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SpammableButton(
              onTapDown: _incrementMin,
              enableRepeat: true,
              child: SizedBox(
                height: 60,
                width: 80,
                child: Center(child: upArrow),
              ),
            ),
            SizedBox(width: 30.0),
            SpammableButton(
              onTapDown: _incrementMax,
              enableRepeat: true,
              child: SizedBox(
                height: 60,
                width: 80,
                child: Center(child: upArrow),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 150),
              child: Column(
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 75,
                        height: 62,
                        child: Center(
                          child: Text(
                            '${widget.minValue}',
                            style: Theme.of(context).textTheme.displayLarge!
                                .copyWith(
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 39,
                        height: 62,
                        child: Center(
                          child: Text(
                            '~',
                            style: Theme.of(context).textTheme.displayLarge!
                                .copyWith(
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        height: 62,
                        child: Center(
                          child: Text(
                            '${widget.maxValue}',
                            style: Theme.of(context).textTheme.displayLarge!
                                .copyWith(
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SpammableButton(
              onTapDown: _decrementMin,
              enableRepeat: true,
              child: SizedBox(
                height: 60,
                width: 80,
                child: Center(child: downArrow),
              ),
            ),
            SizedBox(width: 30.0),
            SpammableButton(
              onTapDown: _decrementMax,
              enableRepeat: true,
              child: SizedBox(
                height: 60,
                width: 80,
                child: Center(child: downArrow),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
