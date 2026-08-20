import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';

enum ScoreCardStatus { initial, loading, loaded, loadingMore, error }

class ScoreCardState {
  final ScoreCardStatus status;
  final ScoreCardResponseModel? data;
  final String timeframe;
  final int currentPage;
  final bool hasNextPage;
  final bool isRefreshing;
  final String? errorMessage;
  final List<LeaderboardMemberModel> allLeaderboardMembers;

  const ScoreCardState({
    this.status = ScoreCardStatus.initial,
    this.data,
    this.timeframe = 'monthly',
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.allLeaderboardMembers = const [],
  });

  ScoreCardState copyWith({
    ScoreCardStatus? status,
    ScoreCardResponseModel? data,
    String? timeframe,
    int? currentPage,
    bool? hasNextPage,
    bool? isRefreshing,
    String? errorMessage,
    List<LeaderboardMemberModel>? allLeaderboardMembers,
  }) {
    return ScoreCardState(
      status: status ?? this.status,
      data: data ?? this.data,
      timeframe: timeframe ?? this.timeframe,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      allLeaderboardMembers: allLeaderboardMembers ?? this.allLeaderboardMembers,
    );
  }
}
