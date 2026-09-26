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

  static bool isCompleted(ChallengeModel c) {
    final status = c.status?.toLowerCase() ?? '';
    final footerType = c.footer?.type?.toLowerCase() ?? '';
    final action = c.button?.action?.toLowerCase() ?? '';
    return status == 'completed' ||
        status.contains('winner') ||
        status.contains('end') ||
        status.contains('distribut') ||
        footerType == 'winner' ||
        footerType == 'ended' ||
        footerType.contains('reward') ||
        footerType.contains('distribut') ||
        action == 'winners';
  }

  static bool isUpcoming(ChallengeModel c) {
    final status = c.status?.toLowerCase() ?? '';
    final footerType = c.footer?.type?.toLowerCase() ?? '';
    final footerTitle = c.footer?.title?.toLowerCase() ?? '';
    return status == 'upcoming' ||
        footerType == 'upcoming' ||
        footerTitle.contains('starts on');
  }

  static bool isOngoing(ChallengeModel c) {
    if (isCompleted(c) || isUpcoming(c)) return false;
    final status = c.status?.toLowerCase() ?? '';
    final footerType = c.footer?.type?.toLowerCase() ?? '';
    final secs = c.footer?.remainingSeconds ?? c.remainingSeconds ?? 0;
    return status == 'ongoing' ||
        status == 'active' ||
        footerType == 'countdown' ||
        secs > 0;
  }

  static bool isEndingSoon(ChallengeModel c) {
    if (!isOngoing(c)) return false;
    final status = c.status?.toLowerCase() ?? '';
    final secs = c.footer?.remainingSeconds ?? c.remainingSeconds ?? 0;
    return status == 'ending_soon' ||
        status.contains('ending') ||
        (secs > 0 && secs <= 24 * 3600);
  }

  static List<ChallengeModel> applyFilters(
    List<ChallengeModel> source, {
    required String status,
    required String? challengeType,
    required String searchQuery,
  }) {
    return source.where((c) {
      // 1. Challenge Type
      if (challengeType != null && challengeType.isNotEmpty) {
        final type = c.challengeType?.toLowerCase().trim() ?? '';
        final filter = challengeType.toLowerCase().trim();
        final bool typeMatches;
        switch (filter) {
          case 'lucky_draw':
            typeMatches = type.contains('lucky') ||
                type.contains('draw') ||
                type == 'lucky_draw';
          case 'performance':
            typeMatches = type.contains('performance');
          case 'community':
            typeMatches = type.contains('community');
          default:
            typeMatches = type == filter || type.contains(filter);
        }
        if (!typeMatches) return false;
      }

      // 2. Status
      if (status.isNotEmpty && status.toLowerCase() != 'all') {
        final s = status.toLowerCase().trim();
        final bool statusMatches;
        switch (s) {
          case 'ongoing':
            statusMatches = isOngoing(c);
          case 'ending_soon':
            statusMatches = isEndingSoon(c);
          case 'upcoming':
            statusMatches = isUpcoming(c);
          case 'completed':
            statusMatches = isCompleted(c);
          default:
            statusMatches = true;
        }
        if (!statusMatches) return false;
      }

      // 3. Search query
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final name = c.name?.toLowerCase() ?? '';
        final desc = c.shortDescription?.toLowerCase() ?? '';
        final brand = c.brand?.name?.toLowerCase() ?? '';
        if (!name.contains(q) && !desc.contains(q) && !brand.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> loadChallenges({bool showLoading = true}) async {
    if (isClosed) return;
    if (showLoading) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final response = await _repository.getChallenges(
        page: 1,
        pageSize: 4,
        status: state.selectedStatus,
        challengeType: state.selectedChallengeType,
        category: state.selectedCategory,
        search: state.searchQuery,
      );
      if (isClosed) return;

      final results = response.results ?? [];
      final bool hasMore = response.next != null && response.next!.isNotEmpty;

      if (isClosed) return;
      emit(state.copyWith(
        allChallenges: results,
        challenges: results,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      if (isClosed) return;
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
    if (isClosed || state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getChallenges(
        page: nextPage,
        pageSize: 4,
        status: state.selectedStatus,
        challengeType: state.selectedChallengeType,
        category: state.selectedCategory,
        search: state.searchQuery,
      );
      if (isClosed) return;

      final newResults = response.results ?? [];
      final bool hasMore = response.next != null && response.next!.isNotEmpty;

      final updatedAll = List<ChallengeModel>.from(state.allChallenges)
        ..addAll(newResults);

      if (isClosed) return;
      emit(state.copyWith(
        allChallenges: updatedAll,
        challenges: updatedAll,
        isLoadingMore: false,
        hasMore: hasMore,
        currentPage: nextPage,
      ));
    } catch (e) {
      debugPrint('Error loading more challenges: $e');
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void filterByStatus(String status) {
    // Toggle: if tapping already selected status, reset to 'all'
    final newStatus = (state.selectedStatus == status) ? 'all' : status;
    emit(state.copyWith(selectedStatus: newStatus));
    loadChallenges();
  }

  void filterByChallengeType(String? type) {
    if (state.selectedChallengeType == type) return;
    emit(state.copyWith(
      selectedChallengeType: type,
      clearChallengeType: type == null,
    ));
    loadChallenges();
  }

  void clearFilters() {
    emit(state.copyWith(
      selectedStatus: 'all',
      clearChallengeType: true,
      searchQuery: '',
    ));
    loadChallenges();
  }

  void filterByCategory(String? category) {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(selectedCategory: category));
    loadChallenges();
  }

  void searchChallenges(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      emit(state.copyWith(searchQuery: query));
      loadChallenges();
    });
  }

  Future<JoinChallengeResponse> joinChallenge(int challengeId) async {
    final response = await _repository.joinChallenge(challengeId);
    if (response.status) {
      refreshChallenges();
    }
    return response;
  }
}
