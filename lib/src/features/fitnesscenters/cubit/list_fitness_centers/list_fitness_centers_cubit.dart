import 'package:customer_mobile_app/imports_bindings.dart';

part 'list_fitness_centers_state.dart';
part 'list_fitness_centers_cubit.freezed.dart';

class ListFitnessCentersCubit extends Cubit<ListFitnessCentersState> {
  final bool ignoreLocation;

  ListFitnessCentersCubit({this.ignoreLocation = false})
    : super(const ListFitnessCentersState());

  Future<void> fetch() async {
    if (isClosed) return;

    final repo = FitnesscenterRepository();
    final cachedCats = repo.cachedCategories;
    final cachedGyms = repo.cachedListFitnesscenter;

    if (cachedCats != null && cachedGyms != null) {
      emit(
        state.copyWith(
          categories: some(right(cachedCats)),
          listFitnessCenters: (data: some(right(cachedGyms)), isPagination: false),
          latitude: 11.2588,
          longitude: 75.7804,
          showLocationBanner: false,
        ),
      );
      // Fetch fresh data in the background
      _fetchFreshData();
      return;
    }

    if (state.listFitnessCenters.data.isNone()) {
      emit(
        state.copyWith(listFitnessCenters: (data: none(), isPagination: false)),
      );
    }

    // Load categories first
    await fetchCategories();
    if (isClosed) return;

    if (ignoreLocation) {
      await fetchListFitnessCenters();
      return;
    }

    // Use default mock location coords (11.2588, 75.7804) defined in the state
    emit(
      state.copyWith(
        latitude: 11.2588,
        longitude: 75.7804,
        showLocationBanner: false,
      ),
    );
    await fetchListFitnessCenters();
  }

  Future<void> _fetchFreshData() async {
    if (isClosed) return;
    // Fetch categories and gyms in background
    final responseCategories = await FitnesscenterRepository().fitnesscenterCategories();
    if (isClosed) return;
    
    // Only update state if categories call succeeded
    responseCategories.fold(
      (_) => null,
      (cats) {
        if (!isClosed) {
          emit(state.copyWith(categories: some(right(cats))));
        }
      },
    );
    
    // Now fetch fresh list of fitness centers in background
    final params = <String, dynamic>{
      'search': state.searchQuery,
      'category_id': state.selectedCategory?.id,
    }..removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    var responseGyms = await FitnesscenterRepository().listFitnesscenter(
      queryParameters: params,
      allGyms: ignoreLocation,
    );

    if (isClosed) return;
    emit(
      state.copyWith(
        listFitnessCenters: (
          data: some(responseGyms),
          isPagination: false,
        ),
      ),
    );
  }

  Future<void> fetchListFitnessCenters({
    bool isPagination = false,
    String? searchQuery,
  }) async {
    if (isClosed) return;
    final fitnessCenters = state.listFitnessCenters.data.fold(
      () => null,
      (t) => t.fold((l) => null, (r) => r),
    );
    if (isPagination && (fitnessCenters?.next?.isEmpty ?? true)) {
      return;
    }
    if (!isPagination && state.listFitnessCenters.data.isNone()) {
      emit(
        state.copyWith(
          listFitnessCenters: (
            data: none(),
            isPagination: isPagination,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          listFitnessCenters: (
            data: state.listFitnessCenters.data,
            isPagination: isPagination,
          ),
        ),
      );
    }
    final params = <String, dynamic>{
      'search': searchQuery ?? state.searchQuery,
      'category_id': state.selectedCategory?.id,
    }..removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    var response = await FitnesscenterRepository().listFitnesscenter(
      queryParameters: params,
      nextUrl: isPagination ? fitnessCenters?.next : null,
      allGyms: ignoreLocation,
    );

    if (isClosed) return;

    if (isPagination) {
      await response.fold(
        (l) async {
          if (isClosed) return;
          emit(
            state.copyWith(
              listFitnessCenters: (
                data: state.listFitnessCenters.data,
                isPagination: false,
              ),
            ),
          );
          await Dialogs.showSnack(msg: l.msg);
        },
        (r) async {
          if (isClosed) return;
          final data = r.copyWith(
            results: [...?fitnessCenters?.results, ...?r.results],
          );
          emit(
            state.copyWith(
              listFitnessCenters: (
                data: some(right(data)),
                isPagination: false,
              ),
            ),
          );
        },
      );
    } else {
      if (isClosed) return;
      emit(
        state.copyWith(
          listFitnessCenters: (
            data: some(response),
            isPagination: isPagination,
          ),
        ),
      );
    }
  }

  Future<void> fetchCategories() async {
    if (isClosed) return;
    if (state.categories.isNone()) {
      emit(state.copyWith(categories: none()));
    }
    final response = await FitnesscenterRepository().fitnesscenterCategories();
    if (isClosed) return;
    emit(state.copyWith(categories: some(response)));
  }

  void selectCategory(SingleFitnesscenterCategoryModel? category) {
    emit(state.copyWith(selectedCategory: category));
    fetchListFitnessCenters();
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    fetchListFitnessCenters();
  }
}
