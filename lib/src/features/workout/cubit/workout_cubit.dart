import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';

part 'workout_state.dart';
part 'workout_cubit.freezed.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  List<Map<String, String>> _allLibraryExercises = [];
  List<Map<String, String>> _allCustomExercises = [];
  String? startedAt;
  final bool isPresetCreation;

  WorkoutCubit({
    bool startFresh = false,
    PresetModel? presetToStart,
    this.isPresetCreation = false,
  }) : super(
         const WorkoutState(
           exercises: [],
           libraryExercises: [],
           customExercises: [],
         ),
       ) {
    _init(startFresh, presetToStart);
  }

  Future<void> _init(bool startFresh, PresetModel? presetToStart) async {
    emit(state.copyWith(isLoadingActiveSession: true));
    try {
      await Future.wait([
        loadLibraryExercises(),
        loadCustomExercises(),
        loadLookups(),
      ]);
      if (isPresetCreation) {
        emit(state.copyWith(isLoadingActiveSession: false));
        return;
      }
      if (presetToStart != null) {
        await startPresetSession(presetToStart);
      } else if (startFresh) {
        await startNewSession();
      } else {
        await loadActiveSession(showLoader: true);
      }
    } catch (e) {
      print('DEBUG: Exception during WorkoutCubit _init: $e');
      emit(state.copyWith(isLoadingActiveSession: false));
    }
  }

  Future<void> startNewSession({String title = 'My Session'}) async {
    emit(
      state.copyWith(
        exercises: [],
        sessionTitle: title,
        isLoadingActiveSession: true,
      ),
    );
    try {
      // 1. Fetch active session first to see if one exists
      print('DEBUG: Fetching active session in startNewSession...');
      final activeRes = await WorkoutRepository().getActiveSession();
      int? activeSessionId;
      String activeTitle = 'My Session';

      activeRes.fold(
        (error) => print('DEBUG: getActiveSession returned error: $error'),
        (data) {
          print('DEBUG: getActiveSession returned data: $data');
          if (data != null && data is Map<String, dynamic>) {
            if (data['id'] != null) {
              activeSessionId = data['id'] as int;
              activeTitle =
                  data['title']?.toString() ??
                  data['name']?.toString() ??
                  'My Session';
            }
          }
        },
      );

      // 2. If there is an active session, finish it first!
      if (activeSessionId != null) {
        print(
          'DEBUG: Active session found (ID: $activeSessionId). Finishing it first...',
        );
        final finishRes = await WorkoutRepository().finishSession(
          sessionId: activeSessionId!,
          title: activeTitle,
        );
        
        bool finishSuccess = false;
        finishRes.fold(
          (error) {
            print('DEBUG: finishSession failed with error: $error');
          },
          (data) {
            print('DEBUG: finishSession succeeded with data: $data');
            finishSuccess = true;
          },
        );

        if (!finishSuccess) {
          print('DEBUG: Finishing failed (possibly 0 completed sets). Deleting/discarding active session...');
          final deleteRes = await WorkoutRepository().deleteActiveSession();
          deleteRes.fold(
            (error) => print('DEBUG: Failed to delete active session: $error'),
            (_) => print('DEBUG: Successfully deleted active session.'),
          );
        }
      }

      // 3. Now start a brand new session!
      print('DEBUG: Starting a brand new session with title: $title...');
      final result = await WorkoutRepository().startSession(title: title);
      result.fold(
        (error) {
          print('DEBUG: Error starting new session: $error');
          emit(state.copyWith(isLoadingActiveSession: false));
        },
        (data) {
          print(
            'DEBUG: Successfully started a new session! Response data: $data',
          );
          loadActiveSession();
        },
      );
    } catch (e) {
      print('DEBUG: Exception in startNewSession: $e');
      emit(state.copyWith(isLoadingActiveSession: false));
    }
  }

  Future<void> startPresetSession(PresetModel preset) async {
    emit(
      state.copyWith(
        exercises: [],
        sessionTitle: preset.title,
        isLoadingActiveSession: true,
      ),
    );
    try {
      // 1. Fetch active session first to see if one exists
      print('DEBUG: Fetching active session in startPresetSession...');
      final activeRes = await WorkoutRepository().getActiveSession();
      int? activeSessionId;
      String activeTitle = 'My Session';

      activeRes.fold(
        (error) => print('DEBUG: getActiveSession returned error: $error'),
        (data) {
          print('DEBUG: getActiveSession returned data: $data');
          if (data != null && data is Map<String, dynamic>) {
            if (data['id'] != null) {
              activeSessionId = data['id'] as int;
              activeTitle =
                  data['title']?.toString() ??
                  data['name']?.toString() ??
                  'My Session';
            }
          }
        },
      );

      // 2. If there is an active session, finish it first!
      if (activeSessionId != null) {
        print(
          'DEBUG: Active session found (ID: $activeSessionId). Finishing it first...',
        );
        final finishRes = await WorkoutRepository().finishSession(
          sessionId: activeSessionId!,
          title: activeTitle,
        );
        
        bool finishSuccess = false;
        finishRes.fold(
          (error) {
            print('DEBUG: finishSession failed with error: $error');
          },
          (data) {
            print('DEBUG: finishSession succeeded with data: $data');
            finishSuccess = true;
          },
        );

        if (!finishSuccess) {
          print('DEBUG: Finishing failed (possibly 0 completed sets). Deleting/discarding active session...');
          final deleteRes = await WorkoutRepository().deleteActiveSession();
          deleteRes.fold(
            (error) => print('DEBUG: Failed to delete active session: $error'),
            (_) => print('DEBUG: Successfully deleted active session.'),
          );
        }
      }

      // 3. Now start a brand new session!
      print('DEBUG: Starting preset session with title: ${preset.title} and ID: ${preset.id}...');
      final result = await WorkoutRepository().startSession(
        title: preset.title,
        presetId: preset.id,
      );

      await result.fold(
        (error) async {
          print('DEBUG: Error starting new preset session: $error');
          emit(state.copyWith(isLoadingActiveSession: false));
        },
        (data) async {
          print('DEBUG: Successfully started preset session on backend!');

          // 5. Reload active session from backend
          await loadActiveSession();

          emit(state.copyWith(isLoadingActiveSession: false));
        },
      );
    } catch (e) {
      print('DEBUG: Exception in startPresetSession: $e');
      emit(state.copyWith(isLoadingActiveSession: false));
    }
  }

  Future<Either<ApiException, dynamic>> finishSession({required String title}) async {
    await flushPendingUpdates();
    final activeRes = await WorkoutRepository().getActiveSession();
    int? activeSessionId;
    int? planDayId;
    activeRes.fold((error) => null, (data) {
      if (data != null && data is Map<String, dynamic>) {
        if (data['id'] != null) {
          activeSessionId = data['id'] as int;
        }
        if (data['plan_day'] != null) {
          planDayId = int.tryParse(data['plan_day'].toString());
        }
      }
    });

    if (activeSessionId != null) {
      final titleToUse = title.isNotEmpty ? title : 'My Workout Plan';

      if (planDayId != null && title.isNotEmpty) {
        final presetsRes = await WorkoutRepository().getPresets();
        await presetsRes.fold((error) async {}, (presetsList) async {
          int? foundPlanId;
          final checkLimit = presetsList.length > 5 ? 5 : presetsList.length;
          final futures = <Future<void>>[];
          for (int i = 0; i < checkLimit; i++) {
            final preset = presetsList[i];
            futures.add(
              WorkoutRepository().getPresetDetail(preset.id).then((detailRes) {
                detailRes.fold((err) {}, (detail) {
                  final days = detail['days'] as List? ?? [];
                  for (final d in days) {
                    if (d['id'] == planDayId) {
                      foundPlanId = preset.id;
                    }
                  }
                });
              }),
            );
          }
          await Future.wait(futures);
          if (foundPlanId != null) {
            await WorkoutRepository().updatePlanName(
              planId: foundPlanId!,
              newName: titleToUse,
            );
          }
        });
      }

      final result = await WorkoutRepository().finishSession(
        sessionId: activeSessionId!,
        title: titleToUse,
      );
      return result.fold(
        (error) {
          print('DEBUG: Error finishing session: $error');
          return left(error);
        },
        (data) {
          print('DEBUG: Successfully finished session!');
          final dateStr = startedAt;
          if (dateStr != null) {
            try {
              final date = DateTime.parse(dateStr);
              WorkoutRepository().invalidateCalendarMonth(date.year, date.month);
            } catch (_) {
              final now = DateTime.now();
              WorkoutRepository().invalidateCalendarMonth(now.year, now.month);
            }
          } else {
            final now = DateTime.now();
            WorkoutRepository().invalidateCalendarMonth(now.year, now.month);
          }
          final Map<String, dynamic> responseMap = data is Map<String, dynamic>
              ? Map<String, dynamic>.from(data)
              : <String, dynamic>{};
          responseMap['id'] ??= activeSessionId;
          responseMap['session_id'] ??= activeSessionId;
          emit(state.copyWith(exercises: [], sessionTitle: ''));
          return right(responseMap);
        },
      );
    }
    return left(const ApiException.unknown());
  }

  Future<void> saveDraftSession(String title) async {
    await flushPendingUpdates();
    if (title.isNotEmpty) {
      await updateSessionTitle(title);
    }
  }

  Future<void> discardSession() async {
    emit(state.copyWith(exercises: [], sessionTitle: ''));
    final res = await WorkoutRepository().deleteActiveSession();
    res.fold((error) => print('DEBUG: Error deleting active session: $error'), (
      _,
    ) {
      print('DEBUG: Successfully deleted active session.');
    });
  }

  Future<void> loadLookups() async {
    emit(state.copyWith(isLoadingLookups: true));
    final muscleResult = await WorkoutRepository().getMuscleGroups();
    final equipResult = await WorkoutRepository().getEquipment();
    final typeResult = await WorkoutRepository().getExerciseTypes();

    List<MuscleGroupModel> muscles = List<MuscleGroupModel>.from(state.muscleGroups);
    List<EquipmentModel> equipment = List<EquipmentModel>.from(state.equipment);
    List<ExerciseTypeModel> types = List<ExerciseTypeModel>.from(state.exerciseTypes);

    muscleResult.fold(
      (error) => null,
      (list) {
        final merged = List<MuscleGroupModel>.from(list);
        for (final m in state.muscleGroups) {
          if (!merged.any((item) => item.id == m.id)) {
            merged.add(m);
          }
        }
        muscles = merged;
      },
    );

    equipResult.fold(
      (error) => null,
      (list) {
        final merged = List<EquipmentModel>.from(list);
        for (final e in state.equipment) {
          if (!merged.any((item) => item.id == e.id)) {
            merged.add(e);
          }
        }
        equipment = merged;
      },
    );

    typeResult.fold(
      (error) => null,
      (list) {
        final merged = List<ExerciseTypeModel>.from(list);
        for (final t in state.exerciseTypes) {
          if (!merged.any((item) => item.id == t.id)) {
            merged.add(t);
          }
        }
        types = merged;
      },
    );

    emit(
      state.copyWith(
        muscleGroups: muscles,
        equipment: equipment,
        exerciseTypes: types,
        isLoadingLookups: false,
      ),
    );
  }

  Future<void> addSet(int exerciseIndex) async {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;

    if (isPresetCreation) {
      final updatedExercises = List<Map<String, dynamic>>.from(
        state.exercises.map((e) => Map<String, dynamic>.from(e)),
      );
      final exercise = updatedExercises[exerciseIndex];
      final sets = List<Map<String, dynamic>>.from(exercise['sets'] as List? ?? []);
      final lastSet = sets.isNotEmpty ? sets.last : null;

      final reps = lastSet != null ? lastSet['reps']?.toString() ?? '' : '';
      final weight = lastSet != null ? lastSet['kg']?.toString() ?? '' : '';

      sets.add({
        'setNum': sets.length + 1,
        'previous': 'no data',
        'kg': weight,
        'reps': reps,
        'checked': false,
      });
      exercise['sets'] = sets;
      emit(state.copyWith(exercises: updatedExercises));
      return;
    }

    final exercise = state.exercises[exerciseIndex];
    final logIdStr = exercise['workout_log_id']?.toString() ?? exercise['id']?.toString();
    final logId = int.tryParse(logIdStr ?? '');

    if (logId != null) {
      final sets = List<Map<String, dynamic>>.from(exercise['sets'] as List? ?? []);
      final lastSet = sets.isNotEmpty ? sets.last : null;

      final reps = lastSet != null
          ? int.tryParse(lastSet['reps']?.toString() ?? '') ?? 0
          : 0;
      final weight = lastSet != null
          ? double.tryParse(lastSet['kg']?.toString() ?? '') ?? 0.0
          : 0.0;

      final result = await WorkoutRepository()
          .addSetToExerciseLog(logId: logId, reps: reps, weightKg: weight);
      await result.fold(
        (error) async {
          print('DEBUG: Error adding set to backend: $error');
          await loadActiveSession();
        },
        (successData) async {
          print('DEBUG: Successfully added set to backend: $successData');
          await loadActiveSession();
        },
      );
    }
  }

  Future<void> updateWorkoutLogWeightType(int exerciseIndex, String weightType) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final exercise = updatedExercises[exerciseIndex];
    exercise['weight_type'] = weightType;
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final logIdStr = exercise['workout_log_id']?.toString() ?? exercise['id']?.toString();
    final logId = int.tryParse(logIdStr ?? '');
    if (logId != null) {
      final result = await WorkoutRepository().updateWorkoutLogWeightType(
        logId: logId,
        weightType: weightType,
      );
      result.fold(
        (error) => print('DEBUG: Error updating workout log weight type: $error'),
        (success) => print('DEBUG: Successfully updated workout log weight type'),
      );
    }
  }

  Future<void> addExercise({
    required int id,
    required String title,
    required String subtitle,
    String? videoUrl,
  }) async {
    if (isPresetCreation) {
      final updatedExercises = List<Map<String, dynamic>>.from(
        state.exercises.map((e) => Map<String, dynamic>.from(e)),
      );
      updatedExercises.add({
        'id': id.toString(),
        'title': title,
        'subtitle': subtitle,
        'video_url': videoUrl ?? '',
        'sets': [
          {
            'setNum': 1,
            'previous': 'no data',
            'kg': '',
            'reps': '',
            'checked': false,
          }
        ],
      });
      emit(state.copyWith(exercises: updatedExercises));
      return;
    }

    final result = await WorkoutRepository().addExercisesToActiveSession(
      workoutIds: [id],
    );
    result.fold(
      (error) {
        print('DEBUG: Error adding exercise to active session: $error');
        loadActiveSession();
      },
      (successData) {
        print(
          'DEBUG: Successfully added exercise to active session on backend!',
        );
        loadActiveSession();
      },
    );
  }

  void swapExercises(int indexA, int indexB) {
    if (indexA < 0 || indexA >= state.exercises.length) return;
    if (indexB < 0 || indexB >= state.exercises.length) return;

    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final temp = updatedExercises[indexA];
    updatedExercises[indexA] = updatedExercises[indexB];
    updatedExercises[indexB] = temp;
    emit(state.copyWith(exercises: updatedExercises));
  }

  Future<void> deleteExercise(int exerciseIndex) async {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;

    final exercise = state.exercises[exerciseIndex];

    // Perform optimistic local removal first so the UI updates instantly
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises.removeAt(exerciseIndex);
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final logIdStr = exercise['workout_log_id']?.toString() ?? exercise['id']?.toString();
    final logId = int.tryParse(logIdStr ?? '');
    if (logId != null) {
      final res = await WorkoutRepository().deleteWorkoutLog(logId: logId);
      res.fold(
        (error) {
          print('DEBUG: Error deleting workout log $logId: $error');
          loadActiveSession();
        },
        (_) {
          print('DEBUG: Successfully deleted workout log $logId');
          loadActiveSession();
        },
      );
    }
  }

  Future<void> createCustomExercise({
    required String name,
    required int muscleGroupId,
    required int equipmentId,
    required String type,
    String? trackBy,
    String? videoUrl,
    List<int>? secondaryMuscleGroupIds,
    required void Function(bool success, String message) onComplete,
  }) async {
    emit(state.copyWith(isCreatingExercise: true));

    final body = <String, dynamic>{
      'name': name,
      'type': type,
      'primary_muscle_group': muscleGroupId,
      'equipment': equipmentId,
      'video_url': videoUrl ?? '',
      'track_by': trackBy ?? 'rep',
      if (secondaryMuscleGroupIds != null && secondaryMuscleGroupIds.isNotEmpty)
        'secondary_muscle_groups': secondaryMuscleGroupIds,
    };

    final result = await WorkoutRepository().createCustomExercise(body: body);

    result.fold(
      (error) {
        emit(state.copyWith(isCreatingExercise: false));
        onComplete(false, error.msg ?? 'Failed to create exercise');
      },
      (newExercise) {
        final updatedCustom = List<Map<String, String>>.from(
          state.customExercises,
        );
        final formattedSub =
            '${newExercise.muscleGroup ?? ''} / ${newExercise.equipment ?? ''} / ${newExercise.type ?? ''}';
        updatedCustom.add({
          'id': (newExercise.id ?? '').toString(),
          'title': newExercise.name ?? '',
          'subtitle': formattedSub,
          'track_by': newExercise.trackBy ?? 'rep',
        });

        emit(
          state.copyWith(
            customExercises: updatedCustom,
            isCreatingExercise: false,
          ),
        );

        if (newExercise.id != null) {
          addExercise(
            id: newExercise.id!,
            title: newExercise.name ?? '',
            subtitle: formattedSub,
            videoUrl: newExercise.videoUrl?.toString(),
          );
        }
      },
    );

    if (result.isRight()) {
      onComplete(true, 'Exercise created successfully');
      await loadCustomExercises();
    }
  }

  final Map<int, Timer> _updateDebouncers = {};

  void _debounceSetUpdate(int setLogId) {
    _updateDebouncers[setLogId]?.cancel();
    _updateDebouncers[setLogId] = Timer(const Duration(milliseconds: 800), () {
      _updateDebouncers.remove(setLogId);
      _performSetUpdate(setLogId);
    });
  }

  Future<void> _performSetUpdate(int setLogId) async {
    Map<String, dynamic>? currentSet;
    for (final exercise in state.exercises) {
      final sets = exercise['sets'] as List?;
      if (sets != null) {
        for (final s in sets) {
          if (s is Map<String, dynamic> && s['id'] == setLogId) {
            currentSet = s;
            break;
          }
        }
      }
      if (currentSet != null) break;
    }

    if (currentSet != null) {
      final reps = double.tryParse(currentSet['reps']?.toString() ?? '')?.round();
      final weightKg = double.tryParse(currentSet['kg']?.toString() ?? '');
      final isCompleted = currentSet['checked'] as bool?;

      final result = await WorkoutRepository().updateSetLog(
        setLogId: setLogId,
        reps: reps,
        weightKg: weightKg,
        isCompleted: isCompleted,
      );
      result.fold(
        (error) => print('DEBUG: Error updating set $setLogId: $error'),
        (success) => print(
          'DEBUG: Successfully updated set $setLogId on backend',
        ),
      );
    }
  }

  Future<void> flushPendingUpdates() async {
    if (_updateDebouncers.isEmpty) return;
    final ids = List<int>.from(_updateDebouncers.keys);
    for (final timer in _updateDebouncers.values) {
      timer.cancel();
    }
    _updateDebouncers.clear();

    final futures = ids.map((id) => _performSetUpdate(id));
    await Future.wait(futures);
  }

  Future<void> toggleSetChecked(int exerciseIndex, int setIndex, {void Function(String errorMessage)? onError}) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final sets = List<Map<String, dynamic>>.from(
      updatedExercises[exerciseIndex]['sets'] as List,
    );
    final set = Map<String, dynamic>.from(sets[setIndex]);
    final newChecked = !(set['checked'] as bool? ?? false);
    set['checked'] = newChecked;
    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final setLogId = set['id'] as int?;
    if (setLogId != null) {
      _updateDebouncers[setLogId]?.cancel();
      _updateDebouncers.remove(setLogId);

      final reps = double.tryParse(set['reps']?.toString() ?? '')?.round();
      final weightKg = double.tryParse(set['kg']?.toString() ?? '');
      final result = await WorkoutRepository().updateSetLog(
        setLogId: setLogId,
        reps: reps,
        weightKg: weightKg,
        isCompleted: newChecked,
      );
      result.fold(
        (error) {
          print('DEBUG: Error updating set checked state: $error');
          // Optimistic Rollback
          final rollbackExercises = List<Map<String, dynamic>>.from(
            state.exercises.map((e) => Map<String, dynamic>.from(e)),
          );
          if (exerciseIndex >= 0 && exerciseIndex < rollbackExercises.length) {
            final rSets = List<Map<String, dynamic>>.from(
              rollbackExercises[exerciseIndex]['sets'] as List,
            );
            if (setIndex >= 0 && setIndex < rSets.length) {
              final rSet = Map<String, dynamic>.from(rSets[setIndex]);
              rSet['checked'] = !newChecked;
              rSets[setIndex] = rSet;
              rollbackExercises[exerciseIndex]['sets'] = rSets;
              emit(state.copyWith(exercises: rollbackExercises));
            }
          }
          if (onError != null) {
            onError(error.msg);
          }
        },
        (success) {
          print('DEBUG: Successfully updated set checked state to $newChecked');
        },
      );
    }
  }

  Future<void> deleteSet(int exerciseIndex, int setIndex) async {
    final exercise = state.exercises[exerciseIndex];
    final sets = List<Map<String, dynamic>>.from(exercise['sets'] as List? ?? []);
    if (setIndex < 0 || setIndex >= sets.length) return;

    final setLog = sets[setIndex];

    // Perform optimistic local removal first so the UI updates instantly
    sets.removeAt(setIndex);
    // Reorder set numbers
    for (int i = 0; i < sets.length; i++) {
      sets[i]['setNum'] = i + 1;
    }
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final setLogId = setLog['id'] as int?;
    if (setLogId != null) {
      final res = await WorkoutRepository().deleteSetLog(setLogId: setLogId);
      res.fold(
        (error) {
          print('DEBUG: Error deleting set log $setLogId: $error');
          loadActiveSession();
        },
        (_) {
          print('DEBUG: Successfully deleted set log $setLogId');
          loadActiveSession();
        },
      );
    }
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

    // Check if the weight is invalid, if so, automatically uncheck
    final kgVal = double.tryParse(val.trim()) ?? 0.0;
    if (val.trim().isEmpty || kgVal < 0.0) {
      set['checked'] = false;
    }

    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final setLogId = set['id'] as int?;
    if (setLogId != null) {
      _debounceSetUpdate(setLogId);
    }
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

    // Check if the reps are invalid, if so, automatically uncheck
    final repsVal = double.tryParse(val.trim()) ?? 0.0;
    if (val.trim().isEmpty || repsVal < 0.0) {
      set['checked'] = false;
    }

    sets[setIndex] = set;
    updatedExercises[exerciseIndex]['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));

    if (isPresetCreation) return;

    final setLogId = set['id'] as int?;
    if (setLogId != null) {
      _debounceSetUpdate(setLogId);
    }
  }

  @override
  Future<void> close() {
    for (final timer in _updateDebouncers.values) {
      timer.cancel();
    }
    _updateDebouncers.clear();
    return super.close();
  }

  Future<void> loadLibraryExercises({
    String? search,
    String? muscleGroup,
  }) async {
    print(
      'DEBUG: loadLibraryExercises() called in WorkoutCubit with search: $search, muscleGroup: $muscleGroup',
    );
    final queryParams = <String, dynamic>{};
    final isSearching =
        (search != null && search.trim().isNotEmpty) ||
        (muscleGroup != null && muscleGroup.trim().isNotEmpty);

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
        print(
          'DEBUG: Successfully loaded ${exercisesList.length} exercises from API!',
        );
        final mappedList =
            exercisesList.map((model) {
              return {
                'id': (model.id ?? '').toString(),
                'title': model.name ?? '',
                'subtitle':
                    '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
                'video_url': model.videoUrl?.toString() ?? '',
                'track_by': model.trackBy ?? 'rep',
              };
            }).toList();
        if (!isSearching) {
          _allLibraryExercises = mappedList;
        }
        emit(state.copyWith(libraryExercises: mappedList));
      },
    );
  }

  Future<void> loadCustomExercises({String? search}) async {
    print(
      'DEBUG: loadCustomExercises() called in WorkoutCubit with search: $search',
    );
    final queryParams = <String, dynamic>{'custom_only': true};

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
        print(
          'DEBUG: Successfully loaded ${exercisesList.length} custom exercises from API!',
        );
        final mappedList =
            exercisesList.map((model) {
              return {
                'id': (model.id ?? '').toString(),
                'title': model.name ?? '',
                'subtitle':
                    '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
                'video_url': model.videoUrl?.toString() ?? '',
                'track_by': model.trackBy ?? 'rep',
              };
            }).toList();
        final isSearching = search != null && search.trim().isNotEmpty;
        if (!isSearching) {
          _allCustomExercises = mappedList;
        }
        emit(state.copyWith(customExercises: mappedList));
      },
    );
  }

  Future<void> loadActiveSession({bool showLoader = false}) async {
    print('DEBUG: loadActiveSession() called in WorkoutCubit');
    if (showLoader) {
      emit(state.copyWith(isLoadingActiveSession: true));
    }
    final response = await WorkoutRepository().getActiveSession();
    response.fold(
      (error) {
        print('DEBUG: Error loading active session: $error');
        debugPrint('Error loading active session: ${error.msg}');
        if (!isClosed) {
          emit(state.copyWith(isLoadingActiveSession: false));
        }
      },
      (data) {
        print('DEBUG: Successfully loaded active session data from API!');
        if (isClosed) return;
        if (data is Map<String, dynamic>) {
          startedAt = data['started_at']?.toString();
        }
        final parsedExercises = _parseActiveSessionExercises(data);
        String title = '';
        if (data is Map<String, dynamic>) {
          title =
              data['plan_name']?.toString() ??
              data['plan_day_title']?.toString() ??
              data['title']?.toString() ??
              data['name']?.toString() ??
              '';
        }
        final finalTitle =
            (title.isNotEmpty && title != 'My Session')
                ? title
                : (state.sessionTitle.isNotEmpty
                    ? state.sessionTitle
                    : (title.isNotEmpty ? title : 'My Session'));
        emit(
          state.copyWith(
            exercises: parsedExercises,
            sessionTitle: finalTitle,
            isLoadingActiveSession: false,
          ),
        );
      },
    );
  }

  Future<void> updateSessionTitle(String title) async {
    if (isClosed) return;
    emit(state.copyWith(sessionTitle: title));

    print('DEBUG: Calling startSession API with title: $title');
    final result = await WorkoutRepository().startSession(title: title);
    result.fold(
      (error) {
        print('DEBUG: Error starting/updating session title: $error');
      },
      (data) {
        print('DEBUG: Successfully updated/started session with title: $title');
      },
    );
  }

  List<Map<String, dynamic>> _parseActiveSessionExercises(dynamic data) {
    final List<Map<String, dynamic>> result = [];

    void extractExercise(Map<String, dynamic> item) {
      String? title;
      String? subtitle;
      int? exerciseId;
      String? videoUrl;
      String? resolvedTrackBy;

      String? rawMuscle;
      String? rawEquip;
      String? rawType;

      if (item['workout'] is Map<String, dynamic>) {
        final workout = item['workout'] as Map<String, dynamic>;
        title = workout['name'] as String?;
        exerciseId = workout['id'] as int?;
        rawMuscle =
            workout['primary_muscle_group_name'] as String? ??
            workout['muscle_group'] as String?;
        rawEquip =
            workout['equipment_name'] as String? ??
            workout['equipment'] as String?;
        rawType = workout['type'] as String?;
        videoUrl = workout['video_url']?.toString();
        resolvedTrackBy = workout['track_by'] as String?;
      } else if (item['exercise'] is Map<String, dynamic>) {
        final exercise = item['exercise'] as Map<String, dynamic>;
        title = exercise['name'] as String?;
        exerciseId = exercise['id'] as int?;
        rawMuscle =
            exercise['primary_muscle_group_name'] as String? ??
            exercise['muscle_group'] as String?;
        rawEquip =
            exercise['equipment_name'] as String? ??
            exercise['equipment'] as String?;
        rawType = exercise['type'] as String?;
        videoUrl = exercise['video_url']?.toString();
        resolvedTrackBy = exercise['track_by'] as String?;
      } else {
        title =
            item['workout_name']?.toString() ??
            item['name']?.toString() ??
            item['title']?.toString();
        exerciseId =
            item['id'] as int? ??
            item['plan_exercise'] as int? ??
            item['workout_id'] as int?;
        rawMuscle =
            item['muscle']?.toString() ??
            item['primary_muscle_group_name']?.toString() ??
            item['muscle_group']?.toString();
        rawEquip =
            item['equipment_name']?.toString() ?? item['equipment']?.toString();
        rawType = item['type']?.toString();
        videoUrl = item['video_url']?.toString();
        resolvedTrackBy = item['track_by']?.toString();
      }

      if (title == null || title.isEmpty) return;

      // Resolve muscle, equipment, type using library/custom exercises lookups if needed
      String? resolvedMuscle = rawMuscle;
      String? resolvedEquip = rawEquip;
      String? resolvedType = rawType;

      if (exerciseId != null) {
        final idStr = exerciseId.toString();
        Map<String, String>? foundEx;
        for (final ex in _allLibraryExercises) {
          if (ex['id'] == idStr) {
            foundEx = ex;
            break;
          }
        }
        if (foundEx == null) {
          for (final ex in _allCustomExercises) {
            if (ex['id'] == idStr) {
              foundEx = ex;
              break;
            }
          }
        }
        if (foundEx != null) {
          if (foundEx['subtitle'] != null) {
            final parts = foundEx['subtitle']!.split('/');
            if (parts.length >= 3) {
              resolvedMuscle = parts[0].trim();
              resolvedEquip = parts[1].trim();
              resolvedType = parts[2].trim();
            }
          }
          if (resolvedTrackBy == null || resolvedTrackBy.isEmpty) {
            resolvedTrackBy = foundEx['track_by'];
          }
        }
      }

      if (resolvedType == null && title.isNotEmpty) {
        final nameLower = title.toLowerCase().trim();
        Map<String, String>? foundEx;
        for (final ex in _allLibraryExercises) {
          if (ex['title']?.toLowerCase().trim() == nameLower) {
            foundEx = ex;
            break;
          }
        }
        if (foundEx == null) {
          for (final ex in _allCustomExercises) {
            if (ex['title']?.toLowerCase().trim() == nameLower) {
              foundEx = ex;
              break;
            }
          }
        }
        if (foundEx != null) {
          if (foundEx['subtitle'] != null) {
            final parts = foundEx['subtitle']!.split('/');
            if (parts.length >= 3) {
              resolvedMuscle = parts[0].trim();
              resolvedEquip = parts[1].trim();
              resolvedType = parts[2].trim();
            }
          }
          if (resolvedTrackBy == null || resolvedTrackBy.isEmpty) {
            resolvedTrackBy = foundEx['track_by'];
          }
        }
      }

      final List<String> subtitleParts = [];
      if (resolvedMuscle != null && resolvedMuscle.isNotEmpty)
        subtitleParts.add(resolvedMuscle);
      if (resolvedEquip != null && resolvedEquip.isNotEmpty)
        subtitleParts.add(resolvedEquip);
      if (resolvedType != null && resolvedType.isNotEmpty)
        subtitleParts.add(resolvedType);

      if (subtitleParts.isNotEmpty) {
        subtitle = subtitleParts.join(' / ');
      } else {
        subtitle = item['subtitle']?.toString() ?? '';
      }

      if (title == null || title.isEmpty) return;

      final List<Map<String, dynamic>> sets = [];
      final rawSets = item['set_logs'] ?? item['sets'];
      if (rawSets is List) {
        for (var i = 0; i < rawSets.length; i++) {
          final s = rawSets[i];
          if (s is Map<String, dynamic>) {
            final targetWeight = s['target_weight'] ?? s['targetWeight'];
            final targetReps = s['target_reps'] ?? s['targetReps'];
            final rawKg = s['weight_kg'] ?? s['weight'] ?? s['kg'] ?? targetWeight;
            final rawReps = s['reps'] ?? targetReps;

            String kgVal = '';
            if (rawKg != null) {
              final val = double.tryParse(rawKg.toString());
              if (val != null && val != 0.0) {
                kgVal = val == val.truncateToDouble() ? val.toInt().toString() : val.toString();
              }
            }

            String repsVal = '';
            if (rawReps != null) {
              final val = int.tryParse(rawReps.toString());
              if (val != null && val != 0) {
                repsVal = val.toString();
              }
            }

            final prevRaw = s['previous'];
            final prevWeightRaw = s['previous_weight_kg'];
            String prevStr;
            if (prevRaw != null && prevRaw.toString().isNotEmpty && prevRaw.toString() != 'no data') {
              // Backend returned formatted string like '80kgX10'
              prevStr = prevRaw.toString();
            } else if (prevWeightRaw != null) {
              // Fallback: only weight available — format as '{weight}kg'
              final w = double.tryParse(prevWeightRaw.toString());
              if (w != null) {
                final wStr = w == w.truncateToDouble() ? w.toInt().toString() : w.toString();
                prevStr = '${wStr}kg';
              } else {
                prevStr = 'no data';
              }
            } else {
              prevStr = 'no data';
            }
            sets.add({
              'id': s['id'],
              'setNum':
                  s['set_number'] ?? s['set_num'] ?? s['setNum'] ?? (i + 1),
              'previous': prevStr,
              'kg': kgVal,
              'reps': repsVal,
              'checked': s['is_completed'] ?? s['checked'] ?? false,
            });
          }
        }
      }

      sets.sort((a, b) {
        final aNum = int.tryParse(a['setNum']?.toString() ?? '') ?? 0;
        final bNum = int.tryParse(b['setNum']?.toString() ?? '') ?? 0;
        return aNum.compareTo(bNum);
      });

      if (sets.isEmpty) {
        sets.add({
          'setNum': 1,
          'previous': 'no data',
          'kg': '10',
          'reps': '15',
          'checked': false,
        });
      }

      result.add({
        'id': exerciseId?.toString() ?? '',
        'workout_log_id': item['id']?.toString() ?? '',
        'title': title,
        'subtitle': subtitle ?? '',
        'video_url': videoUrl ?? '',
        'track_by': resolvedTrackBy ?? 'rep',
        'weight_type': () {
          final type = item['weight_type']?.toString();
          if (type == null) return 'kg';
          if (type.toLowerCase() == 'bw') return 'BW';
          if (type.toLowerCase() == 'kg+bw') return 'kg+BW';
          return type;
        }(),
        'sets': sets,
      });
    }

    if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          extractExercise(item);
        }
      }
    } else if (data is Map<String, dynamic>) {
      final exercisesData =
          data['logs'] ??
          data['exercises'] ??
          data['session_exercises'] ??
          data['results'];
      if (exercisesData is List) {
        for (var item in exercisesData) {
          if (item is Map<String, dynamic>) {
            extractExercise(item);
          }
        }
      }
    }

    return result;
  }

  void loadPreset(PresetModel preset) {
    final List<Map<String, dynamic>> exercises =
        preset.exercises.map((ex) {
          final List<Map<String, dynamic>> sets =
              ex.sets
                  .map(
                    (s) => {
                      'setNum': s.setNumber,
                      'previous': 'no data',
                      'kg': s.weight.toString(),
                      'reps': s.reps.toString(),
                      'checked': false,
                    },
                  )
                  .toList();
          return {
            'id': ex.workoutId.toString(),
            'title': ex.name,
            'subtitle': ex.muscleGroup,
            'sets': sets,
          };
        }).toList();
    emit(state.copyWith(exercises: exercises, sessionTitle: preset.title));
  }

  void addMuscleGroup(MuscleGroupModel item) {
    final updated = List<MuscleGroupModel>.from(state.muscleGroups);
    if (!updated.any((m) => m.id == item.id)) {
      updated.add(item);
      emit(state.copyWith(muscleGroups: updated));
    }
  }

  void addEquipment(EquipmentModel item) {
    final updated = List<EquipmentModel>.from(state.equipment);
    if (!updated.any((e) => e.id == item.id)) {
      updated.add(item);
      emit(state.copyWith(equipment: updated));
    }
  }

  void addExerciseType(ExerciseTypeModel item) {
    final updated = List<ExerciseTypeModel>.from(state.exerciseTypes);
    if (!updated.any((t) => t.id == item.id)) {
      updated.add(item);
      emit(state.copyWith(exerciseTypes: updated));
    }
  }
}
