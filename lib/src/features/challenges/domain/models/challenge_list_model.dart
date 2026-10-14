import 'package:flutter/foundation.dart';

@immutable
class ChallengeBrand {
  final int? id;
  final String? name;
  final String? logo;

  const ChallengeBrand({this.id, this.name, this.logo});

  factory ChallengeBrand.fromJson(Map<String, dynamic> json) {
    return ChallengeBrand(
      id: json['id'] as int?,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'logo': logo};
  }
}

@immutable
class ChallengePartner {
  final int id;
  final String name;
  final String? logo;

  const ChallengePartner({
    required this.id,
    required this.name,
    this.logo,
  });

  factory ChallengePartner.fromJson(Map<String, dynamic> json) {
    return ChallengePartner(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? json['brand_name'] ?? '') as String,
      logo: (json['logo'] ?? json['brand_logo']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'logo': logo};
  }
}

@immutable
class ChallengeJoinedMember {
  final int? id;
  final String? profileImage;

  const ChallengeJoinedMember({this.id, this.profileImage});

  factory ChallengeJoinedMember.fromJson(Map<String, dynamic> json) {
    return ChallengeJoinedMember(
      id: json['id'] as int?,
      profileImage: (json['profile_image'] ?? json['image']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'profile_image': profileImage};
  }
}

@immutable
class ChallengeProgress {
  final String? title;
  final int? current;
  final int? target;
  final num? percentage;

  const ChallengeProgress({
    this.title,
    this.current,
    this.target,
    this.percentage,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      title: json['title'] as String?,
      current: json['current'] as int?,
      target: json['target'] as int?,
      percentage: json['percentage'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'current': current,
      'target': target,
      'percentage': percentage,
    };
  }
}

@immutable
class ChallengeButton {
  final String? text;
  final String? action;
  final bool? enabled;

  const ChallengeButton({this.text, this.action, this.enabled});

