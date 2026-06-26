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
      assignedTrainer:
          json['assigned_trainer'] == null
              ? null
              : AssignedTrainerModel.fromJson(
                json['assigned_trainer'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$$HomeModelImplToJson(_$HomeModelImpl instance) =>
    <String, dynamic>{
      'is_subscribed': instance.isSubscribed,
      'subscription': instance.subscription,
      'banners': instance.banners,
      'fitness_center_banners': instance.fitnessCenterBanners,
      'assigned_trainer': instance.assignedTrainer,
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

_$AssignedTrainerModelImpl _$$AssignedTrainerModelImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedTrainerModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  profileImage: json['profile_image'] as String?,
  mobile: json['mobile'] as String?,
  experienceYears: (json['experience_years'] as num?)?.toInt(),
  bio: json['bio'] as String?,
  specializations:
      (json['specializations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$$AssignedTrainerModelImplToJson(
  _$AssignedTrainerModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profile_image': instance.profileImage,
  'mobile': instance.mobile,
  'experience_years': instance.experienceYears,
  'bio': instance.bio,
  'specializations': instance.specializations,
};
