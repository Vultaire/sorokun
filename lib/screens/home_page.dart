// Modified by Vultaire on 2026-11-01.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/settings.dart';
import 'package:stroke_text/stroke_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isJapanese = Localizations.localeOf(context).languageCode == 'ja';
    final size = MediaQuery.sizeOf(context);
    final bool isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
              padding: const EdgeInsets.all(16.0),
              child: Flex(
                direction: isPortrait ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                spacing: isPortrait ? 40 : 10,
                children: [
                  Expanded(
                    flex: isPortrait ? 0 : 3,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isPortrait
                              ? size.width * 0.9
                              : size.width * 0.4,
                        ),
                        child: FittedBox(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 44,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(220),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 44,
                                vertical: 44,
                              ),
                              child: Semantics(
                                label: l10n.appTitle,
                                child: isJapanese
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/sorokun_white.png',
                                          ),
                                          ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
                                              BlendMode.modulate,
                                            ),
                                            child: Image.asset(
                                              'assets/sorokun_color.png',
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        width: 355,
                                        height: 165,
                                        child: Center(
                                          child: Text(
                                            l10n.appTitle,
                                            style: TextStyle(
                                              fontSize: 82,
                                              fontFamily: 'mPlus',
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
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
                        const desiredHeight = 86.0;
                        const minHeight = 72.0;
                        const spacing = 24.0;
                        const rows = 2;
                        double rowHeight = desiredHeight;
                        if (constraints.maxHeight.isFinite) {
                          final maxAllowed =
                              (constraints.maxHeight - spacing * (rows - 1)) /
                              rows;
                          rowHeight = maxAllowed.clamp(
                            minHeight,
                            desiredHeight,
                          );
                        }
                        final scheme = Theme.of(context).colorScheme;

                        return ConstrainedBox(
                          constraints: BoxConstraints.tightFor(width: 600),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _MenuRow(
                                height: rowHeight,
                                background: scheme.primaryFixedDim,
                                titleColor: scheme.onPrimaryFixedVariant,
                                titleLine1: l10n.homeCombinedLine1,
                                titleLine2: l10n.homeCombinedLine2,
                                rotation: -0.2,
                                buttons: [
                                  _MenuButtonData(
                                    label: l10n.homeSelectSubject,
                                    color: scheme.primary,
                                    onColor: scheme.onPrimary,
                                    onPressed: () =>
                                        context.push('/paper-menu'),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              _MenuRow(
                                height: rowHeight,
                                background: scheme.primaryFixedDim,
                                titleColor: scheme.onPrimaryFixedVariant,
                                titleLine1: l10n.homeFlashLine1,
                                titleLine2: l10n.homeFlashLine2,
                                rotation: -0.2,
                                buttons: [
                                  _MenuButtonData(
                                    label: l10n.homeExam,
                                    color: scheme.primary,
                                    onColor: scheme.onPrimary,
                                    onPressed: () =>
                                        context.push('/flash-level-menu'),
                                  ),
                                  _MenuButtonData(
                                    label: l10n.homeFree,
                                    color: scheme.primary,
                                    onColor: scheme.onPrimary,
                                    onPressed: () =>
                                        context.push('/flash-free-menu'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 24,
              left: 24,
              child: Row(
                spacing: 12,
                children: [
                  SettingsGearButton(),
                  NavigationButton(
                    onPressed: () => context.push('/credits'),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        l10n.credits,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: .w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButtonData {
  final String label;
  final Color color;
  final Color onColor;
  final VoidCallback onPressed;
  const _MenuButtonData({
    required this.label,
    required this.color,
    required this.onColor,
    required this.onPressed,
  });
}

class _MenuRow extends StatelessWidget {
  final double height;
  final Color background;
  final Color titleColor;
  final String titleLine1;
  final String titleLine2;
  final double rotation;
  final List<_MenuButtonData> buttons;

  const _MenuRow({
    required this.height,
    required this.background,
    required this.titleColor,
    required this.titleLine1,
    required this.titleLine2,
    required this.rotation,
    required this.buttons,
  });

  // Space reserved in the button row so nothing sits under the title.
  static const double _reservedWidth = 73;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: background,
            borderRadius: BorderRadius.circular(150),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(width: _reservedWidth), // invisible spacer
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: buttons
                          .map((b) => Expanded(child: _MenuButton(data: b)))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -18,
            top: 8,
            bottom: 0,
            width: 130,
            child: Center(
              child: Transform.rotate(
                angle: rotation,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 120,
                    height: 90,
                    child: StrokeText(
                      text: '$titleLine1\n$titleLine2',
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 42,
                        fontFamily: 'mPlus',
                        height: 1.05,
                        color: Colors.white,
                      ),
                      strokeColor: titleColor,
                      strokeWidth: 7,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final _MenuButtonData data;
  const _MenuButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return NavigationButton(
      color: data.color,
      borderRadius: BorderRadius.circular(80),
      onPressed: data.onPressed,
      child: Center(
        child: Text(
          data.label,
          textAlign: .center,
          style: TextStyle(
            fontSize: 32,
            color: data.onColor,
            fontFamily: 'mPlus',
          ),
        ),
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
          size: Size(MediaQuery.sizeOf(context).width, 250),
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
