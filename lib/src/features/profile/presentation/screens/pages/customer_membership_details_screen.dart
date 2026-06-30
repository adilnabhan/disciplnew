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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: actualIsActive
                      ? Colors.green.withOpacity(0.3)
                      : isExpired
                          ? Colors.red.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card Header
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: actualIsActive
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : isExpired
                                ? [Colors.red.shade50, Colors.red.shade100]
                                : [Colors.orange.shade50, Colors.orange.shade100],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: actualIsActive
                                ? Colors.green
                                : isExpired
                                    ? Colors.red
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            actualIsActive
                                ? Icons.fitness_center
                                : isExpired
                                    ? Icons.cancel
                                    : Icons.pending,
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
                                style: AppStyles.text16Px.poppins.w600.dark,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    actualIsActive
                                        ? Icons.check_circle
                                        : isExpired
                                            ? Icons.cancel
                                            : Icons.schedule,
                                    size: 14,
                                    color: actualIsActive
                                        ? Colors.green
                                        : isExpired
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    actualIsActive
                                        ? 'Active'
                                        : isExpired
                                            ? 'Expired'
                                            : 'Pending',
                                    style: AppStyles.text12Px.poppins.w600.copyWith(
                                      color: actualIsActive
                                          ? Colors.green
                                          : isExpired
                                              ? Colors.red
                                              : Colors.orange,
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

                  // Card Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar (only for active/expired)
                        if (membership.startDate != null && membership.endDate != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Membership Progress',
                                style: AppStyles.text13Px.poppins.w600.dark,
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppStyles.text13Px.poppins.w600.copyWith(
                                  color: actualIsActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              actualIsActive ? Colors.green : Colors.red,
                            ),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            !isExpired
                                ? '🕒 $remainingDays days remaining'
                                : '✅ Membership completed',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: !isExpired ? Colors.orange.shade800 : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.calendar_today,
                                label: 'Start Date',
                                value: membership.startDate != null
                                    ? DateFormat('dd MMM yyyy').format(membership.startDate!.toLocal())
                                    : 'N/A',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.event_busy,
                                label: 'Expiry Date',
                                value: membership.endDate != null
                                    ? DateFormat('dd MMM yyyy').format(membership.endDate!.toLocal())
                                    : 'N/A',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.currency_rupee,
                                label: 'Amount Paid',
                                value: membership.amount != null ? '₹${membership.amount}' : 'N/A',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.payment,
                                label: 'Payment Status',
                                value: (membership.paymentStatus ?? 'N/A').toUpperCase(),
                                color: (membership.paymentStatus ?? '').toLowerCase() == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          icon: Icons.category,
                          label: 'Membership Type',
                          value: membership.packageType ?? 'Regular',
                          color: Colors.purple,
                          fullWidth: true,
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    final bodyWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
                  label,
                  style: AppStyles.text12Px.poppins.w500.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w600.dark,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: bodyWidget,
      );
    }
    return bodyWidget;
  }
}
