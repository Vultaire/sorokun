import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabeledSlidingSegmentedControl<T extends Object> extends StatelessWidget {
  const LabeledSlidingSegmentedControl({
    super.key,
    required this.groupValue,
    required this.options,
    required this.onValueChanged,
  });

  final T groupValue;
  final List<(T value, String label)> options;
  final ValueChanged<T> onValueChanged;

  static TextStyle _segmentStyle(BuildContext context, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      shadowColor: Colors.black,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: groupValue,
        padding: EdgeInsets.all(8),
        backgroundColor: colorScheme.surfaceContainer,
        thumbColor: colorScheme.surfaceContainerHighest,
        children: {
          for (final (value, label) in options)
            value: Text(
              label,
              style: _segmentStyle(context, value == groupValue),
            ),
        },
        onValueChanged: (T? value) {
          if (value != null) {
            onValueChanged(value);
          }
        },
      ),
    );
  }
}
