// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActiveMembershipModelImpl _$$ActiveMembershipModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActiveMembershipModelImpl(
  id: (json['id'] as num?)?.toInt(),
  organization:
      json['organization'] == null
          ? null
          : OrganizationModel.fromJson(
            json['organization'] as Map<String, dynamic>,
          ),
  planId: (json['plan_id'] as num?)?.toInt(),
  planName: json['plan_name'] as String?,
  packageType: json['package_type'] as String?,
  amount: json['amount'] as String?,
  startDate:
      json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
  endDate:
      json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
  isEmiAvailable: json['is_emi_available'] as bool?,
  status: json['status'] as String?,
  paymentType: json['payment_type'] as String?,
  paymentStatus: json['payment_status'] as String?,
  isActive: json['is_active'] as bool?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ActiveMembershipModelImplToJson(
  _$ActiveMembershipModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization': instance.organization,
  'plan_id': instance.planId,
  'plan_name': instance.planName,
  'package_type': instance.packageType,
  'amount': instance.amount,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'is_emi_available': instance.isEmiAvailable,
  'status': instance.status,
  'payment_type': instance.paymentType,
  'payment_status': instance.paymentStatus,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_$OrganizationModelImpl _$$OrganizationModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  logo: json['logo'] as String?,
  socialMedia:
      (json['social_media'] as List<dynamic>?)
          ?.map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  workingTime:
      (json['working_time'] as List<dynamic>?)
          ?.map((e) => WorkingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
  review:
      json['review'] == null
          ? null
          : Review.fromJson(json['review'] as Map<String, dynamic>),
  category:
      (json['category'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$OrganizationModelImplToJson(
  _$OrganizationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo': instance.logo,
  'social_media': instance.socialMedia,
  'location': instance.location,
  'working_time': instance.workingTime,
  'review': instance.review,
  'category': instance.category,
};

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      buildingName: json['building_name'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pin_code'] as String?,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'building_name': instance.buildingName,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'pin_code': instance.pinCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
  hasReviewed: json['has_reviewed'] as bool?,
  rating: (json['rating'] as num?)?.toInt(),
  reviewCount: (json['review_count'] as num?)?.toInt(),
  myReview: json['my_review'],
);

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'has_reviewed': instance.hasReviewed,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'my_review': instance.myReview,
    };
