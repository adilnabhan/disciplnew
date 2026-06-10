class WorkoutModel {
  final int day;
  final String title;
  final int exerciseCount;
  final bool isCompleted;
  final bool isActive;

  const WorkoutModel({
    required this.day,
    required this.title,
    required this.exerciseCount,
    required this.isCompleted,
    required this.isActive,
  });
}
