import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_feedback_evaluator.dart';

export 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_feedback_evaluator.dart';

class WorkoutFeedbackBanner extends StatelessWidget {
  final WorkoutSetFeedbackResult feedback;

  const WorkoutFeedbackBanner({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final isStronger = feedback.type == WorkoutFeedbackType.stronger;

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon badge with pop/bounce animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isStronger
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: isStronger
                  ? Lottie.asset(
                      'assets/images/carousel_images/Fire.json',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFEA580C),
                            size: 18,
                          ),
                    )
                  : const Text(
                      '🎉',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // Feedback Text
          if (isStronger) ...[
            const Expanded(
              child: Text(
                'Stronger than last time',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
            if (feedback.percentage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF065F46),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedback.percentage!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'First time!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    'Great start',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
