import 'package:flutter/material.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';

const up_arrow = Icon(Icons.keyboard_arrow_up_rounded, size: 40);
const down_arrow = Icon(Icons.keyboard_arrow_down_rounded, size: 40);

class Incrementer extends StatefulWidget {
  const Incrementer({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    required this.label,
    this.step,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final String label;
  final int? min;
  final int? max;
  final double? step;

  @override
  State<Incrementer> createState() => _IncrementerState();
}

class _IncrementerState extends State<Incrementer> {
  void _increment() {
    num newValue = widget.value + (widget.step ?? 1);
    if (widget.max != null && newValue > widget.max!) return;
    widget.onChanged((newValue * 10).round() / 10);
  }

  void _decrement() {
    num newValue = widget.value - (widget.step ?? 1);
    if (widget.min != null && newValue < widget.min!) return;
    widget.onChanged((newValue * 10).round() / 10);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SpammableButton(
          onTapDown: _increment,
          enableRepeat: true,
          child: Container(
            height: 60,
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: up_arrow,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: .all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 150),
            child: Column(
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  '${widget.value}',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge!.copyWith(fontFamily: 'robotoMono'),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        SpammableButton(
          onTapDown: _decrement,
          enableRepeat: true,
          child: Container(
            height: 60,
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: down_arrow,
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
      newMax =
          newMin; // drag max along, still <= widget.max since newMin passed the check
    }
    widget.onChanged((newMin, newMax));
  }

  void _decrementMin() {
    int newMin = widget.minValue - 1;
    if (widget.min != null && newMin < widget.min!) return;

    // decrementing min can't push it above max, so max is untouched
    widget.onChanged((newMin, widget.maxValue));
  }

  void _incrementMax() {
    int newMax = widget.maxValue + 1;
    if (widget.max != null && newMax > widget.max!) return;

    // incrementing max can't push it below min, so min is untouched
    widget.onChanged((widget.minValue, newMax));
  }

  void _decrementMax() {
    int newMax = widget.maxValue - 1;
    if (widget.min != null && newMax < widget.min!) return;

    int newMin = widget.minValue;
    if (newMax < newMin) {
      newMin =
          newMax; // drag min along, still >= widget.min since newMax passed the check
    }
    widget.onChanged((newMin, newMax));
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
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: up_arrow,
              ),
            ),
            SizedBox(width: 30.0),
            SpammableButton(
              onTapDown: _incrementMax,
              enableRepeat: true,
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: up_arrow,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: .all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
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
                      width: 82,
                      height: 62,
                      child: Center(
                        child: Text(
                          '${widget.minValue}',
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(fontFamily: 'robotoMono'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 62,
                      child: Center(
                        child: Text(
                          '~',
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(fontFamily: 'robotoMono'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 82,
                      height: 62,
                      child: Center(
                        child: Text(
                          '${widget.maxValue}',
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(fontFamily: 'robotoMono'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SpammableButton(
              onTapDown: _decrementMin,
              enableRepeat: true,
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: down_arrow,
              ),
            ),
            SizedBox(width: 30.0),
            SpammableButton(
              onTapDown: _decrementMax,
              enableRepeat: true,
              child: Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: down_arrow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
