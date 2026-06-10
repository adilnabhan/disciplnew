import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:url_launcher/url_launcher.dart';

class FitnessCentersListingScreen extends StatefulWidget {
  const FitnessCentersListingScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<FitnessCentersListingScreen> createState() =>
      _FitnessCentersListingScreenState();
}

class _FitnessCentersListingScreenState
    extends State<FitnessCentersListingScreen> {
  late final ListFitnessCentersCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _cubit = ListFitnessCentersCubit();
    _fetch();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchListFitnessCenters(isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    await _cubit.fetch();
  }

  Future<void> _fetchCategories() async {
    await _cubit.fetchCategories();
  }

  Future<void> _fetchListFitnessCenters({bool isPagination = false}) async {
    await _cubit.fetchListFitnessCenters(isPagination: isPagination);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _searchBar(),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<ListFitnessCentersCubit, ListFitnessCentersState>(
          builder: (context, state) {
            return state.categories.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold(
                (error) {
                  return error
                      .maybeWhen(
                        network:
                            (e) => ErrorUi.network(onTap: _fetchCategories),
                        notFound:
                            (e) => ErrorUi.notFound(onTap: _fetchCategories),
                        orElse: () => ErrorUi.server(onTap: _fetchCategories),
                      )
                      .center;
                },
                (categories) {
                  return Column(
                    children: [
                      // Main tabs
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: _mainTabsBuild(),
                      ),
                      if (_selectedTabIndex == 0) ...[
                        const SizedBox(height: 16),
                        // Categories as horizontal tile list
                        _categoriesBuild(categories, state),
                        const SizedBox(height: 16),
                        // Fitness centers as vertical tile list
                        Expanded(
                          child: ColoredBox(
                            color: const Color(0xffF7F7F7),
                            child: state.listFitnessCenters.data.fold(
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              (either) => either.fold((error) {
                                return error
                                    .maybeWhen(
                                      network:
                                          (e) => ErrorUi.network(
                                            onTap: _fetchListFitnessCenters,
                                          ),
                                      notFound:
                                          (e) => ErrorUi.notFound(
                                            onTap: _fetchListFitnessCenters,
                                          ),
                                      orElse:
                                          () => ErrorUi.server(
                                            onTap: _fetchListFitnessCenters,
                                          ),
                                    )
                                    .center;
                              }, _fitnessCentersListViewBuild),
                            ),
                          ),
                        ),
                      ] else if (_selectedTabIndex == 1) ...[
                        Expanded(
                          child: _trainersListViewBuild(),
                        ),
                      ] else ...[
                        Expanded(
                          child: _dieticianViewBuild(),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _mainTabsBuild() {
    final tabs = ['Fitness Center', 'Trainer', 'Dietician'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF4F4)
                        : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFCECF)
                          : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.0,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF222222),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  SizedBox _categoriesBuild(
    FitnesscenterCategoriesModel categories,
    ListFitnessCentersState state,
  ) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount:
            (categories.results?.length ?? 0) + 1, // +1 for "All" category
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // First item is "All" category
          if (index == 0) {
            final isSelected = state.selectedCategory == null;
            return CategoryChipButton(
              onTap:
                  () => context.read<ListFitnessCentersCubit>().selectCategory(
                    null,
                  ),
              isSelected: isSelected,
              text: 'All',
            );
          }
          // Regular categories (index - 1 because of "All" category)
          final category = categories.results![index - 1];
          final isSelected = state.selectedCategory?.id == category.id;
          return CategoryChipButton(
            onTap:
                () => context.read<ListFitnessCentersCubit>().selectCategory(
                  category,
                ),
            isSelected: isSelected,
            text: category.name ?? '',
          );
        },
      ),
    );
  }

  Widget _fitnessCentersListViewBuild(ListFitnesscenterModel fitnessCenters) {
    if (fitnessCenters.results?.isEmpty ?? true) {
      return Center(
        child: Text(
          'No fitness centers found!',
          style: AppStyles.text16Px.poppins.w400.textGrey,
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: fitnessCenters.results!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final center = fitnessCenters.results![index];
        return FitnessCenterTile(
          fitnessCenter: center,
          activeMembership: widget.activeMembership,
        );
      },
    );
  }

  Widget _searchBar() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/svg/icons/search_workout_plan.svg',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            left: 72,
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Search by name,place,...',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trainersListViewBuild() {
    if (_trainers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Trainer Available',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We are currently onboarding top trainers to guide you on fitness and training. Check back soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      itemCount: _trainers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trainer = _trainers[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              ClipOval(
                child: ImageNetwork(
                  trainer['image'] as String,
                  width: 80,
                  height: 80,
                  errorWidget: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Column details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trainer['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Specialization chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                      ),
                      child: Text(
                        trainer['specialization'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Location and rating
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Color(0xFF789081),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trainer['location'] as String,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF2C94C),
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF222222),
                                ),
                                children: [
                                  TextSpan(
                                    text: '${trainer['rating']}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: '(${trainer['reviews']})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Enquire Button
              GestureDetector(
                onTap: () async {
                  final phone = (trainer['phone'] as String).replaceAll(RegExp('[^0-9+]'), '');
                  final name = trainer['name'] as String;
                  if (phone.isNotEmpty) {
                    final message = Uri.encodeComponent("Hi, I want to enquire about trainer $name.");
                    final waUrl = Uri.parse('https://wa.me/$phone?text=$message');
                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl);
                    } else {
                      await Dialogs.showSnack(msg: 'Invalid WhatsApp number');
                    }
                  } else {
                    await Dialogs.showSnack(msg: 'WhatsApp number not available');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/icons/whatsapp_logo.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Enquire',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dieticianViewBuild() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Dietician Available',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We are currently onboarding top dieticians to guide you on nutrition and diet planning. Check back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
