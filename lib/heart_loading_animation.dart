import 'dart:math' as math;
import 'package:flutter/material.dart';

// --- New loading heart and bubbles animation widget ---
// A decorative heart animation with floating bubbles used on the counter screen.
class HeartLoadingAnimation extends StatefulWidget {
  const HeartLoadingAnimation({super.key});

  @override
  State<HeartLoadingAnimation> createState() => _HeartLoadingAnimationState();
}

class _HeartLoadingAnimationState extends State<HeartLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _bubbleController;
  final List<_Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // Controller for the heart fill animation (up-down loop)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Controller for bubble updates
    _bubbleController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(_updateBubbles)
          ..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _updateBubbles() {
    // Chance to create a new bubble on each frame.
    if (_random.nextDouble() < 0.08 && _bubbles.length < 25) {
      _bubbles.add(
        _Bubble(
          x: _random.nextDouble() * 160 - 80, // Spread around the heart
          y: 100, // Start below the heart
          size: _random.nextDouble() * 8 + 4,
          speed: _random.nextDouble() * 1.5 + 0.8,
          isHeartShape: _random.nextBool(),
          opacity: _random.nextDouble() * 0.4 + 0.3,
        ),
      );
    }

    // Update positions and remove bubbles that flew out.
    for (int i = _bubbles.length - 1; i >= 0; i--) {
      _bubbles[i].y -= _bubbles[i].speed;
      // Subtle side-to-side drifting.
      _bubbles[i].x += math.sin(_bubbles[i].y / 10) * 0.3;

      if (_bubbles[i].y < -120) {
        _bubbles.removeAt(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Render flying bubbles from bottom to top.
        ..._bubbles.map((bubble) {
          return Positioned(
            bottom: bubble.y,
            left:
                MediaQuery.of(context).size.width / 2 +
                bubble.x -
                (bubble.size / 2) -
                24,
            child: Opacity(
              opacity: bubble.opacity,
              child: Icon(
                bubble.isHeartShape ? Icons.favorite : Icons.circle,
                size: bubble.size,
                color: const Color(0xFFFA709A),
              ),
            ),
          );
        }),
        // Main loading heart.
        AnimatedBuilder(
          animation: _loadingController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: const [Color(0xFFFA709A), Colors.white10],
                  stops: [
                    _loadingController.value,
                    _loadingController.value + 0.1,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Icon(
                Icons.favorite,
                size: 130,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Internal model for a floating bubble in the heart animation.
class _Bubble {
  double x;
  double y;
  final double size;
  final double speed;
  final bool isHeartShape;
  final double opacity;

  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.isHeartShape,
    required this.opacity,
  });
}
