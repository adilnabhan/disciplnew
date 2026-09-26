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
        loadMuscleClassification(),
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
          print(
            'DEBUG: Finishing failed (possibly 0 completed sets). Deleting/discarding active session...',
          );
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
          int? sessionId;
          int? planDayId;
          if (data is Map<String, dynamic>) {
            if (data['id'] != null) {
              sessionId = data['id'] as int;
            }
            if (data['plan_day'] != null) {
              planDayId = int.tryParse(data['plan_day'].toString());
            }
          }
          emit(state.copyWith(sessionId: sessionId, planDayId: planDayId));
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
          print(
            'DEBUG: Finishing failed (possibly 0 completed sets). Deleting/discarding active session...',
          );
          final deleteRes = await WorkoutRepository().deleteActiveSession();
          deleteRes.fold(
            (error) => print('DEBUG: Failed to delete active session: $error'),
            (_) => print('DEBUG: Successfully deleted active session.'),
          );
        }
      }

      // 3. Now start a brand new session!
      print(
        'DEBUG: Starting preset session with title: ${preset.title} and ID: ${preset.id}...',
      );
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
          int? sessionId;
          int? planDayId;
          if (data is Map<String, dynamic>) {
            if (data['id'] != null) {
              sessionId = data['id'] as int;
            }
            if (data['plan_day'] != null) {
              planDayId = int.tryParse(data['plan_day'].toString());
            }
          }
          emit(state.copyWith(sessionId: sessionId, planDayId: planDayId));

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

  Map<String, dynamic> _buildSessionPayload(String title, {String? status}) {
    final List<Map<String, dynamic>> logsList = [];
    for (int i = 0; i < state.exercises.length; i++) {
      final ex = state.exercises[i];
      final logId = int.tryParse(ex['workout_log_id']?.toString() ?? '');
      final workoutId = int.tryParse(ex['id']?.toString() ?? '');

      final trackBy = (ex['track_by']?.toString() ?? 'rep').toLowerCase();
      final inputType =
          (trackBy == 'time' ||
                  trackBy == 'sec' ||
                  trackBy == 'secs' ||
                  trackBy == 'seconds')
              ? 'time'
              : ((trackBy == 'distance' ||
                      trackBy == 'dist' ||
                      trackBy == 'km' ||
                      trackBy == 'm')
                  ? 'distance'
                  : 'rep');

      final List<Map<String, dynamic>> setLogsList = [];
      final sets = ex['sets'] as List? ?? [];
      for (int j = 0; j < sets.length; j++) {
        final s = sets[j];
        final setId = int.tryParse(s['id']?.toString() ?? '');
        final setNum = int.tryParse(s['setNum']?.toString() ?? '') ?? (j + 1);
        final isCompleted = s['checked'] as bool? ?? false;

        final valStr = s['reps']?.toString() ?? s['value']?.toString() ?? '';
        final doubleVal = double.tryParse(valStr);
        final weightKg = double.tryParse(s['kg']?.toString() ?? '') ?? 0.0;

        final Map<String, dynamic> setLog = {
          if (setId != null) 'id': setId,
          'set_number': setNum,
          'weight_kg': weightKg,
          'is_completed': isCompleted,
          'input_type': inputType,
        };

        if (inputType == 'time') {
          setLog['duration'] = doubleVal;
        } else if (inputType == 'distance') {
          setLog['distance'] = doubleVal;
        } else {
          setLog['reps'] = doubleVal?.round();
        }

        setLogsList.add(setLog);
      }

      final Map<String, dynamic> exLog = {
        if (logId != null) 'id': logId,
        'workout_id': workoutId,
        'order_index': i,
        'weight_type': ex['weight_type'] ?? 'KG',
        'input_type': inputType,
        'notes': ex['notes'],
        'set_logs': setLogsList,
      };
      logsList.add(exLog);
    }

    return {
      'title': title,
      if (status != null) 'status': status,
      'logs': logsList,
    };
  }

  Future<Either<ApiException, dynamic>> finishSession({
    required String title,
  }) async {
    final activeSessionId = state.sessionId;
    final planDayId = state.planDayId;

    if (activeSessionId == null) {
      return left(
        const ApiException.unknown(msg: 'No active session found to finish'),
      );
    }

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

    final payload = _buildSessionPayload(titleToUse, status: 'completed');

    final result = await WorkoutRepository().finishSession(
      sessionId: activeSessionId,
      title: titleToUse,
      payload: payload,
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
        emit(
          state.copyWith(
            exercises: [],
            sessionTitle: '',
            sessionId: null,
            planDayId: null,
          ),
        );
        final Map<String, dynamic> responseMap =
            data is Map<String, dynamic>
                ? Map<String, dynamic>.from(data)
                : <String, dynamic>{};
        responseMap['id'] ??= activeSessionId;
        responseMap['session_id'] ??= activeSessionId;
        return right(responseMap);
      },
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> saveDraftSession(
    String title,
  ) async {
    final activeSessionId = state.sessionId;

    if (activeSessionId == null) {
      return left(
        const ApiException.unknown(
          msg: 'No active session found to save draft',
        ),
      );
    }

    final titleToUse = title.isNotEmpty ? title : 'My Session';
    final payload = _buildSessionPayload(titleToUse, status: 'in_progress');
    print(
      'DEBUG: Syncing draft session $activeSessionId with payload: $payload',
    );

    final result = await WorkoutRepository().syncSession(
      sessionId: activeSessionId,
      payload: payload,
    );

    return result.fold(
      (error) {
        print('DEBUG: Save Draft failed: $error');
        return left(error);
      },
      (data) {
        print('DEBUG: Save Draft succeeded! Response: $data');
        if (data is Map<String, dynamic>) {
          startedAt = data['started_at']?.toString();
        }
        final parsedExercises = _parseActiveSessionExercises(data);
        String updatedTitle = '';
        if (data is Map<String, dynamic>) {
          updatedTitle =
              data['plan_name']?.toString() ??
              data['plan_day_title']?.toString() ??
              data['title']?.toString() ??
              data['name']?.toString() ??
              '';
        }
        final finalTitle =
            (updatedTitle.isNotEmpty && updatedTitle != 'My Session')
                ? updatedTitle
                : titleToUse;
        int? resId;
        int? resPlanDayId;
        if (data is Map<String, dynamic>) {
          if (data['id'] != null) {
            resId = data['id'] as int;
          }
          if (data['plan_day'] != null) {
            resPlanDayId = int.tryParse(data['plan_day'].toString());
          }
        }
        emit(
          state.copyWith(
            exercises: parsedExercises,
            sessionTitle: finalTitle,
            sessionId: resId ?? activeSessionId,
            planDayId: resPlanDayId ?? state.planDayId,
          ),
        );
        return right(data);
      },
    );
  }

  Future<void> discardSession() async {
    emit(
      state.copyWith(
        exercises: [],
        sessionTitle: '',
        sessionId: null,
        planDayId: null,
      ),
    );
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

    List<MuscleGroupModel> muscles = List<MuscleGroupModel>.from(
      state.muscleGroups,
    );
    List<EquipmentModel> equipment = List<EquipmentModel>.from(state.equipment);
    List<ExerciseTypeModel> types = List<ExerciseTypeModel>.from(
      state.exerciseTypes,
    );

    muscleResult.fold((error) => null, (list) {
      final merged = List<MuscleGroupModel>.from(list);
      for (final m in state.muscleGroups) {
        if (!merged.any((item) => item.id == m.id)) {
          merged.add(m);
        }
      }
      muscles = merged;
    });

    equipResult.fold((error) => null, (list) {
      final merged = List<EquipmentModel>.from(list);
      for (final e in state.equipment) {
        if (!merged.any((item) => item.id == e.id)) {
          merged.add(e);
        }
      }
      equipment = merged;
    });

    typeResult.fold((error) => null, (list) {
      final merged = List<ExerciseTypeModel>.from(list);
      for (final t in state.exerciseTypes) {
        if (!merged.any((item) => item.id == t.id)) {
          merged.add(t);
        }
      }
      types = merged;
    });

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

    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final exercise = updatedExercises[exerciseIndex];
    final sets = List<Map<String, dynamic>>.from(
      exercise['sets'] as List? ?? [],
    );
    final lastSet = sets.isNotEmpty ? sets.last : null;

    final inputType =
        lastSet != null ? lastSet['input_type']?.toString() : null;

    sets.add({
      'setNum': sets.length + 1,
      'previous': 'no data',
      'kg': '',
      'reps': '',
      'input_type': inputType,
      'checked': false,
    });
    exercise['sets'] = sets;
    emit(state.copyWith(exercises: updatedExercises));
    await saveDraftSession(state.sessionTitle);
  }

  Future<void> updateWorkoutLogWeightType(
    int exerciseIndex,
    String weightType,
  ) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final exercise = updatedExercises[exerciseIndex];
      final canonical = () {
        final lower = weightType.toLowerCase().replaceAll(' ', '');
        if (lower == 'bw') return 'BW';
        if (lower == 'fw' ||
            lower == 'freeweight' ||
            lower == 'baronly' ||
            lower == 'bo' ||
            lower == 'bar') {
          return 'FW';
        }
        return 'KG';
      }();
      exercise['weight_type'] = canonical;
      emit(state.copyWith(exercises: updatedExercises));
      await saveDraftSession(state.sessionTitle);
    }
  }

  Future<void> addExercise({
    required int id,
    required String title,
    required String subtitle,
    String? videoUrl,
    String? trackBy,
  }) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final resolvedTrackBy = trackBy ?? 'rep';
    final trackByLower = resolvedTrackBy.toLowerCase();
    final inputType =
        (trackByLower == 'time' ||
                trackByLower == 'sec' ||
                trackByLower == 'secs' ||
                trackByLower == 'seconds')
            ? 'time'
            : ((trackByLower == 'distance' ||
                    trackByLower == 'dist' ||
                    trackByLower == 'km' ||
                    trackByLower == 'm')
                ? 'distance'
                : 'rep');

    updatedExercises.add({
      'id': id.toString(),
      'title': title,
      'subtitle': subtitle,
      'video_url': videoUrl ?? '',
      'track_by': resolvedTrackBy,
      'weight_type': 'KG',
      'sets': [
        {
          'setNum': 1,
          'previous': 'no data',
          'kg': '',
          'reps': '',
          'input_type': inputType,
          'checked': false,
        },
      ],
    });
    emit(state.copyWith(exercises: updatedExercises));
    // Trigger background sync to get "previous" data and database IDs
    saveDraftSession(state.sessionTitle);
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

  bool isReorderingExercises = false;
  bool showReorderLoadingIndicator = false;
  String? reorderError;

  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= state.exercises.length) return;
    if (newIndex < 0 || newIndex >= state.exercises.length) return;
    if (oldIndex == newIndex) return;

    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    final item = updatedExercises.removeAt(oldIndex);
    updatedExercises.insert(newIndex, item);

    // Recalculate each exercise's order_index starting from 1
    for (var i = 0; i < updatedExercises.length; i++) {
      updatedExercises[i]['order_index'] = i + 1;
    }

    emit(state.copyWith(exercises: updatedExercises));
  }

  void reorderExercise(int oldIndex, int newIndex) {
    reorderExercises(oldIndex, newIndex);
  }

  void moveExerciseToTop(int index) {
    reorderExercise(index, 0);
  }

  void moveExerciseToBottom(int index) {
    reorderExercise(index, state.exercises.length - 1);
  }

  void moveExerciseUp(int index) {
    if (index > 0) {
      reorderExercise(index, index - 1);
    }
  }

  void moveExerciseDown(int index) {
    if (index < state.exercises.length - 1) {
      reorderExercise(index, index + 1);
    }
  }

  Future<void> deleteExercise(int exerciseIndex) async {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;

    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises.removeAt(exerciseIndex);
    emit(state.copyWith(exercises: updatedExercises));
    // Trigger background sync to update the session layout on the server
    saveDraftSession(state.sessionTitle);
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

  Future<void> updateWorkoutLogTrackBy(
    int exerciseIndex,
    String trackBy,
  ) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final exercise = Map<String, dynamic>.from(
        updatedExercises[exerciseIndex],
      );
      exercise['track_by'] = trackBy;

      final trackByLower = trackBy.toLowerCase();
      final inputType =
          (trackByLower == 'time' ||
                  trackByLower == 'sec' ||
                  trackByLower == 'secs' ||
                  trackByLower == 'seconds')
              ? 'time'
              : ((trackByLower == 'distance' ||
                      trackByLower == 'dist' ||
                      trackByLower == 'km' ||
                      trackByLower == 'm')
                  ? 'distance'
                  : 'rep');
      final sets = List<Map<String, dynamic>>.from(
        exercise['sets'] as List? ?? [],
      );
      for (var s in sets) {
        s['input_type'] = inputType;
      }
      exercise['sets'] = sets;

      updatedExercises[exerciseIndex] = exercise;
      emit(state.copyWith(exercises: updatedExercises));
    }
  }

  Future<void> toggleSetChecked(
    int exerciseIndex,
    int setIndex, {
    void Function(String errorMessage)? onError,
  }) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final exercise = updatedExercises[exerciseIndex];
      final sets = List<Map<String, dynamic>>.from(
        exercise['sets'] as List,
      );
      if (setIndex >= 0 && setIndex < sets.length) {
        final set = Map<String, dynamic>.from(sets[setIndex]);
        final newChecked = !(set['checked'] as bool? ?? false);
        set['checked'] = newChecked;
        
        // Evaluate temporary feedback if checking
        if (newChecked) {
          final previousStr = set['previous']?.toString() ?? '';
          
          if (previousStr == 'no data') {
            set['feedback_type'] = 'first_time';
          } else {
            // Attempt to compare raw values if available
            final currentKg = double.tryParse(set['kg']?.toString() ?? '0') ?? 0;
            final currentReps = double.tryParse(set['reps']?.toString() ?? '0') ?? 0;
            
            final prevKg = double.tryParse(set['raw_prev_kg']?.toString() ?? '0') ?? 0;
            final prevReps = double.tryParse(set['raw_prev_reps']?.toString() ?? '0') ?? 0;
            
            final weightType = exercise['weight_type']?.toString().toUpperCase() ?? 'KG';
            final trackBy = exercise['track_by']?.toString().toLowerCase() ?? 'rep';
            
            bool isStronger = false;
            double percentage = 0.0;
            
            if (prevKg > 0 || prevReps > 0) {
              if (weightType == 'BW') {
                if (currentReps > prevReps) {
                  isStronger = true;
                  percentage = prevReps > 0 ? ((currentReps - prevReps) / prevReps) * 100 : 0;
                }
              } else if (trackBy == 'rep') {
                // Simplified 1RM comparison for KG/FW
                final current1RM = currentKg * (1 + (currentReps / 30));
                final prev1RM = prevKg * (1 + (prevReps / 30));
                
                if (current1RM > prev1RM && prev1RM > 0) {
                  isStronger = true;
                  percentage = ((current1RM - prev1RM) / prev1RM) * 100;
                }
              } else if (trackBy == 'time' || trackBy == 'distance') {
                if (currentReps > prevReps) {
                  isStronger = true;
                  percentage = prevReps > 0 ? ((currentReps - prevReps) / prevReps) * 100 : 0;
                }
              }
              
              if (isStronger) {
                set['feedback_type'] = 'stronger';
                set['feedback_pct'] = '+${percentage.toStringAsFixed(0)}%';
              }
            } else {
              // Safest fallback: no raw data = no stronger feedback, do nothing.
            }
          }
          
          // Clear feedback automatically after 3 seconds
          if (set['feedback_type'] != null) {
            Future.delayed(const Duration(seconds: 3), () {
              if (isClosed) return;
              final currentExercises = List<Map<String, dynamic>>.from(
                state.exercises.map((e) => Map<String, dynamic>.from(e)),
              );
              if (exerciseIndex < currentExercises.length) {
                final currentSets = List<Map<String, dynamic>>.from(
                  currentExercises[exerciseIndex]['sets'] as List,
                );
                if (setIndex < currentSets.length) {
                  final targetSet = Map<String, dynamic>.from(currentSets[setIndex]);
                  if (targetSet['checked'] == true) {
                    targetSet.remove('feedback_type');
                    targetSet.remove('feedback_pct');
                    currentSets[setIndex] = targetSet;
                    currentExercises[exerciseIndex]['sets'] = currentSets;
                    emit(state.copyWith(exercises: currentExercises));
                  }
                }
              }
            });
          }
        } else {
          // If unchecked, remove feedback
          set.remove('feedback_type');
          set.remove('feedback_pct');
        }

        sets[setIndex] = set;
        updatedExercises[exerciseIndex]['sets'] = sets;
        emit(state.copyWith(exercises: updatedExercises));
      }
    }
  }

  Future<void> deleteSet(int exerciseIndex, int setIndex) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final exercise = updatedExercises[exerciseIndex];
      final sets = List<Map<String, dynamic>>.from(
        exercise['sets'] as List? ?? [],
      );
      if (setIndex >= 0 && setIndex < sets.length) {
        sets.removeAt(setIndex);
        // Reorder set numbers
        for (int i = 0; i < sets.length; i++) {
          sets[i]['setNum'] = i + 1;
        }
        exercise['sets'] = sets;
        emit(state.copyWith(exercises: updatedExercises));
      }
    }
  }

  void updateSetKg(int exerciseIndex, int setIndex, String val) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final sets = List<Map<String, dynamic>>.from(
        updatedExercises[exerciseIndex]['sets'] as List,
      );
      if (setIndex >= 0 && setIndex < sets.length) {
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
      }
    }
  }

  void updateSetReps(int exerciseIndex, int setIndex, String val) {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    if (exerciseIndex >= 0 && exerciseIndex < updatedExercises.length) {
      final sets = List<Map<String, dynamic>>.from(
        updatedExercises[exerciseIndex]['sets'] as List,
      );
      if (setIndex >= 0 && setIndex < sets.length) {
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
      }
    }
  }

  Future<void> loadMuscleClassification({String? majorMuscle}) async {
    final response = await WorkoutRepository().getMuscleClassification(
      majorMuscle: majorMuscle,
    );
    response.fold(
      (error) => debugPrint('Error loading muscle classification: ${error.msg}'),
      (classification) {
        final isAll = majorMuscle == null || majorMuscle.isEmpty || majorMuscle == 'All';
        final existing = state.majorMuscleCategories;
        final updatedMajorCategories = (isAll || existing.length <= 1)
            ? (classification.allMajorMuscles.length > 1
                ? classification.allMajorMuscles
                : existing)
            : existing;

        emit(
          state.copyWith(
            majorMuscleCategories: updatedMajorCategories.isNotEmpty
                ? updatedMajorCategories
                : classification.allMajorMuscles,
            subMuscles: classification.allSubMuscles,
          ),
        );
      },
    );
  }

  Future<void> loadLibraryExercises({
    String? search,
    String? muscleGroup,
    String? majorMuscle,
    dynamic subMuscle,
    dynamic equipment,
    String? type,
    String? sort,
    String? source,
  }) async {
    print(
      'DEBUG: loadLibraryExercises() called with search: $search, majorMuscle: $majorMuscle, subMuscle: $subMuscle, source: $source',
    );
    final queryParams = <String, dynamic>{};
    final sourceVal = (source != null && source.isNotEmpty) ? source : 'library';
    queryParams['source'] = sourceVal;

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (majorMuscle != null && majorMuscle.trim().isNotEmpty && majorMuscle.trim() != 'All') {
      queryParams['major_muscle'] = majorMuscle.trim();
    }
    if (subMuscle != null && subMuscle.toString().trim().isNotEmpty && subMuscle.toString().trim() != 'All') {
      queryParams['sub_muscle'] = subMuscle;
    } else if (muscleGroup != null && muscleGroup.trim().isNotEmpty && muscleGroup.trim() != 'All') {
      queryParams['sub_muscle'] = muscleGroup.trim();
    }
    if (equipment != null && equipment.toString().trim().isNotEmpty && equipment.toString().trim() != 'All') {
      queryParams['equipment'] = equipment;
    }
    if (type != null && type.trim().isNotEmpty && type.trim() != 'All') {
      queryParams['type'] = type.trim();
    }
    if (sort != null && sort.trim().isNotEmpty) {
      queryParams['sort'] = sort.trim();
    }

    final isSearching = queryParams.length > 1;

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
              final formattedSub = model.subtitle ??
                  '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}';
              return {
                'id': (model.id ?? '').toString(),
                'title': model.name ?? '',
                'subtitle': formattedSub,
                'video_url': model.videoUrl?.toString() ?? '',
                'track_by': model.trackBy ?? 'rep',
                'major_muscle': model.majorMuscle ?? '',
                'source': model.source ?? '',
              };
            }).toList();
        if (!isSearching) {
          _allLibraryExercises = mappedList;
        }
        emit(state.copyWith(libraryExercises: mappedList));
      },
    );
  }

  Future<void> loadCustomExercises({
    String? search,
    String? majorMuscle,
    dynamic subMuscle,
    dynamic equipment,
    String? type,
    String? sort,
  }) async {
    print(
      'DEBUG: loadCustomExercises() called with search: $search, majorMuscle: $majorMuscle',
    );
    final queryParams = <String, dynamic>{
      'source': 'custom',
      'custom_only': true,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (majorMuscle != null && majorMuscle.trim().isNotEmpty && majorMuscle.trim() != 'All') {
      queryParams['major_muscle'] = majorMuscle.trim();
    }
    if (subMuscle != null && subMuscle.toString().trim().isNotEmpty && subMuscle.toString().trim() != 'All') {
      queryParams['sub_muscle'] = subMuscle;
    }
    if (equipment != null && equipment.toString().trim().isNotEmpty && equipment.toString().trim() != 'All') {
      queryParams['equipment'] = equipment;
    }
    if (type != null && type.trim().isNotEmpty && type.trim() != 'All') {
      queryParams['type'] = type.trim();
    }
    if (sort != null && sort.trim().isNotEmpty) {
      queryParams['sort'] = sort.trim();
    }

    final isSearching = queryParams.length > 2;

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
              final formattedSub = model.subtitle ??
                  '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}';
              return {
                'id': (model.id ?? '').toString(),
                'title': model.name ?? '',
                'subtitle': formattedSub,
                'video_url': model.videoUrl?.toString() ?? '',
                'track_by': model.trackBy ?? 'rep',
                'major_muscle': model.majorMuscle ?? '',
                'source': model.source ?? '',
              };
            }).toList();
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
        int? sessionId;
        int? planDayId;
        if (data is Map<String, dynamic>) {
          startedAt = data['started_at']?.toString();
          if (data['id'] != null) {
            sessionId = data['id'] as int;
          }
          if (data['plan_day'] != null) {
            planDayId = int.tryParse(data['plan_day'].toString());
          }
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
            sessionId: sessionId ?? state.sessionId,
            planDayId: planDayId ?? state.planDayId,
          ),
        );
      },
    );
  }

  void updateSessionTitle(String title) {
    if (isClosed) return;
    emit(state.copyWith(sessionTitle: title));
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
            final targetReps =
                s['target_reps'] ??
                s['targetReps'] ??
                s['target_value'] ??
                s['targetValue'];
            final rawKg =
                s['weight_kg'] ?? s['weight'] ?? s['kg'] ?? targetWeight;
            final rawReps = s['reps'] ?? s['value'] ?? targetReps;

            String kgVal = '';
            if (rawKg != null) {
              final val = double.tryParse(rawKg.toString());
              if (val != null && val != 0.0) {
                kgVal =
                    val == val.truncateToDouble()
                        ? val.toInt().toString()
                        : val.toString();
              }
            }

            String repsVal = '';
            if (rawReps != null) {
              final val = double.tryParse(rawReps.toString());
              if (val != null && val != 0.0) {
                repsVal =
                    val == val.truncateToDouble()
                        ? val.toInt().toString()
                        : val.toString();
              }
            }

            final prevRaw = s['previous'];
            final prevWeightRaw = s['previous_weight_kg'] ?? s['previous_weight'] ?? s['previous_kg'];
            final prevRepsRaw = s['previous_reps'] ?? s['previous_value'];
            
            String prevStr;
            if (prevRaw != null &&
                prevRaw.toString().isNotEmpty &&
                prevRaw.toString() != 'no data') {
              // Backend returned formatted string like '80kgX10' or '20kg x 45 sec'
              prevStr = prevRaw.toString();
            } else if (prevWeightRaw != null) {
              // Fallback: only weight available — format as '{weight}kg'
              final w = double.tryParse(prevWeightRaw.toString());
              if (w != null) {
                final wStr =
                    w == w.truncateToDouble()
                        ? w.toInt().toString()
                        : w.toString();
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
              'raw_prev_kg': prevWeightRaw,
              'raw_prev_reps': prevRepsRaw,
              'kg': kgVal,
              'reps': repsVal,
              'input_type': s['input_type'],
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
          'input_type': () {
            final val = resolvedTrackBy?.toLowerCase();
            if (val == 'time' ||
                val == 'sec' ||
                val == 'secs' ||
                val == 'seconds')
              return 'time';
            if (val == 'distance' || val == 'dist' || val == 'km' || val == 'm')
              return 'distance';
            return 'rep';
          }(),
          'checked': false,
        });
      }

      result.add({
        'id': exerciseId?.toString() ?? '',
        'workout_log_id': item['id']?.toString() ?? '',
        'order_index': item['order_index'] ?? item['order'] ?? result.length,
        'title': title,
        'subtitle': subtitle ?? '',
        'video_url': videoUrl ?? '',
        'track_by': () {
          if (sets.isNotEmpty) {
            final firstInputType =
                sets.first['input_type']?.toString().toLowerCase();
            if (firstInputType == 'time' ||
                firstInputType == 'sec' ||
                firstInputType == 'secs' ||
                firstInputType == 'seconds')
              return 'time';
            if (firstInputType == 'distance' ||
                firstInputType == 'dist' ||
                firstInputType == 'km' ||
                firstInputType == 'm')
              return 'distance';
            if (firstInputType == 'rep' || firstInputType == 'reps')
              return 'rep';
          }
          final val = resolvedTrackBy?.toLowerCase();
          if (val == 'time' ||
              val == 'sec' ||
              val == 'secs' ||
              val == 'seconds')
            return 'time';
          if (val == 'distance' || val == 'dist' || val == 'km' || val == 'm')
            return 'distance';
          return 'rep';
        }(),
        'weight_type': () {
          final type = item['weight_type']?.toString();
          if (type == null) return 'KG';
          final lower = type.toLowerCase().replaceAll(' ', '');
          if (lower == 'bw') return 'BW';
          if (lower == 'fw' || lower == 'freeweight' || lower == 'baronly' || lower == 'bo' || lower == 'bar') return 'FW';
          if (lower == 'kg+bw') return 'KG';
          if (lower == 'kg') return 'KG';
          return 'KG';
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

    result.sort((a, b) {
      final aOrder = int.tryParse(a['order_index']?.toString() ?? '') ?? 0;
      final bOrder = int.tryParse(b['order_index']?.toString() ?? '') ?? 0;
      return aOrder.compareTo(bOrder);
    });

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
