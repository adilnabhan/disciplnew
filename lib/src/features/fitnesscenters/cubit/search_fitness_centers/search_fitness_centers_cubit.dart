import 'package:customer_mobile_app/imports_bindings.dart';

part 'search_fitness_centers_state.dart';
part 'search_fitness_centers_cubit.freezed.dart';

class SearchFitnessCentersCubit extends Cubit<SearchFitnessCentersState> {
  SearchFitnessCentersCubit() : super(const SearchFitnessCentersState());

  Future<void> fetchFitnessCenters(String searchQuery) async {
    emit(state.copyWith(fitnessCenters: none()));
    final response = await FitnesscenterRepository().listFitnesscenter(queryParameters: {'search': searchQuery});
    emit(state.copyWith(fitnessCenters: some(response)));
  }
}
