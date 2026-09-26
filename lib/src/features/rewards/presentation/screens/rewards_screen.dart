import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_cubit.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_state.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/discount_rules_card.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/partner_shops_list.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/qr_history_section.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/reward_qr_card.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/rewards_how_it_works_sheet.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/savings_summary_card.dart';

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

class _RewardsScreenViewState extends State<_RewardsScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Rewards & Discounts',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: const Color(0xFF212121),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => RewardsHowItWorksSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          size: 14,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'How it works',
                          style: AppStyles.text11Px.poppins.w600.copyWith(
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
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
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final qrModel = state.partnerQr;
          final isEligible = qrModel?.isEligibleForDiscount ?? true;

          return Column(
            children: [
              // Segmented Tab Switcher
              _buildSegmentedTabBar(state),

              // Tab Content Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: QR & Instant Redemption
                    _buildQrTab(context, state, isEligible, qrModel),

                    // Tab 2: Partner Stores Directory
                    _buildStoresTab(context, state),

                    // Tab 3: Savings Passbook & Redemption History
                    _buildSavingsTab(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentedTabBar(RewardsState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: AppStyles.text12Px.poppins.w600,
          unselectedLabelStyle: AppStyles.text12Px.poppins.w500,
          tabs: [
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('My QR'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_rounded, size: 16),
                  const SizedBox(width: 5),
                  const Text('Stores'),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.filteredShops.length}',
                      style: AppStyles.text10Px.poppins.w700.copyWith(
                        color: _tabController.index == 1
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Savings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: QR & INSTANT REDEMPTION ---
  Widget _buildQrTab(
    BuildContext context,
    RewardsState state,
    bool isEligible,
    PartnerQrModel? qrModel,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eligibility Status Banner
            _buildEligibilityBanner(context, isEligible, qrModel?.eligibilityReason),

            const SizedBox(height: 14),

            // Dynamic QR Code Card (Hero)
            RewardQrCard(
              qrModel: qrModel,
              remainingSeconds: state.remainingSeconds,
              isRefreshing: state.isRefreshing,
              onRefresh: () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
            ),

            const SizedBox(height: 14),

            // Quick Jump Cards (Teasers to other tabs)
            _buildQuickNavigationRow(context, state),



            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: PARTNER STORES DIRECTORY ---
  Widget _buildStoresTab(BuildContext context, RewardsState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick shortcut: Jump to QR at checkout
            _buildQrShortcutBanner(context),

            const SizedBox(height: 16),

            // Working Partner Stores List (search bar + category pills + outlets)
            PartnerShopsList(
              shops: state.filteredShops,
              selectedCategory: state.selectedCategory,
              onCategorySelected: (cat) => context.read<RewardsCubit>().setCategory(cat),
              onSearchChanged: (query) => context.read<RewardsCubit>().setSearchQuery(query),
              onShowQrTapped: () => _tabController.animateTo(0),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: SAVINGS PASSBOOK & HISTORY ---
  Widget _buildSavingsTab(BuildContext context, RewardsState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Savings Summary Card (Hero Dark Gradient Card)
            SavingsSummaryCard(
              summary: state.savingsSummary,
            ),

            const SizedBox(height: 20),

            // QR Code Redemption History (interactive filters + receipt sheet)
            QrHistorySection(
              items: state.historyItems,
              isLoading: state.isHistoryLoading,
              onExploreStores: () => _tabController.animateTo(1),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Quick action shortcut cards shown below QR code
  Widget _buildQuickNavigationRow(BuildContext context, RewardsState state) {
    return Row(
      children: [
        // Shortcut to Savings Passbook
        _buildQuickNavCard(
          onTap: () => _tabController.animateTo(2),
          icon: Icons.savings_rounded,
          iconGradient: const [Color(0xFF10B981), Color(0xFF059669)],
          iconShadowColor: const Color(0xFF10B981),
          accentBorderColor: const Color(0xFFA7F3D0),
          cardGradient: const [
            Color(0xFFF0FDF4),
            Color(0xFFFFFFFF),
            Color(0xFFF7FEE7),
          ],
          title: 'Total Saved',
          value: '₹${state.savingsSummary.totalSaved.toStringAsFixed(0)}',
          accentColor: const Color(0xFF059669),
        ),

        const SizedBox(width: 12),

        // Shortcut to Partner Stores
        _buildQuickNavCard(
          onTap: () => _tabController.animateTo(1),
          icon: Icons.storefront_rounded,
          iconGradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          iconShadowColor: const Color(0xFF3B82F6),
          accentBorderColor: const Color(0xFFBAE6FD),
          cardGradient: const [
            Color(0xFFEFF6FF),
            Color(0xFFFFFFFF),
            Color(0xFFF0F9FF),
          ],
          title: 'Partner Stores',
          value: '${state.filteredShops.length} Outlets',
          accentColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildQuickNavCard({
    required VoidCallback onTap,
    required IconData icon,
    required List<Color> iconGradient,
    required Color iconShadowColor,
    required Color accentBorderColor,
    required List<Color> cardGradient,
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardGradient,
          ),
          border: Border.all(
            color: accentBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: accentColor.withValues(alpha: 0.12),
            highlightColor: accentColor.withValues(alpha: 0.06),
            child: Stack(
              children: [
                // Decorative watermark icon in the background
                Positioned(
                  right: -8,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 54,
                    color: accentColor.withValues(alpha: 0.07),
                  ),
                ),
                // Decorative accent circle in top-right corner
                Positioned(
                  top: -12,
                  right: -12,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                // Foreground content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 24),
                  child: Row(
                    children: [
                      // Gradient Icon Container with colored drop shadow
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: iconGradient,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: iconShadowColor.withValues(alpha: 0.35),
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      // Text details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.text14Px.poppins.w700.copyWith(
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Styled circular arrow forward indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentBorderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick shortcut banner in stores tab
  Widget _buildQrShortcutBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFF34D399),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paying at checkout?',
                  style: AppStyles.text12Px.poppins.w700.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Show your discount QR code',
                  style: AppStyles.text10Px.poppins.w400.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Show QR',
              style: AppStyles.text11Px.poppins.w700.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityBanner(BuildContext context, bool isEligible, String? reason) {
    if (isEligible) {
      return const SizedBox.shrink();
    } else {
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
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discount Inactive for Today',
                    style: AppStyles.text13Px.poppins.w700.copyWith(
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    reason ?? "Complete today's gym workout or steps in Discipl to unlock discount QR.",
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
