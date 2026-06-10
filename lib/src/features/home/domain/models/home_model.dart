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
