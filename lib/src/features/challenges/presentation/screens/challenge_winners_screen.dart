import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/all_challenge_winners_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_details_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:shimmer/shimmer.dart';

class ChallengeWinnersScreen extends StatefulWidget {
  final int? challengeId;
  final ChallengeDetailsResponse? challengeDetails;

  const ChallengeWinnersScreen({
    super.key,
    this.challengeId,
    this.challengeDetails,
  });

  @override
  State<ChallengeWinnersScreen> createState() => _ChallengeWinnersScreenState();
}

class _ChallengeWinnersScreenState extends State<ChallengeWinnersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = true;
  String? _errorMessage;
  AllChallengeWinnersResponse? _response;
  List<ChallengeWinnerItem> _apiWinners = [];

  int _challengeCount = 0;
  int _totalWinners = 0;
  int _totalParticipants = 0;

  String _selectedCategory = 'All Challenges';
  String _selectedTimeframe = 'All Time';
  bool _isLatestFirst = true;

  final List<String> _timeframeOptions = [
    'All Time',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _fetchWinners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWinners({String? searchQuery}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ChallengeRepository().getAllChallengeWinners(
        challengeId: (widget.challengeId != null && widget.challengeId! > 0)
            ? widget.challengeId
            : null,
        search: searchQuery ??
            (_searchController.text.trim().isNotEmpty
                ? _searchController.text.trim()
                : null),
      );

      if (mounted) {
        setState(() {
          _response = response;
          _apiWinners = response.winners;
          _challengeCount =
              response.challengeCount ?? response.totalChallenges ?? 0;
          _totalWinners = response.totalWinners ?? response.winners.length;
          _totalParticipants = response.totalParticipants ??
              response.totalParticipantsCount ??
              0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load winners.';
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchWinners(searchQuery: query);
    });
  }

  List<String> get _categories {
    final list = <String>['All Challenges'];
    for (final w in _apiWinners) {
      if (w.challengeName != null &&
          w.challengeName!.isNotEmpty &&
          !list.contains(w.challengeName)) {
        list.add(w.challengeName!);
      }
    }
    return list;
  }

  List<ChallengeWinnerItem> get _filteredWinners {
    final query = _searchController.text.trim().toLowerCase();
    var list = _apiWinners.where((w) {
      final name = w.userName?.toLowerCase() ?? '';
      final cName = w.challengeName?.toLowerCase() ?? '';
      final prize = (w.prizeTitle ?? w.prize)?.toLowerCase() ?? '';

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          cName.contains(query) ||
          prize.contains(query);

      final matchesCategory = _selectedCategory == 'All Challenges' ||
          cName == _selectedCategory.toLowerCase() ||
          cName.contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();

    if (!_isLatestFirst) {
      list = list.reversed.toList();
    }
    return list;
  }

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return '$num';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4E4E7), width: 0.8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF18181B),
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'All Winners ',
                      style: AppStyles.text18Px.poppins.w700.copyWith(
                        color: const Color(0xFF18181B),
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      '🏆',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Celebrate our champions!',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWinners,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Metrics Card
              _buildSummaryStatsCard(),
              const SizedBox(height: 16),

              // 3. Category Filter Chips (Horizontal Scroll)
              if (_categories.length > 1) ...[
                _buildCategoryChips(),
                const SizedBox(height: 16),
              ],

              // 4. Section Header: All Challenge Winners + Latest First Toggle
              _buildSectionHeader(),
              const SizedBox(height: 12),

              // 5. Winner Cards List / Loading / Empty
              if (_isLoading)
                _buildLoadingShimmer()
              else if (_errorMessage != null)
                _buildErrorWidget()
              else if (_filteredWinners.isEmpty)
                _buildEmptyWidget()
              else
                ..._filteredWinners.map((winner) => _buildWinnerCard(winner)),

              const SizedBox(height: 8),

              // 6. Bottom Banner Card: "Be the next champion!"
              _buildBottomBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Summary Statistics Card (Total Winners, Challenges, Participants)
  Widget _buildSummaryStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4F4F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events_rounded,
              value: _formatNumber(_totalWinners),
              label: 'Total Winners',
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_today_rounded,
              value: _formatNumber(_challengeCount),
              label: 'Challenges',
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.group_rounded,
              value: _formatNumber(_totalParticipants),
              label: 'Participants',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF0F2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD71920),
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.text20Px.poppins.w700.copyWith(
            color: const Color(0xFF18181B),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: const Color(0xFF71717A),
            fontSize: 11,
          ),
        ),
      ],
    );
  }



  // 3. Category Filter Chips (Horizontal Scroll)
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD71920) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD71920)
                        : const Color(0xFFE4E4E7),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFD71920).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getCategoryIcon(cat, isSelected),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color:
                            isSelected ? Colors.white : const Color(0xFF27272A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getCategoryIcon(String category, bool isSelected) {
    final color = isSelected ? Colors.white : const Color(0xFF27272A);

    if (category == 'All Challenges') {
      return Icon(Icons.grid_view_rounded, size: 16, color: color);
    } else {
      return Icon(Icons.emoji_events_rounded, size: 16, color: color);
    }
  }

  // 4. Section Header: All Challenge Winners + Latest First Toggle
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Challenge Winners',
          style: AppStyles.text15Px.poppins.w700.copyWith(
            color: const Color(0xFF18181B),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isLatestFirst = !_isLatestFirst;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLatestFirst ? 'Latest First' : 'Oldest First',
                style: AppStyles.text13Px.poppins.w600.copyWith(
                  color: const Color(0xFFD71920),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.unfold_more_rounded,
                color: Color(0xFFD71920),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Single Winner Card Widget
  Widget _buildWinnerCard(ChallengeWinnerItem winner) {
    final String name = winner.userName ?? 'Winner';
    final String challengeName = winner.challengeName ?? 'Challenge';
    final String prize = winner.prizeTitle ?? winner.prize ?? 'Prize';
    final String date = winner.date ?? 'Recent';
    final String avatarUrl = winner.profilePic ?? '';
    final String winnerTagLabel =
        winner.selectionMethodDisplay ?? 'Lucky Draw';

    const Color themeColor = Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4F4F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Winner Profile Avatar
          _buildAvatar(avatarUrl),
          const SizedBox(width: 12),

          // Center Column: Challenge Pill + Winner Name + Selection Method Label
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Challenge Name Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    challengeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFFD71920),
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Winner Name
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.text15Px.poppins.w700.copyWith(
                    color: const Color(0xFF18181B),
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Selection Method (e.g. ✦ Lucky Draw)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✦ ',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeColor,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        winnerTagLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: themeColor,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Right Column: Prize + Date
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Prize Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        prize,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: const Color(0xFF27272A),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Date String
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 10,
                      color: Color(0xFFA1A1AA),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFFA1A1AA),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Left Winner Profile Avatar Builder
  Widget _buildAvatar(String avatarUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE4E4E7),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? ImageNetwork(
                avatarUrl,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: const Color(0xFFF4F4F5),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFA1A1AA),
                    size: 26,
                  ),
                ),
              )
            : Container(
                color: const Color(0xFFF4F4F5),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFA1A1AA),
                  size: 26,
                ),
              ),
      ),
    );
  }

  // Loading Shimmer Placeholder
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Error State Widget
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD71920),
            size: 42,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Failed to load winners',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _fetchWinners,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD71920),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Retry',
                style: AppStyles.text13Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4F4F5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'No winners found',
            style: AppStyles.text15Px.poppins.w700.copyWith(
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Winners will be announced soon after challenge completion.',
            textAlign: TextAlign.center,
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: const Color(0xFF71717A),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Bottom Banner Card: "Be the next champion!"
  Widget _buildBottomBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Golden Trophy Graphic
          const Text(
            '🏆',
            style: TextStyle(fontSize: 34),
          ),
          const SizedBox(width: 12),

          // Banner Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Be the next champion!',
                  style: AppStyles.text15Px.poppins.w700.copyWith(
                    color: const Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Join challenges, stay consistent and win exciting rewards.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF71717A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Button: Explore Challenges >
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD71920),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD71920).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore Challenges',
                    style: AppStyles.text12Px.poppins.w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 16,
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
