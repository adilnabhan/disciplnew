// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fitnesscenter_categories_model.freezed.dart';
part 'fitnesscenter_categories_model.g.dart';

@freezed
class FitnesscenterCategoriesModel with _$FitnesscenterCategoriesModel {
  const factory FitnesscenterCategoriesModel({@JsonKey(name: 'results') List<SingleFitnesscenterCategoryModel>? results}) = _FitnesscenterCategoriesModel;

  factory FitnesscenterCategoriesModel.fromJson(Map<String, dynamic> json) => _$FitnesscenterCategoriesModelFromJson(json);
}

@freezed
class SingleFitnesscenterCategoryModel with _$SingleFitnesscenterCategoryModel {
  const factory SingleFitnesscenterCategoryModel({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name, @JsonKey(name: 'logo') String? logo}) = _SingleFitnesscenterCategoryModel;

  factory SingleFitnesscenterCategoryModel.fromJson(Map<String, dynamic> json) => _$SingleFitnesscenterCategoryModelFromJson(json);
}
