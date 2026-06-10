// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_posted_reviews_model.freezed.dart';
part 'customer_posted_reviews_model.g.dart';

@freezed
class CustomerPostedReviewsModel with _$CustomerPostedReviewsModel {
  const factory CustomerPostedReviewsModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SingleReviewModel>? results,
  }) = _CustomerPostedReviewsModel;

  factory CustomerPostedReviewsModel.fromJson(Map<String, dynamic> json) => _$CustomerPostedReviewsModelFromJson(json);
}

@freezed
class SingleReviewModel with _$SingleReviewModel {
  const factory SingleReviewModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'organization_category') List<String>? organizationCategory,
    @JsonKey(name: 'customer') int? customer,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
  }) = _SingleReviewModel;

  factory SingleReviewModel.fromJson(Map<String, dynamic> json) => _$SingleReviewModelFromJson(json);
}
