import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class GymScoreCardModel {
  final int? id;
  final String? name;
  final String? logo;
  final String? place;
  final String? location;

  const GymScoreCardModel({
    this.id,
    this.name,
    this.logo,
    this.place,
    this.location,
  });

  factory GymScoreCardModel.fromJson(Map<String, dynamic> json) {
    String? loc;
    if (json['location'] != null) {
      if (json['location'] is String) {
        loc = json['location'] as String;
      } else if (json['location'] is Map<String, dynamic>) {
        final locMap = json['location'] as Map<String, dynamic>;
        final city = locMap['city'] ?? locMap['place'] ?? locMap['area'] ?? locMap['address'] ?? locMap['name'];
        final state = locMap['state'];
        loc = [city, state].where((e) => e != null && e.toString().isNotEmpty).join(', ');
      }
    }
    loc ??= json['address']?.toString() ??
        json['city']?.toString() ??
        json['place']?.toString() ??
        json['area']?.toString() ??
        json['gym_location']?.toString() ??
        json['fitness_center_location']?.toString();

    return GymScoreCardModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? json['center_name'] as String? ?? json['title'] as String?,
      logo: json['logo'] as String? ?? json['image'] as String? ?? json['photo'] as String?,
      place: json['place'] as String?,
      location: loc ?? json['place'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'place': place,
        'location': location,
      };
}

@immutable
class ScoreCardPeriodModel {
  final String? type;
  final String? startDate;
  final String? endDate;

  const ScoreCardPeriodModel({
    this.type,
    this.startDate,
    this.endDate,
  });

  factory ScoreCardPeriodModel.fromJson(Map<String, dynamic> json) {
    return ScoreCardPeriodModel(
      type: json['type'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
      };

  String get formattedRange {
    if (startDate == null || endDate == null) return '';
    try {
      final start = DateTime.parse(startDate!);
      final end = DateTime.parse(endDate!);
      final startFmt = DateFormat('dd MMM').format(start);
      final endFmt = DateFormat('dd MMM yyyy').format(end);
      return '$startFmt - $endFmt';
    } catch (_) {
      return '$startDate - $endDate';
    }
  }
}

@immutable
class ScoreCardUserModel {
  final int? userId;
  final int? customerId;
  final String? name;
  final String? profileImage;
  final int? rank;
  final int? points;
  final int? streak;
  final int? previousRank;
  final int? rankChange;
  final String? rankChangeType;

  const ScoreCardUserModel({
    this.userId,
    this.customerId,
    this.name,
    this.profileImage,
    this.rank,
    this.points,
    this.streak,
    this.previousRank,
    this.rankChange,
    this.rankChangeType,
  });

  factory ScoreCardUserModel.fromJson(Map<String, dynamic> json) {
    return ScoreCardUserModel(
      userId: json['user_id'] as int?,
      customerId: json['customer_id'] as int?,
      name: json['name'] as String?,
      profileImage: json['profile_image'] as String?,
      rank: json['rank'] as int?,
      points: json['points'] as int?,
      streak: json['streak'] as int?,
      previousRank: json['previous_rank'] as int?,
      rankChange: json['rank_change'] as int?,
      rankChangeType: json['rank_change_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'customer_id': customerId,
        'name': name,
        'profile_image': profileImage,
        'rank': rank,
        'points': points,
        'streak': streak,
        'previous_rank': previousRank,
        'rank_change': rankChange,
        'rank_change_type': rankChangeType,
      };
}

@immutable
class UserRankTier {
  final String name;
  final String emoji;
  final int minScore;
  final int maxScore;

  const UserRankTier({
    required this.name,
    required this.emoji,
    required this.minScore,
    required this.maxScore,
  });

  static const List<UserRankTier> tiers = [
    UserRankTier(name: 'Recruit', emoji: '🟢', minScore: 0, maxScore: 499),
    UserRankTier(name: 'Warrior', emoji: '⚔️', minScore: 500, maxScore: 1499),
    UserRankTier(name: 'Gladiator', emoji: '🛡️', minScore: 1500, maxScore: 2999),
    UserRankTier(name: 'Spartan', emoji: '🏛️', minScore: 3000, maxScore: 4999),
    UserRankTier(name: 'Titan', emoji: '🔥', minScore: 5000, maxScore: 7499),
    UserRankTier(name: 'Conqueror', emoji: '👑', minScore: 7500, maxScore: 9999),
    UserRankTier(name: 'Legend', emoji: '⭐', minScore: 10000, maxScore: 14999),
    UserRankTier(name: 'Champion', emoji: '💎', minScore: 15000, maxScore: 19999),
    UserRankTier(name: 'Elite', emoji: '🏆', minScore: 20000, maxScore: 29999),
    UserRankTier(name: 'Mythic', emoji: '👑', minScore: 30000, maxScore: 99999999),
  ];

  static UserRankTier getTierForScore(int score) {
    if (score < 0) score = 0;
    for (final tier in tiers.reversed) {
      if (score >= tier.minScore) {
        return tier;
      }
    }
    return tiers.first;
  }

  static UserRankTier? getNextTier(UserRankTier current) {
    final idx = tiers.indexOf(current);
    if (idx >= 0 && idx < tiers.length - 1) {
      return tiers[idx + 1];
    }
    return null;
  }

  static double calculateProgress(int currentScore, UserRankTier current, UserRankTier? next) {
    if (next == null) return 100.0;
    final int min = current.minScore;
    final int nextMin = next.minScore;
    if (nextMin <= min) return 100.0;
    final progress = ((currentScore - min) / (nextMin - min)) * 100.0;
    return progress.clamp(0.0, 100.0);
  }
}

@immutable
class CategoryBreakdownModel {
  final int attendance;
  final int consistency;
  final int workout;
  final int verification;
  final int steps;
  final int inspiration;
  final int challenge;
  final int penalties;

  const CategoryBreakdownModel({
    this.attendance = 0,
    this.consistency = 0,
    this.workout = 0,
    this.verification = 0,
    this.steps = 0,
    this.inspiration = 0,
    this.challenge = 0,
    this.penalties = 0,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      attendance: json['attendance'] as int? ?? 0,
      consistency: json['consistency'] as int? ?? 0,
      workout: json['workout'] as int? ?? 0,
      verification: json['verification'] as int? ?? 0,
      steps: json['steps'] as int? ?? 0,
      inspiration: json['inspiration'] as int? ?? 0,
      challenge: json['challenge'] as int? ?? 0,
      penalties: json['penalties'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'attendance': attendance,
        'consistency': consistency,
        'workout': workout,
        'verification': verification,
        'steps': steps,
        'inspiration': inspiration,
        'challenge': challenge,
        'penalties': penalties,
      };

  int get totalEarned =>
      attendance + consistency + workout + verification + steps + inspiration + challenge;
}

@immutable
class ScoreTransactionModel {
  final int? id;
  final String? category;
  final int? points;
  final String? description;
  final String? date;

  const ScoreTransactionModel({
    this.id,
    this.category,
    this.points,
    this.description,
    this.date,
  });

  factory ScoreTransactionModel.fromJson(Map<String, dynamic> json) {
    return ScoreTransactionModel(
      id: json['id'] as int?,
      category: json['category'] as String?,
      points: json['points'] as int?,
      description: json['description'] as String?,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'points': points,
        'description': description,
        'date': date,
      };
}

@immutable
class MyPositionModel {
  final int? rank;
  final int? currentRank;
  final int? previousRank;
  final int? rankChange;
  final String? rankChangeType;
  final int? points;
  final int? currentPoints;
  final int? previousPoints;
  final int? pointsChange;
  final String? pointsChangeType;
  final int? streak;
  final int? totalMembers;
  final String? currentRankName;
  final String? rankEmoji;
  final String? nextRank;
  final String? nextRankEmoji;
  final int? nextRankScore;
  final int? remainingScoreToNextRank;
  final double? progressPercentage;
  final int? restDaysCount;
  final int? totalEarnedScore;
  final int? totalPenaltyScore;
  final CategoryBreakdownModel? categoryBreakdown;
  final List<ScoreTransactionModel> recentTransactions;

  const MyPositionModel({
    this.rank,
    this.currentRank,
    this.previousRank,
    this.rankChange,
    this.rankChangeType,
    this.points,
    this.currentPoints,
    this.previousPoints,
    this.pointsChange,
    this.pointsChangeType,
    this.streak,
    this.totalMembers,
    this.currentRankName,
    this.rankEmoji,
    this.nextRank,
    this.nextRankEmoji,
    this.nextRankScore,
    this.remainingScoreToNextRank,
    this.progressPercentage,
    this.restDaysCount,
    this.totalEarnedScore,
    this.totalPenaltyScore,
    this.categoryBreakdown,
    this.recentTransactions = const [],
  });

  factory MyPositionModel.fromJson(Map<String, dynamic> json) {
    return MyPositionModel(
      rank: json['rank'] as int? ?? json['current_rank'] as int?,
      currentRank: json['current_rank'] as int? ?? json['rank'] as int?,
      previousRank: json['previous_rank'] as int?,
      rankChange: json['rank_change'] as int?,
      rankChangeType: json['rank_change_type'] as String?,
      points: json['points'] as int? ?? json['current_points'] as int? ?? json['current_score'] as int?,
      currentPoints: json['current_points'] as int? ?? json['points'] as int? ?? json['current_score'] as int?,
      previousPoints: json['previous_points'] as int?,
      pointsChange: json['points_change'] as int?,
      pointsChangeType: json['points_change_type'] as String?,
      streak: json['streak'] as int? ?? json['streak_days'] as int?,
      totalMembers: json['total_members'] as int?,
      currentRankName: json['current_rank'] is String ? json['current_rank'] as String : json['rank_name'] as String?,
      rankEmoji: json['rank_emoji'] as String?,
      nextRank: json['next_rank'] as String?,
      nextRankEmoji: json['next_rank_emoji'] as String?,
      nextRankScore: json['next_rank_score'] as int?,
      remainingScoreToNextRank: json['remaining_score_to_next_rank'] as int?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
      restDaysCount: json['rest_days_count'] as int?,
      totalEarnedScore: json['total_earned_score'] as int?,
      totalPenaltyScore: json['total_penalty_score'] as int?,
      categoryBreakdown: json['category_breakdown'] != null
          ? CategoryBreakdownModel.fromJson(json['category_breakdown'] as Map<String, dynamic>)
          : null,
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => ScoreTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'current_rank': currentRank,
        'previous_rank': previousRank,
        'rank_change': rankChange,
        'rank_change_type': rankChangeType,
        'points': points,
        'current_points': currentPoints,
        'previous_points': previousPoints,
        'points_change': pointsChange,
        'points_change_type': pointsChangeType,
        'streak': streak,
        'total_members': totalMembers,
        'current_rank_name': currentRankName,
        'rank_emoji': rankEmoji,
        'next_rank': nextRank,
        'next_rank_emoji': nextRankEmoji,
        'next_rank_score': nextRankScore,
        'remaining_score_to_next_rank': remainingScoreToNextRank,
        'progress_percentage': progressPercentage,
        'rest_days_count': restDaysCount,
        'total_earned_score': totalEarnedScore,
        'total_penalty_score': totalPenaltyScore,
        'category_breakdown': categoryBreakdown?.toJson(),
        'recent_transactions': recentTransactions.map((e) => e.toJson()).toList(),
      };
}

@immutable
class PodiumMemberModel {
  final int? rank;
  final int? userId;
  final int? customerId;
  final String? name;
  final String? profileImage;
  final int? points;
  final int? currentPoints;
  final int? previousPoints;
  final int? pointsChange;
  final String? pointsChangeType;
  final int? streak;
  final int? previousRank;
  final int? rankChange;
  final String? rankChangeType;
  final bool isCurrentUser;

  const PodiumMemberModel({
    this.rank,
    this.userId,
    this.customerId,
    this.name,
    this.profileImage,
    this.points,
    this.currentPoints,
    this.previousPoints,
    this.pointsChange,
    this.pointsChangeType,
    this.streak,
    this.previousRank,
    this.rankChange,
    this.rankChangeType,
    this.isCurrentUser = false,
  });

  factory PodiumMemberModel.fromJson(Map<String, dynamic> json) {
    return PodiumMemberModel(
      rank: json['rank'] as int?,
      userId: json['user_id'] as int?,
      customerId: json['customer_id'] as int?,
      name: json['name'] as String?,
      profileImage: json['profile_image'] as String?,
      points: json['points'] as int? ?? json['current_points'] as int?,
      currentPoints: json['current_points'] as int? ?? json['points'] as int?,
      previousPoints: json['previous_points'] as int?,
      pointsChange: json['points_change'] as int?,
      pointsChangeType: json['points_change_type'] as String?,
      streak: json['streak'] as int?,
      previousRank: json['previous_rank'] as int?,
      rankChange: json['rank_change'] as int?,
      rankChangeType: json['rank_change_type'] as String?,
      isCurrentUser: json['is_current_user'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'user_id': userId,
        'customer_id': customerId,
        'name': name,
        'profile_image': profileImage,
        'points': points,
        'current_points': currentPoints,
        'previous_points': previousPoints,
        'points_change': pointsChange,
        'points_change_type': pointsChangeType,
        'streak': streak,
        'previous_rank': previousRank,
        'rank_change': rankChange,
        'rank_change_type': rankChangeType,
        'is_current_user': isCurrentUser,
      };
}

@immutable
class LeaderboardMemberModel {
  final int? rank;
  final int? userId;
  final int? customerId;
  final String? name;
  final String? profileImage;
  final int? points;
  final int? currentPoints;
  final int? previousPoints;
  final int? pointsChange;
  final String? pointsChangeType;
  final int? streak;
  final int? previousRank;
  final int? rankChange;
  final String? rankChangeType;
  final bool isCurrentUser;

  const LeaderboardMemberModel({
    this.rank,
    this.userId,
    this.customerId,
    this.name,
    this.profileImage,
    this.points,
    this.currentPoints,
    this.previousPoints,
    this.pointsChange,
    this.pointsChangeType,
    this.streak,
    this.previousRank,
    this.rankChange,
    this.rankChangeType,
    this.isCurrentUser = false,
  });

  factory LeaderboardMemberModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardMemberModel(
      rank: json['rank'] as int?,
      userId: json['user_id'] as int?,
      customerId: json['customer_id'] as int?,
      name: json['name'] as String?,
      profileImage: json['profile_image'] as String?,
      points: json['points'] as int? ?? json['current_points'] as int?,
      currentPoints: json['current_points'] as int? ?? json['points'] as int?,
      previousPoints: json['previous_points'] as int?,
      pointsChange: json['points_change'] as int?,
      pointsChangeType: json['points_change_type'] as String?,
      streak: json['streak'] as int?,
      previousRank: json['previous_rank'] as int?,
      rankChange: json['rank_change'] as int?,
      rankChangeType: json['rank_change_type'] as String?,
      isCurrentUser: json['is_current_user'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'user_id': userId,
        'customer_id': customerId,
        'name': name,
        'profile_image': profileImage,
        'points': points,
        'current_points': currentPoints,
        'previous_points': previousPoints,
        'points_change': pointsChange,
        'points_change_type': pointsChangeType,
        'streak': streak,
        'previous_rank': previousRank,
        'rank_change': rankChange,
        'rank_change_type': rankChangeType,
        'is_current_user': isCurrentUser,
      };
}

@immutable
class ScoreCardPaginationModel {
  final int page;
  final int pageSize;
  final int totalMembers;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const ScoreCardPaginationModel({
    this.page = 1,
    this.pageSize = 20,
    this.totalMembers = 0,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory ScoreCardPaginationModel.fromJson(Map<String, dynamic> json) {
    return ScoreCardPaginationModel(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalMembers: json['total_members'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'page_size': pageSize,
        'total_members': totalMembers,
        'total_pages': totalPages,
        'has_next': hasNext,
        'has_previous': hasPrevious,
      };
}

@immutable
class ScoreCardResponseModel {
  final bool hasActiveGym;
  final GymScoreCardModel? gym;
  final ScoreCardPeriodModel? period;
  final ScoreCardUserModel? me;
  final MyPositionModel? myPosition;
  final List<PodiumMemberModel> podium;
  final List<LeaderboardMemberModel> leaderboard;
  final int totalMembers;
  final ScoreCardPaginationModel? pagination;
  final String? currentRank;
  final String? rankEmoji;
  final String? nextRank;
  final String? nextRankEmoji;
  final int? nextRankScore;
  final int? remainingScoreToNextRank;
  final double? progressPercentage;
  final int? streakDays;
  final int? restDaysCount;
  final int? totalEarnedScore;
  final int? totalPenaltyScore;
  final CategoryBreakdownModel? categoryBreakdown;
  final List<ScoreTransactionModel> recentTransactions;

  const ScoreCardResponseModel({
    required this.hasActiveGym,
    this.gym,
    this.period,
    this.me,
    this.myPosition,
    this.podium = const [],
    this.leaderboard = const [],
    this.totalMembers = 0,
    this.pagination,
    this.currentRank,
    this.rankEmoji,
    this.nextRank,
    this.nextRankEmoji,
    this.nextRankScore,
    this.remainingScoreToNextRank,
    this.progressPercentage,
    this.streakDays,
    this.restDaysCount,
    this.totalEarnedScore,
    this.totalPenaltyScore,
    this.categoryBreakdown,
    this.recentTransactions = const [],
  });

  factory ScoreCardResponseModel.fromJson(Map<String, dynamic> json) {
    final catBreakdown = json['category_breakdown'] != null
        ? CategoryBreakdownModel.fromJson(json['category_breakdown'] as Map<String, dynamic>)
        : null;
    final transactions = (json['recent_transactions'] as List<dynamic>?)
            ?.map((e) => ScoreTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    MyPositionModel? pos;
    if (json['my_position'] != null) {
      pos = MyPositionModel.fromJson(json['my_position'] as Map<String, dynamic>);
    } else if (json['current_score'] != null ||
        json['current_rank'] != null ||
        json['customer_id'] != null) {
      pos = MyPositionModel(
        points: json['current_score'] as int?,
        streak: json['streak_days'] as int?,
        currentRankName: json['current_rank'] as String?,
        rankEmoji: json['rank_emoji'] as String?,
        nextRank: json['next_rank'] as String?,
        nextRankEmoji: json['next_rank_emoji'] as String?,
        nextRankScore: json['next_rank_score'] as int?,
        remainingScoreToNextRank: json['remaining_score_to_next_rank'] as int?,
        progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
        restDaysCount: json['rest_days_count'] as int?,
        totalEarnedScore: json['total_earned_score'] as int?,
        totalPenaltyScore: json['total_penalty_score'] as int?,
        categoryBreakdown: catBreakdown,
        recentTransactions: transactions,
      );
    }

    return ScoreCardResponseModel(
      hasActiveGym: json['has_active_gym'] as bool? ?? false,
      gym: json['gym'] != null ? GymScoreCardModel.fromJson(json['gym'] as Map<String, dynamic>) : null,
      period: json['period'] != null ? ScoreCardPeriodModel.fromJson(json['period'] as Map<String, dynamic>) : null,
      me: json['me'] != null ? ScoreCardUserModel.fromJson(json['me'] as Map<String, dynamic>) : null,
      myPosition: pos,
      podium: (json['podium'] as List<dynamic>?)
              ?.map((e) => PodiumMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => LeaderboardMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalMembers: json['total_members'] as int? ?? 0,
      pagination: json['pagination'] != null
          ? ScoreCardPaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      currentRank: json['current_rank'] as String?,
      rankEmoji: json['rank_emoji'] as String?,
      nextRank: json['next_rank'] as String?,
      nextRankEmoji: json['next_rank_emoji'] as String?,
      nextRankScore: json['next_rank_score'] as int?,
      remainingScoreToNextRank: json['remaining_score_to_next_rank'] as int?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
      streakDays: json['streak_days'] as int?,
      restDaysCount: json['rest_days_count'] as int?,
      totalEarnedScore: json['total_earned_score'] as int?,
      totalPenaltyScore: json['total_penalty_score'] as int?,
      categoryBreakdown: catBreakdown,
      recentTransactions: transactions,
    );
  }

  Map<String, dynamic> toJson() => {
        'has_active_gym': hasActiveGym,
        'gym': gym?.toJson(),
        'period': period?.toJson(),
        'me': me?.toJson(),
        'my_position': myPosition?.toJson(),
        'podium': podium.map((e) => e.toJson()).toList(),
        'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
        'total_members': totalMembers,
        'pagination': pagination?.toJson(),
        'current_rank': currentRank,
        'rank_emoji': rankEmoji,
        'next_rank': nextRank,
        'next_rank_emoji': nextRankEmoji,
        'next_rank_score': nextRankScore,
        'remaining_score_to_next_rank': remainingScoreToNextRank,
        'progress_percentage': progressPercentage,
        'streak_days': streakDays,
        'rest_days_count': restDaysCount,
        'total_earned_score': totalEarnedScore,
        'total_penalty_score': totalPenaltyScore,
        'category_breakdown': categoryBreakdown?.toJson(),
        'recent_transactions': recentTransactions.map((e) => e.toJson()).toList(),
      };
}
