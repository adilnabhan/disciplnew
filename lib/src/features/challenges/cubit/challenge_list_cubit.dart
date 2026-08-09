import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';

class ChallengeListCubit extends Cubit<ChallengeListState> {
  ChallengeListCubit() : super(const ChallengeListState());

  final ChallengeRepository _repository = ChallengeRepository();
  Timer? _debounceTimer;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> loadChallenges({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final response = await _repository.getChallenges(
        page: 1,
        pageSize: 10,
        status: state.selectedStatus,
        challengeType: state.selectedChallengeType,
        category: state.selectedCategory,
        search: state.searchQuery,
      );

      final results = response.results ?? [];
      final bool hasMore = response.next != null && response.next!.isNotEmpty;

      emit(state.copyWith(
        challenges: results,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refreshChallenges() async {
    await loadChallenges(showLoading: false);
  }

  Future<void> loadMoreChallenges() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getChallenges(
        page: nextPage,
        pageSize: 10,
        status: state.selectedStatus,
        challengeType: state.selectedChallengeType,
        category: state.selectedCategory,
        search: state.searchQuery,
      );

      final newResults = response.results ?? [];
      final bool hasMore = response.next != null && response.next!.isNotEmpty;

      final updatedList = List<ChallengeModel>.from(state.challenges)
        ..addAll(newResults);

      emit(state.copyWith(
        challenges: updatedList,
        isLoadingMore: false,
        hasMore: hasMore,
        currentPage: nextPage,
      ));
    } catch (e) {
      debugPrint('Error loading more challenges: $e');
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void filterByStatus(String status) {
    if (state.selectedStatus == status) return;
    emit(state.copyWith(selectedStatus: status));
    loadChallenges();
  }

  void filterByChallengeType(String? type) {
    if (state.selectedChallengeType == type) return;
    emit(state.copyWith(selectedChallengeType: type));
    loadChallenges();
  }

  void filterByCategory(String? category) {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(selectedCategory: category));
    loadChallenges();
  }

  void searchChallenges(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      emit(state.copyWith(searchQuery: query));
      loadChallenges();
    });
  }

  Future<JoinChallengeResponse> joinChallenge(int challengeId) async {
    final response = await _repository.joinChallenge(challengeId);
    if (response.status) {
      // Refresh list to update button state & member count
      refreshChallenges();
    }
    return response;
  }
}
