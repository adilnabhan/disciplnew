import 'package:customer_mobile_app/imports_bindings.dart';

class EmiCard extends StatefulWidget {
  final Membershipes? data;
  final bool isExpanded;
  final VoidCallback onExpandTap;

  const EmiCard({
    super.key,
    required this.data,
    required this.isExpanded,
    required this.onExpandTap,
  });

  @override
  State<EmiCard> createState() => _EmiCardState();
}

class _EmiCardState extends State<EmiCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return Container(
      padding: const EdgeInsets.all(16),
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          // -------- TOP SECTION ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data?.organizationName ?? ' ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data?.membershipName ?? '',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (data?.isEmi ?? false)
                          Expanded(
                            child: Text(
                              'Next EMI: ${data?.summary?.nextEmiDueDate} (₹${data?.summary?.nextEmiAmount})',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              'Total Amount: ₹${data?.fullPayment?.totalAmount}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        if (data?.isEmi ?? false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${data?.summary?.paidEmiCount}/${data?.summary?.totalEmis} EMIs Paid',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusBgColor(
                                data?.paymentStatus ?? '',
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              // data?.paymentStatus == 'pending'
                              //     ? 'Processing'
                              //     :
                              data?.paymentStatus ?? '',
                              style: TextStyle(
                                color: getStatusTextColor(
                                  data?.paymentStatus ?? '',
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right badge
              const SizedBox(width: 8),

              // Arrow button
              if (data!.isEmi ?? false)
                InkWell(
                  onTap: () {
                    setState(() => isExpanded = !isExpanded);
                  },
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // -------- EXPANDED SECTION ----------
          if (isExpanded) ...[
            const Divider(),

            const SizedBox(height: 8),
            Text(
              'Total amount paid: ₹${data.summary?.totalPaid}/₹${data.summary?.totalAmount}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Installments',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            // EMI List
            if (isExpanded)
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.emiInstallments!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  var emi = data.emiInstallments![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMI ${index + 1}/${data.emiInstallments?.length} :  ₹${emi.amount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Due: ${emi.dueDate}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                emi.status == 'Paid'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            // emi.status! == 'pending'
                            //     ? 'Processing'
                            //     :
                            emi.status! ?? '',

                            style: TextStyle(
                              color:
                                  emi.status == 'Paid'
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.yellow.shade100;
      case 'failed':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.black54;
    }
  }
}

class EmiModel {
  final String title;
  final String dueDate;
  final int amount;
  final String status;

  EmiModel({
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.status,
  });
}
