import 'package:customer_mobile_app/imports_bindings.dart';

part 'add_review_state.dart';
part 'add_review_cubit.freezed.dart';

class AddReviewCubit extends Cubit<AddReviewState> {
  AddReviewCubit() : super(const AddReviewState());

  Future<void> addReview({
    required int organizationId,
    required int rating,
    required String comment,
  }) async {
    emit(state.copyWith(addReview: none()));
    final response = await ReviewsAndReatingRepository().addReview(
      body: {
        'organization': organizationId,
        'rating': rating,
        'comment': comment,
      },
    );
    emit(state.copyWith(addReview: some(response)));
  }
}
