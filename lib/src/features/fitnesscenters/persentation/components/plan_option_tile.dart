import 'package:customer_mobile_app/imports_bindings.dart';

class PlanOptionTile extends StatefulWidget {
  const PlanOptionTile({
    required this.plan,
    super.key,
    this.isSelected = false,
    this.onTap,
    this.onEmiSelected,
  });

  final FitnesscenterMembershipPlansModel? plan;
  final bool isSelected;
  final void Function(FitnesscenterMembershipPlansModel plan)? onTap;
  final void Function(
    FitnesscenterMembershipPlansModel plan,
    EmiOptionsModel? emi,
  )?
  onEmiSelected;
  @override
  State<PlanOptionTile> createState() => _PlanOptionTileState();
}

class _PlanOptionTileState extends State<PlanOptionTile> {
  bool _isEmiSelected = false;
  EmiOptionsModel? _selectedEmi;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return GestureDetector(
      onTap: () {
        if (plan == null || widget.isSelected) return;
        widget.onTap?.call(plan);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              !widget.isSelected
                  ? const Color(0xFF270A0A).withAlpha(150)
                  : null,
          gradient:
              !widget.isSelected
                  ? null
                  : const LinearGradient(
                    colors: [Color(0xFF290F0F), Color(0xff581F1F)],
                  ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                widget.isSelected
                    ? const Color(0xffC39191)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Plan Title & Pricing ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      plan?.name ?? '',
                      style: AppStyles.text14Px.poppins.w500.light,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: AppStyles.text16Px.poppins.w700.light,
                    children: [
                      if (plan?.offerPrice?.isNotEmpty ?? false)
                        TextSpan(
                          text:
                              '₹${plan?.offerPrice?.toNum.toStringAsFixed(2)}',
                          style: AppStyles.text14Px.poppins.w300.light.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (plan?.actualPrice?.isNotEmpty ?? false)
                        const WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text: '₹${plan?.actualPrice?.toNum.toStringAsFixed(2)}',
                        style: AppStyles.text16Px.poppins.w700.light,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// --- Offer Details ---
            if ((plan?.offerPrice?.isNotEmpty ?? false) &&
                (plan?.actualPrice?.isNotEmpty ?? false) &&
                plan?.actualPrice != plan?.offerPrice) ...[
              Row(
                children: [
                  Text(
                    'Total ₹${plan?.offerPrice ?? 00}',
                    style: AppStyles.text12Px.poppins.w400.light,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xff713E3E),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Text(
                      'Save ₹${plan?.actualPrice?.toNum ?? 00}',
                      style: AppStyles.text12Px.poppins.w400.light,
                    ),
                  ),
                ],
              ),
            ],

            /// --- EMI Switch + EMI options ---
            if (plan?.isEmiAvailable == true &&
                (plan?.emiPlans.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Opt for EMI',
                    style: AppStyles.text12Px.poppins.w500.light.copyWith(
                      color: widget.isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  Transform.scale(
                    scale: .8,
                    child: Switch(
                      value: _isEmiSelected,
                      activeColor: const Color(0xffC39191),
                      onChanged:
                          widget.isSelected
                              ? (value) {
                                setState(() {
                                  _isEmiSelected = value;
                                  if (!value) {
                                    _selectedEmi = null;
                                    if (widget.plan != null) {
                                      widget.onEmiSelected?.call(
                                        widget.plan!,
                                        null,
                                      ); // notify parent about reset
                                    }
                                  }
                                });
                              }
                              : null,
                    ),
                  ),
                ],
              ),

              if (widget.isSelected && _isEmiSelected) ...[
                const SizedBox(height: 8),
                Column(
                  children:
                      (plan?.emiPlans ?? []).map<Widget>((emi) {
                        return RadioListTile<EmiOptionsModel>(
                          value: emi,
                          groupValue: _selectedEmi,
                          activeColor: const Color(0xffC39191),
                          title: Text(
                            '${emi.month} ${emi.month == 1 ? 'month' : 'months'} @ ₹${emi.price.toStringAsFixed(2)}',
                            style: AppStyles.text14Px.poppins.w400.light,
                          ),
                          onChanged: (value) {
                            setState(() => _selectedEmi = value);
                            if (value != null) {
                              widget.onEmiSelected?.call(plan!, value);
                            }
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
