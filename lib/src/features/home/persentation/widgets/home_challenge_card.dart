import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/all_challenges_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_details_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_challenge_cubit.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_challenge_state.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_challenge_model.dart';
import 'package:shimmer/shimmer.dart';

class HomeChallengeSection extends StatelessWidget {
  const HomeChallengeSection({super.key});

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
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = challenges.length == 1
            ? (screenWidth - 32.0)
            : (screenWidth - 64.0);

        return Column(
          children: [
            // Horizontal Scrollable Row of Challenge Cards
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: cardWidth,
                    child: HomeChallengeCard(challenge: challenges[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomeChallengeCard extends StatelessWidget {
  final HomeChallenge challenge;

  const HomeChallengeCard({
    super.key,
    required this.challenge,
  });

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

  Widget _buildChallengeTypeBadge(String type, Color themeColor) {
    final lower = type.trim().toLowerCase();
    IconData iconData;

    if (lower.contains('lucky') || lower.contains('draw')) {
      iconData = Icons.card_giftcard_rounded;
    } else if (lower.contains('performance')) {
      iconData = Icons.emoji_events_rounded;
    } else {
      iconData = Icons.verified_rounded;
    }

    final bgColor = themeColor.withValues(alpha: 0.1);
    final borderColor = themeColor.withValues(alpha: 0.3);
    final textColor = themeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 3),
          Text(
            type.toUpperCase(),
            style: AppStyles.text12Px.poppins.w700.copyWith(
              fontSize: 9.5,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseThemeColor(challenge.themeColor);
    final joinedMembers = challenge.joinedMembers ?? [];
    final displayMembers = joinedMembers.take(4).toList();
    return GestureDetector(
      onTap: challenge.id != null
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChallengeDetailsScreen(challengeId: challenge.id!),
                ),
              );
            }
          : null,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top & Middle Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Brand Logo, Challenge Name/Description, Type Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: challenge.brand?.logo != null &&
                                challenge.brand!.logo!.isNotEmpty
                            ? ImageNetwork(
                                challenge.brand!.logo!,
                                fit: BoxFit.cover,
                                errorWidget: Icon(
                                  Icons.fitness_center_rounded,
                                  color: themeColor,
                                  size: 28,
                                ),
                              )
                            : Icon(
                                Icons.fitness_center_rounded,
                                color: themeColor,
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Challenge Name & Short Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name ?? 'Challenge',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            challenge.shortDescription ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF666666),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status / Challenge Type Badges
                    Builder(
                      builder: (context) {
                        final statusStr = challenge.status?.toLowerCase() ?? '';
                        final footerTypeStr = challenge.footer?.type?.toLowerCase() ?? '';
                        final isUpcoming = statusStr == 'upcoming' || footerTypeStr == 'upcoming';

                        if (isUpcoming) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: themeColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '⏳ UPCOMING',
                              style: AppStyles.text10Px.poppins.w700.copyWith(
                                color: themeColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          );
                        } else if (challenge.challengeType != null &&
                            challenge.challengeType!.isNotEmpty) {
                          return _buildChallengeTypeBadge(challenge.challengeType!, themeColor);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Middle Row: Joined Avatars + Count, Join Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Joined Member Avatars + Text
                    Expanded(
                      child: Row(
                        children: [
                          if (displayMembers.isNotEmpty)
                            SizedBox(
                              height: 28,
                              width: (displayMembers.length * 18.0) + 10.0,
                              child: Stack(
                                children: List.generate(displayMembers.length, (index) {
                                  final member = displayMembers[index];
                                  return Positioned(
                                    left: index * 18.0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: member.profileImage != null &&
                                                member.profileImage!.isNotEmpty
                                            ? ImageNetwork(
                                                member.profileImage!,
                                                fit: BoxFit.cover,
                                                errorWidget: ColoredBox(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : ColoredBox(
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          if (displayMembers.isNotEmpty)
                            const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${challenge.joinedMemberCount ?? 0} members joined',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.text13Px.poppins.w500.copyWith(
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Action / Join Button
                    Builder(
                      builder: (context) {
                        final btnText = challenge.button?.text ?? 'Join Now';
                        final action = challenge.button?.action?.toLowerCase() ?? 'join';
                        final isEnabled = challenge.button?.enabled ?? true;

                        Color btnBg;
                        Widget iconWidget;

                        if (!isEnabled) {
                          btnBg = Colors.grey.shade400;
                          iconWidget = const SizedBox.shrink();
                        } else if (action == 'details' || challenge.isJoined == true) {
                          btnBg = themeColor;
                          iconWidget = const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          );
                        } else if (action == 'winners') {
                          btnBg = themeColor;
                          iconWidget = const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 16),
                          );
                        } else {
                          btnBg = themeColor;
                          iconWidget = const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                          );
                        }

                        return GestureDetector(
                          onTap: !isEnabled
                              ? null
                              : () async {
                                  if (action == 'winners') {
                                    if (challenge.id != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChallengeWinnersScreen(challengeId: challenge.id!),
                                        ),
                                      );
                                    }
                                  } else if (action == 'details') {
                                    if (challenge.id != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChallengeDetailsScreen(challengeId: challenge.id!),
                                        ),
                                      );
                                    }
                                  } else if (action == 'join') {
                                    if (challenge.id != null) {
                                      final cubit = context.read<HomeChallengeCubit>();
                                      final response = await cubit.joinChallenge(challenge.id!);
                                      if (context.mounted) {
                                        final message = response.message ??
                                            response.error ??
                                            (response.status
                                                ? 'Successfully joined ${challenge.name}!'
                                                : 'Failed to join challenge.');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(message),
                                            backgroundColor: response.status
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
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: btnBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: !isEnabled
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: btnBg.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  btnText,
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                iconWidget,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Bar: Rendered dynamically based on footer.type
          Builder(
            builder: (context) {
              final footerType = challenge.footer?.type?.toLowerCase() ?? challenge.status?.toLowerCase() ?? 'countdown';
              final footerTitle = challenge.footer?.title;
              final remainingSecs = challenge.footer?.remainingSeconds ?? challenge.remainingSeconds ?? 0;
              final footerDate = challenge.footer?.date ?? '';
              final buttonText = challenge.footer?.buttonText ?? 'View Winners';

              final isRewardsDistributed = footerType.contains('reward') ||
                  footerType.contains('distribut') ||
                  (footerTitle != null && footerTitle.toLowerCase().contains('distributed')) ||
                  (challenge.status != null && challenge.status!.toLowerCase().contains('distribut'));

              if (isRewardsDistributed) {
                return GestureDetector(
                  onTap: () {
                    if (challenge.id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChallengeWinnersScreen(challengeId: challenge.id!),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset(
                            'assets/images/png/icons/Giftbox_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.card_giftcard_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                footerTitle ?? 'Rewards Distributed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text13Px.poppins.w700.copyWith(color: Colors.white),
                              ),
                              Text(
                                footerDate.isNotEmpty ? footerDate : 'Thank you for participating!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white.withValues(alpha: 0.9)),
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
                  height: 52,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '🏁 ${footerTitle ?? 'Challenge Ended'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.text13Px.poppins.w600.copyWith(color: Colors.white),
                        ),
                      ),
                      if (footerDate.isNotEmpty)
                        Text(
                          footerDate,
                          style: AppStyles.text13Px.poppins.w500.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                    ],
                  ),
                );
              }

              if (footerType == 'winner') {
                return GestureDetector(
                  onTap: () {
                    if (challenge.id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChallengeWinnersScreen(challengeId: challenge.id!),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '🏆 ${footerTitle ?? 'Winners Announced'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text13Px.poppins.w600.copyWith(color: Colors.white),
                          ),
                        ),
                        Text(
                          '$buttonText →',
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (footerType == 'upcoming') {
                return Container(
                  height: 52,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '⏳ ${footerTitle ?? 'Challenge Starts On'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.text13Px.poppins.w600.copyWith(color: Colors.white),
                        ),
                      ),
                      if (footerDate.isNotEmpty)
                        Text(
                          footerDate,
                          style: AppStyles.text13Px.poppins.w500.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                    ],
                  ),
                );
              }

              // Default: footer.type == 'countdown'
              return Container(
                height: 52,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        footerTitle ?? 'Challenge ends in:',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text13Px.poppins.w600.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _ChallengeCountdownTimer(
                        initialSeconds: remainingSecs,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}

class _ChallengeCountdownTimer extends StatefulWidget {
  final int initialSeconds;

  const _ChallengeCountdownTimer({
    required this.initialSeconds,
  });

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

  Widget _buildTimerBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.6,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: AppStyles.text9Px.poppins.w400.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        ':',
        style: AppStyles.text14Px.poppins.w700.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int seconds = _remainingSeconds > 0 ? _remainingSeconds : 0;
    final int days = seconds ~/ 86400;
    final int hours = (seconds % 86400) ~/ 3600;
    final int mins = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    final String daysStr = days.toString().padLeft(2, '0');
    final String hoursStr = hours.toString().padLeft(2, '0');
    final String minsStr = mins.toString().padLeft(2, '0');
    final String secsStr = secs.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerBox(daysStr, 'Days'),
        _buildColon(),
        _buildTimerBox(hoursStr, 'Hours'),
        _buildColon(),
        _buildTimerBox(minsStr, 'Mins'),
        _buildColon(),
        _buildTimerBox(secsStr, 'Secs'),
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
        height: 195,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
