// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_center_reviews_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FitnessCenterReviewsModelImpl _$$FitnessCenterReviewsModelImplFromJson(
  Map<String, dynamic> json,
) => _$FitnessCenterReviewsModelImpl(
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      json['results'] == null
          ? null
          : FitnessCenterReviewsResultsModel.fromJson(
            json['results'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$$FitnessCenterReviewsModelImplToJson(
  _$FitnessCenterReviewsModelImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$FitnessCenterReviewsResultsModelImpl
_$$FitnessCenterReviewsResultsModelImplFromJson(Map<String, dynamic> json) =>
    _$FitnessCenterReviewsResultsModelImpl(
      reviewCount: (json['review_count'] as num?)?.toInt(),
      avgRating: (json['avg_rating'] as num?)?.toInt(),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map(
                (e) => SingleFitnessCenterReviewModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );

Map<String, dynamic> _$$FitnessCenterReviewsResultsModelImplToJson(
  _$FitnessCenterReviewsResultsModelImpl instance,
) => <String, dynamic>{
  'review_count': instance.reviewCount,
  'avg_rating': instance.avgRating,
  'reviews': instance.reviews,
};

_$SingleFitnessCenterReviewModelImpl
_$$SingleFitnessCenterReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$SingleFitnessCenterReviewModelImpl(
      id: (json['id'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      created:
          json['created'] == null
              ? null
              : DateTime.parse(json['created'] as String),
      customerName: json['customer_name'] as String?,
      profilePicture: json['profile_picture'],
    );

Map<String, dynamic> _$$SingleFitnessCenterReviewModelImplToJson(
  _$SingleFitnessCenterReviewModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'created': instance.created?.toIso8601String(),
  'customer_name': instance.customerName,
  'profile_picture': instance.profilePicture,
};
