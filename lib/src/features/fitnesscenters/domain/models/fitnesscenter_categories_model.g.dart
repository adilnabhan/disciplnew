// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitnesscenter_categories_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FitnesscenterCategoriesModelImpl _$$FitnesscenterCategoriesModelImplFromJson(
  Map<String, dynamic> json,
) => _$FitnesscenterCategoriesModelImpl(
  results:
      (json['results'] as List<dynamic>?)
          ?.map(
            (e) => SingleFitnesscenterCategoryModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
);

Map<String, dynamic> _$$FitnesscenterCategoriesModelImplToJson(
  _$FitnesscenterCategoriesModelImpl instance,
) => <String, dynamic>{'results': instance.results};

_$SingleFitnesscenterCategoryModelImpl
_$$SingleFitnesscenterCategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$SingleFitnesscenterCategoryModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$$SingleFitnesscenterCategoryModelImplToJson(
  _$SingleFitnesscenterCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo': instance.logo,
};
