import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/cubit/profile_completion/profile_completion_cubit.dart';
import 'package:customer_mobile_app/src/features/profile/domain/helpers/profile_photo_reward_helper.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/helpers/profile_reward_navigation_helper.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/profile_photo_reward_promo_dialog.dart';

/// Reusable reward banner displayed when `profile_photo_reward.banner.should_show == true`.
class ProfilePhotoRewardBanner extends StatelessWidget {
  const ProfilePhotoRewardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
      builder: (context, state) {
        final data = state.data;
        final shouldShow = ProfilePhotoRewardHelper.shouldShowRewardBanner(
          data,
          isPopupVisible: ProfilePhotoRewardPromoDialog.isShowing,
          isDismissedLocally: state.isRewardBannerDismissedLocally,
        );

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        final banner = data!.profilePhotoReward!.banner!;
        final title = banner.title ?? 'Profile Photo Added';
        final message = banner.message ?? 'Earn points for adding a photo!';
        final badgeText = banner.badgeText ?? '+100 PTS';
        final buttonText = banner.buttonText ?? 'View Profile';
        final dismissable = banner.dismissable ?? true;

        return Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFED7AA),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFFEA580C),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppStyles.text13Px.poppins.w600.copyWith(
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Button
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      ProfileRewardNavigationHelper.handleAction(
                        context,
                        action: banner.action ?? 'open_profile_edit',
                        targetScreen: banner.targetScreen ?? 'profile_edit',
                        targetRoute: banner.targetRoute ?? '/profile',
                        autoOpenImagePicker: true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Close Button if dismissable
                if (dismissable) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      context
                          .read<ProfileCompletionCubit>()
                          .dismissRewardBanner();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
