part of 'fitness_center_details_cubit.dart';

@freezed
class FitnessCenterDetailsState with _$FitnessCenterDetailsState {
  const factory FitnessCenterDetailsState({
    @Default(None()) Option<Either<ApiException, FitnesscenterDetailsModel>> fitnessCenterDetails,
    @Default(None()) Option<Either<ApiException, FitnessCenterReviewsModel>> fitnessCenterReviews,
  }) = _FitnessCenterDetailsState;
}
