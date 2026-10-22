import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/point_history_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/point_history_cubit.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/point_history_state.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PointHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PointHistoryCubit()..fetchPointHistory();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.fetchPointHistory(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF1F4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF1F2937),
                  size: 26,
                ),
              ),
            ),
          ),
          title: const Text(
            'Points History',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<PointHistoryCubit, PointHistoryState>(
          builder: (context, state) {
            if (state.status == PointHistoryStatus.loading &&
                state.data == null) {
              return _buildLoadingSkeleton();
            }

            if (state.status == PointHistoryStatus.error &&
                state.data == null) {
              return _buildErrorState(state.errorMessage);
            }

            final summary = state.data?.summary;
            final items = state.filteredItems;

            return RefreshIndicator(
              onRefresh: () => _cubit.fetchPointHistory(refresh: true),
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Top Summary Card
                  if (summary != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: _buildSummaryCard(summary),
                      ),
                    ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFilterChips(state.selectedFilter),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12),
                  ),

                  // Items List or Empty State
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(state.selectedFilter),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < items.length) {
                              return _buildHistoryItemCard(items[index]);
                            }
                            // Bottom loader when fetching more
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount:
                              items.length + (state.hasNextPage ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== SUMMARY HERO CARD ====================
  Widget _buildSummaryCard(PointHistorySummaryModel summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Score + Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT BALANCE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${summary.currentScore}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: Color(0xFF111827),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'pts',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Rank & Streak Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Rank Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          summary.rankEmoji,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          summary.currentRank,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (summary.streakDays > 0) ...[
                    const SizedBox(height: 6),
                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${summary.streakDays} Day Streak',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),

          // Bottom Metric Pills
          Row(
            children: [
              // Total Earned
              Expanded(
                child: _buildMetricTile(
                  title: 'Earned',
                  value: '+${summary.totalEarned}',
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFDCFCE7),
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 8),

              // Total Deducted
              Expanded(
                child: _buildMetricTile(
                  title: 'Deducted',
                  value: '-${summary.totalDeducted}',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEE2E2),
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 8),

              // Net Points
              Expanded(
                child: _buildMetricTile(
                  title: 'Net Points',
                  value: '${summary.netPoints}',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFDBEAFE),
                  icon: Icons.auto_graph_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips(String selectedFilter) {
    final filters = [
      {'label': 'All Transactions', 'value': 'all'},
      {'label': 'Earned (+)', 'value': 'increase'},
      {'label': 'Deducted (-)', 'value': 'decrease'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _cubit.setFilter(f['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== HISTORY ITEM CARD ====================
  Widget _buildHistoryItemCard(PointHistoryItemModel item) {
    final isEarned = item.isIncrease;

    // Category-specific styles
    IconData categoryIcon = Icons.stars_rounded;
    Color iconBgColor = const Color(0xFFF3E8FF);
    Color iconColor = const Color(0xFF9333EA);

    final catLower = item.categorySlug.toLowerCase();
    if (catLower.contains('workout') || catLower.contains('exercise')) {
      categoryIcon = Icons.fitness_center_rounded;
      iconBgColor = const Color(0xFFFFF7ED);
      iconColor = const Color(0xFFEA580C);
    } else if (catLower.contains('profile')) {
      categoryIcon = Icons.person_rounded;
      iconBgColor = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
    } else if (catLower.contains('streak')) {
      categoryIcon = Icons.local_fire_department_rounded;
      iconBgColor = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              categoryIcon,
              size: 22,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip + Action
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.categoryName.isNotEmpty
                            ? item.categoryName
                            : 'Activity',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.action.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5,
                        letterSpacing: 0.4,
                        color: isEarned
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: Color(0xFF1F2937),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Formatted Date
                Text(
                  item.createdAtFormatted.isNotEmpty
                      ? item.createdAtFormatted
                      : item.date,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 11.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Points Change Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isEarned
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isEarned
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
                width: 1,
              ),
            ),
            child: Text(
              item.formattedPoints.isNotEmpty
                  ? '${item.formattedPoints} pts'
                  : '${item.points > 0 ? "+${item.points}" : item.points} pts',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isEarned
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(String filter) {
    String title = 'No Points History';
    String message =
        'Complete workouts, hit streaks, and update your profile to earn points!';

    if (filter == 'increase') {
      title = 'No Earned Points Yet';
      message = 'Finish workout sessions to earn points and climb the ranks!';
    } else if (filter == 'decrease') {
      title = 'No Deductions Found';
      message = 'Great job! You have no point deductions on your account.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 36,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Something went wrong',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _cubit.fetchPointHistory(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LOADING SKELETON ====================
  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary placeholder
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
        const SizedBox(height: 16),

        // Items placeholders
        ...List.generate(
          5,
          (index) => Container(
            height: 76,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}
