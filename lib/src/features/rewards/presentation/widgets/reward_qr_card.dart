import 'dart:ui' as ui;
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RewardQrCard extends StatelessWidget {
  const RewardQrCard({
    required this.qrModel,
    required this.remainingSeconds,
    required this.isRefreshing,
    required this.onRefresh,
    super.key,
    this.isEligible = true,
    this.onInfoTap,
  });

  final PartnerQrModel? qrModel;
  final int remainingSeconds;
  final bool isRefreshing;
  final bool isEligible;
  final VoidCallback onRefresh;
  final VoidCallback? onInfoTap;

  String _formatTimer(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final qrToken = qrModel?.qrToken ?? '';
    final memberCode = qrModel?.memberCode ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final qrSize = (screenWidth * 0.78).clamp(280.0, 340.0);

    final isTimedOut = isEligible && remainingSeconds <= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEE2726),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEE2726).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Info Icon on top right
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onInfoTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Center: QR Code Area (with optional blur and lock/refresh overlay)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: (!isEligible || isTimedOut) ? 7.5 : 0.0,
                    sigmaY: (!isEligible || isTimedOut) ? 7.5 : 0.0,
                  ),
                  child:
                      (qrToken.isNotEmpty || !isEligible)
                          ? QrImageView(
                            data:
                                qrToken.isNotEmpty
                                    ? qrToken
                                    : 'locked_qr_code_placeholder',
                            size: qrSize,
                            padding: const EdgeInsets.all(4),
                          )
                          : SizedBox(
                            width: qrSize,
                            height: qrSize,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                ),

                // Lock icon overlay for ineligible / no active gym users
                if (!isEligible)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFEE2726),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Tap-to-refresh option overlay over the QR code after timeout
                if (isTimedOut)
                  Positioned.fill(
                    child: Center(
                      child: GestureDetector(
                        onTap: isRefreshing ? null : onRefresh,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRefreshing)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                isRefreshing
                                    ? 'Refreshing...'
                                    : 'Tap to Refresh',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          if (memberCode.isNotEmpty) ...[
            Text(
              memberCode,
              textAlign: TextAlign.center,
              style: AppStyles.text28Px.poppins.w800.copyWith(
                color: Colors.white,
                letterSpacing: 0.8,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Timer & Refresh Row
          if (isTimedOut)
            GestureDetector(
              onTap: isRefreshing ? null : onRefresh,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRefreshing)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFFB300),
                        ),
                      )
                    else
                      const Icon(
                        Icons.refresh_rounded,
                        size: 17,
                        color: Color(0xFFFFB300),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      isRefreshing
                          ? 'Refreshing QR Code...'
                          : 'QR Expired • Tap to Refresh',
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color: const Color(0xFFFFB300),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: Color(0xFFFFB300),
                ),
                const SizedBox(width: 5),
                Text(
                  'Auto-refreshes in ${_formatTimer(remainingSeconds)}',
                  style: AppStyles.text13Px.poppins.w500.copyWith(
                    color: const Color(0xFFFFB300),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: isRefreshing ? null : onRefresh,
                  behavior: HitTestBehavior.opaque,
                  child:
                      isRefreshing
                          ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFFB300),
                            ),
                          )
                          : const Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: Color(0xFFFFB300),
                          ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
