import 'dart:async';

import 'package:flutter/material.dart';

class SpammableButton extends StatefulWidget {
  final VoidCallback onTapDown;
  final Widget child;
  final double offsetX;
  final double offsetY;
  final bool enableRepeat;

  const SpammableButton({
    super.key,
    required this.onTapDown,
    required this.child,
    this.offsetX = 2.0,
    this.offsetY = 2.0,
    this.enableRepeat = false,
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
    return GestureDetector(
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
          _isPressed ? widget.offsetX : 0.0,
          _isPressed ? widget.offsetY : 0.0,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}
