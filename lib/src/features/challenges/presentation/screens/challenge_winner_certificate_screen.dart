import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/all_challenge_winners_model.dart';
import 'package:customer_mobile_app/src/features/challenges/logic/challenge_winner_poster_service.dart';

/// Personal winner certificate page — shown when the user wins a challenge.
/// The existing [ChallengeWinnersScreen] (all winners list) is NOT affected.
class ChallengeWinnerCertificateScreen extends StatefulWidget {
  const ChallengeWinnerCertificateScreen({
    super.key,
    required this.challenge,
  });

  final ChallengeModel challenge;

  @override
  State<ChallengeWinnerCertificateScreen> createState() => _ChallengeWinnerCertificateScreenState();
}

class _ChallengeWinnerCertificateScreenState extends State<ChallengeWinnerCertificateScreen> {
  bool _isLoading = true;
  bool _isProcessingPoster = false;
  String? _errorMessage;
  ChallengeWinnerItem? _winner;

  @override
  void initState() {
    super.initState();
    _fetchWinner();
  }

  Future<void> _fetchWinner() async {
    try {
      if (widget.challenge.id == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid challenge ID';
        });
        return;
      }

      final response = await ChallengeRepository().getAllChallengeWinners(
        challengeId: widget.challenge.id,
      );

      if (mounted) {
        setState(() {
          if (response.winners.isNotEmpty) {
            final first = response.winners.first;
            _winner = ChallengeWinnerItem(
              id: first.id,
              challengeId: first.challengeId,
              challengeName: first.challengeName,
              userId: first.userId,
              userName: first.userName,
              profilePic: first.profilePic,
              date: first.date,
              awardedAt: first.awardedAt,
              selectionMethod: first.selectionMethod,
              selectionMethodDisplay: first.selectionMethodDisplay,
              prize: first.prize,
              prizeTitle: first.prizeTitle,
              rank: first.rank,
              isPublished: first.isPublished,
              isPrizeDistributed: first.isPrizeDistributed,
              brandName: first.brandName,
              brandLogo: first.brandLogo,
              rewardImage: first.rewardImage,
              gymName: (first.gymName?.isNotEmpty ?? false)
                  ? first.gymName
                  : (response.gymName?.isNotEmpty ?? false)
                      ? response.gymName
                      : widget.challenge.gymName,
              gymLogo: (first.gymLogo?.isNotEmpty ?? false)
                  ? first.gymLogo
                  : (response.gymLogo?.isNotEmpty ?? false)
                      ? response.gymLogo
                      : widget.challenge.gymLogo,
              gymLocation: (first.gymLocation?.isNotEmpty ?? false)
                  ? first.gymLocation
                  : (response.gymLocation?.isNotEmpty ?? false)
                      ? response.gymLocation
                      : widget.challenge.gymLocation,
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load winner details.';
        });
      }
    }
  }

