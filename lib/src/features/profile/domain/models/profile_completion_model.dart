import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
class ProfileCompletionModel {
  const ProfileCompletionModel({
    required this.completionPercentage,
    required this.isCompleted,
    required this.dismissed,
    required this.title,
    required this.message,
    required this.completedFields,
    required this.missingFields,
    required this.nextScreen,
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      completionPercentage:
          (json['completion_percentage'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      dismissed: json['dismissed'] as bool? ?? false,
      title: json['title'] as String? ?? 'Complete Your Profile',
      message:
          json['message'] as String? ??
          'Complete your profile to get personalized insights and a better fitness experience.',
      completedFields:
          (json['completed_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      missingFields:
          (json['missing_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nextScreen: json['next_screen'] as String? ?? 'profile',
    );
  }

  final int completionPercentage;
  final bool isCompleted;
  final bool dismissed;
  final String title;
  final String message;
  final List<String> completedFields;
  final List<String> missingFields;
  final String nextScreen;
}
