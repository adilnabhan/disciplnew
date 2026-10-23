import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/helpers/profile_reward_navigation_helper.dart';

/// Celebratory dialog shown on Profile Edit screen only after the backend
/// authoritatively confirms that the profile photo reward was awarded.
class ProfilePhotoRewardSuccessDialog extends StatelessWidget {
  const ProfilePhotoRewardSuccessDialog({
    required this.reward,
    this.onViewScoreCard,
    this.onDone,
    super.key,
  });

  final ProfilePhotoRewardModel reward;
  final VoidCallback? onViewScoreCard;
  final VoidCallback? onDone;

  static bool _isShowing = false;

  /// Shows the success dialog once.
  static Future<void> show(
    BuildContext context, {
    required ProfilePhotoRewardModel reward,
    VoidCallback? onViewScoreCard,
    VoidCallback? onDone,
  }) async {
    if (_isShowing || !context.mounted) return;
    _isShowing = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.70),
        builder: (dialogCtx) => PopScope(
          canPop: false,
          child: ProfilePhotoRewardSuccessDialog(
            reward: reward,
            onViewScoreCard: onViewScoreCard,
            onDone: onDone,
          ),
        ),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = reward.title ?? 'Profile Photo Added! 🎉';
    final message = reward.message ??
        'You have earned ${reward.rewardPoints ?? 100} points for adding your profile photo!';
    final description = reward.description ??
        'Your profile photo is set and Discipl Score points have been credited to your score card.';
    final currentScore = reward.currentScore;
    final scoreAfterReward = reward.scoreAfterReward;

    final hasScoreIncrease = currentScore != null &&
        scoreAfterReward != null &&
        scoreAfterReward > currentScore;

    final displayScore = scoreAfterReward ?? currentScore ?? 140;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top 3D Celebration Illustration
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Image.asset(
                        'assets/images/png/vectors/profile_photo_reward_success_illustration.jpg',
                        height: 185,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackIllustration(),
                      ),
                    ),

                    // Title
                    Text(
                      title.replaceAll('! 🎉', '').trim(),
                      textAlign: TextAlign.center,
                      style: AppStyles.text22Px.poppins.w800.copyWith(
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle (Green celebratory message)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFF059669),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Discipl Score Card Panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFFE4E6),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Red Bar Chart Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE4E6),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.bar_chart_rounded,
                                color: Color(0xFFE11D48),
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Vertical Divider
                          Container(
                            height: 38,
                            width: 1,
                            color: const Color(0xFFF1F5F9),
                          ),

                          const SizedBox(width: 14),

                          // Score Label and Value
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Discipl Score',
                                  style:
                                      AppStyles.text12Px.poppins.w600.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (hasScoreIncrease)
                                  Row(
                                    children: [
                                      Text(
                                        '$currentScore',
                                        style: AppStyles.text15Px.poppins.w500
                                            .copyWith(
                                          color: const Color(0xFF94A3B8),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$scoreAfterReward pts',
                                        style: AppStyles.text20Px.poppins.w800
                                            .copyWith(
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '$displayScore pts',
                                    style: AppStyles.text20Px.poppins.w800
                                        .copyWith(
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Primary CTA: View Score Card (Red Gradient Pill Button)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onViewScoreCard != null) {
                          onViewScoreCard!();
                        } else {
                          ProfileRewardNavigationHelper.navigateToScoreCard(
                              context);
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE11D48),
                              Color(0xFFBE123C),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48)
                                  .withValues(alpha: 0.38),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'View Score Card',
                                textAlign: TextAlign.center,
                                style: AppStyles.text15Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Secondary CTA: Done (Outlined Pill Button)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onDone?.call();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Done',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top-Right Close Button
              Positioned(
                top: 14,
                right: 14,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onDone?.call();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback illustration if image is missing.
  Widget _buildFallbackIllustration() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 3),
      ),
      child: const Center(
        child: Icon(
          Icons.verified_rounded,
          size: 72,
          color: Color(0xFF10B981),
        ),
      ),
    );
  }
}
