// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

part 'active_membership_model.freezed.dart';
part 'active_membership_model.g.dart';

@freezed
class ActiveMembershipModel with _$ActiveMembershipModel {
  const factory ActiveMembershipModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') OrganizationModel? organization,
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_type') String? paymentType,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ActiveMembershipModel;

  factory ActiveMembershipModel.fromJson(Map<String, dynamic> json) => _$ActiveMembershipModelFromJson(json);
}

@freezed
class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'social_media') List<SocialMedia>? socialMedia,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'working_time') List<WorkingDay>? workingTime,
    @JsonKey(name: 'review') Review? review,
    @JsonKey(name: 'category') List<String>? category,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) => _$OrganizationModelFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

@freezed
class Review with _$Review {
  const factory Review({
    @JsonKey(name: 'has_reviewed') bool? hasReviewed,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'my_review') dynamic myReview,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
