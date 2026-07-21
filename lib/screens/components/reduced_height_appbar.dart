import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReducedHeightAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  ReducedHeightAppbar({super.key, required this.title})
    : preferredSize = Size.fromHeight(_heightForContext());

  final Widget title;

  @override
  final Size preferredSize;

  static double _heightForContext() {
    // Fallback static value; real orientation-aware height set below via didChangeMetrics if needed.
    return kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      title: title,
      centerTitle: true,
      toolbarHeight: isLandscape ? 40 : kToolbarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/home'),
      ),
    );
  }
}
