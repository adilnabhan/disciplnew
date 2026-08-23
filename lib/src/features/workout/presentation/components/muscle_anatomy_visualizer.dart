import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

enum MuscleGroupTarget {
  chest,
  upperBack,
  lats,
  shoulders,
  biceps,
  triceps,
  abs,
  quadriceps,
  hamstrings,
  calves,
  fullBody,
}

class MuscleAnatomyVisualizer extends StatefulWidget {
  const MuscleAnatomyVisualizer({
    super.key,
    this.primaryMuscles = const [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders, MuscleGroupTarget.quadriceps],
    this.secondaryMuscles = const [MuscleGroupTarget.triceps, MuscleGroupTarget.abs],
    this.width = 130,
    this.height = 160,
    this.isAnimated = true,
  });

  final List<MuscleGroupTarget> primaryMuscles;
  final List<MuscleGroupTarget> secondaryMuscles;
  final double width;
  final double height;
  final bool isAnimated;

  @override
  State<MuscleAnatomyVisualizer> createState() => _MuscleAnatomyVisualizerState();
}

class _MuscleAnatomyVisualizerState extends State<MuscleAnatomyVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _AnatomyPainter(
            primaryMuscles: widget.primaryMuscles,
            secondaryMuscles: widget.secondaryMuscles,
            pulseFactor: widget.isAnimated ? _pulseAnimation.value : 1.0,
          ),
        );
      },
    );
  }
}

class _AnatomyPainter extends CustomPainter {
  _AnatomyPainter({
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.pulseFactor,
  });

  final List<MuscleGroupTarget> primaryMuscles;
  final List<MuscleGroupTarget> secondaryMuscles;
  final double pulseFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 120.0;
    final double scaleY = size.height / 150.0;

    final Paint bodyBasePaint = Paint()
      ..color = const Color(0xFF262633)
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF3D3D4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint goldHighlightPaint = Paint()
      ..color = CyberWorkoutTheme.goldPrimary.withOpacity(0.85 * pulseFactor)
      ..style = PaintingStyle.fill;

