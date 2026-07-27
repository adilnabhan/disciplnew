import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final Dio _dio = DioClient().dio;

  bool _isLoading = true;
  List<dynamic> _leaderboard = [];
  Map<String, dynamic>? _dailyWinner;

  @override
  void initState() {
    super.initState();
    _fetchSocialData();
  }

  Future<void> _fetchSocialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lbResponse = await _dio.get<dynamic>(
        ApiUris.leaderboard,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (lbResponse.statusCode == 200 && lbResponse.data != null) {
        final data = lbResponse.data;
        if (data is List) {
          _leaderboard = data;
        } else if (data is Map && data.containsKey('results')) {
          _leaderboard = (data['results'] as List?) ?? [];
        } else if (data is Map && data.containsKey('leaderboard')) {
          _leaderboard = (data['leaderboard'] as List?) ?? [];
        }
      }

      final dwResponse = await _dio.get<dynamic>(
        ApiUris.dailyWinner,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (dwResponse.statusCode == 200 && dwResponse.data is Map<String, dynamic>) {
        _dailyWinner = dwResponse.data as Map<String, dynamic>;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Gym Score Card',
          style: AppStyles.text20Px.poppins.w700.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: _fetchSocialData,
          ),
        ],
      ),
      body: isGuest
          ? _buildGuestView()
          : _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
              : RefreshIndicator(
                  onRefresh: _fetchSocialData,
                  color: const Color(0xFFF59E0B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Daily Winner Banner (if available)
                        if (_dailyWinner != null) _buildDailyWinnerCard(_dailyWinner!),

                        // Top 3 Podium Section
                        if (_leaderboard.isNotEmpty) _buildPodiumSection(_leaderboard),

                        const SizedBox(height: 16),

                        // Leaderboard Members List Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Gym Members Leaderboard',
                            style: AppStyles.text16Px.poppins.w700.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Full Leaderboard List
                        if (_leaderboard.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No leaderboard entries yet.',
                                style: AppStyles.text14Px.poppins.w400.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _leaderboard.length,
                            itemBuilder: (context, index) {
                              final item = _leaderboard[index] as Map<String, dynamic>;
                              final rank = index + 1;
                              final name = item['name'] as String? ?? item['customer_name'] as String? ?? 'Member';
                              final points = (item['points'] as num?)?.toInt() ?? (item['xp'] as num?)?.toInt() ?? 0;
                              final streak = (item['streak'] as num?)?.toInt() ?? (item['streak_days'] as num?)?.toInt() ?? 0;
                              final pic = item['profile_picture'] as String? ?? '';

                              return _buildLeaderboardRow(rank, name, points, streak, pic);
                            },
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 40, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 24),
            Text(
              'Gym Score Card',
              style: AppStyles.text18Px.poppins.w700.copyWith(
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in to join your gym\'s leaderboard and earn streak rewards!',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyWinnerCard(Map<String, dynamic> winner) {
    final name = winner['name'] as String? ?? 'Daily Winner';
    final points = winner['points'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yesterday\'s Champion!',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  name,
                  style: AppStyles.text16Px.poppins.w700.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$points pts',
              style: AppStyles.text12Px.poppins.w700.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection(List<dynamic> list) {
    final first = list.isNotEmpty ? list[0] : null;
    final second = list.length > 1 ? list[1] : null;
    final third = list.length > 2 ? list[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _buildPodiumSpot(second, '2', '🥈', 90, const Color(0xFF94A3B8)),
          if (first != null) _buildPodiumSpot(first, '1', '🥇', 115, const Color(0xFFF59E0B)),
          if (third != null) _buildPodiumSpot(third, '3', '🥉', 80, const Color(0xFFB45309)),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(Map<String, dynamic> item, String rankStr, String medal, double height, Color color) {
    final name = item['name'] as String? ?? item['customer_name'] as String? ?? 'Member';
    final points = (item['points'] as num?)?.toInt() ?? (item['xp'] as num?)?.toInt() ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          name.split(' ')[0],
          style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$points pts',
          style: AppStyles.text10Px.poppins.w400.copyWith(color: color),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              rankStr,
              style: AppStyles.text24Px.poppins.w800.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, int points, int streak, String profilePic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppStyles.text12Px.poppins.w700.copyWith(
                  color: rank <= 3 ? const Color(0xFFD97706) : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (streak > 0)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 2),
                      Text(
                        '$streak day streak',
                        style: AppStyles.text10Px.poppins.w500.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$points pts',
              style: AppStyles.text12Px.poppins.w700.copyWith(
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
