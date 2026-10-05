import 'package:customer_mobile_app/imports_bindings.dart';

class DiscountRulesCard extends StatelessWidget {
  const DiscountRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Discount Policy & Limits',
                style: AppStyles.text14Px.poppins.w700.copyWith(
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Grid of terms
          Row(
            children: [
              Expanded(
                child: _buildTermTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Min Purchase',
                  value: '₹300',
                  subtitle: 'Valid on orders ₹300+',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTermTile(
                  icon: Icons.percent_rounded,
                  title: 'Max Discount',
                  value: 'Up to ₹150',
                  subtitle: 'Or 20% max per bill',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTermTile(
                  icon: Icons.event_repeat_rounded,
                  title: 'Redemption Limit',
                  value: '1x / Day',
                  subtitle: 'Per partner store',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTermTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Eligibility',
                  value: 'Daily Workout',
                  subtitle: 'Complete workout/steps',
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.text10Px.poppins.w500.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppStyles.text14Px.poppins.w700.copyWith(
              color: const Color(0xFF1E293B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppStyles.text10Px.poppins.w400.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 9.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
