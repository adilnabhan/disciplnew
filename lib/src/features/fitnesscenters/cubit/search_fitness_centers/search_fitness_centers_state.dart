part of 'search_fitness_centers_cubit.dart';

@freezed
class SearchFitnessCentersState with _$SearchFitnessCentersState {
  const factory SearchFitnessCentersState({@Default(None()) Option<Either<ApiException, ListFitnesscenterModel>> fitnessCenters}) = _SearchFitnessCentersState;
}
