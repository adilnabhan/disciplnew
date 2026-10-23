import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_state.dart';

/// Dedicated Score Card view for customers who do not have an active gym membership
/// ("has_active_gym": false).
class NonActiveGymScoreCardView extends StatelessWidget {
  const NonActiveGymScoreCardView({
    required this.state,
    required this.data,
    required this.onRefresh,
    required this.onInfoTap,
    super.key,
  });

  final ScoreCardState state;
  final ScoreCardResponseModel data;
  final Future<void> Function() onRefresh;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    final score = data.displayScore;
    final streakDays = data.displayStreak;
    final workoutsCompleted = data.displayWorkoutsCompleted;
    final nextRankScore = data.displayNextRankScore;
    final remainingScore = data.displayRemainingScore;
    final progressPercentage = data.displayProgressPercentage;

    // Resolve current rank tier & next rank milestone
    final currentTier = UserRankTier.getTierByName(data.displayCurrentRank) ??
        UserRankTier.getTierForScore(score);
    final nextTier = UserRankTier.getTierByName(data.displayNextRank) ??
        UserRankTier.getNextTier(currentTier);

    final currentRankName = data.displayCurrentRank ?? currentTier.name;
    final currentRankEmoji = data.displayRankEmoji ?? currentTier.emoji;
    final nextRankName = data.displayNextRank ?? nextTier?.name;
    final nextRankEmoji = data.displayNextRankEmoji ?? nextTier?.emoji;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Main Score Card: YOUR DISCIPL SCORE
            _buildMainScoreCard(
              context,
              score: score,
            ),

            const SizedBox(height: 14),

            // 2. Two-Column Stats Row: Streak & Workouts Completed
            _buildStatsRow(
              streakDays: streakDays,
              workoutsCompleted: workoutsCompleted,
            ),

            const SizedBox(height: 14),

            // 3. Next Milestone Progress Card
            _buildMilestoneCard(
              context,
              score: score,
              currentRankName: currentRankName,
              currentRankEmoji: currentRankEmoji,
              nextRankName: nextRankName,
              nextRankEmoji: nextRankEmoji,
              nextRankScore: nextRankScore,
              remainingScore: remainingScore,
              progressPercentage: progressPercentage,
            ),

            const SizedBox(height: 20),

            // 4. Ways to Earn Points Section
            _buildWaysToEarnPointsSection(
              context,
              data.displayWaysToEarnPoints,
            ),

            const SizedBox(height: 20),

