import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/rewards_how_it_works_sheet.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'How It Works',
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => RewardsHowItWorksSheet.show(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Full Guide',
                      style: AppStyles.text11Px.poppins.w600.copyWith(
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildStepRow(
            stepNumber: '1',
            title: 'Complete Daily Workout / Steps',
            description:
                'Finish at least 1 gym workout or achieve your daily step goal in Discipl to activate your daily discount QR code.',
            icon: Icons.fitness_center_rounded,
            accentColor: const Color(0xFF3B82F6),
            isLast: false,
          ),
          _buildStepRow(
            stepNumber: '2',
            title: 'Show QR Code to Partner Cashier',
            description:
                'Visit any of our participating partner cafes, restaurants, or stores and present your dynamic QR code at checkout.',
            icon: Icons.qr_code_2_rounded,
            accentColor: const Color(0xFF8B5CF6),
            isLast: false,
          ),
          _buildStepRow(
            stepNumber: '3',
            title: 'Instant Discount Applied',
            description:
                'The cashier scans your code using their partner terminal, and your instant discount is deducted from your total bill.',
            icon: Icons.local_offer_rounded,
            accentColor: const Color(0xFF10B981),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                stepNumber,
                style: AppStyles.text12Px.poppins.w700.copyWith(
                  color: accentColor,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
