import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _isLoading = false;
  int _myPoints = 1420;
  int _myRank = 4;
  int _myStreak = 5;

  List<Map<String, dynamic>> _leaderboardMembers = [
    {'rank': 1, 'name': 'Alex John', 'streak': '7 day streak', 'pts': 2350},
    {'rank': 2, 'name': 'Neha Nair', 'streak': '6 day streak', 'pts': 1980},
    {'rank': 3, 'name': 'Rohan S', 'streak': '5 day streak', 'pts': 1650},
    {'rank': 4, 'name': 'You', 'streak': '5 day streak', 'pts': 1420},
  ];

  @override
  void initState() {
    super.initState();
    _fetchScoreboard();
  }

  Future<void> _fetchScoreboard() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(ApiUris.scoreboard);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data['results'] ?? res.data['leaderboard'] ?? res.data['data'] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            _leaderboardMembers = list.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              return {
                'rank': item['rank'] ?? idx,
                'name': item['customer_name'] ?? item['name'] ?? 'Member',
                'streak': '${item['streak'] ?? item['daily_streak'] ?? 0} day streak',
                'pts': _toInt(item['points'] ?? item['pts'] ?? 0),
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.round();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            const Text('🏆 ', style: TextStyle(fontSize: 18)),
            Text(
              'Score Card & Progress',
              style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            onPressed: _fetchScoreboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchScoreboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Marigold Floral Garland Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text('🌼 🌸 🌿 🌼 🌸 🌿 🌼 🌸 🌿 🌼', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Total Points Hero Card (1:1 with Reference Image 1 & 2 Screen 4)
              _buildTotalPointsHeroCard(),
              const SizedBox(height: 16),

              // Onam Achievements Badges Row (1:1 Match)
              _buildOnamBadgesRow(),
              const SizedBox(height: 20),

              // This Week Overview (1:1 Match: Workouts 5, Burned 3,850, Active 420)
              _buildThisWeekOverview(),
              const SizedBox(height: 20),

              // Recent Achievements Section (1:1 Match)
              _buildRecentAchievementsSection(),
              const SizedBox(height: 20),

              // Leaderboard Members List
              Text(
                'Gym Leaderboard Rankings',
                style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              ..._leaderboardMembers.map((m) {
                final isMe = m['name'].toString().toLowerCase().contains('you');
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isMe ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${m['rank']}',
                          style: AppStyles.text12Px.poppins.w700.copyWith(color: const Color(0xFFD97706)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name'],
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF1E293B)),
                            ),
                            Text(
                              m['streak'],
                              style: AppStyles.text10Px.poppins.w500.copyWith(color: const Color(0xFFF59E0B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${m['pts']} XP',
                          style: AppStyles.text12Px.poppins.w700.copyWith(color: const Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 1:1 Match for Total Points Hero Card
  Widget _buildTotalPointsHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B2E), Color(0xFF135A46), Color(0xFF7C2D12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D0D3B2E),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Points',
                    style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFFFDE68A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1,420 XP',
                    style: AppStyles.text28Px.poppins.w700.copyWith(color: const Color(0xFFFFD700)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Level 12',
                      style: AppStyles.text10Px.poppins.w700.copyWith(color: const Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 54),
            ],
          ),
          const SizedBox(height: 16),

          // Level progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 1420 / 4000,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '2,580 XP to Level 13',
            style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 1:1 Match for Onam Badges Row
  Widget _buildOnamBadgesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBadgeItem('🔥', '5 Day\nStreak'),
        _buildBadgeItem('🌼', 'Onam\nAchiever'),
        _buildBadgeItem('🌺', 'Sadya\nTracker'),
        _buildBadgeItem('☀️', 'Early Bird\nBonus'),
      ],
    );
  }

  Widget _buildBadgeItem(String emojiStr, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Text(emojiStr, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppStyles.text10Px.poppins.w600.copyWith(color: const Color(0xFF475569)),
        ),
      ],
    );
  }

  // 1:1 Match for This Week Overview Card
  Widget _buildThisWeekOverview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week Overview',
            style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('5', 'Workouts', const Color(0xFF0F172A)),
              _buildOverviewItem('3,850', 'Calories Burned\nkcal', const Color(0xFFEF4444)),
              _buildOverviewItem('420', 'Active Minutes\nmin', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String val, String label, Color col) {
    return Column(
      children: [
        Text(val, style: AppStyles.text18Px.poppins.w700.copyWith(color: col)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppStyles.text10Px.poppins.w500.copyWith(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  // 1:1 Match for Recent Achievements Section
  Widget _buildRecentAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          _buildAchievementTile('🌼 Onam Achiever', 'Completed 7 days goal', '+250 XP'),
          _buildAchievementTile('🔥 Calorie Crusher', 'Burned 3,000 kcal', '+200 XP'),
          _buildAchievementTile('⚡ Streak Master', '5 Day Workout Streak', '+150 XP'),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(String title, String sub, String xp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF1E293B))),
              Text(sub, style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF64748B))),
            ],
          ),
          Text(xp, style: AppStyles.text12Px.poppins.w700.copyWith(color: const Color(0xFF10B981))),
        ],
      ),
    );
  }
}
