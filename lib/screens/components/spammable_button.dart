import 'dart:async';

import 'package:flutter/material.dart';

class SpammableButton extends StatefulWidget {
  final VoidCallback onTapDown;
  final Widget child;
  final bool enableRepeat;
  final BoxShape shape;

  const SpammableButton({
    super.key,
    required this.onTapDown,
    required this.child,
    this.enableRepeat = false,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<SpammableButton> createState() => _SpammableButtonState();
}

class _SpammableButtonState extends State<SpammableButton> {
  bool _isPressed = false;
  Timer? _repeatTimer;
  Timer? _delayTimer;

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  void _startRepeating(VoidCallback action) {
    if (!widget.enableRepeat) return;
    _delayTimer = Timer(Duration(milliseconds: 500), () {
      _repeatTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        action();
      });
    });
  }

  void _stopRepeating() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final restingColor = colorScheme.surfaceContainerHigh;
    final pressedColor = Color.lerp(restingColor, colorScheme.primary, 0.15)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onTapDown.call();
        if (widget.enableRepeat) {
          _startRepeating(widget.onTapDown);
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _stopRepeating();
        if (!widget.enableRepeat) {
          widget.onTapDown.call();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _stopRepeating();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.translationValues(
          _isPressed ? 3.0 : 0.0,
          _isPressed ? 3.0 : 0.0,
          0,
        ),
        child: AnimatedPhysicalModel(
          duration: const Duration(milliseconds: 50),
          shape: widget.shape,
          borderRadius: BorderRadius.circular(24),
          color: _isPressed ? pressedColor : restingColor,
          shadowColor: Colors.black,
          elevation: _isPressed ? 2 : 8,
          child: widget.child,
        ),
      ),
    );
  }
}
