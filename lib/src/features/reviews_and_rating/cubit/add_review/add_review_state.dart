part of 'add_review_cubit.dart';

@freezed
class AddReviewState with _$AddReviewState {
  const factory AddReviewState({
    Option<Either<ApiException, void>>? addReview,
  }) = _AddReviewState;
}
