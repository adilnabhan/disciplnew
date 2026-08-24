import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

enum ScoreboardTimeFilter { thisWeek, thisMonth, allTime }

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _isLoading = false;
  ScoreboardTimeFilter _timeFilter = ScoreboardTimeFilter.thisWeek;

  int _myPoints = 1420;
  int _myRank = 4;
  int _myStreak = 5;
  String _myName = 'You';

  List<Map<String, dynamic>> _leaderboardMembers = [
    {'rank': 1, 'name': 'Jasim vp', 'streak': '12 day streak', 'pts': 2850, 'gym': 'Discipl Gym Calicut'},
    {'rank': 2, 'name': 'Adil vc', 'streak': '9 day streak', 'pts': 2340, 'gym': 'Discipl Gold Gym'},
    {'rank': 3, 'name': 'Fathimmathu Uyoon', 'streak': '7 day streak', 'pts': 1980, 'gym': 'Discipl Fitness'},
    {'rank': 4, 'name': 'Shahim badi', 'streak': '5 day streak', 'pts': 1420, 'gym': 'Discipl Downtown'},
    {'rank': 5, 'name': 'Rohan Sharma', 'streak': '4 day streak', 'pts': 1120, 'gym': 'Discipl Express'},
    {'rank': 6, 'name': 'Sneha Menon', 'streak': '4 day streak', 'pts': 980, 'gym': 'Discipl Calicut'},
    {'rank': 7, 'name': 'Rahul Nair', 'streak': '3 day streak', 'pts': 850, 'gym': 'Discipl Arena'},
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
                'streak': '${item['streak'] ?? item['daily_streak'] ?? (7 - idx).clamp(1, 15)} day streak',
                'pts': _toInt(item['points'] ?? item['pts'] ?? 0),
                'gym': item['gym_name'] ?? 'Discipl Gym',
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

  void _showRulesDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: CyberWorkoutTheme.goldPrimary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'HOW TO EARN XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRuleRow('🏋️ Complete Workout Session', '+50 XP'),
              _buildRuleRow('👟 Reach 10,000 Daily Steps', '+30 XP'),
              _buildRuleRow('📍 Gym QR Check-in', '+20 XP'),
              _buildRuleRow('🥗 Log All Daily Meals', '+15 XP'),
              _buildRuleRow('🏃 Marathon Ticket Registration', '+100 XP'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleRow(String action, String reward) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.4)),
            ),
            child: Text(
              reward,
              style: const TextStyle(
                color: CyberWorkoutTheme.crimsonRed,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top1 = _leaderboardMembers.isNotEmpty ? _leaderboardMembers[0] : null;
    final top2 = _leaderboardMembers.length > 1 ? _leaderboardMembers[1] : null;
    final top3 = _leaderboardMembers.length > 2 ? _leaderboardMembers[2] : null;
    final remainingMembers = _leaderboardMembers.length > 3 ? _leaderboardMembers.sublist(3) : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101018),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: CyberWorkoutTheme.goldPrimary, size: 22),
            SizedBox(width: 8),
            Text(
              'GYM SCOREBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            onPressed: _showRulesDialog,
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchScoreboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: CyberWorkoutTheme.crimsonRed,
        backgroundColor: const Color(0xFF141420),
        onRefresh: _fetchScoreboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Time Filter Selector (This Week / This Month / All Time)
              _buildTimeFilters(),
              const SizedBox(height: 20),

              // 2. Top 3 Glory Podium (Gold 1st, Silver 2nd, Bronze 3rd)
              if (top1 != null)
                _buildPodiumSection(top1, top2, top3),

              const SizedBox(height: 20),

              // 3. User's Personal Standing Card
              _buildMyRankBanner(),
              const SizedBox(height: 24),

              // 4. Leaderboard Roster
              const Text(
                'LEADERBOARD ROSTER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              if (remainingMembers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No more rankings yet', style: TextStyle(color: Colors.white38)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: remainingMembers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final member = remainingMembers[index];
                    return _buildRosterTile(member);
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Time Filter Tabs
  Widget _buildTimeFilters() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildFilterItem('THIS WEEK', ScoreboardTimeFilter.thisWeek),
          _buildFilterItem('THIS MONTH', ScoreboardTimeFilter.thisMonth),
          _buildFilterItem('ALL TIME', ScoreboardTimeFilter.allTime),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String title, ScoreboardTimeFilter filter) {
    final bool isSelected = _timeFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? CyberWorkoutTheme.crimsonRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: CyberWorkoutTheme.crimsonRed.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // 2. Top 3 Glory Podium
  Widget _buildPodiumSection(Map<String, dynamic> top1, Map<String, dynamic>? top2, Map<String, dynamic>? top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1B1424),
            const Color(0xFF12121A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 2nd Place (Silver)
          if (top2 != null)
            _buildPodiumColumn(
              member: top2,
              rank: 2,
              height: 120,
              color: const Color(0xFFE2E8F0),
              medalIcon: '🥈',
            ),

          // 1st Place (Gold) - Center and Tallest
          _buildPodiumColumn(
            member: top1,
            rank: 1,
            height: 155,
            color: const Color(0xFFFFD700),
            medalIcon: '👑',
            isChampion: true,
          ),

          // 3rd Place (Bronze)
          if (top3 != null)
            _buildPodiumColumn(
              member: top3,
              rank: 3,
              height: 100,
              color: const Color(0xFFCD7F32),
              medalIcon: '🥉',
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required Map<String, dynamic> member,
    required int rank,
    required double height,
    required Color color,
    required String medalIcon,
    bool isChampion = false,
  }) {
    final String name = member['name'] as String;
    final int pts = member['pts'] as int;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medal Badge
          Text(medalIcon, style: TextStyle(fontSize: isChampion ? 24 : 18)),
          const SizedBox(height: 4),

          // Avatar
          Container(
            width: isChampion ? 58 : 46,
            height: isChampion ? 58 : 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isChampion ? 2.5 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: isChampion ? 14 : 8,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF222230),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isChampion ? 20 : 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isChampion ? 13 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),

          // XP
          Text(
            '$pts XP',
            style: TextStyle(
              color: color,
              fontSize: isChampion ? 13 : 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          // Podium Pillar
          Container(
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.35),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: isChampion ? 28 : 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. User's Personal Standing Banner
  Widget _buildMyRankBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A0812),
            Color(0xFF141420),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CyberWorkoutTheme.crimsonRed, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: CyberWorkoutTheme.crimsonRed.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CyberWorkoutTheme.crimsonRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#$_myRank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR STANDING',
                    style: TextStyle(
                      color: CyberWorkoutTheme.crimsonRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_myName • $_myPoints XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9100).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF9100).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF9100), size: 14),
                const SizedBox(width: 4),
                Text(
                  '$_myStreak-Day Streak',
                  style: const TextStyle(
                    color: Color(0xFFFF9100),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Full Roster List Items
  Widget _buildRosterTile(Map<String, dynamic> member) {
    final int rank = member['rank'] as int;
    final String name = member['name'] as String;
    final String streak = member['streak'] as String;
    final int pts = member['pts'] as int;
    final String gym = member['gym'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Rank badge
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF222230),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name & Gym
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        gym,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $streak',
                        style: const TextStyle(color: Color(0xFFFF9100), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // XP Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.3)),
            ),
            child: Text(
              '$pts XP',
              style: const TextStyle(
                color: CyberWorkoutTheme.crimsonRed,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
