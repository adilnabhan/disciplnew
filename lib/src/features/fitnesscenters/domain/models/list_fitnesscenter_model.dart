// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:customer_mobile_app/imports_bindings.dart';

part 'list_fitnesscenter_model.freezed.dart';
part 'list_fitnesscenter_model.g.dart';

@freezed
class ListFitnesscenterModel with _$ListFitnesscenterModel {
  const factory ListFitnesscenterModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<SingleFItnessCenterModel>? results,
  }) = _ListFitnesscenterModel;

  factory ListFitnesscenterModel.fromJson(Map<String, dynamic> json) => _$ListFitnesscenterModelFromJson(json);
}

@freezed
class SingleFItnessCenterModel with _$SingleFItnessCenterModel {
  const factory SingleFItnessCenterModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'registration_status') String? registrationStatus,
    @JsonKey(name: 'categories') List<Category>? categories,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'mentor_name') String? mentorName,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SingleFItnessCenterModel;

  factory SingleFItnessCenterModel.fromJson(Map<String, dynamic> json) => _$SingleFItnessCenterModelFromJson(json);
}

@freezed
class Category with _$Category {
  const factory Category({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
