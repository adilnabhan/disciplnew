part of 'workout_cubit.dart';

@freezed
class WorkoutState with _$WorkoutState {
  const factory WorkoutState({
    required List<Map<String, dynamic>> exercises,
    required List<Map<String, String>> libraryExercises,
    required List<Map<String, String>> customExercises,
    @Default([]) List<MuscleGroupModel> muscleGroups,
    @Default([]) List<EquipmentModel> equipment,
    @Default([]) List<ExerciseTypeModel> exerciseTypes,
    @Default(false) bool isLoadingLookups,
    @Default(false) bool isCreatingExercise,
    @Default(false) bool isLoadingActiveSession,
    @Default('') String sessionTitle,
  }) = _WorkoutState;
}
