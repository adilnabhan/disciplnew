import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/helpers/profile_reward_navigation_helper.dart';

/// Promotional dialog shown on Home screen offering points for uploading a profile photo.
class ProfilePhotoRewardPromoDialog extends StatelessWidget {
  const ProfilePhotoRewardPromoDialog({
    required this.completionData,
    required this.onDismissed,
    super.key,
  });

  final ProfileCompletionModel completionData;
  final VoidCallback onDismissed;

  static bool _isShowing = false;

  /// Returns whether the promo dialog is currently open.
  static bool get isShowing => _isShowing;

  /// Shows the promo dialog with single-instance and mounted checks.
  static Future<void> show(
    BuildContext context, {
    required ProfileCompletionModel completionData,
    required VoidCallback onDismissed,
  }) async {
    if (_isShowing || !context.mounted) return;
    _isShowing = true;

    try {
      final dismissable =
          completionData.profilePhotoReward?.popup?.dismissable ?? true;
      await showDialog<void>(
        context: context,
        barrierDismissible: dismissable,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        builder: (dialogCtx) => PopScope(
          canPop: dismissable,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              onDismissed();
            }
          },
          child: ProfilePhotoRewardPromoDialog(
            completionData: completionData,
            onDismissed: onDismissed,
          ),
        ),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = completionData.profilePhotoReward;
    final popup = reward?.popup;

    final title = popup?.title ?? 'Claim 100 Free Points! 🎁';
    final subtitle = popup?.subtitle ?? 'Add Your Profile Photo';
    final message = popup?.message ??
        'Upload your profile photo now and get 100 Discipl Score points credited directly to your score card!';
    final points = popup?.rewardPoints ?? reward?.rewardPoints ?? 100;
    final primaryCta = popup?.primaryButtonText ?? 'Upload Photo (+$points pts)';
    final secondaryCta = popup?.secondaryButtonText ?? 'Maybe Later';
    final isDismissable = popup?.dismissable ?? true;

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
                    // Top 3D Illustration
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Image.asset(
                        'assets/images/png/vectors/profile_photo_reward_illustration.jpg',
                        height: 185,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackIllustration(points),
                      ),
                    ),

                    // Title with highlighted points (e.g. Claim 100 Free Points! 🎁)
                    _buildHighlightedTitle(title, points),

                    const SizedBox(height: 6),

                    // Subtitle: Add Your Profile Photo
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFFE11D48),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description / Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3-Column Benefits
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildBenefitItem(
                              icon: Icons.person_rounded,
                              iconColor: const Color(0xFFE11D48),
                              bgColor: const Color(0xFFFFE4E6),
                              label: 'Show your\npersonality',
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            margin: const EdgeInsets.only(top: 4),
                            color: const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildBenefitItem(
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              bgColor: const Color(0xFFFEF3C7),
                              label: 'Earn\n$points points',
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            margin: const EdgeInsets.only(top: 4),
                            color: const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildBenefitItem(
                              icon: Icons.groups_rounded,
                              iconColor: const Color(0xFFE11D48),
                              bgColor: const Color(0xFFFFE4E6),
                              label: 'Connect with\nthe community',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Primary CTA: Vibrant Red Gradient Pill Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onDismissed();
                        ProfileRewardNavigationHelper.handleAction(
                          context,
                          action: popup?.action ?? 'open_profile_edit',
                          targetScreen: popup?.targetScreen ?? 'profile_edit',
                          targetRoute: popup?.targetRoute ?? '/profile',
                          autoOpenImagePicker: true,
                        );
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
                              color: const Color(0xFFE11D48).withValues(alpha: 0.38),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 18),
                            const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                primaryCta,
                                textAlign: TextAlign.center,
                                style: AppStyles.text15Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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

                    // Secondary CTA: Maybe Later (if dismissable)
                    if (isDismissable) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          onDismissed();
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
                              secondaryCta,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Top-Right Close Button
              if (isDismissable)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onDismissed();
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

  /// Builds the 3 benefit highlight columns.
  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppStyles.text11Px.poppins.w500.copyWith(
            color: const Color(0xFF334155),
            height: 1.25,
          ),
        ),
      ],
    );
  }

  /// Builds title with highlighted points in bold red.
  Widget _buildHighlightedTitle(String title, int points) {
    final pointsStr = '$points';

    if (title.contains(pointsStr)) {
      final parts = title.split(pointsStr);
      return Text.rich(
        TextSpan(
          text: parts.first,
          style: AppStyles.text22Px.poppins.w800.copyWith(
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
          children: [
            TextSpan(
              text: pointsStr,
              style: AppStyles.text22Px.poppins.w800.copyWith(
                color: const Color(0xFFE11D48),
                letterSpacing: -0.3,
              ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: parts.sublist(1).join(pointsStr),
                style: AppStyles.text22Px.poppins.w800.copyWith(
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppStyles.text22Px.poppins.w800.copyWith(
        color: const Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    );
  }

  /// Fallback illustration if image is missing.
  Widget _buildFallbackIllustration(int points) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF1F2),
        border: Border.all(color: const Color(0xFFFFE4E6), width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.account_circle_rounded,
            size: 80,
            color: Color(0xFFCBD5E1),
          ),
          Positioned(
            bottom: 12,
            right: 18,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
