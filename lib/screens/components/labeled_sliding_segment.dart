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
  final List<(T value, dynamic label)>
  options; // Supports String or Widget (e.g. Icon)
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      backgroundColor: theme.colorScheme.surfaceContainer,
      thumbColor: theme.colorScheme.primaryContainer,
      children: {
        for (final option in options)
          option.$1: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildLabelWidget(option.$2, textTheme),
          ),
      },
      onValueChanged: (value) {
        if (value != null) {
          onValueChanged(value);
        }
      },
    );
  }

  Widget _buildLabelWidget(dynamic label, TextTheme textTheme) {
    if (label is Widget) {
      return label;
    }
    if (label is String) {
      return Text(label, style: textTheme.headlineSmall);
    }
    return Text(label.toString(), style: textTheme.headlineSmall);
  }
}
