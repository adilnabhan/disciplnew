import 'package:customer_mobile_app/imports_bindings.dart';

class AllFitnessCentersListingScreen extends StatefulWidget {
  const AllFitnessCentersListingScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<AllFitnessCentersListingScreen> createState() =>
      _AllFitnessCentersListingScreenState();
}

class _AllFitnessCentersListingScreenState
    extends State<AllFitnessCentersListingScreen> {
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
    // Set ignoreLocation to true to list all fitness centers generally
    _cubit = ListFitnessCentersCubit(ignoreLocation: true);
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
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF444444),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'All Fitness Centers',
            style: AppStyles.text18Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
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
            child: Text(
              'No fitness centers found!',
              style: AppStyles.text16Px.poppins.w400.textGrey,
            ),
          ),
        ),
      );
    }
    final isPagination = _cubit.state.listFitnessCenters.isPagination;
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: fitnessCenters.results!.length + (isPagination ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == fitnessCenters.results!.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final center = fitnessCenters.results![index];
        return FitnessCenterTile(
          fitnessCenter: center,
          activeMembership: widget.activeMembership,
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
                    'search-fitness-center-all',
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
                          EasyDebounce.cancel('search-fitness-center-all');
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
