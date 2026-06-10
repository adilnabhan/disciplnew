import 'package:customer_mobile_app/imports_bindings.dart';

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({required this.paymentHistory, super.key});

  final SinglePaymentHistoryModel paymentHistory;

  @override
  Widget build(BuildContext context) {
    final org = paymentHistory.organization ?? 'Unknown Organization';
    final amount = paymentHistory.amount ?? '-';
    final paymentType = paymentHistory.paymentType ?? 'Unknown';
    final date = paymentHistory.paymentDate;
    final formattedDate =
        date != null ? DateFormat('dd MMM yyyy').format(date) : 'Unknown Date';

    IconData icon;
    Color iconColor;
    switch (paymentType.toLowerCase()) {
      case 'razorpay':
        icon = Icons.account_balance_wallet_rounded;
        iconColor = AppColors.primary;
      case 'cash':
        icon = Icons.money_rounded;
        iconColor = Colors.green;
      case 'stripe':
        icon = Icons.credit_card_rounded;
        iconColor = Colors.blue;
      default:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.textGrey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderGrey.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withAlpha(32),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org,
                  style: AppStyles.text16Px.poppins.w600.dark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  paymentType.toUpperCase(),
                  style: AppStyles.text13Px.poppins.w400.textGrey,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹$amount',
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
