import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    required this.title,
    required BuildContext context,
    this.actionWidget,
    this.actionPadding = const EdgeInsets.only(right: 10.0),
    this.black = false,
    this.onBackPressed,
    this.thresholdHeight = 600.0,
  }) : isCompact = _checkIsCompact(context, thresholdHeight);

  final String title;
  final Widget? actionWidget;
  final EdgeInsetsGeometry actionPadding;
  final VoidCallback? onBackPressed;
  final bool black;
  final double thresholdHeight;
  final bool isCompact;

  static bool _checkIsCompact(BuildContext context, double threshold) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.landscape &&
        mediaQuery.size.height < threshold;
  }

  double get height => isCompact ? 32.0 : kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double iconSize = isCompact ? 16.0 : 20.0;
    final double fontSize = isCompact ? 14.0 : 22.0;
    final backgroundColor = black ? Colors.black : theme.colorScheme.surface;
    final foregroundColor = black ? Colors.white : theme.colorScheme.onSurface;
    final borderColor = black
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              toolbarHeight: height,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              primary: true,
              centerTitle: true,
              titleSpacing: 0,
              iconTheme: IconThemeData(color: foregroundColor, size: iconSize),
              title: Text(
                title,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              leading: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: height,
                  minHeight: height,
                ),
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: iconSize),
                onPressed: onBackPressed ?? () => context.go('/home'),
              ),
            ),
            if (actionWidget != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: actionPadding,
                  child: Center(
                    child: SizedBox(
                      width: height,
                      height: height,
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(
                            color: foregroundColor,
                            size: iconSize,
                          ),
                          child: actionWidget!,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
