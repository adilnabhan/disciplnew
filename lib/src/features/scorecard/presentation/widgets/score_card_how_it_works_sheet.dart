import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';

class ScoreCardHowItWorksSheet extends StatefulWidget {
  const ScoreCardHowItWorksSheet({super.key, this.currentScore});

  final int? currentScore;

  static void show(BuildContext context, {int? currentScore}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScoreCardHowItWorksSheet(currentScore: currentScore),
    );
  }

  @override
  State<ScoreCardHowItWorksSheet> createState() =>
      _ScoreCardHowItWorksSheetState();
}

class _ScoreCardHowItWorksSheetState extends State<ScoreCardHowItWorksSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Score Card Works',
                        style: AppStyles.text18Px.poppins.w700.copyWith(
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      Text(
                        'Scoring Rules, Streaks & 10 Ranks',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: AppStyles.text12Px.poppins.w600,
              unselectedLabelStyle: AppStyles.text12Px.poppins.w500,
              tabs: const [
                Tab(text: '🎯 Points'),
                Tab(text: '🔥 Streaks'),
                Tab(text: '👑 Ranks'),
                Tab(text: '📊 Board'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointsTab(),
                _buildStreaksTab(),
                _buildRanksTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: POINTS & CATEGORIES ====================
  Widget _buildPointsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Formula Banner Card
        _buildFormulaCard(),
        const SizedBox(height: 16),

        Text(
          '7 Point Categories',
          style: AppStyles.text16Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 10),

        // 1. Workouts
        _buildCategoryCard(
          icon: '🏋️',
          title: 'Workout Points',
          cap: 'Max 40 pts / day',
          items: [
            _buildItemRow('Base Workout Logged', '+30 pts'),
            _buildItemRow('≥ 3 Exercises Bonus', '+5 pts'),
            _buildItemRow('≥ 45 Minutes Duration Bonus', '+5 pts'),
          ],
          note: 'Rule: Maximum 1 workout session scored per day.',
        ),

        // 2. Consistency & Streaks
        _buildCategoryCard(
          icon: '🔥',
          title: 'Daily Streak & Consistency',
          cap: '+10 pts / day',
          items: [
            _buildItemRow('Consecutive Workout Day', '+10 pts'),
            // _buildItemRow('Rest Day Grace (1 day missed)', '+10 pts'),
          ],
          note: 'Streak bonuses range up to +600 pts! See the Streaks tab.',
        ),

        // 3. Attendance
        _buildCategoryCard(
          icon: '📍',
          title: 'Gym Attendance',
          cap: 'Max 5 pts / day',
          items: [
            _buildItemRow('Gym Attendance Marked', '+5 pts'),
            _buildItemRow('Missed / Unmarked Absent', '-2 pts', isPenalty: true),
          ],
          note: 'Rule: Maximum 1 attendance record evaluated per day.',
        ),

        // 4. Trainer Verification
        _buildCategoryCard(
          icon: '👨‍🏫',
          title: 'Trainer Verification',
          cap: 'Max 15 pts / day',
          items: [
            _buildItemRow('Trainer confirms in Mentor App', '+15 pts'),
          ],
          note: 'Earned when your certified trainer confirms your workout.',
        ),

        // 5. Daily Steps
        // _buildCategoryCard(
        //   icon: '🚶',
        //   title: 'Daily Steps Milestones',
        //   cap: 'Max 50 pts / day',
        //   items: [
        //     _buildItemRow('5,000 steps', '+5 pts'),
        //     _buildItemRow('7,500 steps', '+10 pts'),
        //     _buildItemRow('10,000 steps', '+20 pts'),
        //     _buildItemRow('15,000 steps', '+35 pts'),
        //     _buildItemRow('20,000+ steps', '+50 pts'),
        //   ],
        //   note: 'Auto-difference: Higher milestones automatically credit the difference!',
        // ),

        // 6. Inspiration & Community
        // _buildCategoryCard(
        //   icon: '🤝',
        //   title: 'Inspiration & Community',
        //   cap: 'Max 75 pts / day',
        //   items: [
        //     _buildItemRow('Share Achievement Badge', '+10 pts'),
        //     _buildItemRow('Share Workout Completion Card', '+15 pts'),
        //     _buildItemRow('Referral Friend Registration', '+50 pts'),
        //   ],
        //   note: 'Inspire friends and grow the fitness community.',
        // ),

        // 7. Challenges & Events
        // _buildCategoryCard(
        //   icon: '🏆',
        //   title: 'Challenges & Events',
        //   cap: 'Max 330 pts / day',
        //   items: [
        //     _buildItemRow('Join Challenge', '+50 pts'),
        //     _buildItemRow('Attend Fitness Event', '+30 pts'),
        //     _buildItemRow('Complete Challenge', '+100 pts'),
        //     _buildItemRow('Win Tournament / Challenge', '+150 pts'),
        //   ],
        //   note: 'Participate in club tournaments to climb the ranks quickly!',
        // ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ==================== TAB 2: STREAKS & CONSISTENCY ====================
  Widget _buildStreaksTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Grace rule highlight card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Rest Day Grace Rule',
                    style: AppStyles.text15Px.poppins.w700.copyWith(
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'If you miss 1 day (e.g. Sunday rest day), your streak does NOT break! It preserves your consecutive streak and credits +10 points (rest_days_count = 1).',
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF78350F),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Milestone Bonuses
        Text(
          'Streak Milestone Bonuses',
          style: AppStyles.text16Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildStreakMilestoneRow('7-Day Streak', '+25 pts', '🎁 Bronze'),
              const Divider(height: 1),
              _buildStreakMilestoneRow('14-Day Streak', '+50 pts', '🥈 Silver'),
              const Divider(height: 1),
              _buildStreakMilestoneRow('30-Day Streak', '+150 pts', '🥇 Gold'),
              const Divider(height: 1),
              _buildStreakMilestoneRow('50-Day Streak', '+250 pts', '💎 Platinum'),
              const Divider(height: 1),
              _buildStreakMilestoneRow('75-Day Streak', '+400 pts', '🔥 Diamond'),
              const Divider(height: 1),
              _buildStreakMilestoneRow('100-Day Streak', '+600 pts', '👑 Master'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Broken Streak Penalties
        Text(
          'Broken Streak Penalties',
          style: AppStyles.text16Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Incurred only if you remain inactive for more than 1 rest day.',
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            children: [
              _buildStreakPenaltyRow('Lost 1–6 day streak', '-5 pts'),
              const Divider(height: 1),
              _buildStreakPenaltyRow('Lost 7–29 day streak', '-15 pts'),
              const Divider(height: 1),
              _buildStreakPenaltyRow('Lost 30–49 day streak', '-30 pts'),
              const Divider(height: 1),
              _buildStreakPenaltyRow('Lost 50–74 day streak', '-40 pts'),
              const Divider(height: 1),
              _buildStreakPenaltyRow('Lost 75–99 day streak', '-50 pts'),
              const Divider(height: 1),
              _buildStreakPenaltyRow(
                'Lost ≥100 day streak',
                '-75 pts',
                subtitle: 'Streak then resets to Day 1',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ==================== TAB 3: 10 RANKS & BADGES ====================
  Widget _buildRanksTab() {
    final int userScore = widget.currentScore ?? 0;
    final currentTier = UserRankTier.getTierForScore(userScore);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Progress formula card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rank Progress Formula',
                style: AppStyles.text14Px.poppins.w700.copyWith(
                  color: const Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Progress % = (Current Score - Level Min) / (Next Level Min - Level Min) × 100',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: const Color(0xFF1E3A8A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          '10 Rank Tiers',
          style: AppStyles.text16Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 10),

        ...UserRankTier.tiers.map((tier) {
          final bool isCurrent = tier.name == currentTier.name;
          final String rangeStr = tier.maxScore > 50000
              ? '30,000+ pts'
              : '${tier.minScore} – ${tier.maxScore} pts';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent ? AppColors.primary : Colors.grey.shade200,
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(tier.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.name,
                            style: AppStyles.text14Px.poppins.w700.copyWith(
                              color: isCurrent ? AppColors.primary : const Color(0xFF212121),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CURRENT',
                                style: AppStyles.text10Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        rangeStr,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  // ==================== TAB 4: LEADERBOARD & TIMEFRAMES ====================
  Widget _buildLeaderboardTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildLeaderboardTimeframeTile(
          icon: Icons.today_rounded,
          color: const Color(0xFF3B82F6),
          title: 'Daily Leaderboard',
          desc: 'Calculated as the sum of all points earned today. Resets at midnight.',
        ),
        _buildLeaderboardTimeframeTile(
          icon: Icons.date_range_rounded,
          color: const Color(0xFF10B981),
          title: 'Weekly Leaderboard',
          desc: 'Rolling sum of all points earned in the last 7 days.',
        ),
        _buildLeaderboardTimeframeTile(
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFFF59E0B),
          title: 'Monthly Leaderboard',
          desc: 'Rolling sum of all points earned in the last 30 days (default club period).',
        ),
        _buildLeaderboardTimeframeTile(
          icon: Icons.all_inclusive_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'All-Time Leaderboard',
          desc: 'Cumulative lifetime score (Current Score) from all workout records.',
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Immutable Audit Trail',
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Every point gained or deducted is saved as an immutable audit record in ScoreTransaction. Rankings update in real-time as activities are verified.',
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF880E4F), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC2185B).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Core Scoring Formula',
                style: AppStyles.text14Px.poppins.w700.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Current Score = max(0, ∑ Earned - ∑ Penalties)',
              style: AppStyles.text13Px.poppins.w700.copyWith(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Points are accumulated daily across workouts, streaks, attendance, steps, trainer verification, community, and events.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String icon,
    required String title,
    required String cap,
    required List<Widget> items,
    required String note,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cap,
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items,
          const SizedBox(height: 6),
          Text(
            note,
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String points, {bool isPenalty = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '• $label',
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Text(
            points,
            style: AppStyles.text12Px.poppins.w700.copyWith(
              color: isPenalty ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMilestoneRow(String label, String points, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyles.text13Px.poppins.w600.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
          ),
          Text(
            tag,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            points,
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakPenaltyRow(String label, String points, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.text13Px.poppins.w600.copyWith(
                    color: const Color(0xFF212121),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: Colors.red.shade700,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            points,
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTimeframeTile({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
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
