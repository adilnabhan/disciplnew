part of 'list_fitness_centers_cubit.dart';

@freezed
class ListFitnessCentersState with _$ListFitnessCentersState {
  const factory ListFitnessCentersState({
    @Default((data: None(), isPagination: false)) ({Option<Either<ApiException, ListFitnesscenterModel>> data, bool isPagination}) listFitnessCenters,
    @Default(None()) Option<Either<ApiException, FitnesscenterCategoriesModel>> categories,
    SingleFitnesscenterCategoryModel? selectedCategory,
    @Default('') String searchQuery,
  }) = _ListFitnessCentersState;
}
