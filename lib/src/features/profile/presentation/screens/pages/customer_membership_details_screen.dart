import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/dashboard/domain/models/active_membership_model.dart';
import 'package:intl/intl.dart';

class CustomerMembershipDetailsScreen extends StatelessWidget {
  final ActiveMembershipModel membership;

  const CustomerMembershipDetailsScreen({
    required this.membership,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Determine status
    final String statusStr = membership.status ?? 'Pending';
    final bool isActive = membership.isActive ?? false;
    final bool isPending = statusStr.toLowerCase() == 'pending';
    final localEndDate = membership.endDate?.toLocal();
    final remainingDays = isPending
        ? 0
        : (localEndDate != null
            ? DateTime(localEndDate.year, localEndDate.month, localEndDate.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays
            : 0);
    final bool isExpired = !isPending && (statusStr.toLowerCase() == 'expired' || remainingDays < 0);
    final bool actualIsActive = isActive && !isExpired && !isPending;

    // Calculate progress
    double progress = 0.0;
    if (membership.startDate != null && membership.endDate != null) {
      final totalSec = membership.endDate!.difference(membership.startDate!).inSeconds;
      final elapsedSec = now.difference(membership.startDate!).inSeconds;
      if (totalSec > 0) {
        progress = elapsedSec / totalSec;
      }
    }
    progress = progress.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          'Membership Package',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expired Alert Banner
            if (isExpired) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD1D1), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠ ',
                      style: TextStyle(fontSize: 16, color: Color(0xFFD30C15)),
                    ),
                    Expanded(
                      child: Text(
                        'Your membership plan has expired. Please contact your fitness center to renew and keep enjoying premium benefits.',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFFD30C15),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Membership Card
            Container(
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
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card Header
                  Container(
                    decoration: BoxDecoration(
                      color:
                          actualIsActive
                              ? const Color(0xFFD7F7DC)
                              : isExpired
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFFDBA74),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                actualIsActive
                                    ? const Color(0xFF4CAF50)
                                    : isExpired
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                membership.planName ?? 'Standard Plan',
                                style: AppStyles.text15Px.poppins.w600.copyWith(
                                  color: const Color(0xFF111827),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            actualIsActive
                                                ? const Color(0xFF16A34A)
                                                : isExpired
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFFEA580C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      actualIsActive
                                          ? 'Active'
                                          : isExpired
                                          ? 'Expired'
                                          : 'Pending',
                                      style: AppStyles.text11Px.poppins.w600
                                          .copyWith(
                                            color:
                                                actualIsActive
                                                    ? const Color(0xFF16A34A)
                                                    : isExpired
                                                    ? const Color(0xFFDC2626)
                                                    : const Color(0xFFEA580C),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Content
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar (only for active/expired)
                        if (membership.startDate != null &&
                            membership.endDate != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Membership Progress',
                                style: AppStyles.text13Px.poppins.w600.copyWith(
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppStyles.text13Px.poppins.w700.copyWith(
                                  color:
                                      actualIsActive
                                          ? const Color(0xFF16A34A)
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFEFF1F5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                actualIsActive
                                    ? const Color(0xFF16A34A)
                                    : Colors.red,
                              ),
                              minHeight: 7,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                !isExpired
                                    ? '$remainingDays days remaining'
                                    : 'Membership completed',
                                style: AppStyles.text11Px.poppins.w500.copyWith(
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Details Grid (2x2)
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.calendar_today_rounded,
                                label: 'Start Date',
                                value:
                                    membership.startDate != null
                                        ? DateFormat(
                                          'dd MMM yyyy',
                                        ).format(membership.startDate!.toLocal())
                                        : '-',
                                themeColor: const Color(0xFF2563EB),
                                bgColor: const Color(0xFFEFF6FF),
                                borderColor: const Color(0xFFBFDBFE),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.calendar_today_rounded,
                                label: 'End Date',
                                value:
                                    membership.endDate != null
                                        ? DateFormat(
                                          'dd MMM yyyy',
                                        ).format(membership.endDate!.toLocal())
                                        : '-',
                                themeColor: const Color(0xFFEF4444),
                                bgColor: const Color(0xFFFEF2F2),
                                borderColor: const Color(0xFFFECACA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.currency_rupee_rounded,
                                label: 'Amount',
                                value:
                                    membership.amount != null
                                        ? '₹${membership.amount}'
                                        : '₹0.00',
                                themeColor: const Color(0xFF16A34A),
                                bgColor: const Color(0xFFF0FDF4),
                                borderColor: const Color(0xFFBBF7D0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.credit_card_outlined,
                                label: 'Payment',
                                value: _formatPaymentStatus(
                                  membership.paymentStatus,
                                ),
                                themeColor: const Color(0xFF64748B),
                                bgColor: const Color(0xFFF8FAFC),
                                borderColor: const Color(0xFFE2E8F0),
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

            const SizedBox(height: 28),

            // Gym / Fitness Center Section
            if (membership.organization != null) ...[
              Text(
                'Fitness Center Details',
                style: AppStyles.text15Px.poppins.w600.dark,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    if (membership.organization!.logo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          membership.organization!.logo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.fitness_center, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fitness_center, color: AppColors.primary),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership.organization!.name ?? 'Discipl Center',
                            style: AppStyles.text14Px.poppins.w600.dark,
                          ),
                          const SizedBox(height: 4),
                          if (membership.organization!.location?.buildingName != null)
                            Text(
                              membership.organization!.location!.buildingName!,
                              style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          if (membership.organization!.category != null && membership.organization!.category!.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: membership.organization!.category!.map((cat) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    cat,
                                    style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.primary),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPaymentStatus(String? status) {
    if (status == null || status.trim().isEmpty) return 'Completed';
    final raw = status.trim();
    if (raw.toLowerCase() == 'paid') return 'Completed';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color themeColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: themeColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.text11Px.poppins.w500.copyWith(
                    color: themeColor,
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
            style: AppStyles.text12Px.poppins.w600.copyWith(
              color: const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
