import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Standalone 9:16 layout widget used to composite the Challenge Winner Poster
/// before capturing it via [RepaintBoundary].
class ChallengeWinnerPosterWidget extends StatelessWidget {
  const ChallengeWinnerPosterWidget({
    super.key,
    required this.themeColor,
    required this.winnerName,
    this.winnerAvatarUrl,
    this.winnerAvatarBytes,
    this.partnerName,
    this.partnerLogoUrl,
    this.partnerLogoBytes,
    this.partnerLocation,
    this.gymName,
    this.gymLogoUrl,
    this.gymLogoBytes,
    this.gymLocation,
    this.participationDate,
    this.prizeName,
    this.prizeImageUrl,
    this.prizeImageBytes,
  });

  final Color themeColor;
  final String winnerName;
  final String? winnerAvatarUrl;
  final Uint8List? winnerAvatarBytes;
  final String? partnerName;
  final String? partnerLogoUrl;
  final Uint8List? partnerLogoBytes;
  final String? partnerLocation;
  final String? gymName;
  final String? gymLogoUrl;
  final Uint8List? gymLogoBytes;
  final String? gymLocation;
  final String? participationDate;
  final String? prizeName;
  final String? prizeImageUrl;
  final Uint8List? prizeImageBytes;

  /// Logical design dimensions: 540 x 960 (9:16 aspect ratio).
  /// Rendered at pixelRatio 2.667 yields 1440 x 2560 pixels (matching template).
  static const double posterWidth = 540;
  static const double posterHeight = 960;

