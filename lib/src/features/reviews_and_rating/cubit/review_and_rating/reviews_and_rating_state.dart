part of 'reviews_and_rating_cubit.dart';

@freezed
class ReviewsAndRatingState with _$ReviewsAndRatingState {
  const factory ReviewsAndRatingState({
    @Default((data: None(), isPagination: false))
    ({
      Option<Either<ApiException, FitnessCenterReviewsModel>> data,
      bool isPagination,
    })
    fitnessCenterReviews,
  }) = _ReviewsAndRatingState;
}
