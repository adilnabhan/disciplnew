import 'package:customer_mobile_app/imports_bindings.dart';

class RewardsHowItWorksSheet extends StatelessWidget {
  const RewardsHowItWorksSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RewardsHowItWorksSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.86;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Partner Rewards Work',
                        style: AppStyles.text15Px.poppins.w700.copyWith(
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Unlock instant discounts with your fitness streak',
                        style: AppStyles.text11Px.poppins.w400.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Step Cards
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  _buildStepCard(
                    stepNumber: '01',
                    stepTitle: 'Complete Daily Workout',
                    stepDescription:
                        'Finish your gym workout in Discipl to activate your dynamic discount QR.',
                    stepIcon: Icons.fitness_center_rounded,
                    stepColor: const Color(0xFF059669),
                    badgeBgColor: const Color(0xFFECFDF5),
                  ),
                  _buildStepCard(
                    stepNumber: '02',
                    stepTitle: 'Visit Any Partner Store',
                    stepDescription:
                        'Explore verified partner cafes, restaurants, supplement stores, and apparel outlets in the "Stores" tab.',
                    stepIcon: Icons.storefront_rounded,
                    stepColor: const Color(0xFF2563EB),
                    badgeBgColor: const Color(0xFFEFF6FF),
                  ),
                  _buildStepCard(
                    stepNumber: '03',
                    stepTitle: 'Show Dynamic QR at Checkout',
                    stepDescription:
                        'Present your live QR code to the cashier before billing. Codes refresh automatically for security.',
                    stepIcon: Icons.qr_code_scanner_rounded,
                    stepColor: const Color(0xFF7C3AED),
                    badgeBgColor: const Color(0xFFF5F3FF),
                  ),
                  _buildStepCard(
                    stepNumber: '04',
                    stepTitle: 'Get Instant Bill Discount',
                    stepDescription:
                        'The cashier scans your code using the partner terminal to instantly deduct the discount from your final bill.',
                    stepIcon: Icons.verified_rounded,
                    stepColor: const Color(0xFF0D9488),
                    badgeBgColor: const Color(0xFFF0FDFA),
                  ),

                  const SizedBox(height: 6),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Got It, Let’s Explore!',
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
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String stepTitle,
    required String stepDescription,
    required IconData stepIcon,
    required Color stepColor,
    required Color badgeBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon in Tinted Container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: stepColor.withValues(alpha: 0.2)),
            ),
            child: Center(child: Icon(stepIcon, color: stepColor, size: 20)),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stepColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP $stepNumber',
                        style: AppStyles.text9Px.poppins.w700.copyWith(
                          color: stepColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stepTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.text13Px.poppins.w700.copyWith(
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stepDescription,
                  style: AppStyles.text11Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.35,
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
