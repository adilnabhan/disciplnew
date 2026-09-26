import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/repositories/score_card_repository.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_state.dart';

class ScoreCardCubit extends Cubit<ScoreCardState> {
  ScoreCardCubit({ScoreCardRepository? repository})
      : _repository = repository ?? ScoreCardRepository(),
        super(const ScoreCardState());

  final ScoreCardRepository _repository;

  Future<void> fetchScoreCard({
    String? timeframe,
    bool refresh = false,
    bool loadMore = false,
  }) async {
    final selectedTimeframe = timeframe ?? state.timeframe;

    if (loadMore) {
      if (!state.hasNextPage || state.status == ScoreCardStatus.loadingMore) {
        return;
      }
      emit(state.copyWith(status: ScoreCardStatus.loadingMore));
    } else if (refresh) {
      emit(state.copyWith(isRefreshing: true, timeframe: selectedTimeframe));
    } else {
      emit(state.copyWith(
        status: ScoreCardStatus.loading,
        timeframe: selectedTimeframe,
        currentPage: 1,
      ));
    }

    final pageToFetch = loadMore ? state.currentPage + 1 : 1;

    final result = await _repository.getScoreCard(
      timeframe: selectedTimeframe,
      page: pageToFetch,
      pageSize: 10,
    );

    result.fold(
      (error) {
        emit(state.copyWith(
          status: ScoreCardStatus.error,
          isRefreshing: false,
          errorMessage: error.msg ?? 'Unable to load Score Card. Please try again.',
        ));
      },
      (data) {
        final newLeaderboard = data.leaderboard;
        final updatedList = loadMore
            ? [...state.allLeaderboardMembers, ...newLeaderboard]
            : newLeaderboard;

        final hasNext = data.pagination?.hasNext ?? false;

        emit(state.copyWith(
          status: ScoreCardStatus.loaded,
          data: data,
          timeframe: selectedTimeframe,
          currentPage: pageToFetch,
          hasNextPage: hasNext,
          isRefreshing: false,
          allLeaderboardMembers: updatedList,
        ));
      },
    );
  }

  void changeTimeframe(String newTimeframe) {
    if (state.timeframe == newTimeframe && state.status == ScoreCardStatus.loaded) {
      return;
    }
    fetchScoreCard(timeframe: newTimeframe, refresh: false);
  }
}
