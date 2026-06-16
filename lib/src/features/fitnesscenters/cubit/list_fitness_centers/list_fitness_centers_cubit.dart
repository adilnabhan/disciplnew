import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/services/google/services/location_service.dart';

part 'list_fitness_centers_state.dart';
part 'list_fitness_centers_cubit.freezed.dart';

class ListFitnessCentersCubit extends Cubit<ListFitnessCentersState> {
  ListFitnessCentersCubit() : super(const ListFitnessCentersState());

  Future<void> fetch() async {
    if (isClosed) return;
    emit(state.copyWith(listFitnessCenters: (data: none(), isPagination: false)));

    // Load categories first
    await fetchCategories();
    if (isClosed) return;

    // Load the initial list of fitness centers immediately (without location first, so it doesn't block)
    await fetchListFitnessCenters();
    if (isClosed) return;

    // Attempt to retrieve location asynchronously in the background with a 3-second timeout
    try {
      final double? oldLat = state.latitude;
      final double? oldLon = state.longitude;

      await _tryGetLocation().timeout(const Duration(seconds: 3));

      if (isClosed) return;

      // If location coordinates were successfully retrieved and changed, reload the list with location parameters
      if (state.latitude != oldLat || state.longitude != oldLon) {
        await fetchListFitnessCenters();
      }
    } catch (e) {
      debugPrint('Location lookup timed out or failed in ListFitnessCentersCubit: $e');
    }
  }

  Future<void> _tryGetLocation() async {
    try {
      final position = await LocationService().getPostion();
      if (isClosed) return;
      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      debugPrint('Could not fetch location coordinates: $e');
    }
  }

  Future<void> fetchListFitnessCenters({bool isPagination = false, String? searchQuery}) async {
    if (isClosed) return;
    final fitnessCenters = state.listFitnessCenters.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (fitnessCenters?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(listFitnessCenters: (data: isPagination ? state.listFitnessCenters.data : none(), isPagination: isPagination)));
    final params = <String, dynamic>{
      'search': searchQuery ?? state.searchQuery,
      'category_id': state.selectedCategory?.id,
      if (state.latitude != null) 'lat': state.latitude,
      if (state.longitude != null) 'lon': state.longitude,
      if (state.latitude != null && state.longitude != null) 'radius_km': 50,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    var response = await FitnesscenterRepository().listFitnesscenter(
      queryParameters: params,
      nextUrl: isPagination ? fitnessCenters?.next : null,
    );

    if (isClosed) return;

    final isQueryingWithLocation = params.containsKey('lat') || params.containsKey('lon');
    if (isQueryingWithLocation && !isPagination) {
      final shouldFallback = response.fold(
        (err) => false,
        (model) => model.results == null || model.results!.isEmpty,
      );
      if (shouldFallback) {
        debugPrint('DEBUG: Location-based search returned 0 gyms. Falling back to general gym list.');
        final fallbackParams = Map<String, dynamic>.from(params)
          ..remove('lat')
          ..remove('lon')
          ..remove('radius_km');
        response = await FitnesscenterRepository().listFitnesscenter(
          queryParameters: fallbackParams,
          nextUrl: null,
        );
        if (isClosed) return;
      }
    }

    if (isPagination) {
      await response.fold(
        (l) async {
          if (isClosed) return;
          emit(state.copyWith(listFitnessCenters: (data: state.listFitnessCenters.data, isPagination: false)));
          await Dialogs.showSnack(msg: l.msg);
        },
        (r) async {
          if (isClosed) return;
          final data = r.copyWith(results: [...?fitnessCenters?.results, ...?r.results]);
          emit(state.copyWith(listFitnessCenters: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      if (isClosed) return;
      emit(state.copyWith(listFitnessCenters: (data: some(response), isPagination: isPagination)));
    }
  }

  Future<void> fetchCategories() async {
    if (isClosed) return;
    emit(state.copyWith(categories: none()));
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