  Color _parseThemeColor(String? c) {
    if (c == null || c.isEmpty) return const Color(0xFFD71920);
    try {
      final hex = c.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    } catch (_) {}
    return const Color(0xFFD71920);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseThemeColor(widget.challenge.themeColor);
    final bannerUrl = widget.challenge.bannerImage ?? widget.challenge.thumbnailUrl;
    final brandLogoUrl = widget.challenge.brand?.logo;
    final brandName = widget.challenge.brand?.name ?? 'Sponsor';
    final challengeName = widget.challenge.name ?? 'Challenge';

    final displayPrizeName = _winner?.prizeTitle ?? _winner?.prize ?? widget.challenge.name ?? 'Prize';
    final displayPrizeImage = _winner?.rewardImage ?? widget.challenge.thumbnailUrl;
    final displayWinnerName = _winner?.userName ?? 'Lucky Winner';
    final displayWinnerProfile = _winner?.profilePic;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD71920)))
                : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Banner ────────────────────────────────────────
                    _buildBanner(context, bannerUrl, brandLogoUrl, challengeName, themeColor),

                    const SizedBox(height: 32),

                    // ── Congratulations ───────────────────────────────
                    Text(
                      'CONGRATULATIONS!',
                      style: AppStyles.text18Px.poppins.w700.copyWith(
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is the lucky winner',
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Winner Profile ────────────────────────────────
                    _buildWinnerProfile(displayWinnerProfile, displayWinnerName),

                    const SizedBox(height: 40),

                    // ── Prize Card ────────────────────────────────────
                    _buildPrizeCard(
                      context,
                      displayPrizeImage,
                      displayPrizeName,
                      brandLogoUrl,
                      brandName,
                      themeColor,
                    ),

                    const SizedBox(height: 18),

                    // ── Download & Share Buttons (UI only) ────────────
                    _buildActionButtons(context, themeColor),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Done Button ───────────────────────────────────────────
            _buildDoneButton(context, themeColor),
          ],
        ),
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  Widget _buildBanner(
    BuildContext context,
    String? thumbUrl,
    String? brandLogoUrl,
    String challengeName,
    Color themeColor,
  ) {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: thumbUrl != null && thumbUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: thumbUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    memCacheHeight: 500,
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: Duration.zero,
                    placeholder: (_, __) => _bannerFallback(themeColor),
                    errorWidget: (_, __, ___) => _bannerFallback(themeColor),
                  )
                : _bannerFallback(themeColor),
          ),
        ),

        // Dark overlay
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.30),
                ],
              ),
            ),
          ),
        ),

        // "WIN [NAME]" text
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIN',
                style: AppStyles.text18Px.poppins.w700.copyWith(
                  color: const Color(0xFFFBBF24),
                  letterSpacing: 3,
                  height: 1,
                ),
              ),
              Text(
                challengeName.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.text22Px.poppins.w700.copyWith(
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Back button
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerFallback(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor.withValues(alpha: 0.85), const Color(0xFF1A1A1A)],
        ),
      ),
    );
  }

  // ── Winner Profile ─────────────────────────────────────────────────────────

  Widget _buildWinnerProfile(String? profileImage, String name) {
    final cleanProfile = profileImage?.trim();
    final bool hasValidProfile = cleanProfile != null &&
        cleanProfile.isNotEmpty &&
        cleanProfile.toLowerCase() != 'null';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF3F4F6), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: hasValidProfile
                ? CachedNetworkImage(
                    imageUrl: cleanProfile,
                    fit: BoxFit.cover,
                    memCacheWidth: 180,
                    memCacheHeight: 180,
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: Duration.zero,
                    placeholder: (_, __) => _avatarFallback(),
                    errorWidget: (_, __, ___) => _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: AppStyles.text15Px.poppins.w600.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return const SizedBox.expand(
      child: ColoredBox(
        color: Color(0xFFE5E7EB),
        child: Center(
          child: Icon(Icons.person_rounded, color: Color(0xFF9CA3AF), size: 40),
        ),
      ),
    );
  }

  // ── Prize Card ─────────────────────────────────────────────────────────────

  Widget _buildPrizeCard(
    BuildContext context,
    String? prizeImage,
    String prizeName,
    String? brandLogoUrl,
    String brandName,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Prize',
            style: AppStyles.text15Px.poppins.w700.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F0),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFE4B5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Prize image (orange card)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    color: const Color(0xFFFF9500),
                    child: prizeImage != null && prizeImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: prizeImage,
                            fit: BoxFit.cover,
                            memCacheWidth: 200,
                            memCacheHeight: 200,
                            fadeInDuration: const Duration(milliseconds: 150),
                            fadeOutDuration: Duration.zero,
                            placeholder: (_, __) => const Center(
                              child: Icon(Icons.card_giftcard_rounded,
                                  color: Colors.white, size: 36),
                            ),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.card_giftcard_rounded,
                                  color: Colors.white, size: 36),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.card_giftcard_rounded,
                                color: Colors.white, size: 36),
                          ),
                  ),
                ),

                // Prize info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prizeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.text15Px.poppins.w700.copyWith(
                            color: const Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sponsored by',
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (brandLogoUrl != null && brandLogoUrl.isNotEmpty)
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: brandLogoUrl,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 60,
                                    memCacheHeight: 60,
                                    fadeInDuration: const Duration(milliseconds: 150),
                                    fadeOutDuration: Duration.zero,
                                    placeholder: (_, __) => const SizedBox.shrink(),
                                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text13Px.poppins.w600.copyWith(
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Download & Share Buttons ──────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.file_download_outlined,
              label: 'Download',
              isLoading: _isProcessingPoster,
              onTap: () async {
                if (_isProcessingPoster) return;
                setState(() => _isProcessingPoster = true);
                try {
                  await ChallengeWinnerPosterService.instance.handleDownload(
                    context: context,
                    challenge: widget.challenge,
                    winner: _winner,
                  );
                } finally {
                  if (mounted) setState(() => _isProcessingPoster = false);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              isLoading: _isProcessingPoster,
              onTap: () async {
                if (_isProcessingPoster) return;
                setState(() => _isProcessingPoster = true);
                try {
                  await ChallengeWinnerPosterService.instance.handleShare(
                    context: context,
                    challenge: widget.challenge,
                    winner: _winner,
                  );
                } finally {
                  if (mounted) setState(() => _isProcessingPoster = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF1F2937),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Done Button ────────────────────────────────────────────────────────────

  Widget _buildDoneButton(BuildContext context, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Done',
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
