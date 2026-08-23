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
              child: _searchBar(),
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

  Widget _searchBar() {
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
