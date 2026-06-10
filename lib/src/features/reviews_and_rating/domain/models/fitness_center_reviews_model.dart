// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fitness_center_reviews_model.freezed.dart';
part 'fitness_center_reviews_model.g.dart';

@freezed
class FitnessCenterReviewsModel with _$FitnessCenterReviewsModel {
  const factory FitnessCenterReviewsModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') FitnessCenterReviewsResultsModel? results,
  }) = _FitnessCenterReviewsModel;

  factory FitnessCenterReviewsModel.fromJson(Map<String, dynamic> json) => _$FitnessCenterReviewsModelFromJson(json);
}

@freezed
class FitnessCenterReviewsResultsModel with _$FitnessCenterReviewsResultsModel {
  const factory FitnessCenterReviewsResultsModel({
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'avg_rating') int? avgRating,
    @JsonKey(name: 'reviews') List<SingleFitnessCenterReviewModel>? reviews,
  }) = _FitnessCenterReviewsResultsModel;

  factory FitnessCenterReviewsResultsModel.fromJson(Map<String, dynamic> json) => _$FitnessCenterReviewsResultsModelFromJson(json);
}

@freezed
class SingleFitnessCenterReviewModel with _$SingleFitnessCenterReviewModel {
  const factory SingleFitnessCenterReviewModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
  }) = _SingleFitnessCenterReviewModel;

  factory SingleFitnessCenterReviewModel.fromJson(Map<String, dynamic> json) => _$SingleFitnessCenterReviewModelFromJson(json);
}
