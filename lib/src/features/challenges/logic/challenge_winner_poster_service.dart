import 'dart:ui' as ui;
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/all_challenge_winners_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/challenge_winner_poster_widget.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

/// Service responsible for:
/// 1. Preloading remote images and local assets
/// 2. Offscreen rendering of [ChallengeWinnerPosterWidget] at 1440x2560
/// 3. Saving the generated poster PNG to device gallery via [Gal]
/// 4. Sharing the poster PNG via [Share.shareXFiles]
class ChallengeWinnerPosterService {
  ChallengeWinnerPosterService._();
  static final ChallengeWinnerPosterService instance = ChallengeWinnerPosterService._();

  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  /// Helper to fetch raw image bytes from URL cleanly without logger spam.
  /// Returns null if URL is empty, invalid, or fetch fails.
  Future<Uint8List?> _fetchImageBytes(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(url.trim());
      final request = await _httpClient.getUrl(uri);
      request.followRedirects = true;
      request.headers.set(HttpHeaders.acceptHeader, 'image/*,*/*');
      request.headers.set(HttpHeaders.userAgentHeader, 'Discipl/1.0');
      final response = await request.close();
      if (response.statusCode == 200) {
        return await consolidateHttpClientResponseBytes(response);
      }
    } catch (e) {
      debugPrint('ChallengeWinnerPosterService: Failed to fetch image: $url -> $e');
    }
    return null;
  }

  /// Parses hex color strings (#C71C7C, C71C7C, #AARRGGBB, etc.) with safe fallback.
  Color parseThemeColor(String? colorStr, {Color fallback = const Color(0xFFD71920)}) {
    if (colorStr == null || colorStr.trim().isEmpty) return fallback;
    try {
      final hex = colorStr.trim().replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    } catch (_) {}
    return fallback;
  }

  /// Formats date or date range gracefully.
  String _formatParticipationDate(String? rawDate, ChallengeModel challenge) {
    if (rawDate != null && rawDate.trim().isNotEmpty) {
      return rawDate.trim();
    }
    if (challenge.footer?.date != null && challenge.footer!.date!.trim().isNotEmpty) {
      return challenge.footer!.date!.trim();
    }
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  /// Generates the complete 9:16 winner poster PNG file offscreen.
  Future<File?> generatePosterFile({
    required BuildContext context,
    required ChallengeModel challenge,
    required ChallengeWinnerItem? winner,
  }) async {
    OverlayEntry? overlayEntry;
    try {
      final themeColor = parseThemeColor(challenge.themeColor);
      final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
      final assignedGym = currentUser?.customer?.assignedFitnessCenter;

      // ── Winner Details ──────────────────────────────────────────────────────
      final fullName = '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
      final winnerName = (winner?.userName?.isNotEmpty ?? false)
          ? winner!.userName!
          : (fullName.isNotEmpty ? fullName : 'Lucky Winner');

      final winnerAvatarUrl = winner?.profilePic ?? currentUser?.profilePicture?.toString();

      // ── Partner & Gym Details ───────────────────────────────────────────────
      final partnerName = challenge.brand?.name ?? winner?.brandName ?? 'Sponsor';
      final partnerLogoUrl = challenge.brand?.logo ?? winner?.brandLogo;
      final resolvedGymName = (winner?.gymName?.trim().isNotEmpty ?? false)
          ? winner!.gymName!.trim()
          : (challenge.gymName?.trim().isNotEmpty ?? false)
              ? challenge.gymName!.trim()
              : (assignedGym?['name']?.toString() ??
                  assignedGym?['center_name']?.toString() ??
                  'Discipl Fitness Zone');

      final resolvedGymLogoUrl = (winner?.gymLogo?.trim().isNotEmpty ?? false)
          ? winner!.gymLogo!.trim()
          : (challenge.gymLogo?.trim().isNotEmpty ?? false)
              ? challenge.gymLogo!.trim()
              : assignedGym?['logo']?.toString();

      final resolvedGymLocation = (winner?.gymLocation?.trim().isNotEmpty ?? false)
          ? winner!.gymLocation!.trim()
          : (challenge.gymLocation?.trim().isNotEmpty ?? false)
              ? challenge.gymLocation!.trim()
              : (assignedGym?['place']?.toString() ??
                  assignedGym?['city']?.toString() ??
                  '');

      final partnerLocation = resolvedGymLocation.isNotEmpty
          ? resolvedGymLocation
          : (assignedGym?['place']?.toString() ??
              assignedGym?['city']?.toString() ??
              '');

      // ── Prize Details ───────────────────────────────────────────────────────
      final prizeName = winner?.prizeTitle ?? winner?.prize ?? challenge.name ?? 'Exclusive Prize';
      final prizeImageUrl = winner?.rewardImage ?? challenge.thumbnailUrl;

      final participationDate = _formatParticipationDate(winner?.date ?? winner?.awardedAt, challenge);

      // ── Concurrently Pre-fetch Remote Image Bytes ───────────────────────────
      final results = await Future.wait([
        _fetchImageBytes(winnerAvatarUrl),
        _fetchImageBytes(partnerLogoUrl),
        _fetchImageBytes(prizeImageUrl),
        _fetchImageBytes(resolvedGymLogoUrl),
      ]);

      final winnerAvatarBytes = results[0];
      final partnerLogoBytes = results[1];
      final prizeImageBytes = results[2];
      final gymLogoBytes = results[3];

      // Pre-cache template asset, app store asset, and all remote image providers
      if (context.mounted) {
        final precacheTasks = <Future<void>>[];

        precacheTasks.add(
          precacheImage(
            const AssetImage('assets/images/others/Winner_templete.jpeg'),
            context,
          ).catchError((_) {}),
        );

        precacheTasks.add(
          precacheImage(
            const AssetImage('assets/images/others/playstore_appstore.png'),
            context,
          ).catchError((_) {}),
        );

        if (winnerAvatarBytes != null) {
          precacheTasks.add(
            precacheImage(MemoryImage(winnerAvatarBytes), context).catchError((_) {}),
          );
        } else if (winnerAvatarUrl != null && winnerAvatarUrl.isNotEmpty) {
          precacheTasks.add(
            precacheImage(CachedNetworkImageProvider(winnerAvatarUrl), context).catchError((_) {}),
          );
        }

        if (partnerLogoBytes != null) {
          precacheTasks.add(
            precacheImage(MemoryImage(partnerLogoBytes), context).catchError((_) {}),
          );
        } else if (partnerLogoUrl != null && partnerLogoUrl.isNotEmpty) {
          precacheTasks.add(
            precacheImage(CachedNetworkImageProvider(partnerLogoUrl), context).catchError((_) {}),
          );
        }

        if (prizeImageBytes != null) {
          precacheTasks.add(
            precacheImage(MemoryImage(prizeImageBytes), context).catchError((_) {}),
          );
        } else if (prizeImageUrl != null && prizeImageUrl.isNotEmpty) {
          precacheTasks.add(
            precacheImage(CachedNetworkImageProvider(prizeImageUrl), context).catchError((_) {}),
          );
        }

        if (gymLogoBytes != null) {
          precacheTasks.add(
            precacheImage(MemoryImage(gymLogoBytes), context).catchError((_) {}),
          );
        } else if (resolvedGymLogoUrl != null && resolvedGymLogoUrl.isNotEmpty) {
          precacheTasks.add(
            precacheImage(CachedNetworkImageProvider(resolvedGymLogoUrl), context).catchError((_) {}),
          );
        }

        try {
          await Future.wait(precacheTasks);
        } catch (_) {}
      }

      // ── Offscreen Composition via OverlayEntry ──────────────────────────────
      final posterKey = GlobalKey();
      final overlay = Overlay.of(context, rootOverlay: true);

      overlayEntry = OverlayEntry(
        builder: (ctx) => Positioned(
          left: -9999, // Render outside visible screen
          top: -9999,
          child: Material(
            type: MaterialType.transparency,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: RepaintBoundary(
                key: posterKey,
                child: ChallengeWinnerPosterWidget(
                  themeColor: themeColor,
                  winnerName: winnerName,
                  winnerAvatarUrl: winnerAvatarUrl,
                  winnerAvatarBytes: winnerAvatarBytes,
                  partnerName: partnerName,
                  partnerLogoUrl: partnerLogoUrl,
                  partnerLogoBytes: partnerLogoBytes,
                  partnerLocation: partnerLocation,
                  gymName: resolvedGymName,
                  gymLogoUrl: resolvedGymLogoUrl,
                  gymLogoBytes: gymLogoBytes,
                  gymLocation: resolvedGymLocation,
                  participationDate: participationDate,
                  prizeName: prizeName,
                  prizeImageUrl: prizeImageUrl,
                  prizeImageBytes: prizeImageBytes,
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Wait for complete layout, image decoding, and painting
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final boundary = posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('ChallengeWinnerPosterService: boundary render object is null');
        return null;
      }

      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      // Render at pixelRatio 2.667 -> 540x960 * 2.667 = exactly 1440x2560 pixels!
      ui.Image image;
      try {
        image = await boundary.toImage(pixelRatio: 2.667);
      } catch (e) {
        debugPrint('Poster 2.667x failed ($e), falling back to 2x');
        try {
          image = await boundary.toImage(pixelRatio: 2);
        } catch (_) {
          image = await boundary.toImage(pixelRatio: 1.5);
        }
      }

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/discipl_winner_${challenge.id ?? 0}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      debugPrint('ChallengeWinnerPosterService: Saved poster (${pngBytes.length} bytes) to ${file.path}');
      return file;
    } catch (e, stack) {
      debugPrint('ChallengeWinnerPosterService Error: $e\n$stack');
      return null;
    } finally {
      overlayEntry?.remove();
    }
  }

  /// Handles the complete Download flow: Generates poster, requests permissions, saves to Gallery.
  Future<void> handleDownload({
    required BuildContext context,
    required ChallengeModel challenge,
    required ChallengeWinnerItem? winner,
  }) async {
    try {
      await Dialogs.showSnack(msg: 'Generating winner poster... 🎨');

      final file = await generatePosterFile(
        context: context,
        challenge: challenge,
        winner: winner,
      );

      if (file == null) {
        await Dialogs.showSnack(msg: 'Failed to generate winner poster.');
        return;
      }

      var hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess && Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          hasAccess = true;
        } else {
          final photosStatus = await Permission.photos.request();
          if (photosStatus.isGranted) {
            hasAccess = true;
          }
        }
      }

      if (hasAccess) {
        await Gal.putImage(file.path);
        await Dialogs.showSnack(msg: 'Winner poster saved to Gallery! 📥');
      } else {
        // Fallback attempt for Android 10+ MediaStore direct save
        try {
          await Gal.putImage(file.path);
          await Dialogs.showSnack(msg: 'Winner poster saved to Gallery! 📥');
        } catch (_) {
          // If gallery access failed, offer sharing as graceful alternative
          await Dialogs.showSnack(msg: 'Opening share sheet...');
          if (context.mounted) {
            final box = context.findRenderObject() as RenderBox?;
            final sharePositionOrigin =
                box != null ? box.localToGlobal(Offset.zero) & box.size : null;
            await Share.shareXFiles(
              [XFile(file.path, mimeType: 'image/png')],
              text: 'Winner of the ${challenge.name ?? 'Discipl'} Challenge! 🏆',
              sharePositionOrigin: sharePositionOrigin,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      await Dialogs.showSnack(msg: 'Download failed: $e');
    }
  }

  /// Handles the complete Share flow: Generates poster and opens the native share sheet.
  Future<void> handleShare({
    required BuildContext context,
    required ChallengeModel challenge,
    required ChallengeWinnerItem? winner,
  }) async {
    try {
      await Dialogs.showSnack(msg: 'Preparing poster for sharing... 📤');

      final file = await generatePosterFile(
        context: context,
        challenge: challenge,
        winner: winner,
      );

      if (file == null) {
        await Dialogs.showSnack(msg: 'Failed to generate winner poster.');
        return;
      }

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin =
            box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'I won the ${challenge.name ?? 'Challenge'} on Discipl! 🏆',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      debugPrint('Share error: $e');
      await Dialogs.showSnack(msg: 'Share failed: $e');
    }
  }
}
