import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isLandscape = size.width > size.height;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: -0.18,
              child: ScrollingBackground(assetPath: 'assets/soroban-grey.png'),
            ),
          ),

          // Foreground content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: isLandscape
                          ? size.width * 0.5
                          : size.width * 0.9,
                    ),
                    child: FittedBox(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text('そろくん', style: TextStyle(fontWeight: .w900)),
                            Text(
                              '珠算特訓アプリ',
                              style: TextStyle(fontSize: 6, fontWeight: .w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Make A Problem Sheet'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/flash-menu'),
                  child: const Text('Flash Anzan'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/paper-menu'),
                  child: const Text('Train In The App'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/aloud-menu'),
                  child: const Text('Aloud Problem'),
                ),
              ],
            ),
          ),
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
            tintColor: Theme.of(context).colorScheme.primary.withAlpha(120),
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
