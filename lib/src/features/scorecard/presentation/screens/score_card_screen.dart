import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/settings_screen.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_cubit.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_state.dart';
import 'package:customer_mobile_app/src/features/scorecard/presentation/widgets/score_card_how_it_works_sheet.dart';

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
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
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

  void _showHowItWorksSheet(BuildContext context) {
    final currentScore = _cubit.state.data?.myPosition?.points ??
        _cubit.state.data?.myPosition?.currentPoints ??
        _cubit.state.data?.me?.points ??
        0;
    ScoreCardHowItWorksSheet.show(context, currentScore: currentScore);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.bgcolorgrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 16,
          title: Text(
            'Score Card',
            style: AppStyles.text20Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
          actions: [
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.push(const SettingsScreen());
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF1F4),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/svg/icons/settings _icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1F2937),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                padding:
                    const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centered capsule period selector with right info button
                    _buildHeaderControls(state),
                    const SizedBox(height: 10),

                    // 3D Isometric Podium
                    _build3DPodium(data.podium),
                    const SizedBox(height: 16),

                    // My Position Card
                    _buildMyPositionCard(data),
                    const SizedBox(height: 16),

                    // Leaderboard Card
                    _buildLeaderboardCard(state, data),
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

  // ==================== HEADER CONTROLS ====================
  Widget _buildHeaderControls(ScoreCardState state) {
    final timeframeLabels = {
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'all_time': 'All Time',
    };
    final String selectedLabel = timeframeLabels[state.timeframe] ?? 'Monthly';

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Timeframe Capsule Button
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showTimeframePicker(context, state.timeframe),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 38, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF1F4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedLabel,
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right-aligned Circular Info Button
          Positioned(
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showHowItWorksSheet(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF1F4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 3D ISOMETRIC PODIUM ====================
  Widget _build3DPodium(List<PodiumMemberModel> podium) {
    PodiumMemberModel? rank1;
    PodiumMemberModel? rank2;
    PodiumMemberModel? rank3;

    for (final member in podium) {
      if (member.rank == 1) rank1 = member;
      if (member.rank == 2) rank2 = member;
      if (member.rank == 3) rank3 = member;
    }

    if (rank1 == null && podium.isNotEmpty) rank1 = podium[0];
    if (rank2 == null && podium.length > 1) rank2 = podium[1];
    if (rank3 == null && podium.length > 2) rank3 = podium[2];

    rank1 ??= const PodiumMemberModel(rank: 1, name: '—', points: 0);
    rank2 ??= const PodiumMemberModel(rank: 2, name: '—', points: 0);
    rank3 ??= const PodiumMemberModel(rank: 3, name: '—', points: 0);

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2 (Left - Silver)
          Expanded(
            flex: 10,
            child: _buildPodiumRank2(rank2),
          ),

          // Rank 1 (Center - Gold)
          Expanded(
            flex: 13,
            child: _buildPodiumRank1(rank1),
          ),

          // Rank 3 (Right - Bronze)
          Expanded(
            flex: 10,
            child: _buildPodiumRank3(rank3),
          ),
        ],
      ),
    );
  }

  // Rank 2 Column (Silver)
  Widget _buildPodiumRank2(PodiumMemberModel member) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: _buildAvatar(member.profileImage, size: 56),
          ),
        ),
        const SizedBox(height: 8),

        // Member Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(
                member.name ?? 'Member',
                style: AppStyles.text13Px.poppins.w700.copyWith(
                  color: const Color(0xFF111827),
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Points
        Text(
          '${member.points ?? member.currentPoints ?? 0} pts',
          style: AppStyles.text13Px.poppins.w700.copyWith(
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),

        // Isometric Top Face with true elliptical cast shadow
        ClipPath(
          clipper: _LeftPodiumTopClipper(),
          child: Container(
            height: 24,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 62,
                height: 16,
                child: CustomPaint(
                  painter: _PodiumShadowPainter(
                    color: Color(0x30000000),
                    blurRadius: 4.0,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Front Face
        Container(
          height: 110,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD8DDE6), Color(0xFFBAC2D0)],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '2',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Color(0xFF475569),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  // Rank 1 Column (Gold)
  Widget _buildPodiumRank1(PodiumMemberModel member) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Golden Glow + Crown
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.38),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _buildAvatar(member.profileImage, size: 68),
              ),
            ),
            // Tilted Gold Crown on Top Right
            Positioned(
              top: -8,
              right: 2,
              child: Transform.rotate(
                angle: 0.35, // ~20 degrees tilt
                child: const SizedBox(
                  width: 24,
                  height: 20,
                  child: CustomPaint(
                    painter: _CrownPainter(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Member Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            height: 22,
            child: Text(
              member.name ?? 'Member',
              style: AppStyles.text15Px.poppins.w700.copyWith(
                color: const Color(0xFF111827),
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Points
        Text(
          '${member.points ?? member.currentPoints ?? 0} pts',
          style: AppStyles.text14Px.poppins.w700.copyWith(
            color: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(height: 8),

        // Isometric Top Face with true elliptical cast shadow
        ClipPath(
          clipper: _CenterPodiumTopClipper(),
          child: Container(
            height: 24,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDE68A), Color(0xFFFCD34D)],
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 76,
                height: 18,
                child: CustomPaint(
                  painter: _PodiumShadowPainter(
                    color: Color(0x38000000),
                    blurRadius: 4.5,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Front Face
        Container(
          height: 172,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFDE047),
                Color(0xFFFACC15),
                Color(0xFFEAB308),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '1',
            style: TextStyle(
              fontSize: 66,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB45309),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  // Rank 3 Column (Bronze / Terracotta)
  Widget _buildPodiumRank3(PodiumMemberModel member) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE29A83), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: _buildAvatar(member.profileImage, size: 56),
          ),
        ),
        const SizedBox(height: 8),

        // Member Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(
                member.name ?? 'Member',
                style: AppStyles.text13Px.poppins.w700.copyWith(
                  color: const Color(0xFF111827),
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Points
        Text(
          '${member.points ?? member.currentPoints ?? 0} pts',
          style: AppStyles.text13Px.poppins.w700.copyWith(
            color: const Color(0xFF8C4634),
          ),
        ),
        const SizedBox(height: 8),

        // Isometric Top Face with true elliptical cast shadow
        ClipPath(
          clipper: _RightPodiumTopClipper(),
          child: Container(
            height: 24,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEBB29F), Color(0xFFDEA18D)],
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 62,
                height: 16,
                child: CustomPaint(
                  painter: _PodiumShadowPainter(
                    color: Color(0x30000000),
                    blurRadius: 4.0,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Front Face
        Container(
          height: 72,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE5A18C), Color(0xFFD28771)],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '3',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7C2D12),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  // ==================== MY POSITION CARD ====================
  Widget _buildMyPositionCard(ScoreCardResponseModel data) {
    final myPos = data.myPosition;
    final me = data.me;
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final String currentUserName =
        '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
    final String? currentUserPic = currentUser?.profilePicture is String &&
            (currentUser?.profilePicture as String).isNotEmpty
        ? currentUser?.profilePicture as String
        : null;

    final int rank = myPos?.rank ?? myPos?.currentRank ?? me?.rank ?? 0;
    final int points =
        myPos?.points ?? myPos?.currentPoints ?? me?.points ?? 0;
    final String name = (me?.name != null && me!.name!.isNotEmpty)
        ? me.name!
        : (currentUserName.isNotEmpty ? currentUserName : 'You');
    final String? profilePic = me?.profileImage ?? currentUserPic;

    // Rank tier & progress to next tier
    final currentTier = UserRankTier.getTierForScore(points);
    final nextTier = UserRankTier.getNextTier(currentTier);

    final String currentTierName =
        myPos?.currentRankName ?? data.currentRank ?? currentTier.name;
    final String currentTierEmoji =
        myPos?.rankEmoji ?? data.rankEmoji ?? currentTier.emoji;

    final String? nextTierName =
        myPos?.nextRank ?? data.nextRank ?? nextTier?.name;
    final String? nextTierEmoji =
        myPos?.nextRankEmoji ?? data.nextRankEmoji ?? nextTier?.emoji;
    final int nextMinScore =
        myPos?.nextRankScore ?? data.nextRankScore ?? (nextTier?.minScore ?? 500);

    final int remainingPts = myPos?.remainingScoreToNextRank ??
        data.remainingScoreToNextRank ??
        (nextTier != null ? (nextTier.minScore - points).clamp(0, nextTier.minScore) : 0);

    final double progressFraction = (nextTier != null)
        ? ((points - currentTier.minScore) /
                (nextMinScore - currentTier.minScore))
            .clamp(0.0, 1.0)
        : 1.0;
    final int progressPercent = (progressFraction * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Giant Rank Numeral
              Text(
                rank > 0 ? '$rank' : '-',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF59E0B),
                  height: 1.0,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 10),

              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: _buildAvatar(profilePic, size: 40),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Points
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$points pts',
                          style: AppStyles.text14Px.poppins.w700.copyWith(
                            color: const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'You',
                            style: AppStyles.text13Px.poppins.w700.copyWith(
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Streak Card
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 3),
                          Text(
                            '${myPos?.streak ?? me?.streak ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFDC2626),
                              fontFamily: 'Poppins',
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Streak',
                        style: AppStyles.text9Px.poppins.w600.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Divider
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFFDE68A).withOpacity(0.6),
          ),
          const SizedBox(height: 10),

          // Rank & Next Rank Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentTierEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    currentTierName,
                    style: AppStyles.text13Px.poppins.w700.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              if (nextTierName != null)
                Text(
                  remainingPts > 0
                      ? '$remainingPts pts to ${nextTierEmoji ?? ''} $nextTierName'
                      : 'Max Rank Reached',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 7,
              backgroundColor: const Color(0xFFFDE68A).withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 6),

          // Progress Min / Max Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentTier.minScore} pts',
                style: AppStyles.text10Px.poppins.w500.copyWith(
                  color: const Color(0xFF78350F).withOpacity(0.7),
                ),
              ),
              Text(
                '$progressPercent%',
                style: AppStyles.text10Px.poppins.w700.copyWith(
                  color: const Color(0xFF92400E),
                ),
              ),
              Text(
                nextTier != null ? '${nextMinScore} pts' : 'Max',
                style: AppStyles.text10Px.poppins.w500.copyWith(
                  color: const Color(0xFF78350F).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== LEADERBOARD CARD ====================
  Widget _buildLeaderboardCard(
      ScoreCardState state, ScoreCardResponseModel data) {
    // Leaderboard list starts from rank 4 (ranks 1-3 are displayed in the podium)
    final Map<String, LeaderboardMemberModel> memberMap = {};

    final sourceMembers = state.allLeaderboardMembers.isNotEmpty
        ? state.allLeaderboardMembers
        : data.leaderboard;

    for (final m in sourceMembers) {
      // Exclude ranks 1, 2, and 3
      if (m.rank != null && m.rank! < 4) continue;

      // Also ensure members already in podium aren't duplicated
      final isPodium = data.podium.any((p) =>
          (p.userId != null && p.userId == m.userId) ||
          (p.customerId != null && p.customerId == m.customerId) ||
          (p.name != null &&
              m.name != null &&
              p.name!.trim().toLowerCase() == m.name!.trim().toLowerCase()));
      if (isPodium) continue;

      final key = (m.userId != null)
          ? 'u_${m.userId}'
          : ((m.customerId != null)
              ? 'c_${m.customerId}'
              : ((m.name != null && m.name!.isNotEmpty)
                  ? 'n_${m.name}'
                  : 'r_${m.rank}'));
      memberMap[key] = m;
    }

    final allMembers = memberMap.values.toList()
      ..sort((a, b) => (a.rank ?? 9999).compareTo(b.rank ?? 9999));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard',
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),

          if (allMembers.isEmpty) ...[
            const SizedBox(height: 20),
            _buildEmptyLeaderboardWidget(),
            const SizedBox(height: 20),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allMembers.length,
              itemBuilder: (context, index) {
                final member = allMembers[index];
                return _buildLeaderboardRow(member, index, data);
              },
            ),
          ],

          if (state.status == ScoreCardStatus.loadingMore) ...[
            const SizedBox(height: 12),
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

  Widget _buildLeaderboardRow(
    LeaderboardMemberModel member,
    int index,
    ScoreCardResponseModel data,
  ) {
    final bool isUser = _checkIsCurrentUser(member, data);
    final int rank = member.rank ?? (index + 4);
    final int points = member.points ?? member.currentPoints ?? 0;

    final Color rankColor;
    final Color pointsColor;

    if (rank == 1) {
      rankColor = const Color(0xFFD97706);
      pointsColor = const Color(0xFFD97706);
    } else if (rank == 2) {
      rankColor = const Color(0xFF64748B);
      pointsColor = const Color(0xFF475569);
    } else if (rank == 3) {
      rankColor = const Color(0xFFB45309);
      pointsColor = const Color(0xFF8C4634);
    } else {
      rankColor = const Color(0xFF94A3B8);
      pointsColor = const Color(0xFF64748B);
    }

    final int streak = member.streak ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFFFFBEB) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: rankColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: _buildAvatar(member.profileImage, size: 36),
            ),
          ),
          const SizedBox(width: 12),

          // Member Name
          Expanded(
            child: Text(
              member.name ?? 'Member',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: const Color(0xFF1F2937),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Streak
          if (streak > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    '$streak',
                    style: AppStyles.text10Px.poppins.w700.copyWith(
                      color: const Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Points
          Text(
            '$points pts',
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: pointsColor,
            ),
          ),
        ],
      ),
    );
  }

  bool _checkIsCurrentUser(
      LeaderboardMemberModel member, ScoreCardResponseModel data) {
    if (member.isCurrentUser) return true;

    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final currentUserId = currentUser?.id;
    final currentCustomerId = currentUser?.customer?.id;

    if (currentUserId != null &&
        member.userId != null &&
        currentUserId == member.userId) {
      return true;
    }
    if (currentCustomerId != null &&
        member.customerId != null &&
        currentCustomerId == member.customerId) {
      return true;
    }

    final myRank = data.myPosition?.rank ??
        data.myPosition?.currentRank ??
        data.me?.rank;
    if (myRank != null && myRank > 0 && member.rank == myRank) {
      final appUserName =
          '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
      final myName =
          data.me?.name ?? (appUserName.isNotEmpty ? appUserName : null);
      if (myName != null &&
          member.name != null &&
          myName.trim().toLowerCase() == member.name!.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  // ==================== AVATAR BUILDER ====================
  Widget _buildAvatar(String? url, {required double size}) {
    if (url != null && url.isNotEmpty) {
      return ImageNetwork(
        url,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: const Color(0xFFF1F5F9),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/images/svg/icons/person.svg',
            width: size * 0.6,
            height: size * 0.6,
            colorFilter: const ColorFilter.mode(
              AppColors.textGrey,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/svg/icons/person.svg',
        width: size * 0.6,
        height: size * 0.6,
        colorFilter: const ColorFilter.mode(
          AppColors.textGrey,
          BlendMode.srcIn,
        ),
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
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: index == 0 ? 50 : (index == 1 ? 220 : 120),
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

// ==================== 3D PODIUM ISOMETRIC CLIPPERS ====================

class _LeftPodiumTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.08, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _CenterPodiumTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.06, 0);
    path.lineTo(size.width * 0.94, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RightPodiumTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.92, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ==================== GOLD CROWN PAINTER ====================

class _CrownPainter extends CustomPainter {
  final Color color;
  const _CrownPainter({this.color = const Color(0xFFFBBF24)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // 3-point crown with center peak tallest
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width * 0.95, size.height * 0.18);
    path.lineTo(size.width * 0.65, size.height * 0.55);
    path.lineTo(size.width * 0.50, 0);
    path.lineTo(size.width * 0.35, size.height * 0.55);
    path.lineTo(size.width * 0.05, size.height * 0.18);
    path.close();

    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== PODIUM CAST SHADOW PAINTER ====================

class _PodiumShadowPainter extends CustomPainter {
  final Color color;
  final double blurRadius;

  const _PodiumShadowPainter({
    this.color = const Color(0x38000000),
    this.blurRadius = 4.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - (blurRadius * 2),
      height: size.height - (blurRadius * 2),
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _PodiumShadowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.blurRadius != blurRadius;
}
