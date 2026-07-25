import 'package:flutter/material.dart';

class NavigationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Duration duration;
  final Color color;
  final Widget child;
  final EdgeInsets? margin;

  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.margin,
  });

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0.0,
          _isPressed ? 2 : 0.0,
          0,
        ),
        margin: widget.margin ?? const EdgeInsets.all(0),
        child: AnimatedPhysicalModel(
          duration: widget.duration,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12),
          color: widget.color,
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
