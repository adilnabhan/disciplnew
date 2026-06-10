part of 'my_reviews_cubit.dart';

@freezed
class MyReviewsState with _$MyReviewsState {
  const factory MyReviewsState({
    @Default((data: None(), isPagination: false)) ({Option<Either<ApiException, CustomerPostedReviewsModel>> data, bool isPagination}) myReviews,
    @Default(None()) Option<Either<ApiException, ActiveMembershipModel?>> activeMembershipData,
  }) = _MyReviewsState;
}
