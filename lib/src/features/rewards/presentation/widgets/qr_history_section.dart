import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/qr_history_model.dart';

class QrHistorySection extends StatefulWidget {
  const QrHistorySection({
    required this.items,
    this.isLoading = false,
    this.onExploreStores,
    super.key,
  });

  final List<QrRedemptionHistoryItem> items;
  final bool isLoading;
  final VoidCallback? onExploreStores;

  @override
  State<QrHistorySection> createState() => _QrHistorySectionState();
}

class _QrHistorySectionState extends State<QrHistorySection> {
  String _selectedFilter = 'All';
  bool _showAll = false;

  List<String> get _filters {
    final list = <String>['All', 'This Month'];
    for (final item in widget.items) {
      final cat = item.shopCategory.trim();
      if (cat.isNotEmpty && !list.contains(cat)) {
        list.add(cat);
      }
    }
    return list;
  }

  List<QrRedemptionHistoryItem> get _filteredItems {
    final now = DateTime.now();
    return widget.items.where((item) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'This Month') {
        return item.redeemedAt.month == now.month &&
            item.redeemedAt.year == now.year;
      }
      return item.shopCategory.toLowerCase().trim() ==
          _selectedFilter.toLowerCase().trim();
    }).toList();
  }

  String _formatDateTime(DateTime dt, {String? date, String? time}) {
    if (date != null && time != null && date.isNotEmpty && time.isNotEmpty) {
      return '$date • $time';
    }

    final now = DateTime.now();
    final difference = now.difference(dt);

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (difference.inDays == 0 && dt.day == now.day) {
      return 'Today • $timeStr';
    } else if (difference.inDays <= 1 && (now.day - dt.day == 1)) {
      return 'Yesterday • $timeStr';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} • $timeStr';
    }
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') ||
        cat.contains('meal') ||
        cat.contains('restaurant')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('nutrition') ||
        cat.contains('supplement') ||
        cat.contains('protein')) {
      return Icons.fitness_center_rounded;
    } else if (cat.contains('cafe') ||
        cat.contains('smoothie') ||
        cat.contains('salad')) {
      return Icons.local_cafe_rounded;
    } else if (cat.contains('gear') ||
        cat.contains('activewear') ||
        cat.contains('retail')) {
      return Icons.checkroom_rounded;
    } else if (cat.contains('spa') || cat.contains('salon')) {
      return Icons.spa_rounded;
    } else if (cat.contains('hotel')) {
      return Icons.hotel_rounded;
    }
    return Icons.shopping_bag_outlined;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') ||
        cat.contains('meal') ||
        cat.contains('restaurant')) {
      return const Color(0xFFF97316);
    } else if (cat.contains('nutrition') || cat.contains('supplement')) {
      return const Color(0xFF3B82F6);
    } else if (cat.contains('cafe') ||
        cat.contains('smoothie') ||
        cat.contains('salad')) {
      return const Color(0xFF10B981);
    } else if (cat.contains('gear') ||
        cat.contains('activewear') ||
        cat.contains('retail')) {
      return const Color(0xFF8B5CF6);
    } else if (cat.contains('spa') || cat.contains('salon')) {
      return const Color(0xFFEC4899);
    }
    return const Color(0xFF0EA5E9);
  }

  void _showReceiptSheet(BuildContext context, QrRedemptionHistoryItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _RedemptionReceiptSheet(
            item: item,
            formattedDate: _formatDateTime(
              item.redeemedAt,
              date: item.date,
              time: item.time,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'Loading your redemption history...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final displayItems = _filteredItems;
    final visibleItems =
        _showAll ? displayItems : displayItems.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF059669),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Redemption History',
                      style: AppStyles.text15Px.poppins.w700.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Past orders & discount breakdowns',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (displayItems.length > 4)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _showAll ? 'Show Less' : 'View All (${displayItems.length})',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Filter chips (if we have items or filters)
        if (_filters.length > 1 && widget.items.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                        labelStyle: AppStyles.text12Px.poppins.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                        ),
                        selectedColor: const Color(0xFF0F172A),
                        backgroundColor: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // History items list or Empty State
        if (visibleItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 36,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.items.isEmpty
                      ? 'No QR Redemptions Yet'
                      : 'No Redemptions in "$_selectedFilter"',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.items.isEmpty
                      ? 'Scan your Discipl QR code at checkout in any partner store to unlock instant discounts and save money.'
                      : 'Try switching filters to view other orders.',
                  textAlign: TextAlign.center,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (widget.items.isEmpty && widget.onExploreStores != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onExploreStores,
                    icon: const Icon(Icons.storefront_rounded, size: 16),
                    label: const Text('Explore Partner Stores'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ] else if (widget.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                    child: const Text('Reset Filter to All'),
                  ),
                ],
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = visibleItems[index];
              return _buildHistoryCard(context, item);
            },
          ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, QrRedemptionHistoryItem item) {
    final catColor = _getCategoryColor(item.shopCategory);
    final catIcon = _getCategoryIcon(item.shopCategory);
    final hasLogo =
        (item.shopLogo != null && item.shopLogo!.isNotEmpty) ||
        (item.photo != null && item.photo!.isNotEmpty);
    final logoUrl =
        (item.shopLogo?.isNotEmpty ?? false) ? item.shopLogo! : item.photo;

    return InkWell(
      onTap: () => _showReceiptSheet(context, item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Shop Avatar / Logo, Shop Name, Location, Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo or Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        hasLogo
                            ? CachedNetworkImage(
                              imageUrl: logoUrl!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Center(
                                    child: Icon(
                                      catIcon,
                                      color: catColor,
                                      size: 20,
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Center(
                                    child: Icon(
                                      catIcon,
                                      color: catColor,
                                      size: 20,
                                    ),
                                  ),
                            )
                            : Center(
                              child: Icon(catIcon, color: catColor, size: 20),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.shopName,
                              style: AppStyles.text14Px.poppins.w700.copyWith(
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Invoice Number / Ref Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.invoiceNumber ?? item.qrRef,
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color: const Color(0xFF475569),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              item.location,
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${_formatDateTime(item.redeemedAt, date: item.date, time: item.time)}',
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Product Details / Items ordered (if available)
            if (item.productDetails != null &&
                item.productDetails!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.productDetails!,
                        style: AppStyles.text11Px.poppins.w500.copyWith(
                          color: const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.pointsAwarded > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 11,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${item.pointsAwarded} pts',
                              style: AppStyles.text10Px.poppins.w700.copyWith(
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Bottom Financial Row: Purchase Amount, Discount Got, Final Paid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bill Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Amount',
                      style: AppStyles.text10Px.poppins.w500.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '₹${item.billAmount.toStringAsFixed(0)}',
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),

                // Discount Got Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFF059669),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Saved ₹${item.discountAmount.toStringAsFixed(0)}',
                        style: AppStyles.text12Px.poppins.w700.copyWith(
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.discountPercent.toInt()}%',
                          style: AppStyles.text9Px.poppins.w700.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Paid Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount Paid',
                      style: AppStyles.text10Px.poppins.w500.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '₹${item.finalAmount.toStringAsFixed(0)}',
                      style: AppStyles.text14Px.poppins.w700.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RedemptionReceiptSheet extends StatelessWidget {
  const _RedemptionReceiptSheet({
    required this.item,
    required this.formattedDate,
  });

  final QrRedemptionHistoryItem item;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Success circle icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Discount Redeemed',
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Verified at Partner Checkout POS',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 18),

          // Receipt breakdown card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.shopName,
                            style: AppStyles.text14Px.poppins.w700.copyWith(
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${item.shopCategory} • ${item.location}',
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.invoiceNumber ?? item.qrRef,
                        style: AppStyles.text11Px.poppins.w600.copyWith(
                          color: const Color(0xFF334155),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),

                // If items list is present
                if (item.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  Text(
                    'ITEMS ORDERED',
                    style: AppStyles.text10Px.poppins.w700.copyWith(
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...item.items.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 13,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry,
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (item.productDetails != null &&
                    item.productDetails!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Items / Order', item.productDetails!),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // Date & Time
                _buildReceiptRow('Redemption Time', formattedDate),
                if (item.staffName != null && item.staffName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildReceiptRow('Verified By', item.staffName!),
                ],
                if (item.pointsAwarded > 0) ...[
                  const SizedBox(height: 8),
                  _buildReceiptRow(
                    'Discipl Points Earned',
                    '+${item.pointsAwarded} pts',
                    valueColor: const Color(0xFFD97706),
                    isBold: true,
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // Bill Amount
                _buildReceiptRow(
                  'Original Bill Amount',
                  '₹${item.billAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),

                // Discount
                _buildReceiptRow(
                  'Discipl Discount (${item.discountPercent.toInt()}%)',
                  '-₹${item.discountAmount.toStringAsFixed(2)}',
                  valueColor: const Color(0xFF059669),
                  isBold: true,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFCBD5E1)),
                const SizedBox(height: 12),

                // Total Paid
                _buildReceiptRow(
                  'Final Amount Paid',
                  '₹${item.finalAmount.toStringAsFixed(2)}',
                  isLarge: true,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Savings callout banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  color: Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You saved ₹${item.discountAmount.toStringAsFixed(0)} on this order with your Discipl gym workout streak!',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Close button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Close',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isLarge ? AppStyles.text13Px : AppStyles.text12Px).poppins
              .copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
        ),
        Text(
          value,
          style: (isLarge ? AppStyles.text16Px : AppStyles.text12Px).poppins
              .copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
        ),
      ],
    );
  }
}
