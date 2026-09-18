import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RewardQrCard extends StatelessWidget {
  final PartnerQrModel? qrModel;
  final int remainingSeconds;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const RewardQrCard({
    super.key,
    required this.qrModel,
    required this.remainingSeconds,
    required this.isRefreshing,
    required this.onRefresh,
  });

  String _formatTimer(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = remainingSeconds <= 0;
    final isEligible = qrModel?.isEligibleForDiscount ?? true;
    final qrToken = qrModel?.qrToken ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isEligible
              ? AppColors.primary.withValues(alpha: 0.22)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isEligible
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Member Info Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isEligible
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              qrModel?.customerName ?? 'Discipl Member',
                              style: AppStyles.text15Px.poppins.w700.copyWith(
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                                const SizedBox(width: 3),
                                Text(
                                  'ACTIVE',
                                  style: AppStyles.text10Px.poppins.w700.copyWith(
                                    color: const Color(0xFF059669),
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Member ID: ${qrModel?.memberCode ?? "DISC-000012"}',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh Button
                GestureDetector(
                  onTap: isRefreshing ? null : onRefresh,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isRefreshing
                            ? const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                        const SizedBox(width: 4),
                        Text(
                          'Refresh',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QR Code Display Area
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // QR Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: qrToken.isNotEmpty
                      ? QrImageView(
                          data: qrToken,
                          size: 220,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0F172A),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0F172A),
                          ),
                        )
                      : Container(
                          width: 220,
                          height: 220,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: AppColors.primary),
                        ),
                ),

                // Expired Overlay
                if (isExpired)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_off_outlined, color: Colors.amber, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'QR Code Expired',
                            style: AppStyles.text14Px.poppins.w700.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap refresh to generate a new token',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: onRefresh,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Refresh Token'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timer & Validity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: isExpired
                  ? Colors.red.shade50
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpired
                    ? Colors.red.shade200
                    : const Color(0xFFFFEDD5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: isExpired ? Colors.red.shade700 : const Color(0xFFEA580C),
                ),
                const SizedBox(width: 6),
                Text(
                  isExpired
                      ? 'Code expired'
                      : 'Valid for ${_formatTimer(remainingSeconds)}',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: isExpired ? Colors.red.shade700 : const Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Show this QR to the cashier at checkout to claim your member discount.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Brightness & Security Notice Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.brightness_medium_rounded, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dynamic secure token. Turn up screen brightness for fast cashier scan.',
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: const Color(0xFF64748B),
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
}
