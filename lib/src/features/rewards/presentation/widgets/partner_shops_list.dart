import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_shop_model.dart';

class PartnerShopsList extends StatelessWidget {
  const PartnerShopsList({
    required this.shops,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSearchChanged,
    this.onShowQrTapped,
    super.key,
  });

  final List<PartnerShop> shops;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onShowQrTapped;

  static const List<String> categories = [
    'All',
    'Cafe',
    'Restaurant',
    'Nutrition',
    'Retail',
    'Spa',
    'Hotel',
  ];

  static Future<void> launchNavigation(PartnerShop shop) async {
    final destination =
        shop.fullAddress.isNotEmpty
            ? '${shop.name}, ${shop.fullAddress}'
            : '${shop.name}, ${shop.location}';
    final query = Uri.encodeComponent(destination);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching navigation: $e');
    }
  }

  static Future<void> launchPhoneCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    final url = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Outlet Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF059669),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Partner Stores & Outlets',
                  style: AppStyles.text16Px.poppins.w700.copyWith(
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${shops.length} Outlets',
                style: AppStyles.text10Px.poppins.w600.copyWith(
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Search Bar
        Container(
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
          child: TextField(
            onChanged: onSearchChanged,
            style: AppStyles.text13Px.poppins.w500.copyWith(
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Search store, cafe, city, or location...',
              hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Category Filter Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected =
                  cat.toLowerCase() == selectedCategory.toLowerCase() ||
                  (selectedCategory == 'All' && cat == 'All');
              return GestureDetector(
                onTap: () => onCategorySelected(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFE2E8F0),
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Shops List
        if (shops.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 32,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Partner Outlets Available',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Partner outlets and exclusive offers will appear here as new partner locations are activated.',
                  textAlign: TextAlign.center,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildShopCard(context, shops[index]);
            },
          ),
      ],
    );
  }

  Widget _buildShopCard(BuildContext context, PartnerShop shop) {
    final bannerUrl = shop.bannerUrl;
    final hasBanner = bannerUrl != null && bannerUrl.trim().isNotEmpty;
    final logo = shop.logoUrl;
    final hasLogo = logo != null && logo.isNotEmpty;

    return GestureDetector(
      onTap:
          () => showShopDetailsSheet(
            context,
            shop,
            onShowQrTapped: onShowQrTapped,
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Panoramic Banner Image (only if store has a banner)
              if (hasBanner) _buildShopBanner(shop, bannerUrl),

              // Card Body Content
              Padding(
                padding: EdgeInsets.fromLTRB(16, hasBanner ? 14 : 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Avatar Logo + Name & Category/City + Discount Badge
                    Row(
                      children: [
                        // Store Logo Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: shop.themeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child:
                                hasLogo
                                    ? CachedNetworkImage(
                                      imageUrl: logo,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (_, __) => Center(
                                            child: Icon(
                                              shop.iconData,
                                              color: shop.themeColor,
                                              size: 24,
                                            ),
                                          ),
                                      errorWidget:
                                          (_, __, ___) => Center(
                                            child: Icon(
                                              shop.iconData,
                                              color: shop.themeColor,
                                              size: 24,
                                            ),
                                          ),
                                    )
                                    : Center(
                                      child: Icon(
                                        shop.iconData,
                                        color: shop.themeColor,
                                        size: 24,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Store Name, Category Pill, City
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name,
                                style: AppStyles.text16Px.poppins.w700.copyWith(
                                  fontSize: 17,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  // Category Pill
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        shop.displayCategory,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.text11Px.poppins.w600
                                            .copyWith(
                                              color: const Color(0xFF4F46E5),
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                  if (shop.city.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        shop.city,
                                        style: AppStyles.text12Px.poppins.w500
                                            .copyWith(
                                              color: const Color(0xFF64748B),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Discount Badge (e.g., "10% OFF")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            shop.discountTag,
                            style: AppStyles.text12Px.poppins.w700.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (shop.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        shop.description,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Address & Directions Box
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFECFDF5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.place_rounded,
                              size: 15,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shop.fullAddress.isNotEmpty
                                  ? shop.fullAddress
                                  : shop.location,
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Directions button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => launchNavigation(shop),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.navigation_rounded,
                                      size: 12,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Directions',
                                      style: AppStyles.text11Px.poppins.w700
                                          .copyWith(
                                            color: const Color(0xFF2563EB),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Bottom Badges: Min bill, max discount, QR accepted
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                shop.minPurchaseTag,
                                style: AppStyles.text11Px.poppins.w600.copyWith(
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                shop.maxDiscountTag,
                                style: AppStyles.text11Px.poppins.w600.copyWith(
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // QR Accepted Badge
                        Row(
                          children: [
                            const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'QR Accepted',
                              style: AppStyles.text12Px.poppins.w700.copyWith(
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopBanner(PartnerShop shop, String bannerUrl) {
    return _ShopBannerImage(bannerUrl: bannerUrl, themeColor: shop.themeColor);
  }

  static void showShopDetailsSheet(
    BuildContext context,
    PartnerShop shop, {
    VoidCallback? onShowQrTapped,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Store Banner if available
                if (shop.bannerUrl != null && shop.bannerUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: shop.bannerUrl!,
                      width: double.infinity,
                      height: 135,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Header with Store Info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: shop.themeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: shop.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (_, __, ___) => Icon(
                                        shop.iconData,
                                        color: shop.themeColor,
                                        size: 26,
                                      ),
                                )
                                : Icon(
                                  shop.iconData,
                                  color: shop.themeColor,
                                  size: 26,
                                ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: AppStyles.text16Px.poppins.w700.copyWith(
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shop.displayCategory,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: shop.themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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

                const SizedBox(height: 14),

                // Offer & Requirements Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Offer Discount',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            shop.discountTag,
                            style: AppStyles.text13Px.poppins.w700.copyWith(
                              color: shop.themeColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Requirements',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${shop.minPurchaseTag} • ${shop.maxDiscountTag}',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      if (shop.rewardPointsPer100Inr > 0) ...[
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reward Points',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '+${shop.rewardPointsPer100Inr} pts per ₹100 spent',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Address & Navigation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 18,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Store Location',
                                  style: AppStyles.text11Px.poppins.w600
                                      .copyWith(color: const Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  shop.fullAddress,
                                  style: AppStyles.text11Px.poppins.w400
                                      .copyWith(
                                        color: const Color(0xFF475569),
                                        height: 1.35,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Action Row: Open in Maps + Call Store
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => launchNavigation(shop),
                              icon: const Icon(
                                Icons.navigation_rounded,
                                size: 15,
                              ),
                              label: const Text('Open in Maps'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          if (shop.contactPhone != null &&
                              shop.contactPhone!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed:
                                  () => launchPhoneCall(shop.contactPhone!),
                              icon: const Icon(Icons.call_rounded, size: 15),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F172A),
                                elevation: 0,
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Show QR at Counter Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onShowQrTapped?.call();
                    },
                    icon: const Icon(Icons.qr_code_rounded, size: 18),
                    label: const Text('Show QR at Counter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShopBannerImage extends StatefulWidget {
  const _ShopBannerImage({required this.bannerUrl, required this.themeColor});

  final String bannerUrl;
  final Color themeColor;

  @override
  State<_ShopBannerImage> createState() => _ShopBannerImageState();
}

class _ShopBannerImageState extends State<_ShopBannerImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) return const SizedBox.shrink();

    const bannerHeight = 145.0;
    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: CachedNetworkImage(
        imageUrl: widget.bannerUrl,
        width: double.infinity,
        height: bannerHeight,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              width: double.infinity,
              height: bannerHeight,
              color: const Color(0xFFF1F5F9),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.themeColor,
                  ),
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasError) {
              setState(() => _hasError = true);
            }
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
