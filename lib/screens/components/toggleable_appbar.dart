import 'package:flutter/material.dart';

class ToggleableAppBar extends StatefulWidget {
  const ToggleableAppBar({
    super.key,
    required this.child,
    required this.appBar,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOut,
  });

  final Widget child;
  final PreferredSizeWidget appBar;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<ToggleableAppBar> createState() => _ToggleableAppBarState();
}

class _ToggleableAppBarState extends State<ToggleableAppBar> {
  bool _isVisible = false;

  void _toggle() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topSafeArea = MediaQuery.of(context).padding.top;
    final totalAppBarHeight = widget.appBar.preferredSize.height + topSafeArea;

    return Stack(
      children: [
        // 1. Fullscreen body - completely flush to the screen edges, zero padding
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: widget.child,
          ),
        ),

        // 2. Sliding Overlay Header (Appears from the top without pushing the body)
        AnimatedPositioned(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          top: _isVisible ? 0 : -totalAppBarHeight,
          left: 0,
          right: 0,
          height: totalAppBarHeight,
          child: Material(elevation: 4, child: widget.appBar),
        ),
      ],
    );
  }
}

