import 'dart:async';
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
    if (url == null || url.trim().isEmpty || url.trim().toLowerCase() == 'null') return null;
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
      final rawWinnerName = winner?.userName?.trim();
      final winnerName = (rawWinnerName != null && rawWinnerName.isNotEmpty)
          ? rawWinnerName
          : 'Lucky Winner';

      // Only use the winner's actual profile pic. Never fall back to currentUser profile pic,
      // which would incorrectly place the downloading person's photo on the winner poster.
      final rawWinnerPic = winner?.profilePic?.trim();
      final String? winnerAvatarUrl = (rawWinnerPic != null &&
              rawWinnerPic.isNotEmpty &&
              rawWinnerPic.toLowerCase() != 'null')
          ? rawWinnerPic
          : null;

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
        } else if (winnerAvatarUrl != null &&
            winnerAvatarUrl.isNotEmpty &&
            winnerAvatarUrl.toLowerCase() != 'null') {
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
      // To ensure that Impeller (used on real iOS & Android release builds)
      // and Skia do NOT cull or clip the offscreen poster, we place it within
      // the visible screen bounds at 0.001 opacity. This forces Flutter and
      // the GPU compositor to fully lay out and paint all layers, while remaining
      // 100% invisible to the user.
      final posterKey = GlobalKey();
      final overlay = Overlay.of(context, rootOverlay: true);

      overlayEntry = OverlayEntry(
        builder: (ctx) {
          final screenSize = MediaQuery.of(ctx).size;
          final scale = (screenSize.width / 540.0).clamp(0.1, 1.0);
          return Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.001,
                child: Material(
                  type: MaterialType.transparency,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topLeft,
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
              ),
            ),
          );
        },
      );

      overlay.insert(overlayEntry);

      // ── Synchronize Frame Rendering ─────────────────────────────────────────
      // In release mode, boundary.debugNeedsPaint is stripped (always returns false).
      // We must explicitly register a post-frame callback and schedule a frame so
      // the engine completes the build, layout, and raster phases.
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!completer.isCompleted) completer.complete();
      });
      WidgetsBinding.instance.scheduleFrame();
      await completer.future;

      // Ensure all memory images and layer caches have finalized painting
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final boundary = posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('ChallengeWinnerPosterService: boundary render object is null');
        return null;
      }

      // Render at pixelRatio 2.667 -> 540x960 * 2.667 = exactly 1440x2560 pixels!
      // Fallback gracefully across resolutions if GPU texture memory is constrained.
      ui.Image? image;
      const pixelRatios = [2.667, 2.0, 1.5, 1.0];
      for (final ratio in pixelRatios) {
        try {
          image = await boundary.toImage(pixelRatio: ratio);
          if (image != null) break;
        } catch (e) {
          debugPrint('ChallengeWinnerPosterService: toImage at ${ratio}x failed: $e');
        }
      }

      if (image == null) {
        debugPrint('ChallengeWinnerPosterService: Failed to render image from boundary');
        return null;
      }

      ByteData? byteData;
      try {
        byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      } finally {
        image.dispose(); // Prevent GPU texture memory leaks under Impeller
      }

      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/discipl_winner_${challenge.id ?? 0}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);
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

      bool saved = false;

      // 1. Check or request gallery access via Gal
      bool hasAccess = false;
      try {
        hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          hasAccess = await Gal.requestAccess();
        }
      } catch (e) {
        debugPrint('Gal access check error: $e');
      }

      // 2. On Android, if Gal permission is not yet confirmed, fallback to permission_handler
      if (!hasAccess && Platform.isAndroid) {
        try {
          final photosStatus = await Permission.photos.request();
          if (photosStatus.isGranted) {
            hasAccess = true;
          } else {
            final storageStatus = await Permission.storage.request();
            if (storageStatus.isGranted) {
              hasAccess = true;
            }
          }
        } catch (_) {}
      }

      // 3. Attempt to save via Gal.putImage, then Gal.putImageBytes
      try {
        await Gal.putImage(file.path);
        saved = true;
      } catch (e1) {
        debugPrint('Gal.putImage failed ($e1), attempting Gal.putImageBytes...');
        try {
          final bytes = await file.readAsBytes();
          await Gal.putImageBytes(bytes, name: 'discipl_winner_${challenge.id ?? 0}');
          saved = true;
        } catch (e2) {
          debugPrint('Gal.putImageBytes failed: $e2');
        }
      }

      if (saved) {
        await Dialogs.showSnack(msg: 'Winner poster saved to Gallery! 📥');
      } else {
        // Fallback: If gallery direct save could not be completed, open the system share sheet
        // so the user can easily save to Photos / Files or share directly.
        await Dialogs.showSnack(msg: 'Saved image! Opening options...');
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
