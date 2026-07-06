import 'package:customer_mobile_app/imports_bindings.dart';

part 'fitness_center_details_state.dart';
part 'fitness_center_details_cubit.freezed.dart';

class FitnessCenterDetailsCubit extends Cubit<FitnessCenterDetailsState> {
  FitnessCenterDetailsCubit({required this.id, FitnesscenterDetailsModel? previewData})
      : super(FitnessCenterDetailsState(
          fitnessCenterDetails: _getInitialDetails(id, previewData),
          fitnessCenterReviews: _getInitialReviews(id),
        ));

  final int id;

  static Option<Either<ApiException, FitnesscenterDetailsModel>> _getInitialDetails(
    int id,
    FitnesscenterDetailsModel? previewData,
  ) {
    final cached = FitnesscenterRepository().getCachedDetails(id);
    if (cached != null) {
      return some(right(cached));
    }
    if (previewData != null) {
      return some(right(previewData));
    }
    return none();
  }

  static Option<Either<ApiException, FitnessCenterReviewsModel>> _getInitialReviews(int id) {
    final cached = FitnesscenterRepository().getCachedReviews(id);
    if (cached != null) {
      return some(right(cached));
    }
    return none();
  }

  @override
  void emit(FitnessCenterDetailsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> fetch() async {
    await Future.wait([fetchFitnessCenterDetails(id), fetchFitnessCenterReviews(id)]);
  }

  Future<void> fetchFitnessCenterDetails(int id) async {
    final hasFullDetailsCached = FitnesscenterRepository().getCachedDetails(id) != null;

    if (state.fitnessCenterDetails.isNone()) {
      if (isClosed) return;
      emit(state.copyWith(fitnessCenterDetails: none()));
    }
    final response = await FitnesscenterRepository().fitnesscenterDetails(id: id);
    if (isClosed) return;
    response.fold(
      (l) {
        if (!hasFullDetailsCached) {
          if (isClosed) return;
          emit(state.copyWith(fitnessCenterDetails: some(left(l))));
        }
      },
      (r) {
        FitnesscenterRepository().cacheDetails(id, r);
        if (isClosed) return;
        emit(state.copyWith(fitnessCenterDetails: some(right(r))));
      },
    );
  }

  Future<void> fetchFitnessCenterReviews(int id) async {
    final hasReviewsCached = FitnesscenterRepository().getCachedReviews(id) != null;

    if (state.fitnessCenterReviews.isNone()) {
      if (isClosed) return;
      emit(state.copyWith(fitnessCenterReviews: none()));
    }
    final response = await ReviewsAndReatingRepository().fitnessCenterReviews(id: id, queryParameters: {});
    if (isClosed) return;
    response.fold(
      (l) {
        if (!hasReviewsCached) {
          if (isClosed) return;
          emit(state.copyWith(fitnessCenterReviews: some(left(l))));
        }
      },
      (r) {
        FitnesscenterRepository().cacheReviews(id, r);
        if (isClosed) return;
        emit(state.copyWith(fitnessCenterReviews: some(right(r))));
      },
    );
  }
}
