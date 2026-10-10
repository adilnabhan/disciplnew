import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_feedback_evaluator.dart';

export 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_feedback_evaluator.dart';

/// Workout feedback banner matching the pill design with an interior green glow
class WorkoutFeedbackBanner extends StatelessWidget {
  final WorkoutSetFeedbackResult feedback;
  final String? customText;
  final VoidCallback? onDismiss;

  const WorkoutFeedbackBanner({
    super.key,
    required this.feedback,
    this.customText,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    const double baseFontSize = 17.5;
    const double percentageFontSize = 19.0;

    Widget textContent;
    if (customText != null && customText!.isNotEmpty) {
      textContent = Text(
        customText!,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: baseFontSize,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E2022),
          height: 1.2,
        ),
      );
    } else if (feedback.type == WorkoutFeedbackType.stronger) {
      if (feedback.percentage != null && feedback.percentage!.isNotEmpty) {
        textContent = RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: baseFontSize,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2022),
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Stronger than last time! '),
              TextSpan(
                text: feedback.percentage!,
                style: const TextStyle(
                  color: Color(0xFF047857),
                  fontSize: percentageFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      } else {
        textContent = const Text(
          'Stronger than last time! 🔥',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: baseFontSize,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E2022),
            height: 1.2,
          ),
        );
      }
    } else {
      textContent = const Text(
        'First time! Great start 👏',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: baseFontSize,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E2022),
          height: 1.2,
        ),
      );
    }

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Interior green glow spreading horizontally across the card
            Positioned.fill(
              child: CustomPaint(painter: _BannerGreenGlowPainter()),
            ),
            // Celebration confetti burst animation
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/images/carousel_images/Workout_feedback.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            ),
            // Centered Mascot and Feedback text
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: Lottie.asset(
                        'assets/images/svg/vectors/thumbsUp_achievement.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: textContent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerGreenGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center glow horizontally across the card
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    canvas.translate(centerX, centerY);

    final verticalRadius = size.height * 1.15;
    final horizontalRadius = size.width * 0.58;
    final scaleX = horizontalRadius / verticalRadius;

    canvas.scale(scaleX, 1.0);

    final paint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF86FF1E).withValues(alpha: 0.52),
              const Color(0xFFA1FF4A).withValues(alpha: 0.40),
              const Color(0xFFC4FF86).withValues(alpha: 0.25),
              const Color(0xFFE4FFBC).withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.35, 0.65, 0.88, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset.zero, radius: verticalRadius),
          );

    canvas.drawCircle(Offset.zero, verticalRadius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
