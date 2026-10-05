import 'dart:async';
import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart' hide ChallengeButton, ChallengeBrand, ChallengeFooter;
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_details_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_details_state.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_details_model.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class ChallengeDetailsScreen extends StatelessWidget {
  final int challengeId;

  const ChallengeDetailsScreen({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChallengeDetailsCubit()..loadChallengeDetails(challengeId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        body: BlocBuilder<ChallengeDetailsCubit, ChallengeDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const _ChallengeDetailsShimmer();
            }

            if (state.error != null && state.challenge == null) {
              return _buildErrorView(context, state.error!);
            }

            final challenge = state.challenge;
            if (challenge == null) {
              return const SizedBox.shrink();
            }

            return _ChallengeDetailsContent(challenge: challenge);
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load challenge details',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppStyles.text13Px.poppins.w400.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ChallengeDetailsCubit>().loadChallengeDetails(challengeId);
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Retry',
                  style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD71920),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeDetailsContent extends StatefulWidget {
  final ChallengeDetailsResponse challenge;

  const _ChallengeDetailsContent({
    required this.challenge,
  });

  @override
  State<_ChallengeDetailsContent> createState() => _ChallengeDetailsContentState();
}

class _ChallengeDetailsContentState extends State<_ChallengeDetailsContent> {
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
    } catch (_) {}
    return const Color(0xFFD71920);
  }

  void _shareChallenge(ChallengeShare? share) {
    if (share != null) {
      final text = '${share.title ?? ''}\n\n${share.description ?? ''}\n\n${share.deepLink ?? ''}';
      Share.share(text.trim());
    } else if (widget.challenge.name != null) {
      Share.share('Check out this challenge: ${widget.challenge.name}');
    }
  }

  String _formatCurrency(String? currency, num? value) {
    if (value == null) return '';
    final symbol = (currency == 'INR' || currency == null) ? '₹' : (currency == 'USD' ? '\$' : '$currency ');
    return 'Worth $symbol$value';
  }

  Widget _buildTypeBadge(String type) {
    final lower = type.trim().toLowerCase();
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData iconData;

    if (lower.contains('lucky') || lower.contains('draw')) {
      bgColor = const Color(0xFFF3E8FF);
      borderColor = const Color(0xFFE9D5FF);
      textColor = const Color(0xFF6B21A8);
      iconData = Icons.card_giftcard_rounded;
    } else if (lower.contains('performance')) {
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      textColor = const Color(0xFFB45309);
      iconData = Icons.emoji_events_rounded;
    } else {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF86EFAC);
      textColor = const Color(0xFF15803D);
      iconData = Icons.verified_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: AppStyles.text12Px.poppins.w700.copyWith(
              fontSize: 10,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(String? iconStr) {
    if (iconStr == null) return Icons.fitness_center_rounded;
    final lower = iconStr.toLowerCase();
    if (lower.contains('workout') || lower.contains('fitness')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('ticket') || lower.contains('entry')) {
      return Icons.confirmation_number_rounded;
    } else if (lower.contains('gift') || lower.contains('draw')) {
      return Icons.card_giftcard_rounded;
    } else if (lower.contains('trophy') || lower.contains('winner')) {
      return Icons.emoji_events_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final themeColor = _parseThemeColor(challenge.themeColor);
    final brand = challenge.brand;
    final progress = challenge.progress;
    final reward = challenge.reward;
    final howItWorks = challenge.howItWorks ?? [];
    final timeline = challenge.timeline;
    final rules = challenge.rules ?? [];
    final disqualificationRules = challenge.disqualificationRules ?? [];
    final termsAndConditions = challenge.termsAndConditions ?? [];
    final winner = challenge.winner;
    final footer = challenge.footer;
    final button = challenge.button;

    return Column(
      children: [
        // Fixed Constant Top Header / AppBar
        Container(
          color: Colors.white,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button with bggrey background
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),

                  // Share Button with bggrey background
                  GestureDetector(
                    onTap: () => _shareChallenge(challenge.share),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF444444),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Scrollable Area with Pull-to-Refresh
        Expanded(
          child: RefreshIndicator(
            color: themeColor,
            onRefresh: () async {
              if (challenge.id != null) {
                await context.read<ChallengeDetailsCubit>().refreshChallengeDetails(challenge.id!);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image Container with Floating Type Badge
                  Stack(
                    children: [
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: _ChallengeBannerCarousel(
                          images: (challenge.bannerImages != null &&
                                  challenge.bannerImages!.isNotEmpty)
                              ? challenge.bannerImages!
                              : (challenge.bannerImage != null &&
                                      challenge.bannerImage!.isNotEmpty
                                  ? [challenge.bannerImage!]
                                  : const []),
                          themeColor: themeColor,
                        ),
                      ),

                      // Floating Type Badge on top right of banner
                      if (challenge.challengeType != null &&
                          challenge.challengeType!.isNotEmpty)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: _buildTypeBadge(challenge.challengeType!),
                        ),
                    ],
                  ),

                  // Overlapping Brand & Challenge Title Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.70),
                                  Colors.white.withValues(alpha: 0.95),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Brand Info Row
                                Row(
                                  children: [
                                    // Brand Logo
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                      ),
                                      child: ClipOval(
                                        child: brand?.logo != null && brand!.logo!.isNotEmpty
                                            ? ImageNetwork(brand.logo!, fit: BoxFit.cover)
                                            : Icon(Icons.business_rounded, color: themeColor, size: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  brand?.name ?? 'Brand',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppStyles.text14Px.poppins.w600.copyWith(
                                                    color: const Color(0xFF333333),
                                                  ),
                                                ),
                                              ),
                                              if (brand?.verified == true) ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.verified_rounded,
                                                  color: Color(0xFF1D9BF0),
                                                  size: 16,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            challenge.name ?? 'Challenge',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyles.text18Px.poppins.w700.copyWith(
                                              color: const Color(0xFF1E1E1E),
                                              height: 1.25,
                                            ),
                                          ),
                                          if (reward?.rewardValue != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatCurrency(reward?.currency, reward?.rewardValue),
                                              style: AppStyles.text13Px.poppins.w500.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                if (challenge.description != null && challenge.description!.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  const SizedBox(height: 12),
                                  Text(
                                    challenge.description!,
                                    style: AppStyles.text13Px.poppins.w400.copyWith(
                                      color: const Color(0xFF555555),
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Content Cards
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Progress Card (if progress != null)
                          if (progress != null) ...[
                            _buildProgressCard(progress, themeColor),
                            const SizedBox(height: 16),
                          ],

                          // 2. Reward Card (if reward != null)
                          if (reward != null) ...[
                            _buildRewardCard(reward, themeColor),
                            const SizedBox(height: 16),
                          ],

                          // 3. How It Works Section
                          if (howItWorks.isNotEmpty) ...[
                            _buildHowItWorksCard(howItWorks, themeColor),
                            const SizedBox(height: 16),
                          ],

                          // 4. Timeline & Draw Date Countdown Card
                          if (timeline != null) ...[
                            _buildTimelineCard(timeline, themeColor),
                            const SizedBox(height: 16),
                          ],

                          // 5. Winner Announcement Card (if winner.is_announced == true)
                          if (winner?.isAnnounced == true &&
                              winner?.announcedWinners != null &&
                              winner!.announcedWinners!.isNotEmpty) ...[
                            _buildWinnersCard(winner, themeColor),
                            const SizedBox(height: 16),
                          ],

                          // 6. Challenge Rules Card
                          if (rules.isNotEmpty) ...[
                            _buildRulesCard('Challenge Rules', rules, Icons.check_circle_rounded, themeColor),
                            const SizedBox(height: 16),
                          ],


                          // 8. Terms & Conditions Card (Expandable)
                          if (termsAndConditions.isNotEmpty) ...[
                            _buildTermsCard(termsAndConditions, themeColor),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Fixed CTA & Footer Bar
        _buildBottomBar(footer, button, themeColor, challenge.id),
      ],
    );
  }

  Widget _buildProgressCard(ChallengeProgress progress, Color themeColor) {
    final current = progress.current ?? 0;
    final target = progress.target ?? 1;
    final percentage = (progress.percentage ?? ((current / target) * 100)).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: AppStyles.text15Px.poppins.w600.copyWith(
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $target ${progress.title ?? "Workouts"}',
                style: AppStyles.text16Px.poppins.w700.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: AppStyles.text15Px.poppins.w700.copyWith(
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          const SizedBox(height: 14),

          // Inner Entries Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: themeColor.withValues(alpha: 0.15), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.confirmation_number_rounded,
                    color: themeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Entries: $current ${current == 1 ? "Entry" : "Entries"}',
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete the challenge to get lucky draw entries.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(ChallengeReward reward, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: themeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reward Details',
                style: AppStyles.text15Px.poppins.w600.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reward.image != null && reward.image!.isNotEmpty)
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ImageNetwork(reward.image!, fit: BoxFit.cover),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title ?? 'Challenge Prize',
                      style: AppStyles.text15Px.poppins.w600.copyWith(
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    if (reward.rewardValue != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(reward.currency, reward.rewardValue),
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: themeColor,
                        ),
                      ),
                    ],
                    if (reward.description != null && reward.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reward.description!,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                    if (reward.winnerCount != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200, width: 0.8),
                        ),
                        child: Text(
                          '${reward.winnerCount} Lucky Winner(s)',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(List<ChallengeHowItWorks> items, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: AppStyles.text15Px.poppins.w600.copyWith(
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 18),

          // Horizontal Flow matching screenshot
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // Soft Circular Icon Box
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStepIcon(item.icon),
                              color: themeColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Step Number Badge (Small Light Circle)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppStyles.text10Px.poppins.w700.copyWith(
                                  color: themeColor,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Title Text
                          Text(
                            item.title ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: const Color(0xFF222222),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Arrow between items
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Icon(
                          Icons.east_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ChallengeTimeline timeline, Color themeColor) {
    String formattedDate = '';
    if (timeline.drawDate != null) {
      try {
        final dt = DateTime.parse(timeline.drawDate!).toLocal();
        formattedDate = DateFormat('d MMMM yyyy').format(dt);
      } catch (_) {
        formattedDate = timeline.drawDate!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_month_rounded, color: themeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draw Date',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      formattedDate.isNotEmpty ? formattedDate : 'To be announced',
                      style: AppStyles.text16Px.poppins.w700.copyWith(
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    Text(
                      'Winner will be announced on this date',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Local Live Countdown Sub-Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Winner announcement in',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                _LocalCountdownWidget(
                  initialSeconds: timeline.remainingSeconds ?? 0,
                  boxColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnersCard(ChallengeWinner winner, Color themeColor) {
    final winners = winner.announcedWinners ?? [];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChallengeWinnersScreen(
              challengeId: widget.challenge.id,
              challengeDetails: widget.challenge,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🏆 Challenge Winners',
                    style: AppStyles.text16Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Text(
                  'View All →',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Column(
              children: winners.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${w.rank ?? "#"}',
                            style: AppStyles.text12Px.poppins.w700.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipOval(
                        child: w.profileImage != null && w.profileImage!.isNotEmpty
                            ? ImageNetwork(w.profileImage!, width: 36, height: 36, fit: BoxFit.cover)
                            : Container(
                                width: 36,
                                height: 36,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name ?? 'Winner',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            if (w.prize != null)
                              Text(
                                w.prize!,
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCard(String title, List<String> rules, IconData icon, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.text15Px.poppins.w600.copyWith(
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: rules.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: themeColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: AppStyles.text13Px.poppins.w400.copyWith(
                          color: const Color(0xFF444444),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDisqualificationCard(List<String> rules) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD1D1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD30C15), size: 20),
              const SizedBox(width: 8),
              Text(
                'Disqualification Rules',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: const Color(0xFFD30C15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: rules.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFFD30C15), fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        r,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFFD30C15),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard(List<String> terms, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Terms & Conditions',
            style: AppStyles.text15Px.poppins.w600.copyWith(
              color: const Color(0xFF1E1E1E),
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 18, right: 18, bottom: 16),
          children: terms.map((term) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF666666))),
                  Expanded(
                    child: Text(
                      term,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF666666),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    ChallengeFooter? footer,
    ChallengeButton? button,
    Color themeColor,
    int? challengeId,
  ) {
    final footerType = footer?.type?.toLowerCase() ?? 'countdown';
    final btnText = button?.text ?? 'Join Challenge';
    final btnEnabled = button?.enabled ?? true;
    final btnAction = button?.action?.toLowerCase() ?? 'join';

    String footerTitle = footer?.title ?? 'Challenge ends in';
    String? footerSubtitle;

    if (footerType == 'upcoming') {
      footerTitle = '⏳ ${footer?.title ?? "Challenge Starts On"}';
      footerSubtitle = footer?.date;
    } else if (footerType == 'ended') {
      footerTitle = '🏁 ${footer?.title ?? "Challenge Ended"}';
      footerSubtitle = footer?.date;
    } else if (footerType == 'winner') {
      footerTitle = '🏆 ${footer?.title ?? "Winners Announced"}';
      footerSubtitle = footer?.buttonText ?? 'View Winners →';
    } else if (footerType == 'countdown') {
      footerTitle = footer?.title ?? 'Challenge ends in';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left Footer Info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    footerTitle,
                    style: AppStyles.text13Px.poppins.w600.copyWith(
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  if (footerType == 'countdown' && footer?.remainingSeconds != null) ...[
                    const SizedBox(height: 2),
                    _LocalCountdownWidget(
                      initialSeconds: footer!.remainingSeconds!,
                      boxColor: themeColor.withValues(alpha: 0.1),
                      textColor: themeColor,
                      isCompact: true,
                    ),
                  ] else if (footerSubtitle != null && footerSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      footerSubtitle,
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right Action CTA Button
            BlocBuilder<ChallengeDetailsCubit, ChallengeDetailsState>(
              builder: (context, state) {
                final isJoining = state.isJoining;
                final currentChallenge = state.challenge ?? widget.challenge;
                final isJoined = (currentChallenge.isJoined ?? false) ||
                    btnText.toLowerCase().contains('joined') ||
                    btnAction == 'details';
                final isJoinAfter =
                    btnText.toLowerCase().contains('join after');

                return ElevatedButton(
                  onPressed: isJoining
                      ? null
                      : () async {
                          if (isJoined) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You have already joined this challenge.',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else if (isJoinAfter) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Complete your workouts to reach 100% progress, and you will automatically be entered into the challenge.',
                                ),
                              ),
                            );
                          } else if (btnAction == 'join' && challengeId != null) {
                            final success = await context
                                .read<ChallengeDetailsCubit>()
                                .joinChallenge(challengeId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Successfully joined challenge!'
                                        : 'Failed to join challenge.',
                                  ),
                                  backgroundColor: success
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              );
                            }
                          } else if (btnAction == 'winners') {
                            unawaited(
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => ChallengeWinnersScreen(
                                    challengeId: challengeId,
                                    challengeDetails: widget.challenge,
                                  ),
                                ),
                              ),
                            );
                          } else if (!btnEnabled) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  footerSubtitle != null &&
                                          footerSubtitle.isNotEmpty
                                      ? footerSubtitle
                                      : 'This challenge is currently not joinable.',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (btnEnabled || isJoined || isJoinAfter)
                        ? themeColor
                        : Colors.grey.shade400,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    elevation:
                        (btnEnabled || isJoined || isJoinAfter) ? 3 : 0,
                  ),
                  child: isJoining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : isJoined
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  btnText.isNotEmpty ? btnText : 'Joined',
                                  style: AppStyles.text14Px.poppins.w600
                                      .copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_rounded,
                                  size: 17,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          : Text(
                              btnText,
                              style: AppStyles.text14Px.poppins.w600
                                  .copyWith(
                                color: (btnEnabled || isJoinAfter)
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
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

class _LocalCountdownWidget extends StatefulWidget {
  final int initialSeconds;
  final Color boxColor;
  final Color textColor;
  final bool isCompact;

  const _LocalCountdownWidget({
    required this.initialSeconds,
    required this.boxColor,
    required this.textColor,
    this.isCompact = false,
  });

  @override
  State<_LocalCountdownWidget> createState() => _LocalCountdownWidgetState();
}

class _LocalCountdownWidgetState extends State<_LocalCountdownWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _LocalCountdownWidget oldWidget) {
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

  Widget _buildBox(String val, String label) {
    if (widget.isCompact) {
      return Text(
        '$val $label ',
        style: AppStyles.text13Px.poppins.w700.copyWith(color: widget.textColor),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.boxColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            val,
            style: AppStyles.text14Px.poppins.w700.copyWith(
              color: widget.textColor,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: AppStyles.text9Px.poppins.w500.copyWith(
              color: widget.textColor.withValues(alpha: 0.7),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secs = _remainingSeconds > 0 ? _remainingSeconds : 0;
    final days = secs ~/ 86400;
    final hours = (secs % 86400) ~/ 3600;
    final mins = (secs % 3600) ~/ 60;
    final seconds = secs % 60;

    final daysStr = days.toString().padLeft(2, '0');
    final hoursStr = hours.toString().padLeft(2, '0');
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');

    if (widget.isCompact) {
      return Text(
        '${daysStr}d : ${hoursStr}h : ${minsStr}m : ${secsStr}s',
        style: AppStyles.text14Px.poppins.w700.copyWith(
          color: widget.textColor,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBox(daysStr, 'Days'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: AppStyles.text14Px.poppins.w700.copyWith(color: widget.textColor)),
        ),
        _buildBox(hoursStr, 'Hours'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: AppStyles.text14Px.poppins.w700.copyWith(color: widget.textColor)),
        ),
        _buildBox(minsStr, 'Min'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: AppStyles.text14Px.poppins.w700.copyWith(color: widget.textColor)),
        ),
        _buildBox(secsStr, 'Sec'),
      ],
    );
  }
}

class _ChallengeDetailsShimmer extends StatelessWidget {
  const _ChallengeDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 240,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
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

class _ChallengeBannerCarousel extends StatefulWidget {
  const _ChallengeBannerCarousel({
    required this.images,
    required this.themeColor,
  });

  final List<String> images;
  final Color themeColor;

  @override
  State<_ChallengeBannerCarousel> createState() =>
      _ChallengeBannerCarouselState();
}

class _ChallengeBannerCarouselState extends State<_ChallengeBannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ChallengeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final current = _pageController.page?.round() ?? 0;
      final next = (current + 1) % widget.images.length;
      if (next == 0) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return ColoredBox(
        color: widget.themeColor.withValues(alpha: 0.85),
        child: const Center(
          child: Icon(
            Icons.emoji_events_rounded,
            size: 64,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (widget.images.length == 1) {
      return ImageNetwork(
        widget.images.first,
      );
    }

    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        final url = widget.images[index];
        return ImageNetwork(
          url,
        );
      },
    );
  }
}
