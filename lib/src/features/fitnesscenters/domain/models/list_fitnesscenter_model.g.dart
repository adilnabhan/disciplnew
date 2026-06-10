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
  logo: json['logo'] as String?,
  description: json['description'] as String?,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  category:
      (json['category'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num?)?.toInt(),
  isSlotAvailable: json['is_slot_available'] as bool?,
);

Map<String, dynamic> _$$SingleFItnessCenterModelImplToJson(
  _$SingleFItnessCenterModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo': instance.logo,
  'description': instance.description,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'location': instance.location,
  'category': instance.category,
  'services': instance.services,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'is_slot_available': instance.isSlotAvailable,
};

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$ServiceImpl _$$ServiceImplFromJson(Map<String, dynamic> json) =>
    _$ServiceImpl(name: json['name'] as String?);

Map<String, dynamic> _$$ServiceImplToJson(_$ServiceImpl instance) =>
    <String, dynamic>{'name': instance.name};
