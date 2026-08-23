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
  const SingleFItnessCenterModel._();

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
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'mentor_name') String? mentorName,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  }) = _SingleFItnessCenterModel;

  factory SingleFItnessCenterModel.fromJson(Map<String, dynamic> json) => _$SingleFItnessCenterModelFromJson(json);

  List<Category>? get gymCategories => categories ?? category;

  double? get gymLatitude {
    final lat = latitude ?? location?.latitude;
    if (lat == null) return null;
    if (lat is num) return lat.toDouble();
    if (lat is String) return double.tryParse(lat);
    return null;
  }

  double? get gymLongitude {
    final lng = longitude ?? location?.longitude;
    if (lng == null) return null;
    if (lng is num) return lng.toDouble();
    if (lng is String) return double.tryParse(lng);
    return null;
  }
}

@freezed
class Category with _$Category {
  const factory Category({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
