import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/widgets/shimmers/k_shimmer.dart';
import 'package:customer_mobile_app/src/features/profile/cubit/profile_completion/profile_completion_cubit.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';

class ProfileCompletionBanner extends StatelessWidget {
  const ProfileCompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
      builder: (context, state) {
        final data = state.data;
        final isDismissed =
            state.isDismissedLocally ||
            (data != null && (data.dismissed || data.isCompleted));

        // 1. If banner was dismissed locally or on backend, or completed, stay completely hidden
        if (isDismissed) {
          return const SizedBox.shrink();
        }

        // 2. Loading State: Render Shimmer Placeholder only on initial load when no data is present
        if (state.isLoading && data == null) {
          return const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
            child: KShimmer(
              height: 120,
              radius: 14,
            ),
          );
        }

        final shouldShow = data != null && !data.isCompleted && !data.dismissed;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: shouldShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: shouldShow
                ? _buildBannerContent(context, data)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildBannerContent(BuildContext context, ProfileCompletionModel data) {
    final missing = data.missingFields;
    const displayLimit = 2;
    final visibleMissing = missing.take(displayLimit).toList();
    final extraCount = missing.length > displayLimit ? missing.length - displayLimit : 0;
    final percentage = data.completionPercentage.clamp(0, 100).toDouble();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header: Title + Percentage Badge + Dismiss (X)
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.title.contains('✨') ? data.title : '✨ ${data.title}',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${data.completionPercentage}%',
                  style: AppStyles.text13Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    context.read<ProfileCompletionCubit>().dismissBanner();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Animated Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: percentage / 100),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFFFECEF),
                    color: AppColors.primary,
                  );
                },
              ),
            ),

            // Compact Inline Missing Fields line (if any)
            if (missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    'Missing:',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 11,
                    ),
                  ),
                  ...visibleMissing.map(
                    (field) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          field,
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (extraCount > 0)
                    Text(
                      '+$extraCount more',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // Compact Action Button
            SizedBox(
              height: 36,
              width: double.infinity,
              child: Button.filled(
                size: const Size(double.infinity, 36),
                title: 'Complete Profile',
                raduis: 10,
                style: AppStyles.text13Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
                ontap: () {
                  context.read<DashboardCubit>().navigateToProfile();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
