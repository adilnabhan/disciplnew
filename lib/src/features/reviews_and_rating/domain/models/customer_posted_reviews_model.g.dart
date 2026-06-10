// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_posted_reviews_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerPostedReviewsModelImpl _$$CustomerPostedReviewsModelImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerPostedReviewsModelImpl(
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => SingleReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$CustomerPostedReviewsModelImplToJson(
  _$CustomerPostedReviewsModelImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$SingleReviewModelImpl _$$SingleReviewModelImplFromJson(
  Map<String, dynamic> json,
) => _$SingleReviewModelImpl(
  id: (json['id'] as num?)?.toInt(),
  organization: (json['organization'] as num?)?.toInt(),
  organizationName: json['organization_name'] as String?,
  organizationLogo: json['organization_logo'] as String?,
  startDate:
      json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
  endDate:
      json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
  organizationCategory:
      (json['organization_category'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  customer: (json['customer'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  customerName: json['customer_name'] as String?,
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  modified:
      json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
);

Map<String, dynamic> _$$SingleReviewModelImplToJson(
  _$SingleReviewModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization': instance.organization,
  'organization_name': instance.organizationName,
  'organization_logo': instance.organizationLogo,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'organization_category': instance.organizationCategory,
  'customer': instance.customer,
  'rating': instance.rating,
  'comment': instance.comment,
  'customer_name': instance.customerName,
  'created': instance.created?.toIso8601String(),
  'modified': instance.modified?.toIso8601String(),
};
