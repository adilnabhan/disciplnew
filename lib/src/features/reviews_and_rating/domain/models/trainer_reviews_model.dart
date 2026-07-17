class TrainerReviewsModel {
  final int count;
  final String? next;
  final String? previous;
  final List<SingleTrainerReview> results;

  TrainerReviewsModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory TrainerReviewsModel.fromJson(Map<String, dynamic> json) {
    return TrainerReviewsModel(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List? ?? [])
          .map((e) => SingleTrainerReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SingleTrainerReview {
  final int id;
  final String customerName;
  final String? profilePicture;
  final int rating;
  final String comment;
  final DateTime createdAt;

  SingleTrainerReview({
    required this.id,
    required this.customerName,
    this.profilePicture,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory SingleTrainerReview.fromJson(Map<String, dynamic> json) {
    return SingleTrainerReview(
      id: json['id'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? 'Anonymous',
      profilePicture: json['profile_picture'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
