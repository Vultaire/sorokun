// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabeledSlidingSegmentedControl<T extends Object> extends StatelessWidget {
  const LabeledSlidingSegmentedControl({
    super.key,
    required this.groupValue,
    required this.options,
    required this.onValueChanged,
    this.horizontalPadding = 16,
    this.verticalPadding = 16,
  });

  final T groupValue;
  final List<(T value, dynamic label)> options;
  final ValueChanged<T> onValueChanged;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      backgroundColor: colorScheme.surfaceContainer,
      thumbColor: colorScheme.secondaryContainer,
      children: {
        for (final option in options)
          option.$1: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: _buildLabelWidget(
              label: option.$2,
              isSelected: option.$1 == groupValue,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ),
      },
      onValueChanged: (value) {
        if (value != null) {
          onValueChanged(value);
        }
      },
    );
  }

  Widget _buildLabelWidget({
    required dynamic label,
    required bool isSelected,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    final activeColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    final baseStyle = textTheme.headlineSmall!.copyWith(color: activeColor);

    if (label is Widget) {
      return IconTheme(
        data: IconThemeData(color: activeColor),
        child: DefaultTextStyle(style: baseStyle, child: label),
      );
    }

    return Text(label.toString(), style: baseStyle);
  }
}
