import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions; // Exposed trailing actions
  final VoidCallback? onBackPressed;
  final double height;

  CustomAppBar({
    super.key,
    required this.title,
    required BuildContext context,
    this.leading,
    this.actions, // Added to constructor
    this.onBackPressed,
    double thresholdHeight = 600.0,
  }) : height = _calculateHeight(context, thresholdHeight);

  static double _calculateHeight(BuildContext context, double threshold) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact =
        mediaQuery.orientation == Orientation.landscape &&
        mediaQuery.size.height < threshold;
    return isCompact ? 40.0 : kToolbarHeight;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      primary: true,
      title: Text(title),
      centerTitle: true,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: true,
      shadowColor: Colors.transparent,
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () => context.go('/home'),
          ),
      actions: actions, // Passed to AppBar
    );
  }
}

