import 'package:customer_mobile_app/imports_bindings.dart';

part 'list_fitness_centers_state.dart';
part 'list_fitness_centers_cubit.freezed.dart';

class ListFitnessCentersCubit extends Cubit<ListFitnessCentersState> {
  ListFitnessCentersCubit() : super(const ListFitnessCentersState());

  Future<void> fetch() async {
    await Future.wait([fetchCategories(), fetchListFitnessCenters()]);
  }

  Future<void> fetchListFitnessCenters({bool isPagination = false, String? searchQuery}) async {
    final fitnessCenters = state.listFitnessCenters.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (fitnessCenters?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(listFitnessCenters: (data: isPagination ? state.listFitnessCenters.data : none(), isPagination: isPagination)));
    final params = <String, dynamic>{
      'search': searchQuery ?? state.searchQuery,
      'category_id': state.selectedCategory?.id,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    final response = await FitnesscenterRepository().listFitnesscenter(
      queryParameters: params,
      nextUrl: isPagination ? fitnessCenters?.next : null,
    );
    if (isPagination) {
      await response.fold(
        (l) {
          emit(state.copyWith(listFitnessCenters: (data: state.listFitnessCenters.data, isPagination: false)));
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final data = r.copyWith(results: [...?fitnessCenters?.results, ...?r.results]);
          emit(state.copyWith(listFitnessCenters: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      emit(state.copyWith(listFitnessCenters: (data: some(response), isPagination: isPagination)));
    }
  }

  Future<void> fetchCategories() async {
    emit(state.copyWith(categories: none()));
    final response = await FitnesscenterRepository().fitnesscenterCategories();
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
