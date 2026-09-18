import 'package:flutter/foundation.dart';

@immutable
class ChallengeBrand {
  final int? id;
  final String? name;
  final String? logo;

  const ChallengeBrand({
    this.id,
    this.name,
    this.logo,
  });

  factory ChallengeBrand.fromJson(Map<String, dynamic> json) {
    return ChallengeBrand(
      id: json['id'] as int?,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

@immutable
class JoinedMember {
  final int? id;
  final String? profileImage;

  const JoinedMember({
    this.id,
    this.profileImage,
  });

  factory JoinedMember.fromJson(Map<String, dynamic> json) {
    return JoinedMember(
      id: json['id'] as int?,
      profileImage: (json['profile_image'] ?? json['image']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_image': profileImage,
    };
  }
}

@immutable
class ChallengeButton {
  final String? text;
  final String? action;
  final bool? enabled;

  const ChallengeButton({
    this.text,
    this.action,
    this.enabled,
  });

  factory ChallengeButton.fromJson(Map<String, dynamic> json) {
    return ChallengeButton(
      text: json['text'] as String?,
      action: json['action'] as String?,
      enabled: json['enabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'action': action,
      'enabled': enabled,
    };
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
class HomeChallenge {
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
  final List<JoinedMember>? joinedMembers;
  final bool? isJoined;
  final ChallengeButton? button;
  final ChallengeFooter? footer;
  final String? status;
  final int? remainingSeconds;

  const HomeChallenge({
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
    this.isJoined,
    this.button,
    this.footer,
    this.status,
    this.remainingSeconds,
  });

  String? get heroImageUrl {
    if (thumbnailImage != null && thumbnailImage!.trim().isNotEmpty) {
      return thumbnailImage;
    }
    if (bannerImage != null && bannerImage!.trim().isNotEmpty) {
      return bannerImage;
    }
    return null;
  }

  factory HomeChallenge.fromJson(Map<String, dynamic> json) {
    return HomeChallenge(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortDescription: (json['short_description'] ?? json['description']) as String?,
      brand: json['brand'] is Map<String, dynamic>
          ? ChallengeBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      bannerImage: json['banner_image'] as String?,
      thumbnailImage: (json['thumbnail_image'] ??
          json['thumbnail'] ??
          json['thumbnail_url'] ??
          json['image']) as String?,
      category: json['category'] as String?,
      categoryDisplay: (json['category_display'] ?? json['category']) as String?,
      challengeType: json['challenge_type'] as String?,
      themeColor: json['theme_color'] as String?,
      joinedMemberCount: json['joined_member_count'] as int?,
      joinedMembers: (json['joined_members'] as List<dynamic>?)
          ?.map((e) => JoinedMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      isJoined: _parseBool(json['is_joined']),
      button: json['button'] is Map<String, dynamic>
          ? ChallengeButton.fromJson(json['button'] as Map<String, dynamic>)
          : null,
      footer: json['footer'] is Map<String, dynamic>
          ? ChallengeFooter.fromJson(json['footer'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      remainingSeconds: json['remaining_seconds'] as int?,
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
      'is_joined': isJoined,
      'button': button?.toJson(),
      'footer': footer?.toJson(),
      'status': status,
      'remaining_seconds': remainingSeconds,
    };
  }
}

@immutable
class HomeChallengeResponse {
  final List<HomeChallenge>? results;

  const HomeChallengeResponse({
    this.results,
  });

  factory HomeChallengeResponse.fromJson(Map<String, dynamic> json) {
    return HomeChallengeResponse(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => HomeChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results?.map((e) => e.toJson()).toList(),
    };
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
