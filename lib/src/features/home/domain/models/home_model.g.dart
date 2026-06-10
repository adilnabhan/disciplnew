// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeModelImpl _$$HomeModelImplFromJson(Map<String, dynamic> json) =>
    _$HomeModelImpl(
      isSubscribed: json['is_subscribed'] as bool?,
      subscription:
          json['subscription'] == null
              ? null
              : Subscription.fromJson(
                json['subscription'] as Map<String, dynamic>,
              ),
      banners:
          (json['banners'] as List<dynamic>?)?.map((e) => e as String).toList(),
      fitnessCenterBanners:
          (json['fitness_center_banners'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$$HomeModelImplToJson(_$HomeModelImpl instance) =>
    <String, dynamic>{
      'is_subscribed': instance.isSubscribed,
      'subscription': instance.subscription,
      'banners': instance.banners,
      'fitness_center_banners': instance.fitnessCenterBanners,
    };

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      organizationName: json['organization_name'] as String?,
      organizationLogo: json['organization_logo'] as String?,
      planName: json['plan_name'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      startDate:
          json['start_date'] == null
              ? null
              : DateTime.parse(json['start_date'] as String),
      endDate:
          json['end_date'] == null
              ? null
              : DateTime.parse(json['end_date'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'organization_name': instance.organizationName,
      'organization_logo': instance.organizationLogo,
      'plan_name': instance.planName,
      'duration_days': instance.durationDays,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
    };
