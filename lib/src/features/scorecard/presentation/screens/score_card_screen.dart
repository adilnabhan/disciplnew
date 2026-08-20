import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/settings_screen.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_cubit.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_state.dart';

class ScoreCardScreen extends StatefulWidget {
  const ScoreCardScreen({super.key});

  @override
  State<ScoreCardScreen> createState() => _ScoreCardScreenState();
}

class _ScoreCardScreenState extends State<ScoreCardScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ScoreCardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ScoreCardCubit()..fetchScoreCard();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.fetchScoreCard(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showTimeframePicker(BuildContext context, String currentSelection) {
    final options = [
      {'label': 'Daily', 'value': 'daily'},
      {'label': 'Weekly', 'value': 'weekly'},
      {'label': 'Monthly', 'value': 'monthly'},
      {'label': 'All Time', 'value': 'all_time'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Leaderboard Period',
                  style: AppStyles.text16Px.poppins.w600,
                ),
                const SizedBox(height: 16),
                ...options.map((opt) {
                  final isSelected = currentSelection == opt['value'];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                    title: Text(
                      opt['label']!,
                      style: AppStyles.text14Px.poppins.copyWith(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _cubit.changeTimeframe(opt['value']!);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Score Card Rules', style: AppStyles.text16Px.poppins.w600),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem('💪 Workouts Logged', 'Earn 10 points for every completed workout.'),
            const SizedBox(height: 8),
            _buildRuleItem('🔥 Consistency Streak', 'Maintain daily workout streaks to boost your rank.'),
            const SizedBox(height: 8),
            _buildRuleItem('🏆 Gym Leaderboard', 'Compete with active members of your gym in real-time.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got It', style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.text14Px.poppins.w600.copyWith(fontSize: 13)),
        const SizedBox(height: 2),
        Text(desc, style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.grey.shade600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            'Score Card',
            style: AppStyles.text20Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                context.push(const SettingsScreen());
              },
              child: SvgPicture.asset(
                'assets/images/svg/icons/settings _icon.svg',
                width: 22,
                height: 22,
              ),
            ).pOnly(right: 20),
          ],
        ),
        body: BlocBuilder<ScoreCardCubit, ScoreCardState>(
          builder: (context, state) {
            if (state.status == ScoreCardStatus.loading && state.data == null) {
              return _buildSkeletonLoader();
            }

            if (state.status == ScoreCardStatus.error && state.data == null) {
              return _buildErrorWidget(state.errorMessage);
            }

            final data = state.data;
            if (data == null) {
              return _buildSkeletonLoader();
            }

            if (!data.hasActiveGym) {
              return _buildNoActiveGymWidget(context);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _cubit.fetchScoreCard(refresh: true),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Gym Card
                    if (data.gym != null) ...[
                      _buildActiveGymCard(data.gym!),
                      const SizedBox(height: 14),
                    ],

                    // Leaderboard Period Selector Card
                    _buildPeriodSelectorCard(
                      context,
                      data.period,
                      state.timeframe,
                    ),
                    const SizedBox(height: 16),

                    // Top 3 Podium
                    if (data.podium.isNotEmpty) ...[
                      _buildTop3Podium(data.podium),
                      const SizedBox(height: 16),
                    ],

                    // Current User / My Position Card
                    if (data.myPosition != null || data.me != null) ...[
                      _buildMyPositionCard(
                        data.myPosition ??
                            MyPositionModel(
                              rank: data.me?.rank,
                              points: data.me?.points,
                              streak: data.me?.streak,
                              rankChange: data.me?.rankChange,
                              rankChangeType: data.me?.rankChangeType,
                            ),
                        data.me,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Leaderboard Section
                    _buildLeaderboardSection(state),
                    const SizedBox(height: 20),

                    // Summary Metric Cards Footer
                    _buildSummaryFooter(data),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== ACTIVE GYM CARD ====================
  Widget _buildActiveGymCard(GymScoreCardModel gym) {
    final currentUserCustomer =
        Feggy.read<AppCubit>()?.state.currentUser?.customer;
    final assignedCenter = currentUserCustomer?.assignedFitnessCenter;

    String? fallbackLocation;
    if (assignedCenter != null) {
      if (assignedCenter['location'] is String) {
        fallbackLocation = assignedCenter['location'] as String;
      } else if (assignedCenter['location'] is Map) {
        final locMap = assignedCenter['location'] as Map;
        final city = locMap['city'] ?? locMap['place'] ?? locMap['area'] ?? locMap['address'];
        final state = locMap['state'];
        fallbackLocation = [city, state].where((e) => e != null && e.toString().isNotEmpty).join(', ');
      }
      fallbackLocation ??= assignedCenter['address']?.toString() ??
          assignedCenter['city']?.toString() ??
          assignedCenter['place']?.toString() ??
          assignedCenter['area']?.toString();
    }

    final String locationText = (gym.location != null && gym.location!.trim().isNotEmpty)
        ? gym.location!
        : ((gym.place != null && gym.place!.trim().isNotEmpty)
            ? gym.place!
            : ((fallbackLocation != null && fallbackLocation.trim().isNotEmpty)
                ? fallbackLocation
                : 'Active Member'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gym Logo Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: (gym.logo != null && gym.logo!.isNotEmpty)
                  ? ImageNetwork(
                      gym.logo!,
                      fit: BoxFit.cover,
                      errorWidget: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Gym Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Gym',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  gym.name ?? 'Gym Member',
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        locationText,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9E9E9E),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ==================== PERIOD SELECTOR CARD ====================
  Widget _buildPeriodSelectorCard(
    BuildContext context,
    ScoreCardPeriodModel? period,
    String currentSelection,
  ) {
    final String rangeStr = period?.formattedRange.isNotEmpty == true
        ? period!.formattedRange
        : '01 Aug - 31 Aug 2026';

    final timeframeLabels = {
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'all_time': 'All Time',
    };

    final String selectedLabel = timeframeLabels[currentSelection] ?? 'Monthly';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Red Calendar Container Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Period Dates
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard Period',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rangeStr,
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF212121),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Timeframe Dropdown Button
          GestureDetector(
            onTap: () => _showTimeframePicker(context, currentSelection),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    selectedLabel,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TOP 3 PODIUM ====================
  Widget _buildTop3Podium(List<PodiumMemberModel> podium) {
    PodiumMemberModel? rank1;
    PodiumMemberModel? rank2;
    PodiumMemberModel? rank3;

    for (final member in podium) {
      if (member.rank == 1) rank1 = member;
      if (member.rank == 2) rank2 = member;
      if (member.rank == 3) rank3 = member;
    }

    // Fallbacks if podium list doesn't explicitly flag rank == 1, 2, 3
    if (rank1 == null && podium.isNotEmpty) rank1 = podium[0];
    if (rank2 == null && podium.length > 1) rank2 = podium[1];
    if (rank3 == null && podium.length > 2) rank3 = podium[2];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Confetti Specks
          Positioned.fill(
            child: CustomPaint(
              painter: _PodiumConfettiPainter(),
            ),
          ),

          // Podium Slots Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // #2 Rank (Left)
              Expanded(
                child: rank2 != null
                    ? _buildPodiumSlot(
                        member: rank2,
                        rankNumber: 2,
                        borderColor: const Color(0xFFB0BEC5),
                        badgeColor: const Color(0xFF90A4AE),
                        podiumHeight: 58,
                        starColor: const Color(0xFF90A4AE),
                        capColor: const Color(0xFFCFD8DC),
                      )
                    : const SizedBox.shrink(),
              ),

              // #1 Rank (Center, Elevated & Largest)
              Expanded(
                child: rank1 != null
                    ? _buildPodiumSlot(
                        member: rank1,
                        rankNumber: 1,
                        borderColor: const Color(0xFFFFB300),
                        badgeColor: const Color(0xFFFFB300),
                        podiumHeight: 82,
                        starColor: const Color(0xFFE53935),
                        capColor: const Color(0xFFD32F2F),
                        isWinner: true,
                      )
                    : const SizedBox.shrink(),
              ),

              // #3 Rank (Right)
              Expanded(
                child: rank3 != null
                    ? _buildPodiumSlot(
                        member: rank3,
                        rankNumber: 3,
                        borderColor: const Color(0xFFCD7F32),
                        badgeColor: const Color(0xFFCD7F32),
                        podiumHeight: 44,
                        starColor: const Color(0xFFCD7F32),
                        capColor: const Color(0xFFE0A96D),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSlot({
    required PodiumMemberModel member,
    required int rankNumber,
    required Color borderColor,
    required Color badgeColor,
    required double podiumHeight,
    required Color starColor,
    required Color capColor,
    bool isWinner = false,
  }) {
    final double avatarSize = isWinner ? 70 : 56;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating Crown for #1 Winner
        if (isWinner)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFB300),
              size: 28,
            ),
          )
        else
          const SizedBox(height: 18),

        // Avatar + Rank Badge
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isWinner ? 3.5 : 2.5),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: (member.profileImage != null &&
                        member.profileImage!.isNotEmpty)
                    ? ImageNetwork(
                        member.profileImage!,
                        fit: BoxFit.cover,
                        errorWidget: SvgPicture.asset(
                          'assets/images/svg/icons/person.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.textGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/images/svg/icons/person.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.textGrey,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
            ),
            Positioned(
              top: -6,
              left: -2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rankNumber',
                    style: AppStyles.text12Px.poppins.w700.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // User Card Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                member.name ?? 'Member',
                style: AppStyles.text12Px.poppins.w700.copyWith(
                  color: const Color(0xFF111111),
                  fontSize: isWinner ? 13 : 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${member.points ?? member.currentPoints ?? 0}',
                    style: AppStyles.text14Px.poppins.w800.copyWith(
                      color: const Color(0xFFD32F2F),
                      fontSize: isWinner ? 15 : 13,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'pts',
                    style: AppStyles.text12Px.poppins.w700.copyWith(
                      color: const Color(0xFFD32F2F),
                      fontSize: isWinner ? 13 : 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildRankChangeBadge(
                member.rankChangeType,
                member.rankChange,
                member.previousRank,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 3D Step Base
        Container(
          height: podiumHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Cap colored edge
              Container(
                height: isWinner ? 9 : 7,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: capColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.star_rounded,
                    color: starColor,
                    size: isWinner ? 22 : 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MY POSITION CARD ====================
  Widget _buildMyPositionCard(MyPositionModel myPos, ScoreCardUserModel? me) {
    final int rank = myPos.rank ?? myPos.currentRank ?? me?.rank ?? 0;
    final int points = myPos.points ?? myPos.currentPoints ?? me?.points ?? 0;
    final int streak = myPos.streak ?? me?.streak ?? 0;
    final int? pointsChange = myPos.pointsChange;
    final String? profilePic = me?.profileImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Position',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Large Rank Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank > 0 ? '#$rank' : '-',
                    style: AppStyles.text26Px.poppins.w800.copyWith(
                      color: const Color(0xFF1F1F1F),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRankChangeBadge(
                    myPos.rankChangeType ?? me?.rankChangeType,
                    myPos.rankChange ?? me?.rankChange,
                    myPos.previousRank ?? me?.previousRank,
                  ),
                ],
              ),
              const Spacer(),

              // Profile Avatar with YOU pill badge
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: (profilePic != null && profilePic.isNotEmpty)
                          ? ImageNetwork(
                              profilePic,
                              fit: BoxFit.cover,
                              errorWidget: SvgPicture.asset(
                                'assets/images/svg/icons/person.svg',
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              'assets/images/svg/icons/person.svg',
                              colorFilter: const ColorFilter.mode(
                                AppColors.textGrey,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'YOU',
                        style: AppStyles.text12Px.poppins.w700.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Points Stat Box
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Points',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$points pts',
                    style: AppStyles.text16Px.poppins.w700.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                  if (pointsChange != null && pointsChange > 0)
                    Text(
                      '+ $pointsChange',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Streak Stat Box
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Streak',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$streak days',
                    style: AppStyles.text16Px.poppins.w700.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                  Text(
                    '+ 1 day',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFFFD6D6), height: 1),
          const SizedBox(height: 10),

          // Motivational Quote
          () {
            late final String motivationalMessage;
            late final IconData motivationalIcon;
            late final Color motivationalColor;

            if (points == 0) {
              motivationalMessage =
                  "Log a workout today to get on the leaderboard and start climbing!";
              motivationalIcon = Icons.bolt_rounded;
              motivationalColor = const Color(0xFFD97706);
            } else if (rank == 1) {
              motivationalMessage =
                  "You're at the top! Outstanding work maintaining 1st place.";
              motivationalIcon = Icons.emoji_events_rounded;
              motivationalColor = const Color(0xFFFFB300);
            } else {
              motivationalMessage =
                  "You're doing great! Keep pushing to reach the top.";
              motivationalIcon = Icons.trending_up_rounded;
              motivationalColor = AppColors.primary;
            }

            return Row(
              children: [
                Icon(
                  motivationalIcon,
                  color: motivationalColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    motivationalMessage,
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: motivationalColor == const Color(0xFFFFB300)
                          ? const Color(0xFFD97706)
                          : motivationalColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            );
          }(),
        ],
      ),
    );
  }

  // ==================== RANK CHANGE BADGE ====================
  Widget _buildRankChangeBadge(String? type, int? change, int? prevRank) {
    if (type == 'increased') {
      final changeStr = change != null ? '$change' : '';
      final prevStr = prevRank != null ? ' from #$prevRank' : '';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_drop_up_rounded,
              color: Color(0xFF2E7D32), size: 18),
          Text(
            '$changeStr$prevStr',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: const Color(0xFF2E7D32),
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (type == 'decreased') {
      final changeStr = change != null ? '$change' : '';
      final prevStr = prevRank != null ? ' from #$prevRank' : '';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_drop_down_rounded,
              color: Color(0xFFD32F2F), size: 18),
          Text(
            '$changeStr$prevStr',
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: const Color(0xFFD32F2F),
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (type == 'new') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'NEW',
          style: AppStyles.text12Px.poppins.w700.copyWith(
            color: AppColors.primary,
            fontSize: 9,
          ),
        ),
      );
    }

    // Default / no_change
    final prevStr = prevRank != null ? ' from #$prevRank' : '';
    return Text(
      '—$prevStr',
      style: AppStyles.text12Px.poppins.w500.copyWith(
        color: Colors.grey.shade500,
        fontSize: 11,
      ),
    );
  }

  // ==================== LEADERBOARD SECTION ====================
  Widget _buildLeaderboardSection(ScoreCardState state) {
    final hasPodium = state.data?.podium.isNotEmpty ?? false;
    final List<LeaderboardMemberModel> displayMembers;

    if (hasPodium) {
      displayMembers = state.allLeaderboardMembers.where((m) {
        if (m.rank != null) return m.rank! > 3;
        return state.allLeaderboardMembers.indexOf(m) >= 3;
      }).toList();
    } else {
      displayMembers = state.allLeaderboardMembers;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Headers
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text('Rank',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.grey.shade500, fontSize: 11)),
              ),
              Expanded(
                flex: 3,
                child: Text('Member',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.grey.shade500, fontSize: 11)),
              ),
              Expanded(
                flex: 2,
                child: Text('Points',
                    textAlign: TextAlign.center,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.grey.shade500, fontSize: 11)),
              ),
              Expanded(
                flex: 2,
                child: Text('Streak',
                    textAlign: TextAlign.center,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.grey.shade500, fontSize: 11)),
              ),
              Expanded(
                flex: 2,
                child: Text('Change',
                    textAlign: TextAlign.right,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.grey.shade500, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          if (state.allLeaderboardMembers.isEmpty) ...[
            const SizedBox(height: 20),
            _buildEmptyLeaderboardWidget(),
            const SizedBox(height: 20),
          ] else if (displayMembers.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'All members are featured on the podium! 🏆',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayMembers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
              itemBuilder: (context, index) {
                final member = displayMembers[index];
                return _buildLeaderboardRow(member);
              },
            ),
          ],

          if (state.status == ScoreCardStatus.loadingMore) ...[
            const SizedBox(height: 16),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardMemberModel member) {
    final bool isUser = member.isCurrentUser;
    final int points = member.points ?? member.currentPoints ?? 0;
    final int streak = member.streak ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFFFF5F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 36,
            child: Text(
              '${member.rank ?? '-'}',
              style: AppStyles.text14Px.poppins.w700.copyWith(
                color: isUser ? AppColors.primary : const Color(0xFF424242),
              ),
            ),
          ),

          // Member Avatar & Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUser ? AppColors.primary : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: (member.profileImage != null &&
                            member.profileImage!.isNotEmpty)
                        ? ImageNetwork(
                            member.profileImage!,
                            fit: BoxFit.cover,
                            errorWidget: SvgPicture.asset(
                              'assets/images/svg/icons/person.svg',
                              colorFilter: const ColorFilter.mode(
                                AppColors.textGrey,
                                BlendMode.srcIn,
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/images/svg/icons/person.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.textGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              (member.name != null &&
                                      member.name!.isNotEmpty &&
                                      member.name != 'You')
                                  ? member.name!
                                  : (isUser ? 'You' : 'Member'),
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: isUser
                                    ? AppColors.primary
                                    : const Color(0xFF212121),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUser &&
                              member.name != null &&
                              member.name!.isNotEmpty &&
                              member.name != 'You') ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'YOU',
                                style: AppStyles.text12Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Points
          Expanded(
            flex: 2,
            child: Text(
              '$points pts',
              textAlign: TextAlign.center,
              style: AppStyles.text14Px.poppins.w700.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),

          // Streak
          Expanded(
            flex: 2,
            child: Text(
              '$streak ${streak == 1 ? 'day' : 'days'}',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: const Color(0xFF424242),
                fontSize: 12,
              ),
            ),
          ),

          // Change
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildRankChangeBadge(
                member.rankChangeType,
                member.rankChange,
                member.previousRank,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUMMARY FOOTER METRICS ====================
  Widget _buildSummaryFooter(ScoreCardResponseModel data) {
    final int myRank = data.myPosition?.rank ?? data.me?.rank ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.group_rounded,
            label: 'Total Members',
            value: '${data.totalMembers}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.trending_up_rounded,
            label: 'Your Best Rank',
            value: myRank > 0 ? '#$myRank' : '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.track_changes_rounded,
            label: 'Goal',
            value: 'Top 3',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NO ACTIVE GYM WIDGET ====================
  Widget _buildNoActiveGymWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Gym',
              style: AppStyles.text20Px.poppins.w700.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join a gym to see your Score Card and compete with other members.',
              textAlign: TextAlign.center,
              style: AppStyles.text14Px.poppins.w400.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push(const FitnessCentersListingScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Explore Gyms',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY LEADERBOARD WIDGET ====================
  Widget _buildEmptyLeaderboardWidget() {
    return Column(
      children: [
        const Icon(Icons.emoji_events_outlined,
            color: Colors.grey, size: 36),
        const SizedBox(height: 8),
        Text(
          'No leaderboard data yet.',
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete your workouts and be the first on the Score Card!',
          textAlign: TextAlign.center,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ==================== SKELETON LOADER ====================
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: index == 0 ? 70 : (index == 1 ? 50 : 120),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ERROR WIDGET ====================
  Widget _buildErrorWidget(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load Score Card',
              style: AppStyles.text18Px.poppins.w700.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: AppStyles.text14Px.poppins.w400.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cubit.fetchScoreCard(refresh: true),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text('Retry',
                  style: AppStyles.text14Px.poppins.w600
                      .copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final confettiList = [
      (0.10, 0.08, 4.0, const Color(0xFFFF9800), false),
      (0.22, 0.16, 5.0, const Color(0xFF29B6F6), true),
      (0.06, 0.28, 4.5, const Color(0xFFE53935), false),
      (0.35, 0.06, 6.0, const Color(0xFFFFC107), true),
      (0.48, 0.02, 5.0, const Color(0xFFFF5722), false),
      (0.64, 0.07, 5.5, const Color(0xFFAB47BC), true),
      (0.78, 0.14, 4.0, const Color(0xFF29B6F6), false),
      (0.88, 0.09, 5.0, const Color(0xFFFF9800), true),
      (0.94, 0.26, 4.5, const Color(0xFFE53935), false),
      (0.18, 0.38, 4.0, const Color(0xFFFFC107), false),
      (0.82, 0.36, 5.0, const Color(0xFFFF5722), true),
    ];

    for (final c in confettiList) {
      final paint = Paint()
        ..color = c.$4.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      final center = Offset(size.width * c.$1, size.height * c.$2);
      if (c.$5) {
        canvas.drawCircle(center, c.$3 / 2, paint);
      } else {
        final rect = Rect.fromCenter(center: center, width: c.$3, height: c.$3 * 1.4);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