    final Paint redHighlightPaint = Paint()
      ..color = CyberWorkoutTheme.crimsonRed.withOpacity(0.9 * pulseFactor)
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()
      ..color = CyberWorkoutTheme.goldPrimary.withOpacity(0.3 * pulseFactor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final double cx = size.width / 2;

    // 1. Head
    canvas.drawCircle(Offset(cx, 16 * scaleY), 10 * scaleX, bodyBasePaint);
    canvas.drawCircle(Offset(cx, 16 * scaleY), 10 * scaleX, outlinePaint);

    // 2. Neck & Traps
    final Path neckPath = Path()
      ..moveTo(cx - 6 * scaleX, 24 * scaleY)
      ..lineTo(cx + 6 * scaleX, 24 * scaleY)
      ..lineTo(cx + 16 * scaleX, 32 * scaleY)
      ..lineTo(cx - 16 * scaleX, 32 * scaleY)
      ..close();
    canvas.drawPath(neckPath, bodyBasePaint);

    // 3. Shoulders (Deltoids)
    final bool shouldersActive = primaryMuscles.contains(MuscleGroupTarget.shoulders) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint shoulderPaint = shouldersActive ? redHighlightPaint : bodyBasePaint;

    // Left Deltoid
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 24 * scaleX, 38 * scaleY), width: 14 * scaleX, height: 16 * scaleY),
      shouldersActive ? glowPaint : bodyBasePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 24 * scaleX, 38 * scaleY), width: 14 * scaleX, height: 16 * scaleY),
      shoulderPaint,
    );

    // Right Deltoid
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 24 * scaleX, 38 * scaleY), width: 14 * scaleX, height: 16 * scaleY),
      shouldersActive ? glowPaint : bodyBasePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 24 * scaleX, 38 * scaleY), width: 14 * scaleX, height: 16 * scaleY),
      shoulderPaint,
    );

    // 4. Chest (Pectorals)
    final bool chestActive = primaryMuscles.contains(MuscleGroupTarget.chest) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint chestPaint = chestActive ? goldHighlightPaint : bodyBasePaint;

    final Path leftPec = Path()
      ..moveTo(cx - 2 * scaleX, 35 * scaleY)
      ..lineTo(cx - 18 * scaleX, 35 * scaleY)
      ..quadraticBezierTo(cx - 18 * scaleX, 50 * scaleY, cx - 2 * scaleX, 48 * scaleY)
      ..close();
    if (chestActive) canvas.drawPath(leftPec, glowPaint);
    canvas.drawPath(leftPec, chestPaint);

    final Path rightPec = Path()
      ..moveTo(cx + 2 * scaleX, 35 * scaleY)
      ..lineTo(cx + 18 * scaleX, 35 * scaleY)
      ..quadraticBezierTo(cx + 18 * scaleX, 50 * scaleY, cx + 2 * scaleX, 48 * scaleY)
      ..close();
    if (chestActive) canvas.drawPath(rightPec, glowPaint);
    canvas.drawPath(rightPec, chestPaint);

    // 5. Abdominals / Core
    final bool absActive = primaryMuscles.contains(MuscleGroupTarget.abs) ||
        secondaryMuscles.contains(MuscleGroupTarget.abs) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint absPaint = absActive
        ? (primaryMuscles.contains(MuscleGroupTarget.abs) ? redHighlightPaint : goldHighlightPaint)
        : bodyBasePaint;

    for (int i = 0; i < 3; i++) {
      final double yOff = (52 + i * 8) * scaleY;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx - 6 * scaleX, yOff), width: 8 * scaleX, height: 6 * scaleY),
          const Radius.circular(2),
        ),
        absPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx + 6 * scaleX, yOff), width: 8 * scaleX, height: 6 * scaleY),
          const Radius.circular(2),
        ),
        absPaint,
      );
    }

    // 6. Arms (Biceps/Triceps/Forearms)
    final bool armsActive = primaryMuscles.contains(MuscleGroupTarget.biceps) ||
        primaryMuscles.contains(MuscleGroupTarget.triceps) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint armPaint = armsActive ? goldHighlightPaint : bodyBasePaint;

    // Left Arm
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 28 * scaleX, 56 * scaleY), width: 10 * scaleX, height: 20 * scaleY),
      armPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 30 * scaleX, 78 * scaleY), width: 8 * scaleX, height: 22 * scaleY),
      armPaint,
    );

    // Right Arm
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 28 * scaleX, 56 * scaleY), width: 10 * scaleX, height: 20 * scaleY),
      armPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 30 * scaleX, 78 * scaleY), width: 8 * scaleX, height: 22 * scaleY),
      armPaint,
    );

    // 7. Quadriceps (Thighs)
    final bool quadActive = primaryMuscles.contains(MuscleGroupTarget.quadriceps) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint quadPaint = quadActive ? goldHighlightPaint : bodyBasePaint;

    // Left Quad
    final Path leftQuad = Path()
      ..moveTo(cx - 4 * scaleX, 80 * scaleY)
      ..lineTo(cx - 20 * scaleX, 80 * scaleY)
      ..lineTo(cx - 15 * scaleX, 115 * scaleY)
      ..lineTo(cx - 5 * scaleX, 115 * scaleY)
      ..close();
    if (quadActive) canvas.drawPath(leftQuad, glowPaint);
    canvas.drawPath(leftQuad, quadPaint);

    // Right Quad
    final Path rightQuad = Path()
      ..moveTo(cx + 4 * scaleX, 80 * scaleY)
      ..lineTo(cx + 20 * scaleX, 80 * scaleY)
      ..lineTo(cx + 15 * scaleX, 115 * scaleY)
      ..lineTo(cx + 5 * scaleX, 115 * scaleY)
      ..close();
    if (quadActive) canvas.drawPath(rightQuad, glowPaint);
    canvas.drawPath(rightQuad, quadPaint);

    // 8. Calves
    final bool calvesActive = primaryMuscles.contains(MuscleGroupTarget.calves) ||
        primaryMuscles.contains(MuscleGroupTarget.fullBody);
    final Paint calfPaint = calvesActive ? goldHighlightPaint : bodyBasePaint;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 10 * scaleX, 132 * scaleY), width: 8 * scaleX, height: 22 * scaleY),
      calfPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 10 * scaleX, 132 * scaleY), width: 8 * scaleX, height: 22 * scaleY),
      calfPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnatomyPainter oldDelegate) {
    return oldDelegate.pulseFactor != pulseFactor ||
        oldDelegate.primaryMuscles != primaryMuscles ||
        oldDelegate.secondaryMuscles != secondaryMuscles;
  }
}
