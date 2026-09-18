import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trainer_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/domain/respositories/fitnesscenter_repository.dart';

class FitnessCentersListingScreen extends StatefulWidget {
  const FitnessCentersListingScreen({
    super.key,
    this.activeMembership,
    this.isFromBottomNav,
  });

  final ActiveMembershipModel? activeMembership;
  final bool? isFromBottomNav;

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
  bool _isLocationFlowRunning = false;
  int _selectedTabIndex = 0; // 0: Fitness Center, 1: Trainer
  bool _isLoadingTrainers = false;
  List<GymTrainer>? _trainersList;
  String? _trainersError;

  Future<void> _fetchTrainers({String? search}) async {
    setState(() {
      _isLoadingTrainers = true;
      _trainersError = null;
    });

    final res = await FitnesscenterRepository().fetchPremiumTrainers(
      search: search ?? _searchController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingTrainers = false;
      res.fold(
        (error) {
          _trainersError = 'Failed to load trainers. Please try again.';
        },
        (trainers) {
          _trainersList = trainers;
        },
      );
    });
  }

  Future<void> _openWhatsAppEnquiry(GymTrainer trainer) async {
    final currentUser = context.read<AppCubit>().state.currentUser;
    if (currentUser == null) {
      GuestLoginSheet.show(
        context,
        message: 'Log in to enquire with certified trainers and personal coaches.',
      );
      return;
    }

    final rawPhone = trainer.mobile ?? '';
    String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    if (cleanPhone.isNotEmpty) {
      final trainerName = trainer.fullName ?? 'Trainer';
      final message = Uri.encodeComponent(
        'Hi $trainerName,\n\n'
        'I would like to enquire about your personal training sessions and fitness coaching.\n\n'
        'Thank you.\n\n'
        '—\n'
        'This enquiry was initiated through the Discipl App.',
      );
      final waUrl = Uri.parse('https://wa.me/$cleanPhone?text=$message');
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        await Dialogs.showSnack(msg: 'Could not open WhatsApp');
      }
    } else {
      await Dialogs.showSnack(msg: 'WhatsApp contact not available for this trainer');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _showClearButton.value = _searchController.text.isNotEmpty;
    });
    _cubit = ListFitnessCentersCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeLocationFlow();
      }
    });
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

  Future<void> _initializeLocationFlow() async {
    if (_isLocationFlowRunning) return;
    _isLocationFlowRunning = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        await _getLocationAndFetch(prefs);
      } else if (permission == LocationPermission.deniedForever) {
        await _cubit.setLocationDeniedAndFetch(permanentlyDenied: true);
      } else {
        // Directly show the system location permission dialog
        if (!mounted) return;
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.always ||
            newPermission == LocationPermission.whileInUse) {
          await _getLocationAndFetch(prefs, force: true);
        } else if (newPermission == LocationPermission.deniedForever) {
          await _cubit.setLocationDeniedAndFetch(permanentlyDenied: true);
        } else {
          await _cubit.setLocationDeniedAndFetch(permanentlyDenied: false);
        }
      }
    } finally {
      _isLocationFlowRunning = false;
    }
  }

  Future<void> _getLocationAndFetch(SharedPreferences prefs, {bool force = false}) async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (mounted) {
          Dialogs.showSnack(msg: 'Please enable device location services.');
        }
        final cachedLat = prefs.getDouble('cached_latitude');
        final cachedLon = prefs.getDouble('cached_longitude');
        if (cachedLat != null && cachedLon != null) {
          await _cubit.updateLocationAndFetch(latitude: cachedLat, longitude: cachedLon);
        } else {
          await _cubit.setLocationDeniedAndFetch(permanentlyDenied: false);
        }
        return;
      }

      final cachedLat = prefs.getDouble('cached_latitude');
      final cachedLon = prefs.getDouble('cached_longitude');
      bool loadedFromCache = false;

      if (cachedLat != null && cachedLon != null) {
        if (_cubit.state.latitude == null || _cubit.state.longitude == null) {
          await _cubit.updateLocationAndFetch(latitude: cachedLat, longitude: cachedLon);
          loadedFromCache = true;
        }
      }

      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      ).then((position) async {
        bool locationChangedSignificantly = true;
        final lastLat = prefs.getDouble('cached_latitude');
        final lastLon = prefs.getDouble('cached_longitude');
        if (lastLat != null && lastLon != null) {
          final distance = Geolocator.distanceBetween(
            lastLat,
            lastLon,
            position.latitude,
            position.longitude,
          );
          if (distance < 300 && loadedFromCache && !force) {
            locationChangedSignificantly = false;
          }
        }

        await prefs.setDouble('cached_latitude', position.latitude);
        await prefs.setDouble('cached_longitude', position.longitude);

        if (locationChangedSignificantly || !loadedFromCache) {
          await _cubit.updateLocationAndFetch(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      }).catchError((e) async {
        if (!loadedFromCache) {
          final permission = await Geolocator.checkPermission();
          await _cubit.setLocationDeniedAndFetch(
            permanentlyDenied: permission == LocationPermission.deniedForever,
          );
        }
      });
    } catch (e) {
      final cachedLat = prefs.getDouble('cached_latitude');
      final cachedLon = prefs.getDouble('cached_longitude');
      if (cachedLat != null && cachedLon != null) {
        await _cubit.updateLocationAndFetch(latitude: cachedLat, longitude: cachedLon);
      } else {
        final permission = await Geolocator.checkPermission();
        await _cubit.setLocationDeniedAndFetch(
          permanentlyDenied: permission == LocationPermission.deniedForever,
        );
      }
    }
  }


  Widget _buildLocationBanner(ListFitnessCentersState state) {
    final bool isPermanentlyDenied = state.isLocationPermanentlyDenied;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '📍',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPermanentlyDenied
                  ? 'Location permission is disabled. Enable it from Settings to discover nearby gyms.'
                  : 'Enable location to discover gyms near you.',
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final permission = await Geolocator.checkPermission();
              
              if (permission == LocationPermission.deniedForever || isPermanentlyDenied) {
                await Geolocator.openAppSettings();
                return;
              }
              
              final newPermission = await Geolocator.requestPermission();
              if (newPermission == LocationPermission.always ||
                  newPermission == LocationPermission.whileInUse) {
                await _getLocationAndFetch(prefs, force: true);
              } else if (newPermission == LocationPermission.deniedForever) {
                await _cubit.setLocationDeniedAndFetch(permanentlyDenied: true);
              } else {
                Dialogs.showSnack(msg: 'Location permission denied.');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPermanentlyDenied ? 'Settings' : 'Enable',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetch() async {
    final prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      await _getLocationAndFetch(prefs, force: true);
    } else {
      await _cubit.fetch();
    }
  }

  Future<void> _fetchCategories() async {
    await _cubit.fetchCategories();
  }

  Future<void> _fetchListFitnessCenters({bool isPagination = false}) async {
    await _cubit.fetchListFitnessCenters(isPagination: isPagination);
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final bool showBackButton = (widget.isFromBottomNav == true)
        ? false
        : (widget.isFromBottomNav == false || canPop);

    final Widget mainContent = BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: showBackButton ? 56 : 0,
            leading: showBackButton
                ? Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
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
                  )
                : null,
            centerTitle: false,
            titleSpacing: showBackButton ? 12 : 20,
            title: Text(
              'Explore',
              style: AppStyles.text20Px.poppins.w500.copyWith(
                height: 1.0,
                color: AppColors.textDark,
              ),
            ),
            actions: showBackButton
                ? null
                : [
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
              preferredSize: const Size.fromHeight(116),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
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
                  _buildTabBar(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          body: _selectedTabIndex == 0
              ? BlocConsumer<ListFitnessCentersCubit, ListFitnessCentersState>(
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
                )
              : _buildTrainersView(),
        ),
      );

    DashboardCubit? dashboardCubit;
    try {
      dashboardCubit = context.read<DashboardCubit>();
    } catch (_) {
      dashboardCubit = null;
    }

    if (dashboardCubit != null) {
      return BlocListener<DashboardCubit, DashboardState>(
        bloc: dashboardCubit,
        listener: (context, dashboardState) {
          if (dashboardState.navIndex == 2) {
            _initializeLocationFlow();
          }
        },
        child: mainContent,
      );
    }

    return mainContent;
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
                  if (state.showLocationBanner) _buildLocationBanner(state),
                  const SizedBox(height: 16),
                  _categoriesBuild(categories, state),
                  const SizedBox(height: 16),
                  if (state.latitude != null && state.longitude != null)
                    _buildSortingLabel(),
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

  Widget _buildSortingLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📍',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                'Nearest to you',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: const Color(0xFF666666),
                ),
              ),
            ],
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
                  'No nearby fitness centers found.',
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
                        'Browse all gyms',
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
                  if (_selectedTabIndex == 0) {
                    EasyDebounce.debounce(
                      'search-fitness-center',
                      const Duration(milliseconds: 500),
                      () => _cubit.search(value),
                    );
                  } else {
                    EasyDebounce.debounce(
                      'search-trainers',
                      const Duration(milliseconds: 500),
                      () => _fetchTrainers(search: value),
                    );
                  }
                },
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: _selectedTabIndex == 0 ? 'Search by name,place,...' : 'Search trainer by name, specialty,...',
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
                          if (_selectedTabIndex == 0) {
                            EasyDebounce.cancel('search-fitness-center');
                            _cubit.search('');
                          } else {
                            EasyDebounce.cancel('search-trainers');
                            _fetchTrainers(search: '');
                          }
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildTabPill(
              title: 'Fitness Center',
              isSelected: _selectedTabIndex == 0,
              onTap: () {
                if (_selectedTabIndex != 0) {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabPill(
              title: 'Trainer',
              isSelected: _selectedTabIndex == 1,
              onTap: () {
                if (_selectedTabIndex != 1) {
                  setState(() {
                    _selectedTabIndex = 1;
                  });
                  if (_trainersList == null) {
                    _fetchTrainers();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F1) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCDD2) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFF1F2937),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTrainersView() {
    if (_isLoadingTrainers && (_trainersList == null || _trainersList!.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
        ),
      );
    }

    if (_trainersError != null && (_trainersList == null || _trainersList!.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _trainersError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchTrainers(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_trainersList == null || _trainersList!.isEmpty) {
      return _buildNoTrainersView();
    }

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      onRefresh: () => _fetchTrainers(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _trainersList!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final trainer = _trainersList![index];
          return _buildTrainerCard(trainer);
        },
      ),
    );
  }

  Widget _buildTrainerCard(GymTrainer trainer) {
    String specialtyText = 'Body Building';
    if (trainer.specializations != null && trainer.specializations!.isNotEmpty) {
      specialtyText = trainer.specializations!.first;
    } else if (trainer.bio != null && trainer.bio!.trim().isNotEmpty) {
      specialtyText = trainer.bio!.trim();
    }

    final locationText = trainer.place ??
        trainer.location?.place ??
        trainer.location?.city ??
        trainer.location?.area ??
        '';

    return GestureDetector(
      onTap: () {
        context.push(TrainerDetailsScreen(trainer: trainer));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Avatar
            ClipOval(
              child: SizedBox(
                width: 66,
                height: 66,
                child: trainer.profileImage != null && trainer.profileImage!.trim().isNotEmpty
                    ? ImageNetwork(
                        trainer.profileImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF94A3B8),
                          size: 34,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trainer.fullName ?? 'Trainer Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      specialtyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Red Rounded WhatsApp Enquire Button
            GestureDetector(
              onTap: () => _openWhatsAppEnquiry(trainer),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTrainersView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF1F2),
                border: Border.all(
                  color: const Color(0xFFFFCDD2),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_search_rounded,
                  size: 44,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Trainers Available Yet',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We are currently onboarding certified fitness trainers and personal coaches in your area.\nPlease check back soon or explore partnered fitness centers.',
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explore Fitness Centers',
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
