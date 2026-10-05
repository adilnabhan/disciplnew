import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_cubit.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_state.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/screens/partners_screen.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/qr_history_section.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/savings_summary_card.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RewardsCubit>();
      return const _SavingsScreenView();
    } catch (_) {
      return BlocProvider(
        create: (_) => RewardsCubit()..loadRewards(),
        child: const _SavingsScreenView(),
      );
    }
  }
}

class _SavingsScreenView extends StatelessWidget {
  const _SavingsScreenView();

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
          'Savings',
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

          return RefreshIndicator(
            color: const Color(0xFFEE2726),
            onRefresh:
                () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SavingsSummaryCard(summary: state.savingsSummary),
                  const SizedBox(height: 20),
                  QrHistorySection(
                    items: state.historyItems,
                    isLoading: state.isHistoryLoading,
                    onExploreStores: () {
                      context.push(
                        BlocProvider.value(
                          value: context.read<RewardsCubit>(),
                          child: const PartnersScreen(),
                        ),
                      );
                    },
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
