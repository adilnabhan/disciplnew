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
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'services') List<Service>? services,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'is_slot_available') bool? isSlotAvailable,
  }) = _SingleFItnessCenterModel;

  factory SingleFItnessCenterModel.fromJson(Map<String, dynamic> json) => _$SingleFItnessCenterModelFromJson(json);
}

@freezed
class Category with _$Category {
  const factory Category({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name}) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class Service with _$Service {
  const factory Service({@JsonKey(name: 'name') String? name}) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
