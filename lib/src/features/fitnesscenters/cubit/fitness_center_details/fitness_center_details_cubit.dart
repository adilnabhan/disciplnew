import 'package:customer_mobile_app/imports_bindings.dart';

part 'fitness_center_details_state.dart';
part 'fitness_center_details_cubit.freezed.dart';

class FitnessCenterDetailsCubit extends Cubit<FitnessCenterDetailsState> {
  FitnessCenterDetailsCubit({required this.id}) : super(const FitnessCenterDetailsState());

  final int id;

  Future<void> fetch() async {
    await Future.wait([fetchFitnessCenterDetails(id), fetchFitnessCenterReviews(id)]);
  }

  Future<void> fetchFitnessCenterDetails(int id) async {
    emit(state.copyWith(fitnessCenterDetails: none()));
    final response = await FitnesscenterRepository().fitnesscenterDetails(id: id);
    response.fold((l) => emit(state.copyWith(fitnessCenterDetails: some(left(l)))), (r) => emit(state.copyWith(fitnessCenterDetails: some(right(r)))));
  }

  Future<void> fetchFitnessCenterReviews(int id) async {
    emit(state.copyWith(fitnessCenterReviews: none()));
    final response = await ReviewsAndReatingRepository().fitnessCenterReviews(id: id, queryParameters: {});
    response.fold((l) => emit(state.copyWith(fitnessCenterReviews: some(left(l)))), (r) => emit(state.copyWith(fitnessCenterReviews: some(right(r)))));
  }
}
