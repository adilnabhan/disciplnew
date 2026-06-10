import 'package:customer_mobile_app/imports_bindings.dart';

part 'reviews_and_rating_state.dart';
part 'reviews_and_rating_cubit.freezed.dart';

class ReviewsAndRatingCubit extends Cubit<ReviewsAndRatingState> {
  ReviewsAndRatingCubit() : super(const ReviewsAndRatingState());

  Future<void> fetchFitnessCenterReviews(int id, {bool isPagination = false}) async {
    final reviews = state.fitnessCenterReviews.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (reviews?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(fitnessCenterReviews: (data: isPagination ? state.fitnessCenterReviews.data : none(), isPagination: isPagination)));
    final response = await ReviewsAndReatingRepository().fitnessCenterReviews(id: id, queryParameters: {});
    if (isPagination) {
      await response.fold(
        (l) {
          emit(state.copyWith(fitnessCenterReviews: (data: state.fitnessCenterReviews.data, isPagination: false)));
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final combinedReviews = [...?reviews?.results?.reviews, ...?r.results?.reviews];
          final updatedResults = r.results?.copyWith(reviews: combinedReviews);
          final data = r.copyWith(results: updatedResults);
          emit(state.copyWith(fitnessCenterReviews: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      emit(state.copyWith(fitnessCenterReviews: (data: some(response), isPagination: false)));
    }
  }
}
