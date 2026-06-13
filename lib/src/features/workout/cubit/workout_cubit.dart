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
    loadCustomExercises();
    loadLookups();
  }

  Future<void> loadLookups() async {
    emit(state.copyWith(isLoadingLookups: true));
    final muscleResult = await WorkoutRepository().getMuscleGroups();
    final equipResult = await WorkoutRepository().getEquipment();
    final typeResult = await WorkoutRepository().getExerciseTypes();

    List<MuscleGroupModel> muscles = [];
    List<EquipmentModel> equipment = [];
    List<ExerciseTypeModel> types = [];

    muscleResult.fold((error) => null, (list) => muscles = list);
    equipResult.fold((error) => null, (list) => equipment = list);
    typeResult.fold((error) => null, (list) => types = list);

    emit(state.copyWith(
      muscleGroups: muscles,
      equipment: equipment,
      exerciseTypes: types,
      isLoadingLookups: false,
    ));
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

  Future<void> createCustomExercise({
    required String name,
    required int muscleGroupId,
    required int equipmentId,
    required String type,
    String? videoUrl,
    required void Function(bool success, String message) onComplete,
  }) async {
    emit(state.copyWith(isCreatingExercise: true));

    final body = <String, dynamic>{
      'name': name,
      'type': type,
      'primary_muscle_group': muscleGroupId,
      'equipment': equipmentId,
      'video_url': videoUrl ?? '',
    };

    final result = await WorkoutRepository().createCustomExercise(body: body);

    result.fold(
      (error) {
        emit(state.copyWith(isCreatingExercise: false));
        onComplete(false, error.msg ?? 'Failed to create exercise');
      },
      (newExercise) {
        final updatedCustom = List<Map<String, String>>.from(state.customExercises);
        final formattedSub = '${newExercise.muscleGroup ?? ''} / ${newExercise.equipment ?? ''} / ${newExercise.type ?? ''}';
        updatedCustom.add({
          'title': newExercise.name ?? '',
          'subtitle': formattedSub,
        });

        final updatedExercises = List<Map<String, dynamic>>.from(
          state.exercises.map((e) => Map<String, dynamic>.from(e)),
        );
        updatedExercises.add(<String, dynamic>{
          'title': newExercise.name ?? '',
          'subtitle': formattedSub,
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
          isCreatingExercise: false,
        ));
      },
    );

    if (result.isRight()) {
      onComplete(true, 'Exercise created successfully');
      await loadCustomExercises();
    }
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
    final isSearching = (search != null && search.trim().isNotEmpty) || (muscleGroup != null && muscleGroup.trim().isNotEmpty);

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
        if (isClosed) return;
        final mappedList = exercisesList.map((model) {
          return {
            'title': model.name ?? '',
            'subtitle': '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
          };
        }).toList();
        emit(state.copyWith(libraryExercises: mappedList));
      },
    );
  }

  Future<void> loadCustomExercises({String? search}) async {
    print('DEBUG: loadCustomExercises() called in WorkoutCubit with search: $search');
    final queryParams = <String, dynamic>{
      'custom_only': true,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await WorkoutRepository().getExerciseLibrary(
      queryParameters: queryParams,
    );

    response.fold(
      (error) {
        print('DEBUG: Error loading custom exercises: $error');
        debugPrint('Error loading custom exercises: ${error.msg}');
      },
      (exercisesList) {
        print('DEBUG: Successfully loaded ${exercisesList.length} custom exercises from API!');
        if (isClosed) return;
        final mappedList = exercisesList.map((model) {
          return {
            'title': model.name ?? '',
            'subtitle': '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
          };
        }).toList();
        emit(state.copyWith(customExercises: mappedList));
      },
    );
  }
}
