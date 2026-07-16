import 'package:customer_mobile_app/imports_bindings.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _showClearButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _showClearButton.value = _searchController.text.isNotEmpty;
    });
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
    _searchController.dispose();
    _showClearButton.dispose();
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
          centerTitle: false,
          titleSpacing: 20,
          title: Text(
            'Explore',
            style: AppStyles.text20Px.poppins.w500.copyWith(
              height: 1.0,
              color: AppColors.textDark,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  context.push(const SettingsScreen());
                },
                child: SvgPicture.asset(
                  'assets/images/svg/icons/settings _icon.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(66),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: BlocBuilder<ListFitnessCentersCubit, ListFitnessCentersState>(
                builder: (context, state) {
                  final hasError = state.categories.fold(() => false, (either) => either.isLeft()) ||
                      state.listFitnessCenters.data.fold(() => false, (either) => either.isLeft());
                  final isInitialLoading = !hasError &&
                      (state.categories.isNone() || state.listFitnessCenters.data.isNone());
                  return _searchBar(isLoading: isInitialLoading);
                },
              ),
            ),
          ),
        ),
        body: BlocConsumer<ListFitnessCentersCubit, ListFitnessCentersState>(
          listenWhen: (previous, current) {
            final wasLoading = previous.listFitnessCenters.data.fold(() => true, (_) => false);
            final isLoaded = current.listFitnessCenters.data.fold(() => false, (_) => true);
            return wasLoading && isLoaded;
          },
          listener: (context, state) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          builder: (context, state) {
            final hasError = state.categories.fold(
                  () => false,
                  (either) => either.isLeft(),
                ) ||
                state.listFitnessCenters.data.fold(
                  () => false,
                  (either) => either.isLeft(),
                );

            final isInitialLoading = !hasError &&
                (state.categories.isNone() || state.listFitnessCenters.data.isNone());

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: isInitialLoading
                  ? _buildExploreShimmer(key: const ValueKey('explore_shimmer'))
                  : hasError
                      ? _buildErrorUi(state)
                      : _buildLoadedContent(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadedContent(ListFitnessCentersState state) {
    return state.categories.fold(
      () => const SizedBox.shrink(),
      (eitherCats) => eitherCats.fold(
        (error) => const SizedBox.shrink(),
        (categories) => state.listFitnessCenters.data.fold(
          () => const SizedBox.shrink(),
          (eitherGyms) => eitherGyms.fold(
            (error) => const SizedBox.shrink(),
            (fitnessCenters) {
              return Column(
                key: const ValueKey('explore_loaded'),
                children: [
                  const SizedBox(height: 16),
                  _categoriesBuild(categories, state),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ColoredBox(
                      color: const Color(0xffF7F7F7),
                      child: _fitnessCentersListViewBuild(fitnessCenters),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorUi(ListFitnessCentersState state) {
    return Center(
      key: const ValueKey('explore_error'),
      child: state.categories.fold(
        () => const SizedBox.shrink(),
        (eitherCats) => eitherCats.fold(
          (error) => error.maybeWhen(
            network: (e) => ErrorUi.network(onTap: _fetchCategories),
            notFound: (e) => ErrorUi.notFound(onTap: _fetchCategories),
            orElse: () => ErrorUi.server(onTap: _fetchCategories),
          ),
          (_) => state.listFitnessCenters.data.fold(
            () => const SizedBox.shrink(),
            (eitherGyms) => eitherGyms.fold(
              (error) => error.maybeWhen(
                network: (e) => ErrorUi.network(onTap: _fetchListFitnessCenters),
                notFound: (e) => ErrorUi.notFound(onTap: _fetchListFitnessCenters),
                orElse: () => ErrorUi.server(onTap: _fetchListFitnessCenters),
              ),
              (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreShimmer({Key? key}) {
    return SingleChildScrollView(
      key: key,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Category chips placeholder
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const KShimmer(
                  width: 70,
                  height: 32,
                  radius: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 5-6 gym card placeholders
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image placeholder
                      const KShimmer(
                        width: 126,
                        height: 126,
                        radius: 16,
                      ),
                      const SizedBox(width: 16),
                      // Content Column
                      Expanded(
                        child: SizedBox(
                          height: 126,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Gym name placeholder
                                  const KShimmer(
                                    width: 140,
                                    height: 16,
                                    radius: 4,
                                  ),
                                  const SizedBox(height: 8),
                                  // Category chips placeholder
                                  Row(
                                    children: [
                                      const KShimmer(
                                        width: 60,
                                        height: 22,
                                        radius: 8,
                                      ),
                                      const SizedBox(width: 6),
                                      const KShimmer(
                                        width: 60,
                                        height: 22,
                                        radius: 8,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Location placeholder
                                  Row(
                                    children: const [
                                      KShimmer(
                                        width: 16,
                                        height: 16,
                                        radius: 8,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: KShimmer(
                                          height: 14,
                                          radius: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Enquire button placeholder
                              const KShimmer(
                                width: 90,
                                height: 32,
                                radius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 96),
          ],
        ),
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
      return RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No fitness centers found!',
                  style: AppStyles.text16Px.poppins.w500.copyWith(color: const Color(0xFF666666)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.push(AllFitnessCentersListingScreen(activeMembership: widget.activeMembership));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all fitness centers',
                        style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.primary,
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
    final isPagination = _cubit.state.listFitnessCenters.isPagination;
    final results = fitnessCenters.results!;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: results.length + 1 + (isPagination ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index < results.length) {
          final center = results[index];
          return FitnessCenterTile(
            fitnessCenter: center,
            activeMembership: widget.activeMembership,
          );
        }

        if (index == results.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  context.push(AllFitnessCentersListingScreen(activeMembership: widget.activeMembership));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(50), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all fitness centers',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
        );
      },
    ),
  );
}

  Widget _searchBar({bool isLoading = false}) {
    if (isLoading) {
      return Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const KShimmer(
              width: 22,
              height: 22,
              radius: 11,
            ),
            const SizedBox(width: 12),
            const KShimmer(
              width: 180,
              height: 16,
              radius: 4,
            ),
          ],
        ),
      );
    }
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
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
          Positioned(
            left: 72,
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  EasyDebounce.debounce(
                    'search-fitness-center',
                    const Duration(milliseconds: 500),
                    () => _cubit.search(value),
                  );
                },
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Search by name,place,...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  suffixIcon: ValueListenableBuilder<bool>(
                    valueListenable: _showClearButton,
                    builder: (context, show, child) {
                      if (!show) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9E9E9E), size: 20),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _searchController.clear();
                          EasyDebounce.cancel('search-fitness-center');
                          _cubit.search('');
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
