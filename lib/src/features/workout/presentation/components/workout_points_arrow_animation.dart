import 'package:flutter/material.dart';
import 'package:customer_mobile_app/core/themes/app_colors.dart';
import 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_points_helper.dart';

/// Red Upward Arrow widget matching the design from uploaded mock
class WorkoutPointsArrowWidget extends StatelessWidget {
  final int points;
  final double arrowWidth;
  final double arrowHeight;
  final Color arrowColor;
  final TextStyle? pointsTextStyle;

  const WorkoutPointsArrowWidget({
    super.key,
    required this.points,
    this.arrowWidth = 84,
    this.arrowHeight = 114,
    this.arrowColor = const Color(0xFFBA1A1A),
    this.pointsTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(arrowWidth, arrowHeight),
          painter: _RedArrowPainter(color: arrowColor),
        ),
        const SizedBox(height: 12),
        Text(
          '+$points points',
          style: pointsTextStyle ??
              TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: arrowColor,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}

class _RedArrowPainter extends CustomPainter {
  final Color color;

  const _RedArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    final headBottom = h * 0.48;
    final shaftWidth = w * 0.32;
    final shaftLeft = (w - shaftWidth) / 2;
    final shaftRight = shaftLeft + shaftWidth;

    final path = Path();
    // Rounded apex
    final apexRadius = w * 0.10;
    path.moveTo(w / 2 - apexRadius, apexRadius * 1.1);
    path.quadraticBezierTo(w / 2, 0, w / 2 + apexRadius, apexRadius * 1.1);

    // Line to right fin tip
    path.lineTo(w - 6, headBottom - 5);
    path.quadraticBezierTo(w, headBottom, w - 8, headBottom + 3);

    // Inset to right side of shaft
    path.lineTo(shaftRight, headBottom);

    // Right shaft downwards
    final bottomCorner = shaftWidth * 0.35;
    path.lineTo(shaftRight, h - bottomCorner);
    path.quadraticBezierTo(shaftRight, h, shaftRight - bottomCorner, h);

    // Bottom shaft edge
    path.lineTo(shaftLeft + bottomCorner, h);
    path.quadraticBezierTo(shaftLeft, h, shaftLeft, h - bottomCorner);

    // Left shaft upwards
    path.lineTo(shaftLeft, headBottom);

    // Outset to left fin tip
    path.lineTo(8, headBottom + 3);
    path.quadraticBezierTo(0, headBottom, 6, headBottom - 5);

    path.close();

    // Subtle drop shadow for elevation
    canvas.drawShadow(
      path,
      color.withValues(alpha: 0.35),
      8.0,
      false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RedArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Fullscreen or card overlay animating the red arrow up from the bottom
class WorkoutPointsRisingOverlay extends StatefulWidget {
  final WorkoutPointsBreakdown breakdown;
  final VoidCallback? onDismiss;

  const WorkoutPointsRisingOverlay({
    super.key,
    required this.breakdown,
    this.onDismiss,
  });

  @override
  State<WorkoutPointsRisingOverlay> createState() =>
      _WorkoutPointsRisingOverlayState();
}

class _WorkoutPointsRisingOverlayState
    extends State<WorkoutPointsRisingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Rising from bottom upwards
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();

    // Auto dismiss after animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.breakdown.hasPoints) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        _controller.stop();
        widget.onDismiss?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slideY = _slideAnimation.value * (size.height * 0.55);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0, slideY),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: WorkoutPointsArrowWidget(
                    points: widget.breakdown.totalPoints,
                    arrowWidth: 104,
                    arrowHeight: 142,
                    arrowColor: const Color(0xFFBA1A1A),
                    pointsTextStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBA1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
