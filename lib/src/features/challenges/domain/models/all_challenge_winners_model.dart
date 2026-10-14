import 'package:flutter/foundation.dart';

@immutable
class AllChallengeWinnersResponse {
  final String? status;
  final int? challengeCount;
  final int? totalChallenges;
  final int? totalWinners;
  final int? totalParticipants;
  final int? totalParticipantsCount;
  final String? gymName;
  final String? gymLogo;
  final String? gymLocation;
  final List<ChallengeWinnerItem> winners;

  const AllChallengeWinnersResponse({
    this.status,
    this.challengeCount,
    this.totalChallenges,
    this.totalWinners,
    this.totalParticipants,
    this.totalParticipantsCount,
    this.gymName,
    this.gymLogo,
    this.gymLocation,
    this.winners = const [],
  });

  factory AllChallengeWinnersResponse.fromJson(Map<String, dynamic> json) {
    return AllChallengeWinnersResponse(
      status: json['status'] as String?,
      challengeCount: json['challenge_count'] as int? ?? json['total_challenges'] as int?,
      totalChallenges: json['total_challenges'] as int? ?? json['challenge_count'] as int?,
      totalWinners: json['total_winners'] as int?,
      totalParticipants: json['total_participants'] as int? ?? json['total_participants_count'] as int?,
      totalParticipantsCount: json['total_participants_count'] as int? ?? json['total_participants'] as int?,
      gymName: (json['gym_name'] ??
          json['fitness_center_name'] ??
          (json['gym'] is Map ? json['gym']['name'] ?? json['gym']['center_name'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['name'] ?? json['fitness_center']['center_name'] : null))?.toString(),
      gymLogo: (json['gym_logo'] ??
          json['fitness_center_logo'] ??
          (json['gym'] is Map ? json['gym']['logo'] ?? json['gym']['image'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['logo'] ?? json['fitness_center']['image'] : null))?.toString(),
      gymLocation: (json['gym_location'] ??
          json['gym_place'] ??
          json['gym_city'] ??
          json['fitness_center_location'] ??
          (json['gym'] is Map ? json['gym']['place'] ?? json['gym']['city'] ?? json['gym']['location'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['place'] ?? json['fitness_center']['city'] ?? json['fitness_center']['location'] : null))?.toString(),
      winners: (json['winners'] as List<dynamic>?)
              ?.map((e) => ChallengeWinnerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

@immutable
class ChallengeWinnerItem {
  final int? id;
  final int? challengeId;
  final String? challengeName;
  final int? userId;
  final String? userName;
  final String? profilePic;
  final String? date;
  final String? awardedAt;
  final String? selectionMethod;
  final String? selectionMethodDisplay;
  final String? prize;
  final String? prizeTitle;
  final int? rank;
  final bool? isPublished;
  final bool? isPrizeDistributed;
  final String? brandName;
  final String? brandLogo;
  final String? rewardImage;
  final String? gymName;
  final String? gymLogo;
  final String? gymLocation;

  const ChallengeWinnerItem({
    this.id,
    this.challengeId,
    this.challengeName,
    this.userId,
    this.userName,
    this.profilePic,
    this.date,
    this.awardedAt,
    this.selectionMethod,
    this.selectionMethodDisplay,
    this.prize,
    this.prizeTitle,
    this.rank,
    this.isPublished,
    this.isPrizeDistributed,
    this.brandName,
    this.brandLogo,
    this.rewardImage,
    this.gymName,
    this.gymLogo,
    this.gymLocation,
  });

  factory ChallengeWinnerItem.fromJson(Map<String, dynamic> json) {
    return ChallengeWinnerItem(
      id: json['id'] as int?,
      challengeId: json['challenge_id'] as int?,
      challengeName: json['challenge_name'] as String?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      profilePic: json['profile_pic'] as String?,
      date: json['date'] as String?,
      awardedAt: json['awarded_at'] as String?,
      selectionMethod: json['selection_method'] as String?,
      selectionMethodDisplay: json['selection_method_display'] as String?,
      prize: json['prize'] as String? ?? json['prize_title'] as String?,
      prizeTitle: json['prize_title'] as String? ?? json['prize'] as String?,
      rank: json['rank'] as int?,
      isPublished: json['is_published'] as bool?,
      isPrizeDistributed: json['is_prize_distributed'] as bool?,
      brandName: json['brand_name'] as String?,
      brandLogo: json['brand_logo'] as String?,
      rewardImage: json['reward_image'] as String?,
      gymName: (json['gym_name'] ??
          json['fitness_center_name'] ??
          json['center_name'] ??
          (json['gym'] is Map ? json['gym']['name'] ?? json['gym']['center_name'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['name'] ?? json['fitness_center']['center_name'] : null))?.toString(),
      gymLogo: (json['gym_logo'] ??
          json['fitness_center_logo'] ??
          json['center_logo'] ??
          (json['gym'] is Map ? json['gym']['logo'] ?? json['gym']['image'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['logo'] ?? json['fitness_center']['image'] : null))?.toString(),
      gymLocation: (json['gym_location'] ??
          json['gym_place'] ??
          json['gym_city'] ??
          json['fitness_center_location'] ??
          (json['gym'] is Map ? json['gym']['place'] ?? json['gym']['city'] ?? json['gym']['location'] : null) ??
          (json['fitness_center'] is Map ? json['fitness_center']['place'] ?? json['fitness_center']['city'] ?? json['fitness_center']['location'] : null))?.toString(),
    );
  }
}
