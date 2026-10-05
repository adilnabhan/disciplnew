import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_cubit.dart';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_state.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_shop_model.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/widgets/partner_shops_list.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RewardsCubit>();
      return const _PartnersScreenView();
    } catch (_) {
      return BlocProvider(
        create: (_) => RewardsCubit()..loadRewards(),
        child: const _PartnersScreenView(),
      );
    }
  }
}

class _PartnersScreenView extends StatefulWidget {
  const _PartnersScreenView();

  @override
  State<_PartnersScreenView> createState() => _PartnersScreenViewState();
}

class _PartnersScreenViewState extends State<_PartnersScreenView> {
  final ScrollController _scrollController = ScrollController();

  static const List<String> _categories = [
    'All',
    'Cafe',
    'Restaurant',
    'Nutrition',
    'Retail',
    'Spa',
    'Hotel',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.90),
                          const Color(0xFFEEEEEE).withValues(alpha: 0.65),
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF222222),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Partners',
          style: AppStyles.text18Px.poppins.w700.copyWith(
            color: const Color(0xFF1E1E1E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => context.push(const SettingsScreen()),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.90),
                            const Color(0xFFEEEEEE).withValues(alpha: 0.65),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/svg/icons/settings _icon.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<RewardsCubit, RewardsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE2726)),
            );
          }

          final allShops = state.allShops;
          final filteredShops = state.filteredShops;

          return RefreshIndicator(
            color: const Color(0xFFEE2726),
            onRefresh:
                () => context.read<RewardsCubit>().loadRewards(isRefresh: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading: Partners
                  Text(
                    'Partners',
                    style: AppStyles.text22Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Top Container: Shops Logo Only Grid
                  _buildLogosContainer(context, allShops),

                  const SizedBox(height: 20),

                  // Category Filter Chips
                  _buildCategoryFilter(context, state.selectedCategory),

                  const SizedBox(height: 16),

                  // Shops Name Portion (Shop Cards List)
                  _buildShopsNamePortion(context, filteredShops),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogosContainer(
    BuildContext context,
    List<PartnerShop> allShops,
  ) {
    if (allShops.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF94A3B8),
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Partner Brands Available',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Partner brand collaborations and exclusive perks will appear here once partnerships are active.',
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final displayShops = allShops.take(8).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (12 * 3)) / 4;
          final itemHeight = itemWidth * 1.05;

          return Wrap(
            spacing: 12,
            runSpacing: 14,
            children:
                displayShops.map((shop) {
                  final logoUrl = shop.logoUrl;

                  return GestureDetector(
                    onTap: () {
                      PartnerShopsList.showShopDetailsSheet(
                        context,
                        shop,
                        onShowQrTapped: () => Navigator.pop(context),
                      );
                    },
                    child: Container(
                      width: itemWidth,
                      height: itemHeight,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child:
                            logoUrl != null && logoUrl.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: logoUrl,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorWidget:
                                        (_, __, ___) => Icon(
                                          shop.iconData,
                                          color: shop.themeColor,
                                          size: 24,
                                        ),
                                  ),
                                )
                                : Icon(
                                  shop.iconData,
                                  color: shop.themeColor,
                                  size: 24,
                                ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, String selectedCategory) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected =
              cat.toLowerCase() == selectedCategory.toLowerCase() ||
              (selectedCategory == 'All' && cat == 'All');

          return GestureDetector(
            onTap: () => context.read<RewardsCubit>().setCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopsNamePortion(
    BuildContext context,
    List<PartnerShop> filteredShops,
  ) {
    if (filteredShops.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
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
              'Participating partner stores and exclusive offers will appear here once registered.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredShops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _buildShopNameCard(context, filteredShops[index]);
      },
    );
  }

  Widget _buildShopNameCard(BuildContext context, PartnerShop shop) {
    final bannerUrl = shop.bannerUrl;
    final hasBanner = bannerUrl != null && bannerUrl.trim().isNotEmpty;
    final logo = shop.logoUrl;
    final hasLogo = logo != null && logo.isNotEmpty;

    return GestureDetector(
      onTap:
          () => PartnerShopsList.showShopDetailsSheet(
            context,
            shop,
            onShowQrTapped: () => Navigator.pop(context),
          ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Panoramic Banner Image from API
              if (hasBanner)
                _ShopCardBanner(
                  bannerUrl: bannerUrl,
                  themeColor: shop.themeColor,
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(16, hasBanner ? 14 : 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Avatar Logo + Name & Category/City + Discount Badge
                    Row(
                      children: [
                        // Store Logo Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDEC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child:
                                hasLogo
                                    ? CachedNetworkImage(
                                      imageUrl: logo,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (_, __, ___) => Center(
                                            child: Icon(
                                              shop.iconData,
                                              color: const Color(0xFFEE2726),
                                              size: 24,
                                            ),
                                          ),
                                    )
                                    : Center(
                                      child: Icon(
                                        shop.iconData,
                                        color: const Color(0xFFEE2726),
                                        size: 24,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name & Category Badge & City
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name,
                                style: AppStyles.text16Px.poppins.w700.copyWith(
                                  fontSize: 16.5,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
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
                                              fontSize: 10.5,
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
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4F46E5,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6,
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
                      const SizedBox(height: 10),
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

                    const SizedBox(height: 12),

                    // Address & Directions Container
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFECFDF5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.place_rounded,
                              size: 14,
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
                          // Directions Button
                          GestureDetector(
                            onTap:
                                () => PartnerShopsList.launchNavigation(shop),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.navigation_rounded,
                                    size: 11,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),

                    // Bottom Row: Min/Max Tags + QR Accepted
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                shop.minPurchaseTag,
                                style: AppStyles.text11Px.poppins.w500.copyWith(
                                  color: const Color(0xFF475569),
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                shop.maxDiscountTag,
                                style: AppStyles.text11Px.poppins.w500.copyWith(
                                  color: const Color(0xFF475569),
                                  fontSize: 10.5,
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
                              size: 15,
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
}

class _ShopCardBanner extends StatefulWidget {
  const _ShopCardBanner({required this.bannerUrl, required this.themeColor});

  final String bannerUrl;
  final Color themeColor;

  @override
  State<_ShopCardBanner> createState() => _ShopCardBannerState();
}

class _ShopCardBannerState extends State<_ShopCardBanner> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) return const SizedBox.shrink();

    const bannerHeight = 140.0;
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
