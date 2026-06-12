import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';

part 'workout_state.dart';
part 'workout_cubit.freezed.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit()
      : super(
          const WorkoutState(
            exercises: [],
            libraryExercises: [],
            customExercises: [],
          ),
        ) {
    loadLibraryExercises();
  }

  void addSet(int exerciseIndex) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final sets = List<Map<String, dynamic>>.from(
      updatedExercises[exerciseIndex]['sets'] as List,
    );
    final lastSet = sets.isNotEmpty ? sets.last : null;
    final newSetNum = sets.length + 1;

    sets.add(<String, dynamic>{
      'setNum': newSetNum,
      'previous': lastSet != null
          ? '${lastSet['kg']}kg×${lastSet['reps']}'
          : '10kg×15',
      'kg': lastSet != null ? lastSet['kg'] : '10',
      'reps': lastSet != null ? lastSet['reps'] : '15',
      'checked': false,
    });
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));
  }

  void addExercise(String title, String subtitle) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises.add(<String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'sets': <Map<String, dynamic>>[
        <String, dynamic>{
          'setNum': 1,
          'previous': '10kg×15',
          'kg': '10',
          'reps': '15',
          'checked': false,
        },
      ],
    });
    emit(state.copyWith(exercises: updatedExercises));
  }

  void createCustomExercise({
    required String name,
    required String muscle,
    required String equipment,
    required String type,
  }) {
    final newExercise = {
      'title': name,
      'subtitle': '$muscle / $equipment / $type',
    };
    final updatedCustom = List<Map<String, String>>.from(state.customExercises);
    updatedCustom.add(newExercise);

    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises.add(<String, dynamic>{
      'title': name,
      'subtitle': '$muscle / $equipment / $type',
      'sets': <Map<String, dynamic>>[
        <String, dynamic>{
          'setNum': 1,
          'previous': '10kg×15',
          'kg': '10',
          'reps': '15',
          'checked': false,
        },
      ],
    });

    emit(state.copyWith(
      customExercises: updatedCustom,
      exercises: updatedExercises,
    ));
  }

  void toggleSetChecked(int exerciseIndex, int setIndex) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final sets = List<Map<String, dynamic>>.from(
      updatedExercises[exerciseIndex]['sets'] as List,
    );
    final set = Map<String, dynamic>.from(sets[setIndex]);
    set['checked'] = !(set['checked'] as bool? ?? false);
    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));
  }

  void updateSetKg(int exerciseIndex, int setIndex, String val) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final sets = List<Map<String, dynamic>>.from(
      updatedExercises[exerciseIndex]['sets'] as List,
    );
    final set = Map<String, dynamic>.from(sets[setIndex]);
    set['kg'] = val;
    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));
  }

  void updateSetReps(int exerciseIndex, int setIndex, String val) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final sets = List<Map<String, dynamic>>.from(
      updatedExercises[exerciseIndex]['sets'] as List,
    );
    final set = Map<String, dynamic>.from(sets[setIndex]);
    set['reps'] = val;
    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));
  }

  Future<void> loadLibraryExercises({String? search, String? muscleGroup}) async {
    print('DEBUG: loadLibraryExercises() called in WorkoutCubit with search: $search, muscleGroup: $muscleGroup');
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (muscleGroup != null && muscleGroup.trim().isNotEmpty) {
      queryParams['muscle_group'] = muscleGroup.trim();
    }

    final response = await WorkoutRepository().getExerciseLibrary(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    response.fold(
      (error) {
        print('DEBUG: Error loading library exercises: $error');
        debugPrint('Error loading library exercises: ${error.msg}');
      },
      (exercisesList) {
        print('DEBUG: Successfully loaded ${exercisesList.length} exercises from API!');
        if (exercisesList.isEmpty) {
          print('DEBUG: API returned an empty list of exercises!');
        }
        final mappedList = exercisesList.map((model) {
          return {
            'title': model.name ?? '',
            'subtitle': '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
          };
        }).toList();
        if (isClosed) return;
        emit(state.copyWith(libraryExercises: mappedList));
      },
    );
  }
}