            // 5. Join a Gym Leaderboard Banner
            _buildJoinGymBanner(context),
          ],
        ),
      ),
    );
  }

  /// Builds the top hero "YOUR DISCIPL SCORE" card with flame graphic.
  Widget _buildMainScoreCard(
    BuildContext context, {
    required int score,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFEAEA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Score details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with info icon
                Row(
                  children: [
                    Text(
                      'YOUR DISCIPL SCORE',
                      style: AppStyles.text11Px.poppins.w700.copyWith(
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onInfoTap,
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Large Score
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      NumberFormat('#,###').format(score),
                      style: AppStyles.text36Px.poppins.w800.copyWith(
                        color: AppColors.primary,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'pts',
                      style: AppStyles.text18Px.poppins.w800.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Crown / Personal score pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '👑',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Your personal score',
                        style: AppStyles.text11Px.poppins.w700.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Subtext
                Text(
                  'Stay consistent. Complete workouts.\nEarn points. Be a better you!',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Layered flame graphic
          Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF5F5),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFEAEA),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 2-column stats row: Streak and Workouts Completed.
  Widget _buildStatsRow({
    required int streakDays,
    required int workoutsCompleted,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Streak Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEAEA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streakDays days',
                          style: AppStyles.text15Px.poppins.w800.copyWith(
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Current streak',
                          style: AppStyles.text11Px.poppins.w500.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Workouts Completed Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEAEA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$workoutsCompleted',
                          style: AppStyles.text15Px.poppins.w800.copyWith(
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Workouts completed',
                          style: AppStyles.text11Px.poppins.w500.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Next Milestone Card showing the user's current rank tier,
  /// the next milestone rank tier, remaining points needed, and linear progress.
  Widget _buildMilestoneCard(
    BuildContext context, {
    required int score,
    required String currentRankName,
    required String currentRankEmoji,
    required String? nextRankName,
    required String? nextRankEmoji,
    required int nextRankScore,
    required int remainingScore,
    required double progressPercentage,
  }) {
    final progress = (progressPercentage / 100.0).clamp(0.0, 1.0);
    final hasNextRank = nextRankName != null && nextRankName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Milestone Icon + Rank Details + Target Points
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NEXT MILESTONE',
                      style: AppStyles.text10Px.poppins.w700.copyWith(
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasNextRank
                          ? 'Unlock ${nextRankEmoji ?? '⚔️'} $nextRankName'
                          : 'Top Rank Achieved 👑',
                      style: AppStyles.text15Px.poppins.w800.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasNextRank
                          ? (remainingScore > 0
                              ? '$remainingScore more points to unlock $nextRankName!'
                              : 'Ready to promote to $nextRankName!')
                          : 'You have reached the maximum rank: $currentRankName',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFEAEA),
                  ),
                ),
                child: Text(
                  '${NumberFormat('#,###').format(nextRankScore)} pts',
                  style: AppStyles.text12Px.poppins.w700.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Bottom Labels: current rank & score vs next rank & score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentRankEmoji,
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$currentRankName • ${NumberFormat('#,###').format(score)} pts',
                    style: AppStyles.text11Px.poppins.w600.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (hasNextRank)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (nextRankEmoji != null && nextRankEmoji.isNotEmpty) ...[
                      Text(
                        nextRankEmoji,
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '$nextRankName • ${NumberFormat('#,###').format(nextRankScore)} pts',
                      style: AppStyles.text11Px.poppins.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the "Ways to Earn Points" section displaying activities to gain score.
  Widget _buildWaysToEarnPointsSection(
    BuildContext context,
    List<WayToEarnPointsModel> ways,
  ) {
    if (ways.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ways to Earn Points',
                  style: AppStyles.text16Px.poppins.w800.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete activities to level up your rank',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFEAEA),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    'Earn Daily',
                    style: AppStyles.text11Px.poppins.w700.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal Row of Ways Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: ways.asMap().entries.map((entry) {
                final isLast = entry.key == ways.length - 1;
                return Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 12),
                  child: _buildWayCard(context, entry.value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an individual non-clickable card for a way to earn points.
  Widget _buildWayCard(BuildContext context, WayToEarnPointsModel item) {
    final iconData = _getWayIconData(item.icon);

    return Container(
      width: 195,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Circular icon on left, points badge on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconData.backgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconData.icon,
                  color: iconData.iconColor,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFEAEA),
                  ),
                ),
                child: Text(
                  item.points,
                  style: AppStyles.text11Px.poppins.w700.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            item.title,
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            item.description,
            style: AppStyles.text11Px.poppins.w400.copyWith(
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Maps icon names to Material Icons and harmonious color schemes.
  ({IconData icon, Color iconColor, Color backgroundColor}) _getWayIconData(
    String iconKey,
  ) {
    switch (iconKey.toLowerCase().trim()) {
      case 'workout':
        return (
          icon: Icons.fitness_center_rounded,
          iconColor: AppColors.primary,
          backgroundColor: const Color(0xFFFFEAEA),
        );
      case 'streak':
        return (
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFEA580C),
          backgroundColor: const Color(0xFFFFF7ED),
        );
      case 'verified':
        return (
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF059669),
          backgroundColor: const Color(0xFFECFDF5),
        );
      case 'steps':
        return (
          icon: Icons.directions_walk_rounded,
          iconColor: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFFEFF6FF),
        );
      case 'profile':
        return (
          icon: Icons.account_circle_rounded,
          iconColor: const Color(0xFF7C3AED),
          backgroundColor: const Color(0xFFFAF5FF),
        );
      default:
        return (
          icon: Icons.stars_rounded,
          iconColor: AppColors.primary,
          backgroundColor: const Color(0xFFFFEAEA),
        );
    }
  }

  /// Builds the "Join a Gym Leaderboard" card with CTA.
  Widget _buildJoinGymBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7F7),
        borderRadius: BorderRadius.all(Radius.circular(22)),
        border: Border.fromBorderSide(
          BorderSide(
            color: Color(0xFFFFEAEA),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join a Gym Leaderboard',
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Find a gym, connect with a community, and compete with members.',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Explore Gyms Button
          GestureDetector(
            onTap: () {
              try {
                context.read<DashboardCubit>().changeNav(index: 3);
                return;
              } catch (_) {}
              context.push(const FitnessCentersListingScreen());
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    Color(0xFFAD090D),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Explore Gyms',
                    style: AppStyles.text15Px.poppins.w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
