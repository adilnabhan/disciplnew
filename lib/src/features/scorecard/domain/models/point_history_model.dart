import 'package:flutter/foundation.dart';

@immutable
class PointHistoryResponseModel {
  final bool success;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final String? next;
  final String? previous;
  final PointHistorySummaryModel? summary;
  final List<PointHistoryItemModel> results;

  const PointHistoryResponseModel({
    this.success = true,
    this.count = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 20,
    this.next,
    this.previous,
    this.summary,
    this.results = const [],
  });

  bool get hasNext => next != null && next!.isNotEmpty;

  factory PointHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryResponseModel(
      success: json['success'] as bool? ?? true,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? PointHistorySummaryModel.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : null,
      results: (json['results'] as List<dynamic>?)
              ?.map(
                (e) => PointHistoryItemModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }
}

@immutable
class PointHistorySummaryModel {
  final int currentScore;
  final int totalEarned;
  final int totalDeducted;
  final int netPoints;
  final int streakDays;
  final String currentRank;
  final String rankEmoji;

  const PointHistorySummaryModel({
    this.currentScore = 0,
    this.totalEarned = 0,
    this.totalDeducted = 0,
    this.netPoints = 0,
    this.streakDays = 0,
    this.currentRank = 'Warrior',
    this.rankEmoji = '⚔️',
  });

  factory PointHistorySummaryModel.fromJson(Map<String, dynamic> json) {
    return PointHistorySummaryModel(
      currentScore: (json['current_score'] as num?)?.toInt() ?? 0,
      totalEarned: (json['total_earned'] as num?)?.toInt() ?? 0,
      totalDeducted: (json['total_deducted'] as num?)?.toInt() ?? 0,
      netPoints: (json['net_points'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      currentRank: json['current_rank'] as String? ?? 'Warrior',
      rankEmoji: json['rank_emoji'] as String? ?? '⚔️',
    );
  }
}

@immutable
class PointHistoryItemModel {
  final int id;
  final int points;
  final String formattedPoints;
  final String change;
  final String type;
  final String action;
  final bool isIncrease;
  final bool isDecrease;
  final String category;
  final String categoryName;
  final String categorySlug;
  final String description;
  final String? referenceId;
  final String date;
  final String createdAt;
  final String createdAtFormatted;

  const PointHistoryItemModel({
    this.id = 0,
    this.points = 0,
    this.formattedPoints = '',
    this.change = '',
    this.type = 'increase',
    this.action = 'earned',
    this.isIncrease = true,
    this.isDecrease = false,
    this.category = '',
    this.categoryName = '',
    this.categorySlug = '',
    this.description = '',
    this.referenceId,
    this.date = '',
    this.createdAt = '',
    this.createdAtFormatted = '',
  });

  factory PointHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as num?)?.toInt() ?? 0;
    final isInc = json['is_increase'] as bool? ?? (rawPoints >= 0);
    final isDec = json['is_decrease'] as bool? ?? (rawPoints < 0);

    return PointHistoryItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      points: rawPoints,
      formattedPoints: json['formatted_points'] as String? ??
          (rawPoints >= 0 ? '+$rawPoints' : '$rawPoints'),
      change: json['change'] as String? ??
          (rawPoints >= 0 ? '+$rawPoints' : '$rawPoints'),
      type: json['type'] as String? ?? (rawPoints >= 0 ? 'increase' : 'decrease'),
      action: json['action'] as String? ?? (rawPoints >= 0 ? 'earned' : 'deducted'),
      isIncrease: isInc,
      isDecrease: isDec,
      category: json['category'] as String? ?? '',
      categoryName: json['category_name'] as String? ??
          (json['category'] as String? ?? ''),
      categorySlug: json['category_slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      date: json['date'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      createdAtFormatted: json['created_at_formatted'] as String? ?? '',
    );
  }
}
