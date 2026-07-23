import 'package:flutter/material.dart';

class NavigationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Duration duration;
  final Duration debounceTime;
  final Widget? image;
  final Color color;
  final bool? imageAbove;
  final bool isCircular; // new
  final double? size; // new, useful to give circle a fixed diameter

  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.duration = const Duration(milliseconds: 100),
    this.debounceTime = const Duration(milliseconds: 1000),
    this.image,
    required this.color,
    this.imageAbove,
    this.isCircular = false,
    this.size,
  });

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  bool _isPressed = false;
  bool _isNavigating = false;

  void _handleTap() {
    if (_isNavigating) return;
    _isNavigating = true;
    widget.onPressed();
    Future.delayed(widget.debounceTime, () {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isCircular ? null : BorderRadius.circular(12);
    final shape = widget.isCircular ? BoxShape.circle : BoxShape.rectangle;

    return GestureDetector(
      onTapDown: _isNavigating
          ? null
          : (_) {
              setState(() => _isPressed = true);
            },
      onTapUp: _isNavigating
          ? null
          : (_) {
              setState(() => _isPressed = false);
              _handleTap();
            },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0.0,
          _isPressed ? 2 : 0.0,
          0,
        ),
        margin: const EdgeInsets.all(6),
        child: Opacity(
          opacity: _isNavigating ? 0.5 : 1.0,
          child: Container(
            width: widget.isCircular ? widget.size : null,
            height: widget.isCircular ? widget.size : null,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.color,
              shape: shape,
              borderRadius: borderRadius,
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.color,
                shape: shape,
                borderRadius: borderRadius,
              ),
              child: widget.image != null
                  ? Flex(
                      direction: widget.imageAbove!
                          ? Axis.vertical
                          : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: widget.imageAbove! ? 3 : 1,
                          child: widget.image!,
                        ),
                        Expanded(
                          flex: widget.imageAbove! ? 1 : 2,
                          child: Text(
                            widget.label,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