  factory ChallengeButton.fromJson(Map<String, dynamic> json) {
    return ChallengeButton(
      text: json['text'] as String?,
      action: json['action'] as String?,
      enabled: json['enabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'action': action, 'enabled': enabled};
  }
}

@immutable
class ChallengeFooter {
  final String? type;
  final String? title;
  final int? remainingSeconds;
  final String? date;
  final String? buttonText;

  const ChallengeFooter({
    this.type,
    this.title,
    this.remainingSeconds,
    this.date,
    this.buttonText,
  });

  factory ChallengeFooter.fromJson(Map<String, dynamic> json) {
    return ChallengeFooter(
      type: json['type'] as String?,
      title: json['title'] as String?,
      remainingSeconds: json['remaining_seconds'] as int?,
      date: json['date'] as String?,
      buttonText: json['button_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'remaining_seconds': remainingSeconds,
      'date': date,
      'button_text': buttonText,
    };
  }
}

@immutable
class ChallengeModel {
  final int? id;
  final String? name;
  final String? shortDescription;
  final ChallengeBrand? brand;
  final String? bannerImage;
  final String? thumbnailImage;
  final String? category;
  final String? categoryDisplay;
  final String? challengeType;
  final String? themeColor;
  final int? joinedMemberCount;
  final List<ChallengeJoinedMember>? joinedMembers;
  final ChallengeProgress? progress;
  final bool? isJoined;
  final ChallengeButton? button;
  final ChallengeFooter? footer;
  final String? status;
  final int? remainingSeconds;
  final String? challengeTypeValue;
  final bool? isEndingSoon;
  final String? gymName;
  final String? gymLogo;
  final String? gymLocation;

  const ChallengeModel({
    this.id,
    this.name,
    this.shortDescription,
    this.brand,
    this.bannerImage,
    this.thumbnailImage,
    this.category,
    this.categoryDisplay,
    this.challengeType,
    this.themeColor,
    this.joinedMemberCount,
    this.joinedMembers,
    this.progress,
    this.isJoined,
    this.button,
    this.footer,
    this.status,
    this.remainingSeconds,
    this.challengeTypeValue,
    this.isEndingSoon,
    this.gymName,
    this.gymLogo,
    this.gymLocation,
  });

  /// Best available image URL: thumbnail first, then banner.
  String? get thumbnailUrl {
    if (thumbnailImage != null && thumbnailImage!.trim().isNotEmpty) {
      return thumbnailImage;
    }
    if (bannerImage != null && bannerImage!.trim().isNotEmpty) {
      return bannerImage;
    }
    return null;
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortDescription:
          (json['short_description'] ?? json['description']) as String?,
      brand:
          json['brand'] is Map<String, dynamic>
              ? ChallengeBrand.fromJson(json['brand'] as Map<String, dynamic>)
              : null,
      bannerImage: json['banner_image'] as String?,
      thumbnailImage:
          (json['thumbnail_image'] ??
                  json['thumbnail'] ??
                  json['thumbnail_url'] ??
                  json['image'])
              as String?,
      category: json['category'] as String?,
      categoryDisplay:
          (json['category_display'] ?? json['category_name']) as String?,
      challengeType: json['challenge_type'] as String?,
      themeColor: json['theme_color'] as String?,
      joinedMemberCount: json['joined_member_count'] as int?,
      joinedMembers:
          (json['joined_members'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ChallengeJoinedMember.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      progress:
          json['progress'] is Map<String, dynamic>
              ? ChallengeProgress.fromJson(
                json['progress'] as Map<String, dynamic>,
              )
              : null,
      isJoined: _parseBool(json['is_joined']),
      button:
          json['button'] is Map<String, dynamic>
              ? ChallengeButton.fromJson(json['button'] as Map<String, dynamic>)
              : null,
      footer:
          json['footer'] is Map<String, dynamic>
              ? ChallengeFooter.fromJson(json['footer'] as Map<String, dynamic>)
              : null,
      status: json['status'] as String?,
      remainingSeconds: json['remaining_seconds'] as int?,
      challengeTypeValue: json['challenge_type_value'] as String?,
      isEndingSoon: _parseBool(json['is_ending_soon']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_description': shortDescription,
      'brand': brand?.toJson(),
      'banner_image': bannerImage,
      'thumbnail_image': thumbnailImage,
      'category': category,
      'category_display': categoryDisplay,
      'challenge_type': challengeType,
      'theme_color': themeColor,
      'joined_member_count': joinedMemberCount,
      'joined_members': joinedMembers?.map((e) => e.toJson()).toList(),
      'progress': progress?.toJson(),
      'is_joined': isJoined,
      'button': button?.toJson(),
      'footer': footer?.toJson(),
      'status': status,
      'remaining_seconds': remainingSeconds,
      'challenge_type_value': challengeTypeValue,
      'is_ending_soon': isEndingSoon,
      'gym_name': gymName,
      'gym_logo': gymLogo,
      'gym_location': gymLocation,
    };
  }
}

@immutable
class ChallengeListResponse {
  final int? count;
  final String? next;
  final String? previous;
  final List<ChallengeModel>? results;

  const ChallengeListResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ChallengeListResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeListResponse(
      count: json['count'] as int?,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((e) => e.toJson()).toList(),
    };
  }
}

@immutable
class JoinChallengeResponse {
  final bool status;
  final String? message;
  final String? error;
  final bool? isJoined;
  final String? joinedAt;
  final int? challengeId;
  final ChallengeButton? button;

  const JoinChallengeResponse({
    required this.status,
    this.message,
    this.error,
    this.isJoined,
    this.joinedAt,
    this.challengeId,
    this.button,
  });

  factory JoinChallengeResponse.fromJson(Map<String, dynamic> json) {
    return JoinChallengeResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String?,
      error: json['error'] as String?,
      isJoined: _parseBool(json['is_joined']),
      joinedAt: json['joined_at'] as String?,
      challengeId: json['challenge_id'] as int?,
      button:
          json['button'] is Map<String, dynamic>
              ? ChallengeButton.fromJson(json['button'] as Map<String, dynamic>)
              : null,
    );
  }
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
  }
  return null;
}
