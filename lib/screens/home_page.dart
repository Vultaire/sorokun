import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final Size size = media.size;
    final bool isPortrait = media.orientation == Orientation.portrait;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isPortrait)
            Positioned(
              top: size.height * 0.1,
              child: Transform.rotate(
                angle: -0.18,
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: ScrollingBackground(
                      assetPath: 'assets/soroban-grey.png',
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: -0.18,
                  child: ExcludeSemantics(
                    child: RepaintBoundary(
                      child: ScrollingBackground(
                        assetPath: 'assets/soroban-grey.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Flex(
              direction: isPortrait ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              spacing: isPortrait ? 40 : 0,
              children: [
                Expanded(
                  flex: isPortrait ? 0 : 3,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isPortrait
                            ? size.width * 0.9
                            : size.width * 0.4,
                      ),
                      child: FittedBox(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'そろくん',
                                style: TextStyle(
                                  fontWeight: .w900,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '珠算特訓アプリ',
                                style: TextStyle(
                                  fontSize: 6,
                                  fontWeight: .w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: isPortrait ? 0 : 3,
                  fit: isPortrait ? FlexFit.loose : FlexFit.tight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const desiredHeight =
                          100.0; // the taller height you want normally
                      const minHeight =
                          64.0; // floor — never shrink smaller than this
                      const spacing = 16.0;
                      const rows = 3; // train button + flash row + aloud row
                      double rowHeight = desiredHeight;
                      if (constraints.maxHeight.isFinite) {
                        final maxAllowed =
                            (constraints.maxHeight - spacing * (rows - 1)) /
                            rows;
                        rowHeight = maxAllowed.clamp(minHeight, desiredHeight);
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: rowHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryFixedDim,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    spacing: 8,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
                                              BlendMode.srcIn,
                                            ),
                                            child: Image.asset(
                                              'assets/shumoku_icon.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          onPressed: () =>
                                              context.push('/paper-menu'),
                                          child: Center(
                                            child: FittedBox(
                                              fit: .scaleDown,
                                              child: Text(
                                                '基本種目を練習',
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            height: rowHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryFixedDim,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    spacing: 8,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
                                              BlendMode.srcIn,
                                            ),
                                            child: Image.asset(
                                              'assets/flash_icon.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          onPressed: () =>
                                              context.push('/flash-level-menu'),
                                          child: FittedBox(
                                            fit: .scaleDown,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'フラッシュ暗算',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                                Text(
                                                  '検定',
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          onPressed: () =>
                                              context.push('/flash-free-menu'),
                                          child: FittedBox(
                                            fit: .scaleDown,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'フラッシュ暗算',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                                Text(
                                                  'フリー',
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          SizedBox(
                            height: rowHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryFixedDim,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    spacing: 8,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
                                              BlendMode.srcIn,
                                            ),
                                            child: Image.asset(
                                              'assets/aloud_icon.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          onPressed: () =>
                                              context.push('/aloud-level-menu'),
                                          child: FittedBox(
                                            fit: .scaleDown,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '読み上げ算',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                                Text(
                                                  '検定',
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NavigationButton(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          onPressed: () =>
                                              context.push('/aloud-free-menu'),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '読み上げ算',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                                Text(
                                                  'フリー',
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(top: 24, left: 24, child: SettingsGearButton()),
        ],
      ),
    );
  }
}

class ScrollingBackground extends StatefulWidget {
  final String assetPath;

  const ScrollingBackground({super.key, required this.assetPath});

  @override
  State<ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final stream = AssetImage(
      widget.assetPath,
    ).resolve(ImageConfiguration.empty);
    stream.addListener(
      ImageStreamListener((info, _) {
        if (mounted) setState(() => _image = info.image);
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 250),
          painter: _TiledScrollPainter(
            image: _image,
            progress: _controller.value,
            tintColor: Theme.of(context).colorScheme.primary.withAlpha(190),
          ),
        );
      },
    );
  }
}

class _TiledScrollPainter extends CustomPainter {
  final ui.Image? image;
  final double progress;
  final Color tintColor;

  _TiledScrollPainter({
    required this.image,
    required this.progress,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    final scale = size.height / image!.height;
    final scaledWidth = image!.width * scale;
    final offset = progress * scaledWidth;
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(tintColor, BlendMode.modulate);

    // Extra padding accounts for the visual overflow caused by rotation
    const rotationPadding = 300.0;
    double x = -offset - rotationPadding;
    while (x < size.width + rotationPadding) {
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(x, 0, scaledWidth, size.height),
        paint,
      );
      x += scaledWidth - 0.5;
    }
  }

  @override
  bool shouldRepaint(_TiledScrollPainter old) =>
      old.progress != progress || old.image != image;
}
