import 'package:flutter/material.dart';
import 'package:soroban_app/screens/components/spammable_button.dart';

class Incrementer extends StatefulWidget {
  const Incrementer({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    required this.label,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final int? min;
  final int? max;

  @override
  State<Incrementer> createState() => _IncrementerState();
}

class _IncrementerState extends State<Incrementer> {
  void _increment() {
    int newValue = widget.value + 1;
    if (widget.max != null && newValue > widget.max!) return;
    widget.onChanged(newValue);
  }

  void _decrement() {
    int newValue = widget.value - 1;
    if (widget.min != null && newValue < widget.min!) return;
    widget.onChanged(newValue);
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
            width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.keyboard_arrow_up_rounded),
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
                  style: Theme.of(context).textTheme.displayLarge,
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
            width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ],
    );
  }
}
