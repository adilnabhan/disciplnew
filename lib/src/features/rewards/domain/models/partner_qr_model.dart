import 'package:flutter/foundation.dart';

@immutable
class PartnerQrModel {
  final String? qrToken;
  final String? memberCode;
  final int? customerId;
  final String? customerName;
  final bool? isActiveMember;
  final bool? isWorkoutCompleted;
  final bool? isStepsCompleted;
  final bool? isEligibleForDiscount;
  final String? eligibilityStatus;
  final String? eligibilityReason;
  final String? membershipStatus;
  final int? expiresInSeconds;
  final DateTime? generatedAt;

  const PartnerQrModel({
    this.qrToken,
    this.memberCode,
    this.customerId,
    this.customerName,
    this.isActiveMember,
    this.isWorkoutCompleted,
    this.isStepsCompleted,
    this.isEligibleForDiscount,
    this.eligibilityStatus,
    this.eligibilityReason,
    this.membershipStatus,
    this.expiresInSeconds,
    this.generatedAt,
  });

  factory PartnerQrModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['generated_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['generated_at'].toString());
      } catch (_) {
        parsedDate = null;
      }
    }

    return PartnerQrModel(
      qrToken: json['qr_token'] as String?,
      memberCode: json['member_code'] as String?,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String?,
      isActiveMember: json['is_active_member'] as bool?,
      isWorkoutCompleted: json['is_workout_completed'] as bool?,
      isStepsCompleted: json['is_steps_completed'] as bool?,
      isEligibleForDiscount: json['is_eligible_for_discount'] as bool?,
      eligibilityStatus: json['eligibility_status'] as String?,
      eligibilityReason: json['eligibility_reason'] as String?,
      membershipStatus: json['membership_status'] as String?,
      expiresInSeconds: json['expires_in_seconds'] as int?,
      generatedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_token': qrToken,
      'member_code': memberCode,
      'customer_id': customerId,
      'customer_name': customerName,
      'is_active_member': isActiveMember,
      'is_workout_completed': isWorkoutCompleted,
      'is_steps_completed': isStepsCompleted,
      'is_eligible_for_discount': isEligibleForDiscount,
      'eligibility_status': eligibilityStatus,
      'eligibility_reason': eligibilityReason,
      'membership_status': membershipStatus,
      'expires_in_seconds': expiresInSeconds,
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}
