import 'package:customer_mobile_app/imports_bindings.dart';

part 'my_reviews_state.dart';
part 'my_reviews_cubit.freezed.dart';

class MyReviewsCubit extends Cubit<MyReviewsState> {
  MyReviewsCubit() : super(const MyReviewsState());

  Future<void> fetchMyReviews({bool isPagination = false}) async {
    final reviews = state.myReviews.data.fold(() => null, (t) => t.fold((l) => null, (r) => r));
    if (isPagination && (reviews?.next?.isEmpty ?? true)) {
      return;
    }
    emit(state.copyWith(myReviews: (data: isPagination ? state.myReviews.data : none(), isPagination: isPagination)));
    final response = await ReviewsAndReatingRepository().customerPostedReviews(queryParameters: {}, nextUrl: reviews?.next);
    if (isPagination) {
      await response.fold(
        (l) {
          emit(state.copyWith(myReviews: (data: state.myReviews.data, isPagination: false)));
          return Dialogs.showSnack(msg: l.msg);
        },
        (r) {
          final combinedReviews = [...?reviews?.results, ...?r.results];
          final data = r.copyWith(results: combinedReviews);
          emit(state.copyWith(myReviews: (data: some(right(data)), isPagination: false)));
        },
      );
    } else {
      emit(state.copyWith(myReviews: (data: some(response), isPagination: false)));
    }
  }

  //* Fetch active membership data
  Future<void> fetchActiveMembership() async {
    emit(state.copyWith(activeMembershipData: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(state.copyWith(activeMembershipData: some(left(const ApiException.unknown()))));
      return;
    }
    final response = await CustomerMembershipRepository().activeMembership(id: id);
    emit(state.copyWith(activeMembershipData: some(response)));
  }
}
