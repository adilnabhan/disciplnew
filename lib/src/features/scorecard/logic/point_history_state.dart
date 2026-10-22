import 'package:customer_mobile_app/src/features/scorecard/domain/models/point_history_model.dart';

enum PointHistoryStatus { initial, loading, loaded, loadingMore, error }

class PointHistoryState {
  final PointHistoryStatus status;
  final PointHistoryResponseModel? data;
  final List<PointHistoryItemModel> allItems;
  final int currentPage;
  final bool hasNextPage;
  final bool isRefreshing;
  final String? errorMessage;
  final String selectedFilter; // 'all', 'increase', 'decrease'

  const PointHistoryState({
    this.status = PointHistoryStatus.initial,
    this.data,
    this.allItems = const [],
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.selectedFilter = 'all',
  });

  PointHistoryState copyWith({
    PointHistoryStatus? status,
    PointHistoryResponseModel? data,
    List<PointHistoryItemModel>? allItems,
    int? currentPage,
    bool? hasNextPage,
    bool? isRefreshing,
    String? errorMessage,
    String? selectedFilter,
  }) {
    return PointHistoryState(
      status: status ?? this.status,
      data: data ?? this.data,
      allItems: allItems ?? this.allItems,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<PointHistoryItemModel> get filteredItems {
    if (selectedFilter == 'increase') {
      return allItems.where((item) => item.isIncrease).toList();
    } else if (selectedFilter == 'decrease') {
      return allItems.where((item) => item.isDecrease).toList();
    }
    return allItems;
  }
}
