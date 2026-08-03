import 'package:flutter/material.dart';

class NavigationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Duration duration;
  final Color color;
  final Widget child;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.margin,
    this.borderRadius,
  });

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pressedColor = Color.lerp(widget.color, colorScheme.primary, 0.15)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0.0, 0),
        margin: widget.margin ?? const EdgeInsets.all(0),
        child: AnimatedPhysicalModel(
          duration: widget.duration,
          shape: BoxShape.rectangle,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
          color: _isPressed ? pressedColor : widget.color,
          shadowColor: Colors.black,
          elevation: _isPressed ? 2 : 8,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

Widget iconHelper(BuildContext context, IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.headlineSmall),
      ],
    ),
  );
}
