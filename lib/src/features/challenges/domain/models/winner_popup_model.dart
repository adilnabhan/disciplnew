import 'package:flutter/foundation.dart';

@immutable
final class WinnerReward {
  final String title;
  final String type;
  final String? image;
  final double value;
  final String currency;

  const WinnerReward({
    required this.title,
    required this.type,
    required this.value,
    required this.currency,
    this.image,
  });

  factory WinnerReward.fromJson(Map<String, dynamic> json) {
    return WinnerReward(
      title: json['title'] as String? ?? 'Reward',
      type: json['type'] as String? ?? '',
      image: json['image'] as String?,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'image': image,
      'value': value,
      'currency': currency,
    };
  }

  String get formattedValue {
    if (value <= 0) return '';
    final symbol = currency.toUpperCase() == 'INR' ? '₹' : '$currency ';
    final valString = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    return 'Worth $symbol$valString';
  }
}

@immutable
final class WinnerPopupData {
  final int id;
  final int challengeId;
  final String challengeName;
  final String brandName;
  final String title;
  final String subtitle;
  final String message;
  final String? profileImage;
  final String? themeColor;
  final String? startDate;
  final String? endDate;
  final WinnerReward reward;
  final String selectionMethod;

  const WinnerPopupData({
    required this.id,
    required this.challengeId,
    required this.challengeName,
    required this.brandName,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.reward,
    required this.selectionMethod,
    this.profileImage,
    this.themeColor,
    this.startDate,
    this.endDate,
  });

  factory WinnerPopupData.fromJson(Map<String, dynamic> json) {
    return WinnerPopupData(
      id: json['id'] as int? ?? 0,
      challengeId: (json['challenge_id'] ?? json['challengeId']) as int? ?? 0,
      challengeName: json['challenge_name'] as String? ?? '',
      brandName: json['brand_name'] as String? ?? '',
      title: json['title'] as String? ?? 'Congratulations!',
      subtitle: json['subtitle'] as String? ?? 'You are a Lucky Winner!',
      message: json['message'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
      themeColor: (json['theme_color'] ??
              json['themeColor'] ??
              json['color'] ??
              (json['challenge'] is Map ? (json['challenge']['theme_color'] ?? json['challenge']['themeColor']) : null) ??
              (json['brand'] is Map ? (json['brand']['theme_color'] ?? json['brand']['themeColor']) : null))
          ?.toString(),
      startDate: (json['start_date'] ??
              json['startDate'] ??
              json['start'] ??
              json['challenge_start_date'] ??
              json['date_range'] ??
              json['date'] ??
              (json['challenge'] is Map ? (json['challenge']['start_date'] ?? json['challenge']['startDate']) : null) ??
              (json['details'] is Map ? (json['details']['start_date'] ?? json['details']['startDate']) : null))
          ?.toString(),
      endDate: (json['end_date'] ??
              json['endDate'] ??
              json['end'] ??
              json['challenge_end_date'] ??
              (json['challenge'] is Map ? (json['challenge']['end_date'] ?? json['challenge']['endDate']) : null) ??
              (json['details'] is Map ? (json['details']['end_date'] ?? json['details']['endDate']) : null))
          ?.toString(),
      reward: json['reward'] is Map<String, dynamic>
          ? WinnerReward.fromJson(json['reward'] as Map<String, dynamic>)
          : const WinnerReward(title: 'Reward', type: '', value: 0, currency: 'INR'),
      selectionMethod: json['selection_method'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'challenge_name': challengeName,
      'brand_name': brandName,
      'title': title,
      'subtitle': subtitle,
      'message': message,
      'profile_image': profileImage,
      'theme_color': themeColor,
      'start_date': startDate,
      'end_date': endDate,
      'reward': reward.toJson(),
      'selection_method': selectionMethod,
    };
  }

  String get formattedSubtext {
    if (startDate != null && startDate!.isNotEmpty && endDate != null && endDate!.isNotEmpty) {
      return '$startDate – $endDate';
    }
    if (startDate != null && startDate!.isNotEmpty) {
      return startDate!;
    }
    if (endDate != null && endDate!.isNotEmpty) {
      return endDate!;
    }
    if (brandName.isNotEmpty) return brandName;
    if (subtitle.isNotEmpty) return subtitle;
    return 'Challenge Completed';
  }
}

@immutable
final class WinnerPopupResponse {
  final bool showPopup;
  final WinnerPopupData? winner;

  const WinnerPopupResponse({
    required this.showPopup,
    this.winner,
  });

  factory WinnerPopupResponse.fromJson(Map<String, dynamic> json) {
    return WinnerPopupResponse(
      showPopup: json['show_popup'] as bool? ?? false,
      winner: json['winner'] is Map<String, dynamic>
          ? WinnerPopupData.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_popup': showPopup,
      'winner': winner?.toJson(),
    };
  }
}
