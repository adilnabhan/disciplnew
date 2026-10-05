import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_cubit.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_state.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/screens/partners_screen.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/screens/savings_screen.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/reward_qr_card.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/rewards_how_it_works_sheet.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RewardsCubit()..loadRewards(),
      child: const _RewardsScreenView(),
    );
  }
}

class _RewardsScreenView extends StatefulWidget {
  const _RewardsScreenView();

  @override
  State<_RewardsScreenView> createState() => _RewardsScreenViewState();
}

class _RewardsScreenViewState extends State<_RewardsScreenView> {
  bool _checkHasActiveGym(BuildContext context) {
    try {
      final dashState = context.read<DashboardCubit>().state;
      final fromDash = dashState.activeMembershipData.fold(
        () => null,
        (either) => either.fold(
          (_) => false,
          (m) =>
              m != null &&
              ((m.isActive ?? false) || m.organization != null || m.id != null),
        ),
      );
      if (fromDash != null) return fromDash;
    } catch (_) {}

    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    if (currentUser?.customer != null) {
      final c = currentUser!.customer!;
      return (c.isActiveMember ?? false) ||
          c.organizationId != null ||
          c.assignedFitnessCenter != null;
    }
    return true;
  }

  Widget _buildSavingsSummaryCard(BuildContext context, RewardsState state) {
    return GestureDetector(
      onTap: () {
        context.push(
          BlocProvider.value(
            value: context.read<RewardsCubit>(),
            child: const SavingsScreen(),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.70),
                ],
              ),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${state.savingsSummary.totalSaved.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.text22Px.poppins.w800.copyWith(
                    color: const Color(0xFF00A859),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total\nSavings',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                        height: 1.25,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF00A859),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnersCountCard(BuildContext context, RewardsState state) {
    final partnersCount = state.allShops.length;

    return GestureDetector(
      onTap: () {
        context.push(
          BlocProvider.value(
            value: context.read<RewardsCubit>(),
            child: const PartnersScreen(),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.70),
                ],
              ),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$partnersCount',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.text22Px.poppins.w800.copyWith(
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discipl\nPartners',
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E293B),
                        height: 1.25,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF1E293B),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIneligibilityBanner(
    BuildContext context, {
    required bool hasGym,
    String? reason,
  }) {
    final title = hasGym ? 'Discount Inactive for Today' : 'No Active Gym';
    final desc =
        hasGym
            ? (reason ??
                "Complete today's gym workout or steps in Discipl to unlock discount QR.")
            : (reason ??
                'Join or activate a gym membership to unlock partner discount QR codes.');
    final icon =
        hasGym ? Icons.info_outline_rounded : Icons.fitness_center_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppStyles.text13Px.poppins.w700.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  desc,
                  style: AppStyles.text11Px.poppins.w500.copyWith(
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          if (!hasGym) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                context.push(const FitnessCentersListingScreen());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Explore',
                  style: AppStyles.text11Px.poppins.w700.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.90),
                          const Color(0xFFEEEEEE).withValues(alpha: 0.65),
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF222222),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Rewards',
          style: AppStyles.text18Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => context.push(const SettingsScreen()),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.90),
                            const Color(0xFFEEEEEE).withValues(alpha: 0.65),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/svg/icons/settings _icon.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<RewardsCubit, RewardsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE2726)),
            );
          }

          final qrModel = state.partnerQr;
          final hasGym = _checkHasActiveGym(context);
          final isEligible =
              hasGym &&
              (qrModel?.isEligibleForDiscount ?? true) &&
              (qrModel?.isActiveMember ?? true);

          return RefreshIndicator(
            color: const Color(0xFFEE2726),
            onRefresh:
                () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message container banner for ineligible / no active gym users
                  if (!isEligible) ...[
                    _buildIneligibilityBanner(
                      context,
                      hasGym: hasGym,
                      reason: qrModel?.eligibilityReason,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Main Vibrant Red QR Card
                  RewardQrCard(
                    qrModel: qrModel,
                    remainingSeconds: state.remainingSeconds,
                    isRefreshing: state.isRefreshing,
                    isEligible: isEligible,
                    onRefresh:
                        () => context.read<RewardsCubit>().loadRewards(
                          isRefresh: true,
                        ),
                    onInfoTap: () => RewardsHowItWorksSheet.show(context),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Two Action Cards (Total Savings & Discipl Partners)
                  Row(
                    children: [
                      Expanded(child: _buildSavingsSummaryCard(context, state)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildPartnersCountCard(context, state)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
