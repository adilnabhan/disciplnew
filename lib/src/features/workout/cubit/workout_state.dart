part of 'workout_cubit.dart';

@freezed
class WorkoutState with _$WorkoutState {
  const factory WorkoutState({
    required List<Map<String, dynamic>> exercises,
    required List<Map<String, String>> libraryExercises,
    required List<Map<String, String>> customExercises,
  }) = _WorkoutState;
}
