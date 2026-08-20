import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

/// Modular Onam Seasonal Achievement Celebration
class OnamAchievementCelebration extends StatefulWidget {
  final Widget childCard;
  final Widget shareSection;
  final Widget doneButton;
  final VoidCallback onBack;

  const OnamAchievementCelebration({
    required this.childCard,
    required this.shareSection,
    required this.doneButton,
    required this.onBack,
    super.key,
  });

  @override
  State<OnamAchievementCelebration> createState() =>
      _OnamAchievementCelebrationState();
}

class _OnamAchievementCelebrationState
    extends State<OnamAchievementCelebration>
    with TickerProviderStateMixin {
  AnimationController? _mainController;
  AnimationController? _petalsController;
  AnimationController? _pookalamController;
  AnimationController? _floatController;

  // Staggered Animations
  Animation<double>? _maveliScale;
  Animation<double>? _maveliFade;
  Animation<double>? _maveliFloat;
  Animation<double>? _textFade;
  Animation<Offset>? _textSlide;
  Animation<double>? _cardFade;
  Animation<Offset>? _cardSlide;
  Animation<double>? _bottomFade;
  Animation<Offset>? _bottomSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _mainController?.forward(from: 0.0);

    // Trigger single-pass flower shower starting at 0.5s
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _petalsController?.forward(from: 0.0);
      }
    });
  }

  void _initAnimations() {
    _mainController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (_petalsController == null) {
      _petalsController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      );
      _petalsController!.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {});
        }
      });
    }

    _pookalamController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _floatController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _maveliScale ??= Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.10, 0.40, curve: Curves.easeOutBack),
      ),
    );

    _maveliFade ??= Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.10, 0.40, curve: Curves.easeIn),
      ),
    );

    _maveliFloat ??= Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController!,
        curve: Curves.easeInOut,
      ),
    );

    _textFade ??= Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.40, 0.60, curve: Curves.easeOut),
      ),
    );

    _textSlide ??= Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.40, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _cardFade ??= Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
      ),
    );

    _cardSlide ??= Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _bottomFade ??= Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
      ),
    );

    _bottomSlide ??= Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _mainController?.dispose();
    _petalsController?.dispose();
    _pookalamController?.dispose();
    _floatController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();

    final maveliScaleAnim = _maveliScale ?? const AlwaysStoppedAnimation(1.0);
    final maveliFadeAnim = _maveliFade ?? const AlwaysStoppedAnimation(1.0);
    final maveliFloatAnim = _maveliFloat ?? const AlwaysStoppedAnimation(0.0);
    final textFadeAnim = _textFade ?? const AlwaysStoppedAnimation(1.0);
    final textSlideAnim = _textSlide ?? const AlwaysStoppedAnimation(Offset.zero);
    final cardFadeAnim = _cardFade ?? const AlwaysStoppedAnimation(1.0);
    final cardSlideAnim = _cardSlide ?? const AlwaysStoppedAnimation(Offset.zero);
    final bottomFadeAnim = _bottomFade ?? const AlwaysStoppedAnimation(1.0);
    final bottomSlideAnim = _bottomSlide ?? const AlwaysStoppedAnimation(Offset.zero);

    return Stack(
      children: [
        // Scrollable Content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF444444),
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Maveli Animation + Soft Pookalam Background
              Center(
                child: MaveliAnimation(
                  scaleAnimation: maveliScaleAnim,
                  fadeAnimation: maveliFadeAnim,
                  floatAnimation: maveliFloatAnim,
                  pookalamController: _pookalamController,
                ),
              ),

              const SizedBox(height: 8),

              // Success Text Animation
              SuccessTextAnimation(
                fadeAnimation: textFadeAnim,
                slideAnimation: textSlideAnim,
              ),

              const SizedBox(height: 12),

              // Workout Card Animation
              WorkoutCardAnimation(
                fadeAnimation: cardFadeAnim,
                slideAnimation: cardSlideAnim,
                childCard: widget.childCard,
              ),

              const SizedBox(height: 16),

              // Bottom Section Animation (Share & Done Buttons)
              FadeTransition(
                opacity: bottomFadeAnim,
                child: SlideTransition(
                  position: bottomSlideAnim,
                  child: Column(
                    children: [
                      widget.shareSection,
                      const SizedBox(height: 20),
                      widget.doneButton,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),

        // Falling Petals Animation (Top Layer)
        Positioned.fill(
          child: FallingPetalsWidget(controller: _petalsController),
        ),
      ],
    );
  }
}

/// Fitness Maveli Entrance Animation & Rotating Pookalam Background Pattern
class MaveliAnimation extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> floatAnimation;
  final AnimationController? pookalamController;

  const MaveliAnimation({
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.floatAnimation,
    this.pookalamController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final listenables = [scaleAnimation, fadeAnimation, floatAnimation];
    if (pookalamController != null) listenables.add(pookalamController!);

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, child) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SizedBox(
              width: 250,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating soft circular pookalam background (5-8% opacity)
                  if (pookalamController != null)
                    RotationTransition(
                      turns: pookalamController!,
                      child: const SoftPookalamBackground(),
                    )
                  else
                    const SoftPookalamBackground(),

                  // Floating Fitness Maveli Image
                  Transform.translate(
                    offset: Offset(0, floatAnimation.value),
                    child: Image.asset(
                      'assets/images/png/vectors/maveli_achievement_page.png',
                      width: 230,
                      height: 230,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Lottie.asset(
                        'assets/images/svg/vectors/thumbsUp_achievement.json',
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Subtle Circular Pookalam Background
class SoftPookalamBackground extends StatelessWidget {
  const SoftPookalamBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: _PookalamPainter(),
    );
  }
}

class _PookalamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final ringPaint = Paint()
      ..color = const Color(0xFFD32F2F).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Concentric delicate pookalam rings
    canvas.drawCircle(center, radius * 0.95, ringPaint);
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.55, ringPaint);

    // Soft floral radial spokes (12 petals pattern)
    final petalPaint = Paint()
      ..color = const Color(0xFFFBC02D).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(radius * 0.65, 0),
          width: radius * 0.35,
          height: radius * 0.18,
        ),
        petalPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Success Text Entrance Animation
class SuccessTextAnimation extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const SuccessTextAnimation({
    required this.fadeAnimation,
    required this.slideAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            Text(
              'Good Job!',
              style: AppStyles.text24Px.poppins.w700.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Workout Completed',
              style: AppStyles.text16Px.poppins.w500.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workout Card Entrance Animation
class WorkoutCardAnimation extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget childCard;

  const WorkoutCardAnimation({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.childCard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: childCard,
      ),
    );
  }
}

/// Onam Falling Flower Petals Widget
class FallingPetalsWidget extends StatelessWidget {
  final AnimationController? controller;

  const FallingPetalsWidget({
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    if (activeController == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: activeController,
        builder: (context, child) {
          if (activeController.value <= 0.0 || activeController.value >= 1.0) {
            return const SizedBox.shrink();
          }
          return CustomPaint(
            painter: _OnamPetalsPainter(progress: activeController.value),
          );
        },
      ),
    );
  }
}

enum _FlowerType { marigold, jasmine, rose, singlePetal }

class _PetalItem {
  final double? xRatio;
  final double? size;
  final Color? color;
  final double? rotationSpeed;
  final double? driftAmplitude;
  final double? driftFrequency;
  final double? fallDelay;
  final double? initialAngle;
  final _FlowerType? flowerType;

  const _PetalItem({
    this.xRatio = 0.5,
    this.size = 14.0,
    this.color = const Color(0xFFFF8F00),
    this.rotationSpeed = 1.0,
    this.driftAmplitude = 3.0,
    this.driftFrequency = 1.0,
    this.fallDelay = 0.0,
    this.initialAngle = 0.0,
    this.flowerType = _FlowerType.singlePetal,
  });
}

class _OnamPetalsPainter extends CustomPainter {
  final double progress;

  static List<_PetalItem>? _staticPetalsCache;

  static List<_PetalItem> get _staticPetals {
    _staticPetalsCache ??= _generatePetals();
    return _staticPetalsCache!;
  }

  static List<_PetalItem> _generatePetals() {
    final random = math.Random(108);
    const colors = [
      Color(0xFFFF8F00), // Rich Marigold Orange
      Color(0xFFFFC107), // Golden Yellow
      Color(0xFFFFFFFF), // Jasmine White
      Color(0xFFE53935), // Deep Chetti Red
      Color(0xFFFF6F00), // Deep Marigold Orange
      Color(0xFFFFD54F), // Bright Yellow
      Color(0xFFFB8C00), // Vibrant Amber
    ];

    // Scattered X ratios across screen width
    final xPositions = [0.08, 0.65, 0.32, 0.86, 0.18, 0.48, 0.76, 0.24, 0.92, 0.40, 0.14, 0.58, 0.82, 0.28, 0.70, 0.44];

    return List.generate(16, (index) {
      final flowerType = index % 4 == 0
          ? _FlowerType.marigold
          : (index % 4 == 1
              ? _FlowerType.jasmine
              : (index % 4 == 2 ? _FlowerType.rose : _FlowerType.singlePetal));

      final xPos = xPositions[index % xPositions.length] + (random.nextDouble() * 0.03 - 0.015);

      return _PetalItem(
        xRatio: xPos.clamp(0.04, 0.94),
        size: flowerType == _FlowerType.marigold
            ? 16.0 + random.nextDouble() * 5.0
            : (flowerType == _FlowerType.jasmine
                ? 13.0 + random.nextDouble() * 4.0
                : (flowerType == _FlowerType.rose
                    ? 14.0 + random.nextDouble() * 5.0
                    : 11.0 + random.nextDouble() * 5.0)),
        color: colors[(index * 2) % colors.length],
        rotationSpeed: (random.nextDouble() - 0.5) * 2.5,
        driftAmplitude: random.nextDouble() * 4.0, // Micro drift for straight top-to-bottom fall
        driftFrequency: 0.8 + random.nextDouble() * 0.8,
        fallDelay: (index % 6) * 0.05 + (random.nextDouble() * 0.02), // Staggered entry without forming horizontal line
        initialAngle: random.nextDouble() * math.pi * 2,
        flowerType: flowerType,
      );
    });
  }

  _OnamPetalsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    for (final petal in _staticPetals) {
      final fallDelay = petal.fallDelay ?? 0.0;
      final driftFrequency = petal.driftFrequency ?? 1.0;
      final driftAmplitude = petal.driftAmplitude ?? 3.0;
      final xRatio = petal.xRatio ?? 0.5;
      final initialAngle = petal.initialAngle ?? 0.0;
      final rotationSpeed = petal.rotationSpeed ?? 1.0;
      final petalSize = petal.size ?? 14.0;
      final petalColor = petal.color ?? const Color(0xFFFF8F00);

      if (progress < fallDelay) continue;
      final rawT = (progress - fallDelay) / (1.0 - fallDelay);
      final t = rawT.clamp(0.0, 1.0);

      // Direct straight vertical movement from top to completely below screen bottom
      final startY = -50.0;
      final endY = size.height + 80.0;
      final currentY = startY + (endY - startY) * t;

      // Straight top-to-bottom X position with micro wiggle
      final startX = size.width * xRatio;
      final drift = math.sin(t * math.pi * driftFrequency) * driftAmplitude;
      final currentX = startX + drift;

      // Slow rotation
      final currentRotation = initialAngle + (t * rotationSpeed);

      // Fade out smoothly well before lower screen area (Done button)
      double opacity = 1.0;
      if (t < 0.08) {
        opacity = t / 0.08;
      } else if (t > 0.45) {
        opacity = (0.70 - t) / 0.25;
      }
      opacity = opacity.clamp(0.0, 1.0);

      if (opacity <= 0.0) continue;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      final paint = Paint()
        ..color = petalColor.withValues(alpha: opacity * 0.95)
        ..style = PaintingStyle.fill;

      final activeFlowerType = petal.flowerType ?? _FlowerType.singlePetal;

      if (activeFlowerType == _FlowerType.marigold) {
        // High Quality Dual-Layer 8-Petal Marigold
        final radius = petalSize / 2;
        for (int i = 0; i < 8; i++) {
          final angle = i * (math.pi / 4);
          canvas.save();
          canvas.rotate(angle);
          final petalPath = Path();
          petalPath.moveTo(0, 0);
          petalPath.cubicTo(
            radius * 0.45,
            -radius * 0.5,
            radius * 0.45,
            -radius * 1.15,
            0,
            -radius * 1.25,
          );
          petalPath.cubicTo(
            -radius * 0.45,
            -radius * 1.15,
            -radius * 0.45,
            -radius * 0.5,
            0,
            0,
          );
          canvas.drawPath(petalPath, paint);
          canvas.restore();
        }
        // Inner Petals Layer
        final innerPaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: opacity * 0.9)
          ..style = PaintingStyle.fill;
        for (int i = 0; i < 4; i++) {
          final angle = (i * (math.pi / 2)) + (math.pi / 8);
          canvas.save();
          canvas.rotate(angle);
          final innerPath = Path();
          innerPath.moveTo(0, 0);
          innerPath.cubicTo(
            radius * 0.3,
            -radius * 0.35,
            radius * 0.3,
            -radius * 0.75,
            0,
            -radius * 0.85,
          );
          innerPath.cubicTo(
            -radius * 0.3,
            -radius * 0.75,
            -radius * 0.3,
            -radius * 0.35,
            0,
            0,
          );
          canvas.drawPath(innerPath, innerPaint);
          canvas.restore();
        }
        // Core Center Cluster
        final corePaint = Paint()
          ..color = const Color(0xFFD84315).withValues(alpha: opacity * 0.95)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, radius * 0.32, corePaint);
      } else if (activeFlowerType == _FlowerType.jasmine) {
        // High Quality 5-Petal White Jasmine Blossom
        final radius = petalSize / 2;
        final jasminePaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.96)
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = const Color(0xFFFFB74D).withValues(alpha: opacity * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

        for (int i = 0; i < 5; i++) {
          final angle = i * (math.pi * 2 / 5);
          canvas.save();
          canvas.rotate(angle);
          final petalPath = Path();
          petalPath.moveTo(0, 0);
          petalPath.cubicTo(
            radius * 0.35,
            -radius * 0.4,
            radius * 0.3,
            -radius * 1.05,
            0,
            -radius * 1.3,
          );
          petalPath.cubicTo(
            -radius * 0.3,
            -radius * 1.05,
            -radius * 0.35,
            -radius * 0.4,
            0,
            0,
          );
          canvas.drawPath(petalPath, jasminePaint);
          canvas.drawPath(petalPath, strokePaint);
          canvas.restore();
        }
        // Golden Center Core
        final corePaint = Paint()
          ..color = const Color(0xFFFFB300).withValues(alpha: opacity * 0.95)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, radius * 0.28, corePaint);
      } else if (activeFlowerType == _FlowerType.rose) {
        // Chetti / Red Rose Pookalam Flower
        final radius = petalSize / 2;
        final rosePaint = Paint()
          ..color = const Color(0xFFE53935).withValues(alpha: opacity * 0.94)
          ..style = PaintingStyle.fill;
        for (int i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          canvas.save();
          canvas.rotate(angle);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(radius * 0.5, 0),
              width: radius * 0.9,
              height: radius * 0.55,
            ),
            rosePaint,
          );
          canvas.restore();
        }
        // Gold Center Core
        final corePaint = Paint()
          ..color = const Color(0xFFFFC107).withValues(alpha: opacity * 0.95)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, radius * 0.35, corePaint);
      } else {
        // Detailed Organic Teardrop Petal
        final pSize = petalSize;
        final path = Path();
        path.moveTo(0, -pSize * 0.65);
        path.cubicTo(
          pSize * 0.55,
          -pSize * 0.35,
          pSize * 0.5,
          pSize * 0.35,
          0,
          pSize * 0.55,
        );
        path.cubicTo(
          -pSize * 0.5,
          pSize * 0.35,
          -pSize * 0.55,
          -pSize * 0.35,
          0,
          -pSize * 0.65,
        );
        path.close();

        canvas.drawPath(path, paint);

        // Subtle center leaf vein stroke
        final veinPaint = Paint()
          ..color = Colors.black.withValues(alpha: opacity * 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9;
        final veinPath = Path();
        veinPath.moveTo(0, -pSize * 0.45);
        veinPath.lineTo(0, pSize * 0.35);
        canvas.drawPath(veinPath, veinPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is _OnamPetalsPainter && oldDelegate.progress != progress;
  }
}
