import 'package:flutter/foundation.dart';

@immutable
class ChallengeBrand {
  final int? id;
  final String? name;
  final String? logo;
  final String? website;
  final bool? verified;

  const ChallengeBrand({
    this.id,
    this.name,
    this.logo,
    this.website,
    this.verified,
  });

  factory ChallengeBrand.fromJson(Map<String, dynamic> json) {
    return ChallengeBrand(
      id: json['id'] as int?,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      website: json['website'] as String?,
      verified: json['verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'website': website,
      'verified': verified,
    };
  }
}

@immutable
class ChallengeJoinedMember {
  final int? id;
  final String? profileImage;

  const ChallengeJoinedMember({
    this.id,
    this.profileImage,
  });

  factory ChallengeJoinedMember.fromJson(Map<String, dynamic> json) {
    return ChallengeJoinedMember(
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
class ChallengeReward {
  final String? type;
  final String? title;
  final String? description;
  final String? image;
  final int? winnerCount;
  final num? rewardValue;
  final String? currency;
  final String? distributionStatus;

  const ChallengeReward({
    this.type,
    this.title,
    this.description,
    this.image,
    this.winnerCount,
    this.rewardValue,
    this.currency,
    this.distributionStatus,
  });

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(
      type: json['type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      winnerCount: json['winner_count'] as int?,
      rewardValue: json['reward_value'] as num?,
      currency: json['currency'] as String?,
      distributionStatus: json['distribution_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'image': image,
      'winner_count': winnerCount,
      'reward_value': rewardValue,
      'currency': currency,
      'distribution_status': distributionStatus,
    };
  }
}

@immutable
class ChallengeHowItWorks {
  final String? icon;
  final String? title;
  final String? description;

  const ChallengeHowItWorks({
    this.icon,
    this.title,
    this.description,
  });

  factory ChallengeHowItWorks.fromJson(Map<String, dynamic> json) {
    return ChallengeHowItWorks(
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
    };
  }
}

@immutable
class ChallengeTimeline {
  final String? startsAt;
  final String? endsAt;
  final String? drawDate;
  final int? remainingSeconds;
  final String? serverTime;

  const ChallengeTimeline({
    this.startsAt,
    this.endsAt,
    this.drawDate,
    this.remainingSeconds,
    this.serverTime,
  });

  factory ChallengeTimeline.fromJson(Map<String, dynamic> json) {
    return ChallengeTimeline(
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      drawDate: json['draw_date'] as String?,
      remainingSeconds: json['remaining_seconds'] as int?,
      serverTime: json['server_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'starts_at': startsAt,
      'ends_at': endsAt,
      'draw_date': drawDate,
      'remaining_seconds': remainingSeconds,
      'server_time': serverTime,
    };
  }
}

@immutable
class AnnouncedWinner {
  final int? id;
  final String? name;
  final String? profileImage;
  final int? rank;
  final String? prize;

  const AnnouncedWinner({
    this.id,
    this.name,
    this.profileImage,
    this.rank,
    this.prize,
  });

  factory AnnouncedWinner.fromJson(Map<String, dynamic> json) {
    return AnnouncedWinner(
      id: json['id'] as int?,
      name: json['name'] as String?,
      profileImage: (json['profile_image'] ?? json['image']) as String?,
      rank: json['rank'] as int?,
      prize: json['prize'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'rank': rank,
      'prize': prize,
    };
  }
}

@immutable
class ChallengeWinner {
  final String? selectionMethod;
  final String? announcementDate;
  final bool? isAnnounced;
  final List<AnnouncedWinner>? announcedWinners;

  const ChallengeWinner({
    this.selectionMethod,
    this.announcementDate,
    this.isAnnounced,
    this.announcedWinners,
  });

  factory ChallengeWinner.fromJson(Map<String, dynamic> json) {
    return ChallengeWinner(
      selectionMethod: json['selection_method'] as String?,
      announcementDate: json['announcement_date'] as String?,
      isAnnounced: json['is_announced'] as bool?,
      announcedWinners: (json['announced_winners'] as List<dynamic>?)
          ?.map((e) => AnnouncedWinner.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selection_method': selectionMethod,
      'announcement_date': announcementDate,
      'is_announced': isAnnounced,
      'announced_winners': announcedWinners?.map((e) => e.toJson()).toList(),
    };
  }
}

@immutable
class ChallengeShare {
  final String? title;
  final String? description;
  final String? deepLink;

  const ChallengeShare({
    this.title,
    this.description,
    this.deepLink,
  });

  factory ChallengeShare.fromJson(Map<String, dynamic> json) {
    return ChallengeShare(
      title: json['title'] as String?,
      description: json['description'] as String?,
      deepLink: json['deep_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deep_link': deepLink,
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
class ChallengeDetailsResponse {
  final int? id;
  final String? name;
  final String? shortDescription;
  final String? description;
  final String? category;
  final String? challengeType;
  final String? themeColor;
  final String? bannerImage;
  final ChallengeBrand? brand;
  final bool? isJoined;
  final int? joinedMemberCount;
  final List<ChallengeJoinedMember>? joinedMembers;
  final ChallengeProgress? progress;
  final ChallengeReward? reward;
  final List<ChallengeHowItWorks>? howItWorks;
  final ChallengeTimeline? timeline;
  final ChallengeWinner? winner;
  final ChallengeShare? share;
  final List<String>? rules;
  final List<String>? disqualificationRules;
  final List<String>? termsAndConditions;
  final ChallengeButton? button;
  final ChallengeFooter? footer;
  final String? status;

  const ChallengeDetailsResponse({
    this.id,
    this.name,
    this.shortDescription,
    this.description,
    this.category,
    this.challengeType,
    this.themeColor,
    this.bannerImage,
    this.brand,
    this.isJoined,
    this.joinedMemberCount,
    this.joinedMembers,
    this.progress,
    this.reward,
    this.howItWorks,
    this.timeline,
    this.winner,
    this.share,
    this.rules,
    this.disqualificationRules,
    this.termsAndConditions,
    this.button,
    this.footer,
    this.status,
  });

  factory ChallengeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeDetailsResponse(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      challengeType: json['challenge_type'] as String?,
      themeColor: json['theme_color'] as String?,
      bannerImage: json['banner_image'] as String?,
      brand: json['brand'] is Map<String, dynamic>
          ? ChallengeBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      isJoined: _parseBool(json['is_joined']),
      joinedMemberCount: json['joined_member_count'] as int?,
      joinedMembers: (json['joined_members'] as List<dynamic>?)
          ?.map((e) => ChallengeJoinedMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: json['progress'] is Map<String, dynamic>
          ? ChallengeProgress.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      reward: json['reward'] is Map<String, dynamic>
          ? ChallengeReward.fromJson(json['reward'] as Map<String, dynamic>)
          : null,
      howItWorks: (json['how_it_works'] as List<dynamic>?)
          ?.map((e) => ChallengeHowItWorks.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: json['timeline'] is Map<String, dynamic>
          ? ChallengeTimeline.fromJson(json['timeline'] as Map<String, dynamic>)
          : null,
      winner: json['winner'] is Map<String, dynamic>
          ? ChallengeWinner.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
      share: json['share'] is Map<String, dynamic>
          ? ChallengeShare.fromJson(json['share'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      disqualificationRules: (json['disqualification_rules'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      termsAndConditions: (json['terms_and_conditions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      button: json['button'] is Map<String, dynamic>
          ? ChallengeButton.fromJson(json['button'] as Map<String, dynamic>)
          : null,
      footer: json['footer'] is Map<String, dynamic>
          ? ChallengeFooter.fromJson(json['footer'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'category': category,
      'challenge_type': challengeType,
      'theme_color': themeColor,
      'banner_image': bannerImage,
      'brand': brand?.toJson(),
      'is_joined': isJoined,
      'joined_member_count': joinedMemberCount,
      'joined_members': joinedMembers?.map((e) => e.toJson()).toList(),
      'progress': progress?.toJson(),
      'reward': reward?.toJson(),
      'how_it_works': howItWorks?.map((e) => e.toJson()).toList(),
      'timeline': timeline?.toJson(),
      'winner': winner?.toJson(),
      'share': share?.toJson(),
      'rules': rules,
      'disqualification_rules': disqualificationRules,
      'terms_and_conditions': termsAndConditions,
      'button': button?.toJson(),
      'footer': footer?.toJson(),
      'status': status,
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
