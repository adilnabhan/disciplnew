import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
class ProfileCompletionModel {
  const ProfileCompletionModel({
    required this.completionPercentage,
    required this.isCompleted,
    required this.dismissed,
    required this.title,
    required this.message,
    required this.completedFields,
    required this.missingFields,
    required this.nextScreen,
    this.profilePhotoReward,
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      completionPercentage:
          (json['completion_percentage'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      dismissed: json['dismissed'] as bool? ?? false,
      title: json['title'] as String? ?? 'Complete Your Profile',
      message:
          json['message'] as String? ??
          'Complete your profile to get personalized insights and a better fitness experience.',
      completedFields:
          (json['completed_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      missingFields:
          (json['missing_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nextScreen: json['next_screen'] as String? ?? 'profile',
      profilePhotoReward: json['profile_photo_reward'] is Map<String, dynamic>
          ? ProfilePhotoRewardModel.fromJson(
              json['profile_photo_reward'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completion_percentage': completionPercentage,
      'is_completed': isCompleted,
      'dismissed': dismissed,
      'title': title,
      'message': message,
      'completed_fields': completedFields,
      'missing_fields': missingFields,
      'next_screen': nextScreen,
      'profile_photo_reward': profilePhotoReward?.toJson(),
    };
  }

  final int completionPercentage;
  final bool isCompleted;
  final bool dismissed;
  final String title;
  final String message;
  final List<String> completedFields;
  final List<String> missingFields;
  final String nextScreen;
  final ProfilePhotoRewardModel? profilePhotoReward;
}

@immutable
class ProfilePhotoRewardModel {
  const ProfilePhotoRewardModel({
    this.success,
    this.shouldShow,
    this.hasProfilePhoto,
    this.rewardPoints,
    this.isAwarded,
    this.currentScore,
    this.scoreAfterReward,
    this.title,
    this.message,
    this.description,
    this.profilePhotoUrl,
    this.banner,
    this.popup,
    this.dismissed,
    this.dismissedAt,
    this.reappearsAfterHours,
  });

  factory ProfilePhotoRewardModel.fromJson(Map<String, dynamic> json) {
    return ProfilePhotoRewardModel(
      success: json['success'] as bool?,
      shouldShow: json['should_show'] as bool?,
      hasProfilePhoto: json['has_profile_photo'] as bool?,
      rewardPoints: (json['reward_points'] as num?)?.toInt(),
      isAwarded: json['is_awarded'] as bool?,
      currentScore: (json['current_score'] as num?)?.toInt(),
      scoreAfterReward: (json['score_after_reward'] as num?)?.toInt(),
      title: json['title'] as String?,
      message: json['message'] as String?,
      description: json['description'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      banner: json['banner'] is Map<String, dynamic>
          ? RewardBannerModel.fromJson(json['banner'] as Map<String, dynamic>)
          : null,
      popup: json['popup'] is Map<String, dynamic>
          ? RewardPopupModel.fromJson(json['popup'] as Map<String, dynamic>)
          : null,
      dismissed: json['dismissed'] as bool?,
      dismissedAt: json['dismissed_at'] as String?,
      reappearsAfterHours: (json['reappears_after_hours'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'should_show': shouldShow,
      'has_profile_photo': hasProfilePhoto,
      'reward_points': rewardPoints,
      'is_awarded': isAwarded,
      'current_score': currentScore,
      'score_after_reward': scoreAfterReward,
      'title': title,
      'message': message,
      'description': description,
      'profile_photo_url': profilePhotoUrl,
      'banner': banner?.toJson(),
      'popup': popup?.toJson(),
      'dismissed': dismissed,
      'dismissed_at': dismissedAt,
      'reappears_after_hours': reappearsAfterHours,
    };
  }

  final bool? success;
  final bool? shouldShow;
  final bool? hasProfilePhoto;
  final int? rewardPoints;
  final bool? isAwarded;
  final int? currentScore;
  final int? scoreAfterReward;
  final String? title;
  final String? message;
  final String? description;
  final String? profilePhotoUrl;
  final RewardBannerModel? banner;
  final RewardPopupModel? popup;
  final bool? dismissed;
  final String? dismissedAt;
  final int? reappearsAfterHours;
}

@immutable
class RewardBannerModel {
  const RewardBannerModel({
    this.shouldShow,
    this.title,
    this.message,
    this.badgeText,
    this.buttonText,
    this.action,
    this.targetScreen,
    this.targetRoute,
    this.dismissable,
  });

  factory RewardBannerModel.fromJson(Map<String, dynamic> json) {
    return RewardBannerModel(
      shouldShow: json['should_show'] as bool?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      badgeText: json['badge_text'] as String?,
      buttonText: json['button_text'] as String?,
      action: json['action'] as String?,
      targetScreen: json['target_screen'] as String?,
      targetRoute: json['target_route'] as String?,
      dismissable: json['dismissable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'should_show': shouldShow,
      'title': title,
      'message': message,
      'badge_text': badgeText,
      'button_text': buttonText,
      'action': action,
      'target_screen': targetScreen,
      'target_route': targetRoute,
      'dismissable': dismissable,
    };
  }

  final bool? shouldShow;
  final String? title;
  final String? message;
  final String? badgeText;
  final String? buttonText;
  final String? action;
  final String? targetScreen;
  final String? targetRoute;
  final bool? dismissable;
}

@immutable
class RewardPopupModel {
  const RewardPopupModel({
    this.shouldShow,
    this.title,
    this.subtitle,
    this.message,
    this.rewardPoints,
    this.currentScore,
    this.newScore,
    this.icon,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.action,
    this.targetScreen,
    this.targetRoute,
    this.dismissable,
  });

  factory RewardPopupModel.fromJson(Map<String, dynamic> json) {
    return RewardPopupModel(
      shouldShow: json['should_show'] as bool?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      message: json['message'] as String?,
      rewardPoints: (json['reward_points'] as num?)?.toInt(),
      currentScore: (json['current_score'] as num?)?.toInt(),
      newScore: (json['new_score'] as num?)?.toInt(),
      icon: json['icon'] as String?,
      primaryButtonText: json['primary_button_text'] as String?,
      secondaryButtonText: json['secondary_button_text'] as String?,
      action: json['action'] as String?,
      targetScreen: json['target_screen'] as String?,
      targetRoute: json['target_route'] as String?,
      dismissable: json['dismissable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'should_show': shouldShow,
      'title': title,
      'subtitle': subtitle,
      'message': message,
      'reward_points': rewardPoints,
      'current_score': currentScore,
      'new_score': newScore,
      'icon': icon,
      'primary_button_text': primaryButtonText,
      'secondary_button_text': secondaryButtonText,
      'action': action,
      'target_screen': targetScreen,
      'target_route': targetRoute,
      'dismissable': dismissable,
    };
  }

  final bool? shouldShow;
  final String? title;
  final String? subtitle;
  final String? message;
  final int? rewardPoints;
  final int? currentScore;
  final int? newScore;
  final String? icon;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final String? action;
  final String? targetScreen;
  final String? targetRoute;
  final bool? dismissable;
}
