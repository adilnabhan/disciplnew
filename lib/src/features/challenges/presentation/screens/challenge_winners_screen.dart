import 'package:customer_mobile_app/imports_bindings.dart' hide ChallengeBrand, ChallengeFooter;
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_details_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:share_plus/share_plus.dart';
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
  late ChallengeRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  ChallengeDetailsResponse? _details;

  @override
  void initState() {
    super.initState();
    _repository = ChallengeRepository();
    _details = widget.challengeDetails;

    if (_details == null && widget.challengeId != null) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _repository.getChallengeDetails(widget.challengeId!);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res != null) {
          _details = res;
        } else {
          _errorMessage = 'Failed to load winner information.';
        }
      });
    }
  }

  void _shareWinnerPage() {
    final details = _details;
    final share = details?.share;
    if (share?.deepLink != null && share!.deepLink!.isNotEmpty) {
      Share.share('${share.title ?? details?.name ?? "Challenge Winners"}\n\n${share.description ?? ""}\n\n${share.deepLink!}');
    } else if (details?.name != null) {
      Share.share('Check out the winners for ${details!.name!}!');
    } else {
      Share.share('Check out the Challenge Winners!');
    }
  }

  Color _parseThemeColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) {
      return const Color(0xFFD71920);
    }
    try {
      final hex = hexString.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFD71920);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseThemeColor(_details?.themeColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF374151),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: _shareWinnerPage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: themeColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(themeColor),
    );
  }

  Widget _buildBody(Color themeColor) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    final details = _details;
    if (details == null) {
      return _buildEmptyState('No winner data available for this challenge.');
    }

    final winnersList = details.winner?.announcedWinners ?? [];
    final AnnouncedWinner? mainWinner = winnersList.isNotEmpty ? winnersList[0] : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Hero Banner Image Card
          _buildBannerCard(details, themeColor),
          const SizedBox(height: 20),

          // 2. Winner & Prize Highlight Section (Handles Selected / Not Selected)
          _buildWinnerHighlightSection(mainWinner, details, themeColor),
          const SizedBox(height: 24),

          // 3. Other Winners Section (if more than 1 winner)
          if (winnersList.length > 1) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Other Winners',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...winnersList.skip(1).map((w) => _buildWinnerTile(w, themeColor)),
            const SizedBox(height: 24),
          ],

          // 4. Bottom Notice Banner
          _buildNoticeBanner(details, themeColor),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBannerCard(ChallengeDetailsResponse details, Color themeColor) {
    final bannerUrl = details.bannerImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        color: const Color(0xFFE5E7EB),
        child: bannerUrl != null && bannerUrl.isNotEmpty
            ? ImageNetwork(
                bannerUrl,
                fit: BoxFit.cover,
                errorWidget: _buildDefaultBannerPlaceholder(details, themeColor),
              )
            : _buildDefaultBannerPlaceholder(details, themeColor),
      ),
    );
  }

  Widget _buildDefaultBannerPlaceholder(ChallengeDetailsResponse details, Color themeColor) {
    return Container(
      color: themeColor,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
            const SizedBox(height: 10),
            Text(
              details.name ?? 'CHALLENGE WINNERS',
              textAlign: TextAlign.center,
              style: AppStyles.text18Px.poppins.w700.copyWith(
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerHighlightSection(
    AnnouncedWinner? winner,
    ChallengeDetailsResponse details,
    Color themeColor,
  ) {
    final hasWinner = winner != null && winner.name != null && winner.name!.trim().isNotEmpty;
    final avatarUrl = winner?.profileImage;
    final rewardTitle = (winner?.prize != null && winner!.prize!.isNotEmpty)
        ? winner.prize!
        : (details.reward?.title ?? 'Challenge Reward');
    final rewardImage = details.reward?.image;
    final brandName = details.brand?.name ?? "Brand";
    final brandLogo = details.brand?.logo;
    final brandSubtitle = details.brand?.website ?? details.reward?.description ?? '';

    return Column(
      children: [
        // CONGRATULATIONS! / WINNER PENDING
        Text(
          hasWinner ? 'CONGRATULATIONS!' : 'WINNER PENDING',
          textAlign: TextAlign.center,
          style: AppStyles.text20Px.poppins.w700.copyWith(
            color: const Color(0xFF111827),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle: Lucky Winner / Winner Not Selected
        Text(
          hasWinner ? 'Lucky Winner' : 'Winner Not Selected Yet',
          textAlign: TextAlign.center,
          style: AppStyles.text14Px.poppins.w400.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),

        // Centered Winner Avatar
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: themeColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ImageNetwork(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(Icons.person, size: 48, color: Color(0xFF9CA3AF)),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.person, size: 48, color: Color(0xFF9CA3AF)),
                  ),
          ),
        ),
        const SizedBox(height: 10),

        // Winner Name / Winner Not Selected
        Text(
          hasWinner ? winner.name! : 'Winner Not Selected',
          textAlign: TextAlign.center,
          style: AppStyles.text16Px.poppins.w700.copyWith(
            color: hasWinner ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),

        // Prize Section Heading
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Prize',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: const Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Prize Card Container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Large Reward Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: rewardImage != null && rewardImage.isNotEmpty
                      ? ImageNetwork(
                          rewardImage,
                          fit: BoxFit.cover,
                          errorWidget: _buildRewardPlaceholder(themeColor),
                        )
                      : _buildRewardPlaceholder(themeColor),
                ),
              ),
              const SizedBox(width: 14),

              // Reward Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rewardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text16Px.poppins.w700.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sponsored by',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Brand Logo + Brand Name
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF111827),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                          ),
                          child: ClipOval(
                            child: brandLogo != null && brandLogo.isNotEmpty
                                ? ImageNetwork(
                                    brandLogo,
                                    fit: BoxFit.cover,
                                    errorWidget: Center(
                                      child: Text(
                                        brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B',
                                        style: AppStyles.text14Px.poppins.w700.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B',
                                      style: AppStyles.text14Px.poppins.w700.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text14Px.poppins.w700.copyWith(
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              if (brandSubtitle.isNotEmpty) ...[
                                Text(
                                  brandSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.text12Px.poppins.w400.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardPlaceholder(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor,
            themeColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.fastfood_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildNoticeBanner(ChallengeDetailsResponse details, Color themeColor) {
    var title = details.footer?.title ?? '';
    if (title.isEmpty || title.toLowerCase().contains('view winner')) {
      title = 'Winners will be contacted personally.';
    }
    const subtitle = 'Prizes will be distributed soon. Stay tuned!';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.text13Px.poppins.w600.copyWith(
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerTile(AnnouncedWinner winner, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${winner.rank ?? "#"}',
                style: AppStyles.text12Px.poppins.w700.copyWith(
                  color: themeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipOval(
            child: winner.profileImage != null && winner.profileImage!.isNotEmpty
                ? ImageNetwork(
                    winner.profileImage!,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 42,
                    height: 42,
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.person, color: Color(0xFF9CA3AF)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  winner.name ?? 'Winner',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xFF111827),
                  ),
                ),
                if (winner.prize != null && winner.prize!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    winner.prize!,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 24,
              width: 140,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load winners',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDetails,
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
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 60,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.text15Px.poppins.w500.copyWith(
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