  @override
  Widget build(BuildContext context) {
    const goldYellowTop = Color(0xFFFFDF00);
    const goldYellowBottom = Color(0xFFFF9500);
    const goldExtrusionShadow = Color(0xFF4A1A00);
    const starColor = Color(0xFFFFB800);

    final displayPrize = (prizeName?.isNotEmpty ?? false) ? prizeName! : 'Exclusive Reward';
    final displayPartner = (partnerName?.isNotEmpty ?? false) ? partnerName! : 'Discipl Partner';
    final displayDate = (participationDate?.isNotEmpty ?? false) ? participationDate! : 'Challenge Winner';

    return SizedBox(
      width: posterWidth,
      height: posterHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── 1. Base Layer: Recolorized Template Background ──────────────────
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(themeColor, BlendMode.modulate),
              child: Image.asset(
                'assets/images/others/Winner_templete.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ),

          // ── 2. Top Partner Logo Badge (Fits inside template's top ring) ─────
          // Template top ring: Center X = 270, Center Y = 46, Inner Diameter = 61.5.
          Positioned(
            top: 15,
            left: (posterWidth - 62) / 2,
            width: 62,
            height: 62,
            child: _buildPartnerTopBadge(),
          ),

          // ── 3. "LUCKY DRAW WINNER" & Decorative Stars ───────────────────────
          // Left Stars
          Positioned(
            left: 36,
            top: 114,
            child: _buildStar(18, starColor),
          ),
          Positioned(
            left: 40,
            top: 158,
            child: _buildStar(28, starColor),
          ),

          // Right Stars
          Positioned(
            right: 36,
            top: 114,
            child: _buildStar(18, starColor),
          ),
          Positioned(
            right: 40,
            top: 158,
            child: _buildStar(28, starColor),
          ),

          // Headings (Cleanly positioned below top logo badge to prevent any overlap)
          const Positioned(
            top: 98,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "LUCKY DRAW" Arched with vibrant gold/yellow arcade gradient and 3D extrusion
                ArchedText(
                  text: 'LUCKY DRAW',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: 36,
                    height: 1,
                  ),
                  topColor: goldYellowTop,
                  bottomColor: goldYellowBottom,
                  shadowColor: goldExtrusionShadow,
                  curvature: 16,
                  maxRotation: 0.18,
                  letterSpacing: 2.2,
                ),

                SizedBox(height: 2),

                // "WINNER" Arched with metallic white sheen and 3D extrusion
                ArchedText(
                  text: 'WINNER',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: 50,
                    height: 1,
                  ),
                  topColor: Colors.white,
                  bottomColor: Color(0xFFD6DEE5),
                  shadowColor: Color(0xFF0F172A),
                  curvature: 10,
                  maxRotation: 0.10,
                  letterSpacing: 2,
                  shadowDepth: 6,
                ),

                SizedBox(height: 8),

                // "CONGRATULATIONS!"
                Text(
                  'CONGRATULATIONS!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── 4. Winner Circular Profile Picture ──────────────────────────────
          // Template Center Circle: Center X = 270, Center Y = 361, Inner Diameter = 225.
          Positioned(
            top: 248,
            left: (posterWidth - 226) / 2,
            width: 226,
            height: 226,
            child: _buildWinnerAvatar(),
          ),

          // ── 5. Winner Info & Prize Card (Fixed gap: Card is right below Prize text) ────────
          Positioned(
            top: 508,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Winner Name
                Text(
                  winnerName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                // "from" (Enlarged for readability)
                const Text(
                  'from',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 6),

                // Gym Logo & Name / Location (Enlarged)
                _buildGymInfo(),

                const SizedBox(height: 12),

                // "Participated on: ..." (Enlarged)
                Text(
                  'Participated on: $displayDate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // "Prize:" (Enlarged)
                const Text(
                  'Prize:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Prize Card (Directly below "Prize:" with clean 10px gap, eliminating empty void)
                SizedBox(
                  width: posterWidth - 84,
                  height: 126,
                  child: _buildPrizeCard(displayPrize, displayPartner, partnerLocation, themeColor),
                ),
              ],
            ),
          ),

          // ── 7. Bottom Footer: uses playstore_appstore.png asset spanning full width ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/others/playstore_appstore.png',
              width: posterWidth,
              fit: BoxFit.fitWidth,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Helper (handles memory bytes and network cache fallback) ───────────

  Widget _buildImage({
    Uint8List? bytes,
    String? url,
    BoxFit fit = BoxFit.cover,
    Widget? fallback,
  }) {
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _buildUrlOrFallback(url, fit, fallback),
      );
    }
    return _buildUrlOrFallback(url, fit, fallback);
  }

  Widget _buildUrlOrFallback(String? url, BoxFit fit, Widget? fallback) {
    if (url != null && url.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url.trim(),
        fit: fit,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => fallback ?? const SizedBox.shrink(),
        errorWidget: (_, __, ___) => fallback ?? const SizedBox.shrink(),
      );
    }
    return fallback ?? const SizedBox.shrink();
  }

  // ── Sub-components ──────────────────────────────────────────────────────────

  Widget _buildPartnerTopBadge() {
    return ClipOval(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        child: ClipOval(
          child: _buildImage(
            bytes: partnerLogoBytes,
            url: partnerLogoUrl,
            fit: BoxFit.contain,
            fallback: Center(
              child: Text(
                ((partnerName?.isNotEmpty ?? false) ? partnerName![0] : 'D').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar(double size, Color color) {
    return Icon(
      Icons.star_rounded,
      size: size,
      color: color,
      shadows: [
        Shadow(
          blurRadius: 6,
          color: color.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildWinnerAvatar() {
    return ClipOval(
      child: _buildImage(
        bytes: winnerAvatarBytes,
        url: winnerAvatarUrl,
        fit: BoxFit.cover,
        fallback: const ColoredBox(
          color: Color(0xFFE5E7EB),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: 110,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGymInfo() {
    final gym = (gymName?.isNotEmpty ?? false) ? gymName! : 'Discipl Fitness Zone';
    final location = (gymLocation?.isNotEmpty ?? false) ? gymLocation! : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gym Logo Circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(color: Colors.white38, width: 1.2),
          ),
          child: ClipOval(
            child: _buildImage(
              bytes: gymLogoBytes,
              url: gymLogoUrl,
              fit: BoxFit.cover,
              fallback: const Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 18,
                  color: Color(0xFF4ADE80),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Gym Name & Location
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gym,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    height: 1.15,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeCard(
    String displayPrize,
    String displayPartner,
    String? location,
    Color themeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prize Thumbnail (vivid yellow background matching reference)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 98,
              height: 98,
              color: const Color(0xFFFFAE00),
              child: _buildImage(
                bytes: prizeImageBytes,
                url: prizeImageUrl,
                fit: BoxFit.cover,
                fallback: const Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Prize Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayPrize,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Sponsored by',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: ClipOval(
                        child: _buildImage(
                          bytes: partnerLogoBytes,
                          url: partnerLogoUrl,
                          fit: BoxFit.cover,
                          fallback: Center(
                            child: Text(
                              displayPartner.isNotEmpty ? displayPartner[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayPartner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              height: 1.1,
                            ),
                          ),
                          if (location != null && location.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              location.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                                height: 1.1,
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
    );
  }
}

/// Renders text arched along a smooth parabolic curve with vibrant gradient and 3D extruded shadow.
class ArchedText extends StatelessWidget {
  const ArchedText({
    super.key,
    required this.text,
    required this.style,
    required this.topColor,
    required this.bottomColor,
    required this.shadowColor,
    this.curvature = 18.0,
    this.maxRotation = 0.20,
    this.letterSpacing = 2.0,
    this.shadowDepth = 5,
  });

  final String text;
  final TextStyle style;
  final double curvature;
  final double maxRotation;
  final double letterSpacing;
  final Color topColor;
  final Color bottomColor;
  final Color shadowColor;
  final int shadowDepth;

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    final n = chars.length;
    if (n == 0) return const SizedBox.shrink();

    final stepShadows = <Shadow>[];
    for (int s = 1; s <= shadowDepth; s++) {
      stepShadows.add(Shadow(offset: Offset(0, s.toDouble()), color: shadowColor));
    }
    stepShadows.add(
      Shadow(
        offset: Offset(0, (shadowDepth + 2).toDouble()),
        blurRadius: 4,
        color: Colors.black.withValues(alpha: 0.6),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(n, (i) {
        if (chars[i] == ' ') {
          return SizedBox(width: letterSpacing * 3.5);
        }
        final t = n > 1 ? (i - (n - 1) / 2.0) / ((n - 1) / 2.0) : 0.0;
        final yOffset = -curvature * (1.0 - t * t);
        final angle = t * maxRotation;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.rotate(
            angle: angle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: letterSpacing / 2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Bottom 3D Extruded Shadow Layer
                  Text(
                    chars[i],
                    style: style.copyWith(
                      color: shadowColor,
                      shadows: stepShadows,
                    ),
                  ),
                  // 2. Top Gradient Fill Layer
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, bottomColor],
                    ).createShader(bounds),
                    child: Text(
                      chars[i],
                      style: style.copyWith(
                        color: Colors.white,
                        shadows: const [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
