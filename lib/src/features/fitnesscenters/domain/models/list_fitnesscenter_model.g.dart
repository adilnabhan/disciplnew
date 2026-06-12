// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_fitnesscenter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListFitnesscenterModelImpl _$$ListFitnesscenterModelImplFromJson(
  Map<String, dynamic> json,
) => _$ListFitnesscenterModelImpl(
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'],
  results:
      (json['results'] as List<dynamic>?)
          ?.map(
            (e) => SingleFItnessCenterModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$$ListFitnesscenterModelImplToJson(
  _$ListFitnesscenterModelImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$SingleFItnessCenterModelImpl _$$SingleFItnessCenterModelImplFromJson(
  Map<String, dynamic> json,
) => _$SingleFItnessCenterModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  logo: json['logo'] as String?,
  slug: json['slug'] as String?,
  active: json['active'] as bool?,
  isPublic: json['is_public'] as bool?,
  registrationStatus: json['registration_status'] as String?,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  mentorName: json['mentor_name'] as String?,
  reviewCount: (json['review_count'] as num?)?.toInt(),
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$SingleFItnessCenterModelImplToJson(
  _$SingleFItnessCenterModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'logo': instance.logo,
  'slug': instance.slug,
  'active': instance.active,
  'is_public': instance.isPublic,
  'registration_status': instance.registrationStatus,
  'categories': instance.categories,
  'location': instance.location,
  'mentor_name': instance.mentorName,
  'review_count': instance.reviewCount,
  'average_rating': instance.averageRating,
  'created_at': instance.createdAt?.toIso8601String(),
};

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
