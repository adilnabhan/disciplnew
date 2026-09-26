import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/all_challenges_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_details_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';

class HomeChallengeSection extends StatefulWidget {
  const HomeChallengeSection({super.key});

  @override
  State<HomeChallengeSection> createState() => _HomeChallengeSectionState();
}

class _HomeChallengeSectionState extends State<HomeChallengeSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _cardWidth = 0;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isAutoScrolling || !_scrollController.hasClients || _cardWidth == 0) return;
      
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) return;

      double nextScroll = _scrollController.offset + _cardWidth + 10.0; // cardWidth + separatorWidth
      if (nextScroll > maxScroll + (_cardWidth / 2)) {
        nextScroll = 0;
      } else if (nextScroll > maxScroll) {
        nextScroll = maxScroll;
      }

      _scrollController.animateTo(
        nextScroll,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeChallengeCubit, HomeChallengeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _HomeChallengeShimmer();
        }
        if (state.errorMessage != null || state.challenges.isEmpty) {
          return const SizedBox.shrink();
        }

        final challenges = state.challenges;

        return LayoutBuilder(
          builder: (context, constraints) {
            final hasMultiple = challenges.length > 1;
            const separatorWidth = 10.0;
            // When multiple challenges exist, show a 22px peek of the next card
            final cardWidth =
                hasMultiple
                    ? (constraints.maxWidth - 32.0)
                    : constraints.maxWidth;
            _cardWidth = cardWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header: "Challenges" + "View All" Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Challenges',
                      style: AppStyles.text18Px.poppins.w700.copyWith(
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        try {
                          context.read<DashboardCubit>().changeNav(index: 3);
                        } catch (_) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AllChallengesScreen(),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: AppStyles.text13Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Horizontal Scrollable Row of Challenge Cards with Peek
                SizedBox(
                  height: 248,
                  child: Listener(
                    onPointerDown: (_) => _isAutoScrolling = false,
                    onPointerUp: (_) => _isAutoScrolling = true,
                    onPointerCancel: (_) => _isAutoScrolling = true,
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: challenges.length,
                      separatorBuilder:
                          (_, __) => const SizedBox(width: separatorWidth),
                      itemBuilder: (context, index) {
                        final challengeItem = challenges[index];
                        return SizedBox(
                          key: ValueKey(
                            'home_challenge_item_${challengeItem.id ?? index}',
                          ),
                          width: cardWidth,
                          child: HomeChallengeCard(
                            key: ValueKey(
                              'home_challenge_card_${challengeItem.id ?? index}',
                            ),
                            challenge: challengeItem,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class HomeChallengeCard extends StatelessWidget {
  const HomeChallengeCard({required this.challenge, super.key});

  final HomeChallenge challenge;

  Color _parseThemeColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) {
      return const Color(0xFFD71920);
    }
    try {
      final cleanHex = colorStr.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (e) {
      debugPrint('Error parsing theme color: $e');
    }
    return const Color(0xFFD71920);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseThemeColor(challenge.themeColor);

    return GestureDetector(
      onTap:
          challenge.id != null
              ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) =>
                            ChallengeDetailsScreen(challengeId: challenge.id!),
                  ),
                );
              }
              : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Panoramic Hero Banner Image with Badges and Brand Info
              _buildHeroBanner(context, challenge, themeColor),

              // 2. Middle Action Row: Joined Members Stack + Action Button
              _buildActionRow(context, challenge, themeColor),

              // 3. Bottom Panel: Countdown Timer or Status Panel
              _buildBottomPanel(context, challenge, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    HomeChallenge challenge,
    Color themeColor,
  ) {
    const bannerHeight = 110.0;
    final heroImg = challenge.heroImageUrl;
    final hasHeroImg = heroImg != null && heroImg.trim().isNotEmpty;

    final tagText =
        (challenge.challengeType != null && challenge.challengeType!.isNotEmpty)
            ? challenge.challengeType!
            : 'LUCKY DRAW';

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (hasHeroImg)
                CachedNetworkImage(
                  imageUrl: heroImg,
                  fit: BoxFit.cover,
                  memCacheWidth: 720,
                  memCacheHeight: 280,
                  fadeInDuration: const Duration(milliseconds: 150),
                  fadeOutDuration: Duration.zero,
                  placeholder: (_, __) => _buildFallbackBannerBackground(),
                  errorWidget: (_, __, ___) => _buildFallbackBannerBackground(),
                )
              else
                _buildFallbackBannerBackground(),

              // Dark Gradient Overlay for Maximum Legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.84),
                      Colors.black.withValues(alpha: 0.50),
                      Colors.black.withValues(alpha: 0.10),
                    ],
                    stops: const [0, 0.62, 1],
                  ),
                ),
              ),

              // Banner Content Overlay
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Tag Badge aligned to the left
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Tag Badge (Right) - White Pill with Red Dice & Text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF1493,
                                ).withValues(alpha: 0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.card_giftcard_rounded,
                                color: Color(0xFFFF1493),
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tagText.toUpperCase(),
                                style: AppStyles.text10Px.poppins.w800.copyWith(
                                  color: const Color(0xFFFF1493),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Brand Logo + Title & Short Description Row
                    Row(
                      children: [
                        // Brand Logo Avatar (Circular with gold border)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(
                              color: const Color(0xFFFBBF24),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                challenge.brand?.logo != null &&
                                        challenge.brand!.logo!.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl: challenge.brand!.logo!,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 100,
                                      memCacheHeight: 100,
                                      fadeInDuration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      fadeOutDuration: Duration.zero,
                                      placeholder:
                                          (_, __) => const ColoredBox(
                                            color: Colors.black,
                                            child: Icon(
                                              Icons.restaurant_rounded,
                                              color: Color(0xFFFBBF24),
                                              size: 24,
                                            ),
                                          ),
                                      errorWidget:
                                          (_, __, ___) => const Icon(
                                            Icons.restaurant_rounded,
                                            color: Color(0xFFFBBF24),
                                            size: 24,
                                          ),
                                    )
                                    : const Icon(
                                      Icons.restaurant_rounded,
                                      color: Color(0xFFFBBF24),
                                      size: 24,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                challenge.name ?? 'Challenge',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text16Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                challenge.shortDescription ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text11Px.poppins.w400.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBannerBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1C16), Color(0xFF1B1410), Color(0xFF0F0B09)],
        ),
      ),
    );
  }

  bool _isChallengeJoined(HomeChallenge challenge) {
    if (challenge.isJoined != null) {
      return challenge.isJoined!;
    }
    final action = challenge.button?.action?.toLowerCase() ?? '';
    final text = challenge.button?.text?.toLowerCase() ?? '';
    if (action == 'join' ||
        text.contains('join now') ||
        text.contains('join after')) {
      return false;
    }
    if (text == 'joined' || text.contains('joined')) {
      return true;
    }
    return false;
  }

  Widget _buildActionRow(
    BuildContext context,
    HomeChallenge challenge,
    Color themeColor,
  ) {
    final isJoined = _isChallengeJoined(challenge);
    final isEnabled = challenge.button?.enabled ?? true;
    final action = challenge.button?.action?.toLowerCase() ?? 'join';
    final footerType =
        challenge.footer?.type?.toLowerCase() ??
        challenge.status?.toLowerCase() ??
        '';
    final footerTitle = challenge.footer?.title?.toLowerCase() ?? '';
    final isWinnerAnnounced =
        (footerType == 'winner' ||
            action == 'winners' ||
            challenge.status?.toLowerCase() == 'winner' ||
            footerTitle.contains('announced')) &&
        !footerTitle.contains('selection');

    final String btnText;
    if (isWinnerAnnounced) {
      btnText = isJoined ? 'Joined' : 'Ended';
    } else if (isJoined) {
      btnText =
          ((challenge.button?.text?.toLowerCase().contains('join after') ??
                  false)
              ? 'Joined'
              : (challenge.button?.text ?? 'Joined'));
    } else {
      btnText = challenge.button?.text ?? 'Join After Workout';
    }

    Color? btnBg;
    Gradient? btnGradient;
    var textColor = Colors.white;
    Border? border;
    List<BoxShadow>? boxShadow;
    Widget? prefixWidget;
    Widget iconWidget;

    if (!isEnabled) {
      btnBg = Colors.grey.shade300;
      textColor = Colors.grey.shade600;
      border = null;
      boxShadow = null;
      iconWidget = const SizedBox.shrink();
    } else if (isJoined && isWinnerAnnounced) {
      btnBg = const Color(0xFFF6F2EC);
      textColor = const Color(0xFF3B230E);
      border = null;
      boxShadow = null;
      prefixWidget = const Padding(
        padding: EdgeInsets.only(right: 6),
        child: Text('🏆', style: TextStyle(fontSize: 13, height: 1.1)),
      );
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.check_rounded, color: Color(0xFF3B230E), size: 15),
      );
    } else if (!isJoined && isWinnerAnnounced) {
      btnBg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF64748B);
      border = Border.all(color: const Color(0xFFE2E8F0));
      boxShadow = null;
      prefixWidget = null;
      iconWidget = const SizedBox.shrink();
    } else if (isJoined) {
      btnGradient = const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF10B981)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
      textColor = Colors.white;
      border = null;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.check_rounded, color: Colors.white, size: 15),
      );
    } else if (action == 'winners') {
      btnBg = const Color(0xFFD97706);
      textColor = Colors.white;
      border = null;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFFD97706).withValues(alpha: 0.28),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 15),
      );
    } else {
      // Default: "Join After Workout >" with Solid Vibrant Red button (as in Image 2)
      btnBg = const Color(0xFFDC2626);
      textColor = Colors.white;
      border = null;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFFDC2626).withValues(alpha: 0.28),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 3),
        child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 17),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Joined Members Avatar Stack + Count
          Expanded(child: _buildJoinedMembersStack(challenge)),
          const SizedBox(width: 8),

          // Right: Action Button
          GestureDetector(
            onTap:
                !isEnabled
                    ? null
                    : () async {
                      if (isWinnerAnnounced || action == 'winners') {
                        if (challenge.id != null) {
                          unawaited(
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) => ChallengeWinnersScreen(
                                      challengeId: challenge.id,
                                    ),
                              ),
                            ),
                          );
                        }
                      } else if (action == 'details') {
                        if (challenge.id != null) {
                          unawaited(
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) => ChallengeDetailsScreen(
                                      challengeId: challenge.id!,
                                    ),
                              ),
                            ),
                          );
                        }
                      } else if (action == 'join') {
                        if (challenge.id != null) {
                          final cubit = context.read<HomeChallengeCubit>();
                          final response = await cubit.joinChallenge(
                            challenge.id!,
                          );
                          if (context.mounted) {
                            final message =
                                response.message ??
                                response.error ??
                                (response.status
                                    ? 'Successfully joined ${challenge.name}!'
                                    : 'Failed to join challenge.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor:
                                    response.status
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      }
                    },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8.5,
              ),
              decoration: BoxDecoration(
                color: btnBg,
                gradient: btnGradient,
                borderRadius: BorderRadius.circular(22),
                border: border,
                boxShadow: boxShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixWidget != null) prefixWidget,
                  Text(
                    btnText,
                    style: AppStyles.text12Px.poppins.w700.copyWith(
                      color: textColor,
                    ),
                  ),
                  iconWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedMembersStack(HomeChallenge challenge) {
    final members = challenge.joinedMembers ?? [];
    final totalCount = challenge.joinedMemberCount ?? members.length;
    final displayMembers = members.take(3).toList();
    final extraCount = totalCount - displayMembers.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayMembers.isNotEmpty)
          SizedBox(
            height: 28,
            width: (displayMembers.length * 16.0) + 12.0,
            child: Stack(
              children: List.generate(displayMembers.length, (index) {
                final member = displayMembers[index];
                return Positioned(
                  left: index * 15.0,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ClipOval(
                      child:
                          member.profileImage != null &&
                                  member.profileImage!.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: member.profileImage!,
                                fit: BoxFit.cover,
                                memCacheWidth: 60,
                                memCacheHeight: 60,
                                fadeInDuration: const Duration(
                                  milliseconds: 150,
                                ),
                                fadeOutDuration: Duration.zero,
                                placeholder:
                                    (_, __) => ColoredBox(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.person,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                errorWidget:
                                    (_, __, ___) => ColoredBox(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.person,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                              : ColoredBox(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                );
              }),
            ),
          ),
        if (extraCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$extraCount joined',
              style: AppStyles.text10Px.poppins.w600.copyWith(
                color: const Color(0xFF334155),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    HomeChallenge challenge,
    Color themeColor,
  ) {
    final footerType =
        challenge.footer?.type?.toLowerCase() ??
        challenge.status?.toLowerCase() ??
        'countdown';
    final footerTitle = challenge.footer?.title;
    final remainingSecs =
        challenge.footer?.remainingSeconds ?? challenge.remainingSeconds ?? 0;
    final footerDate = challenge.footer?.date ?? '';
    final buttonText = challenge.footer?.buttonText ?? 'View Winners';

    final isRewardsDistributed =
        footerType.contains('reward') ||
        footerType.contains('distribut') ||
        (footerTitle != null &&
            footerTitle.toLowerCase().contains('distributed')) ||
        (challenge.status != null &&
            challenge.status!.toLowerCase().contains('distribut'));

    if (isRewardsDistributed) {
      return GestureDetector(
        onTap: () {
          if (challenge.id != null) {
            unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => ChallengeWinnersScreen(challengeId: challenge.id),
                ),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF16A34A),
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      footerTitle ?? 'Rewards Distributed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text12Px.poppins.w700.copyWith(
                        color: const Color(0xFF166534),
                      ),
                    ),
                    Text(
                      footerDate.isNotEmpty
                          ? footerDate
                          : 'Thank you for participating!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (footerType == 'ended') {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Color(0xFF64748B),
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                footerTitle ?? 'Challenge Ended',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (footerType == 'winner') {
      return GestureDetector(
        onTap: () {
          if (challenge.id != null) {
            unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => ChallengeWinnersScreen(challengeId: challenge.id),
                ),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFD97706),
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      footerTitle ?? 'Winners Announced',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text12Px.poppins.w700.copyWith(
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      footerDate.isNotEmpty
                          ? footerDate
                          : "Check if you're one of the lucky winners!",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  buttonText,
                  style: AppStyles.text11Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (footerType == 'upcoming') {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF2563EB),
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    footerTitle ?? 'Challenge Starts On',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.text12Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  if (footerDate.isNotEmpty)
                    Text(
                      footerDate,
                      style: AppStyles.text10Px.poppins.w500.copyWith(
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isWinnerSelection =
        footerType.contains('selection') ||
        (footerTitle != null &&
            footerTitle.toLowerCase().contains('selection')) ||
        (challenge.status != null &&
            challenge.status!.toLowerCase().contains('selection'));

    final String displayTitle;
    final IconData badgeIcon;

    if (isWinnerSelection) {
      displayTitle = 'Selecting Winners';
      badgeIcon = Icons.emoji_events_rounded;
    } else {
      displayTitle = footerTitle ?? 'Challenge ends in';
      badgeIcon = Icons.access_time_rounded;
    }

    // Default: 'countdown' or 'winner selection' - Exactly matches user reference design
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFE4E6), Color(0xFFFFF1F2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE4E6).withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFDA4AF), width: 1.2),
            ),
            child: Icon(
              badgeIcon,
              color: const Color(0xFFE11D48),
              size: isWinnerSelection ? 17 : 16,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                displayTitle,
                style: AppStyles.text14Px.poppins.w800.copyWith(
                  color: const Color(0xFF1E1B4B),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          Container(
            width: 1.2,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFFFDA4AF).withValues(alpha: 0.6),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: _ChallengeCountdownTimer(initialSeconds: remainingSecs),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCountdownTimer extends StatefulWidget {
  const _ChallengeCountdownTimer({required this.initialSeconds});

  final int initialSeconds;

  @override
  State<_ChallengeCountdownTimer> createState() =>
      __ChallengeCountdownTimerState();
}

class __ChallengeCountdownTimerState extends State<_ChallengeCountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ChallengeCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _remainingSeconds = widget.initialSeconds;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildTimerUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDA4AF).withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppStyles.text14Px.poppins.w700.copyWith(
              color: const Color(0xFFE11D48),
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.text9Px.poppins.w500.copyWith(
            color: const Color(0xFF64748B),
            height: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _remainingSeconds > 0 ? _remainingSeconds : 0;
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final daysStr = days.toString().padLeft(2, '0');
    final hoursStr = hours.toString().padLeft(2, '0');
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerUnit(daysStr, 'Days'),
        const SizedBox(width: 4),
        _buildTimerUnit(hoursStr, 'Hours'),
        const SizedBox(width: 4),
        _buildTimerUnit(minsStr, 'Mins'),
        const SizedBox(width: 4),
        _buildTimerUnit(secsStr, 'Secs'),
      ],
    );
  }
}

class _HomeChallengeShimmer extends StatelessWidget {
  const _HomeChallengeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 248,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
