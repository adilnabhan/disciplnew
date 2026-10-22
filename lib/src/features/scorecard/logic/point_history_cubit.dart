import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/repositories/score_card_repository.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/point_history_state.dart';

class PointHistoryCubit extends Cubit<PointHistoryState> {
  PointHistoryCubit({ScoreCardRepository? repository})
      : _repository = repository ?? ScoreCardRepository(),
        super(const PointHistoryState());

  final ScoreCardRepository _repository;

  Future<void> fetchPointHistory({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!state.hasNextPage || state.status == PointHistoryStatus.loadingMore) {
        return;
      }
      emit(state.copyWith(status: PointHistoryStatus.loadingMore));
    } else if (refresh) {
      emit(state.copyWith(isRefreshing: true));
    } else {
      emit(state.copyWith(
        status: PointHistoryStatus.loading,
        currentPage: 1,
      ));
    }

    final pageToFetch = loadMore ? state.currentPage + 1 : 1;

    final result = await _repository.getPointHistory(
      page: pageToFetch,
      pageSize: 20,
    );

    result.fold(
      (error) {
        emit(state.copyWith(
          status: PointHistoryStatus.error,
          isRefreshing: false,
          errorMessage:
              error.msg ?? 'Unable to load Points History. Please try again.',
        ));
      },
      (data) {
        final newItems = data.results;
        final updatedList = loadMore
            ? [...state.allItems, ...newItems]
            : newItems;

        final hasNext = data.hasNext;

        emit(state.copyWith(
          status: PointHistoryStatus.loaded,
          isRefreshing: false,
          data: data,
          allItems: updatedList,
          currentPage: pageToFetch,
          hasNextPage: hasNext,
          errorMessage: null,
        ));
      },
    );
  }

  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }
}
