// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
class HomeModel with _$HomeModel {
  const factory HomeModel({
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'subscription') Subscription? subscription,
    @JsonKey(name: 'banners') List<String>? banners,
    @JsonKey(name: 'fitness_center_banners') List<String>? fitnessCenterBanners,
    @JsonKey(name: 'assigned_trainer') AssignedTrainerModel? assignedTrainer,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) => _$HomeModelFromJson(json);
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
}

@freezed
class AssignedTrainerModel with _$AssignedTrainerModel {
  const factory AssignedTrainerModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'experience_years') int? experienceYears,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'specializations') List<String>? specializations,
  }) = _AssignedTrainerModel;

  factory AssignedTrainerModel.fromJson(Map<String, dynamic> json) => _$AssignedTrainerModelFromJson(json);
}
