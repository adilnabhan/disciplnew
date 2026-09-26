import 'package:customer_mobile_app/imports_bindings.dart';

import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winner_certificate_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_details_screen.dart';

class ChallengeItemCard extends StatefulWidget {
  const ChallengeItemCard({
    super.key,
    required this.challenge,
    this.onTapDetails,
  });

  final ChallengeModel challenge;
  final VoidCallback? onTapDetails;

  @override
  State<ChallengeItemCard> createState() => _ChallengeItemCardState();
}

class _ChallengeItemCardState extends State<ChallengeItemCard> {
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds =
        widget.challenge.footer?.remainingSeconds ??
        widget.challenge.remainingSeconds ??
        0;
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant ChallengeItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSecs =
        widget.challenge.footer?.remainingSeconds ??
        widget.challenge.remainingSeconds ??
        0;
    final oldSecs =
        oldWidget.challenge.footer?.remainingSeconds ??
        oldWidget.challenge.remainingSeconds ??
        0;
    if (newSecs != oldSecs) {
      _countdownTimer?.cancel();
      _remainingSeconds = newSecs;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_remainingSeconds <= 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Color _parseThemeColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFFD71920);
    try {
      final hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    } catch (_) {}
    return const Color(0xFFD71920);
  }

  bool _isChallengeJoined() {
    final c = widget.challenge;
    if (c.isJoined != null) return c.isJoined!;
    final action = c.button?.action?.toLowerCase() ?? '';
    final text = c.button?.text?.toLowerCase() ?? '';
    if (action == 'join' ||
        text.contains('join now') ||
        text.contains('join after'))
      return false;
    if (text == 'joined' || text.contains('joined')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final themeColor = _parseThemeColor(challenge.themeColor);
    final isJoined = _isChallengeJoined();

    return GestureDetector(
      onTap: () {
        if (widget.onTapDetails != null) {
          widget.onTapDetails!();
        } else if (challenge.id != null) {
          unawaited(
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder:
                    (_) => ChallengeDetailsScreen(challengeId: challenge.id!),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.20),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeroBanner(themeColor),
              _buildMembersRow(context, themeColor, isJoined),
              if (isJoined && challenge.progress != null)
                _buildProgressBar(themeColor),
              _buildFooterBar(context, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  // -- Hero Banner ------------------------------------------------------

  Widget _buildHeroBanner(Color themeColor) {
    final challenge = widget.challenge;
    final thumbUrl = challenge.thumbnailUrl;
    final hasImg = thumbUrl != null && thumbUrl.isNotEmpty;
    final category = challenge.categoryDisplay ?? challenge.category;
    final typeText =
        challenge.challengeType?.isNotEmpty == true
            ? challenge.challengeType!.toUpperCase()
            : 'LUCKY DRAW';

    return SizedBox(
      height: 96,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImg)
            CachedNetworkImage(
              imageUrl: thumbUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 360,
              fadeInDuration: const Duration(milliseconds: 150),
              fadeOutDuration: Duration.zero,
              placeholder: (_, __) => _buildBannerFallback(),
              errorWidget: (_, __, ___) => _buildBannerFallback(),
            )
          else
            _buildBannerFallback(),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.88),
                  Colors.black.withValues(alpha: 0.60),
                  Colors.black.withValues(alpha: 0.12),
                ],
                stops: const [0, 0.58, 1],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildTypeBadge(typeText)],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBrandLogo(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            challenge.name ?? 'Challenge',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text16Px.poppins.w700.copyWith(
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            challenge.shortDescription ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.3,
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
    );
  }

  Widget _buildBannerFallback() {
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

  Widget _buildTypeBadge(String typeText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: Color(0xFFDC2626),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            typeText,
            style: AppStyles.text10Px.poppins.w700.copyWith(
              color: const Color(0xFFDC2626),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    final challenge = widget.challenge;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(color: const Color(0xFFFBBF24), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child:
            challenge.brand?.logo?.isNotEmpty == true
                ? CachedNetworkImage(
                  imageUrl: challenge.brand!.logo!,
                  fit: BoxFit.cover,
                  memCacheWidth: 120,
                  memCacheHeight: 120,
                  fadeInDuration: const Duration(milliseconds: 150),
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
                      (_, __, ___) => const ColoredBox(
                        color: Colors.black,
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Color(0xFFFBBF24),
                          size: 24,
                        ),
                      ),
                )
                : const ColoredBox(
                  color: Colors.black,
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFFFBBF24),
                    size: 24,
                  ),
                ),
      ),
    );
  }

  // -- Members Row ------------------------------------------------------

  Widget _buildMembersRow(
    BuildContext context,
    Color themeColor,
    bool isJoined,
  ) {
    final challenge = widget.challenge;
    final members = challenge.joinedMembers ?? [];
    final totalCount = challenge.joinedMemberCount ?? members.length;
    final displayMembers = members.take(4).toList();
    final extra = totalCount - displayMembers.length;

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
      btnText = 'Ended';
    } else if (isJoined) {
      btnText =
          (challenge.button?.text?.toLowerCase().contains('join after') ??
                  false)
              ? 'Joined'
              : (challenge.button?.text ?? 'Joined');
    } else {
      btnText = challenge.button?.text ?? 'Join After Workout';
    }

    Color btnBg;
    var textColor = Colors.white;
    Border? border;
    Widget? prefixWidget;
    Widget iconWidget;

    if (!isEnabled) {
      btnBg = Colors.grey.shade300;
      textColor = Colors.grey.shade600;
      iconWidget = const SizedBox.shrink();
    } else if (isWinnerAnnounced) {
      btnBg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF64748B);
      border = Border.all(color: const Color(0xFFE2E8F0));
      iconWidget = const SizedBox.shrink();
    } else if (isJoined) {
      btnBg = const Color(0xFFF8FAFB);
      textColor = const Color(0xFF1A1A1A);
      border = Border.all(color: const Color(0xFFD1D5DB));
      prefixWidget = const Padding(
        padding: EdgeInsets.only(right: 5),
        child: Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFF59E0B),
          size: 14,
        ),
      );
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.check_rounded, color: Color(0xFF1A1A1A), size: 15),
      );
    } else if (action == 'winners') {
      btnBg = const Color(0xFFD97706);
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 15),
      );
    } else {
      btnBg = themeColor;
      iconWidget = const Padding(
        padding: EdgeInsets.only(left: 3),
        child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 17),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      child: Row(
        children: [
          if (displayMembers.isNotEmpty)
            SizedBox(
              height: 30,
              width: (displayMembers.length * 20.0) + 10,
              child: Stack(
                children: List.generate(displayMembers.length, (i) {
                  final m = displayMembers[i];
                  return Positioned(
                    left: i * 20.0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: ClipOval(
                        child:
                            m.profileImage?.isNotEmpty == true
                                ? CachedNetworkImage(
                                  imageUrl: m.profileImage!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 70,
                                  memCacheHeight: 70,
                                  fadeInDuration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  fadeOutDuration: Duration.zero,
                                  placeholder:
                                      (_, __) => ColoredBox(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  errorWidget:
                                      (_, __, ___) => ColoredBox(
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
          if (displayMembers.isNotEmpty && extra > 0)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '+$extra',
                      style: AppStyles.text13Px.poppins.w700.copyWith(
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    TextSpan(
                      text: ' joined',
                      style: AppStyles.text13Px.poppins.w500.copyWith(
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),

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
                                    (_) => ChallengeWinnerCertificateScreen(
                                      challenge: challenge,
                                    ),
                              ),
                            ),
                          );
                        }
                      } else if (action == 'details') {
                        if (widget.onTapDetails != null) {
                          widget.onTapDetails!();
                        } else if (challenge.id != null) {
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
                          final cubit = context.read<ChallengeListCubit>();
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(22),
                border: border,
                boxShadow:
                    isEnabled && !isWinnerAnnounced && border == null
                        ? [
                          BoxShadow(
                            color: btnBg.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixWidget != null) prefixWidget!,
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
          ),
        ],
      ),
    );
  }

  // -- Progress Bar -----------------------------------------------------

  Widget _buildProgressBar(Color themeColor) {
    final progress = widget.challenge.progress!;
    final title = progress.title ?? 'Workout';
    final current = progress.current ?? 0;
    final target = progress.target ?? 0;
    final pct = (progress.percentage ?? 0).toDouble().clamp(0.0, 100.0);
    final progressColor = pct >= 100.0 ? const Color(0xFF16A34A) : themeColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 14,
                    color: themeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your Progress ($title: $current/$target)',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              Text(
                '${pct.toInt()}%',
                style: AppStyles.text13Px.poppins.w700.copyWith(
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 7,
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
      ),
    );
  }

  // -- Footer Bar --------------------------------------------------------

  Widget _buildFooterBar(BuildContext context, Color themeColor) {
    final challenge = widget.challenge;
    final footerType =
        challenge.footer?.type?.toLowerCase() ??
        challenge.status?.toLowerCase() ??
        'countdown';
    final footerTitle = challenge.footer?.title;
    final footerDate = challenge.footer?.date ?? '';
    final buttonText = challenge.footer?.buttonText ?? 'View Winners';
    final secs = _remainingSeconds.clamp(0, 99999999);

    const roundedBottom = BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );

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
                      (_) => ChallengeWinnerCertificateScreen(
                        challenge: challenge,
                      ),
                ),
              ),
            );
          }
        },
        child: Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: roundedBottom,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  footerTitle ?? 'Rewards Distributed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (footerType == 'ended') {
      return Container(
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: roundedBottom,
        ),
        child: Row(
          children: [
            const Text('?? ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                footerTitle ?? 'Challenge Ended',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (footerDate.isNotEmpty)
              Text(
                footerDate,
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
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
                      (_) => ChallengeWinnerCertificateScreen(
                        challenge: challenge,
                      ),
                ),
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: roundedBottom,
            border: const Border(top: BorderSide(color: Color(0xFFFFE8CC))),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      footerTitle ?? 'Winners Announced',
                      style: AppStyles.text13Px.poppins.w700.copyWith(
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      footerDate.isNotEmpty
                          ? footerDate
                          : "Check if you're one of the lucky winners.",
                      style: AppStyles.text10Px.poppins.w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isWinnerSelection =
        footerType.contains('selection') ||
        (footerTitle != null &&
            footerTitle.toLowerCase().contains('selection')) ||
        (challenge.status != null &&
            challenge.status!.toLowerCase().contains('selection'));

    final days = secs ~/ 86400;
    final hours = (secs % 86400) ~/ 3600;
    final mins = (secs % 3600) ~/ 60;
    final secsLeft = secs % 60;

    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: themeColor, borderRadius: roundedBottom),
      child: Row(
        children: [
          Icon(
            isWinnerSelection
                ? Icons.emoji_events_rounded
                : Icons.timer_outlined,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isWinnerSelection
                  ? 'Selecting Winners'
                  : (footerTitle ?? 'Challenge ends in'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.text13Px.poppins.w700.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeBox(days.toString().padLeft(2, '0'), 'Days'),
              _timeSep(),
              _timeBox(hours.toString().padLeft(2, '0'), 'Hours'),
              _timeSep(),
              _timeBox(mins.toString().padLeft(2, '0'), 'Mins'),
              _timeSep(),
              _timeBox(secsLeft.toString().padLeft(2, '0'), 'Secs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppStyles.text13Px.poppins.w700.copyWith(
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text9Px.poppins.w500.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _timeSep() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12, left: 2, right: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1,
        ),
      ),
    );
  }
}
