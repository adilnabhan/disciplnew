import 'dart:async';
import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';

class ChallengeItemCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTapDetails;

  const ChallengeItemCard({
    super.key,
    required this.challenge,
    this.onTapDetails,
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

  Widget _buildActionButton(BuildContext context, Color themeColor) {
    final btnText = challenge.button?.text ?? 'Join Now';
    final action = challenge.button?.action?.toLowerCase() ?? 'join';
    final isEnabled = challenge.button?.enabled ?? true;

    Color btnBg;
    Color textColor = Colors.white;
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
                if (onTapDetails != null) {
                  onTapDetails!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Challenge Details for ${challenge.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              } else if (action == 'join') {
                if (challenge.id != null) {
                  final cubit = context.read<ChallengeListCubit>();
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
                        backgroundColor:
                            response.status ? Colors.green.shade700 : Colors.red.shade700,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: textColor,
              ),
            ),
            iconWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ChallengeProgress progress, Color themeColor) {
    final title = progress.title ?? 'Workout';
    final current = progress.current ?? 0;
    final target = progress.target ?? 0;
    final pct = (progress.percentage ?? 0).toDouble().clamp(0.0, 100.0);
    final is100Pct = pct >= 100.0;
    final progressColor = is100Pct ? const Color(0xFF16A34A) : themeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Progress ($title: $current/$target)',
              style: AppStyles.text13Px.poppins.w500.copyWith(
                color: const Color(0xFF4B5563),
              ),
            ),
            Text(
              '${pct.toInt()}%',
              style: AppStyles.text14Px.poppins.w700.copyWith(
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 8,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (pct / 100.0).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseThemeColor(challenge.themeColor);
    final joinedMembers = challenge.joinedMembers ?? [];
    final displayMembers = joinedMembers.take(4).toList();

    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Brand Logo, Challenge Name & Description, Badge, Detail Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: challenge.brand?.logo != null &&
                                challenge.brand!.logo!.isNotEmpty
                            ? ImageNetwork(
                                challenge.brand!.logo!,
                                fit: BoxFit.cover,
                                errorWidget: Icon(
                                  Icons.fitness_center_rounded,
                                  color: themeColor,
                                  size: 30,
                                ),
                              )
                            : Icon(
                                Icons.fitness_center_rounded,
                                color: themeColor,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name ?? 'Challenge',
                            maxLines: 2,
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

                    // Badge & Optional Detail Arrow
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (challenge.challengeType != null &&
                            challenge.challengeType!.isNotEmpty)
                          _buildChallengeTypeBadge(challenge.challengeType!, themeColor),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onTapDetails,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.95),
                                      const Color(0xFFEDEFF3).withValues(alpha: 0.85),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFCDD2DB),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      blurRadius: 3,
                                      offset: const Offset(-1, -1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF475569),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Middle Row: Member Avatars + Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Member Avatars & Count
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
                            const SizedBox(width: 8),
                          Expanded(
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

                    // Action Button
                    _buildActionButton(context, themeColor),
                  ],
                ),

                // Progress Bar Section (Requirement 9)
                if (challenge.progress != null)
                  _buildProgressBar(challenge.progress!, themeColor),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                style: AppStyles.text14Px.poppins.w700.copyWith(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    Text(
                      footerTitle ?? 'Challenge ends in:',
                      style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
                    ),
                    _ChallengeItemCountdownTimer(
                      initialSeconds: remainingSecs,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChallengeItemCountdownTimer extends StatefulWidget {
  final int initialSeconds;

  const _ChallengeItemCountdownTimer({
    required this.initialSeconds,
  });

  @override
  State<_ChallengeItemCountdownTimer> createState() =>
      __ChallengeItemCountdownTimerState();
}

class __ChallengeItemCountdownTimerState
    extends State<_ChallengeItemCountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ChallengeItemCountdownTimer oldWidget) {
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

    final String daysStr = days.toString();
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
