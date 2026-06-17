import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';

part 'workout_state.dart';
part 'workout_cubit.freezed.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  List<Map<String, String>> _allLibraryExercises = [];
  List<Map<String, String>> _allCustomExercises = [];
  String? startedAt;

  WorkoutCubit({bool startFresh = false, PresetModel? presetToStart})
      : super(
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
    emit(state.copyWith(exercises: [], sessionTitle: title, isLoadingActiveSession: true));
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
              activeTitle = data['title']?.toString() ?? data['name']?.toString() ?? 'My Session';
            }
          }
        },
      );
      
      // 2. If there is an active session, finish it first!
      if (activeSessionId != null) {
        print('DEBUG: Active session found (ID: $activeSessionId). Finishing it first...');
        final finishRes = await WorkoutRepository().finishSession(
          sessionId: activeSessionId!,
          title: activeTitle,
        );
        finishRes.fold(
          (error) => print('DEBUG: finishSession failed with error: $error'),
          (data) => print('DEBUG: finishSession succeeded with data: $data'),
        );
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
          print('DEBUG: Successfully started a new session! Response data: $data');
          loadActiveSession();
        },
      );
    } catch (e) {
      print('DEBUG: Exception in startNewSession: $e');
      emit(state.copyWith(isLoadingActiveSession: false));
    }
  }

  Future<void> startPresetSession(PresetModel preset) async {
    emit(state.copyWith(exercises: [], sessionTitle: preset.title, isLoadingActiveSession: true));
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
              activeTitle = data['title']?.toString() ?? data['name']?.toString() ?? 'My Session';
            }
          }
        },
      );
      
      // 2. If there is an active session, finish it first!
      if (activeSessionId != null) {
        print('DEBUG: Active session found (ID: $activeSessionId). Finishing it first...');
        final finishRes = await WorkoutRepository().finishSession(
          sessionId: activeSessionId!,
          title: activeTitle,
        );
        finishRes.fold(
          (error) => print('DEBUG: finishSession failed with error: $error'),
          (data) => print('DEBUG: finishSession succeeded with data: $data'),
        );
      }

      // 3. Now start a brand new session!
      print('DEBUG: Starting preset session with title: ${preset.title}...');
      final result = await WorkoutRepository().startSession(title: preset.title);
      
      await result.fold(
        (error) async {
          print('DEBUG: Error starting new preset session: $error');
          emit(state.copyWith(isLoadingActiveSession: false));
        },
        (data) async {
          print('DEBUG: Successfully started preset session on backend!');
          
          // 4. Add each exercise in the preset to the session
          final workoutIds = preset.exercises.map((e) => e.workoutId).toList();
          final addRes = await WorkoutRepository().addExercisesToActiveSession(workoutIds: workoutIds);
          addRes.fold(
            (err) => print('DEBUG: Error adding preset exercises: $err'),
            (ok) => print('DEBUG: Successfully added preset exercises to active session!'),
          );

          // 5. Reload active session from backend
          await loadActiveSession();

          // 6. Override the sets in the Cubit state with the ones from the preset
          final updatedExercises = List<Map<String, dynamic>>.from(
            state.exercises.map((e) => Map<String, dynamic>.from(e)),
          );

          for (var i = 0; i < updatedExercises.length; i++) {
            final activeEx = updatedExercises[i];
            // Find matching preset exercise by name
            final presetEx = preset.exercises.firstWhere(
              (pe) => pe.name.toLowerCase() == activeEx['title']?.toString().toLowerCase(),
              orElse: () => preset.exercises[i < preset.exercises.length ? i : 0],
            );
            
            final List<Map<String, dynamic>> presetSets = presetEx.sets.map((s) => {
              'setNum': s.setNumber,
              'previous': '10kg×15',
              'kg': s.weight.toString(),
              'reps': s.reps.toString(),
              'checked': false,
            }).toList();
            
            if (presetSets.isNotEmpty) {
              activeEx['sets'] = presetSets;
            }
          }

          emit(state.copyWith(
            exercises: updatedExercises,
            isLoadingActiveSession: false,
          ));
        },
      );
    } catch (e) {
      print('DEBUG: Exception in startPresetSession: $e');
      emit(state.copyWith(isLoadingActiveSession: false));
    }
  }

  Future<void> finishSession({required String title}) async {
    final activeRes = await WorkoutRepository().getActiveSession();
    int? activeSessionId;
    int? planDayId;
    activeRes.fold(
      (error) => null,
      (data) {
        if (data != null && data is Map<String, dynamic>) {
          if (data['id'] != null) {
            activeSessionId = data['id'] as int;
          }
          if (data['plan_day'] != null) {
            planDayId = int.tryParse(data['plan_day'].toString());
          }
        }
      },
    );

    if (activeSessionId != null) {
      final titleToUse = title.isNotEmpty ? title : 'My Session';

      if (planDayId != null && title.isNotEmpty) {
        final presetsRes = await WorkoutRepository().getPresets();
        await presetsRes.fold(
          (error) async {},
          (presetsList) async {
            int? foundPlanId;
            final checkLimit = presetsList.length > 5 ? 5 : presetsList.length;
            final futures = <Future<void>>[];
            for (int i = 0; i < checkLimit; i++) {
              final preset = presetsList[i];
              futures.add(
                WorkoutRepository().getPresetDetail(preset.id).then((detailRes) {
                  detailRes.fold(
                    (err) {},
                    (detail) {
                      final days = detail['days'] as List? ?? [];
                      for (final d in days) {
                        if (d['id'] == planDayId) {
                          foundPlanId = preset.id;
                        }
                      }
                    },
                  );
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
          },
        );
      }

      final result = await WorkoutRepository().finishSession(
        sessionId: activeSessionId!,
        title: titleToUse,
      );
      result.fold(
        (error) {
          print('DEBUG: Error finishing session: $error');
        },
        (data) {
          print('DEBUG: Successfully finished session!');
          emit(state.copyWith(exercises: [], sessionTitle: ''));
        },
      );
    }
  }

  Future<void> saveDraftSession(String title) async {
    if (title.isNotEmpty) {
      await updateSessionTitle(title);
    }
  }

  Future<void> discardSession() async {
    emit(state.copyWith(exercises: [], sessionTitle: ''));
    final res = await WorkoutRepository().deleteActiveSession();
    res.fold(
      (error) => print('DEBUG: Error deleting active session: $error'),
      (_) {
        print('DEBUG: Successfully deleted active session.');
      },
    );
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

    final logIdStr = updatedExercises[exerciseIndex]['id']?.toString();
    final logId = int.tryParse(logIdStr ?? '');

    if (logId != null) {
      final reps = lastSet != null ? int.tryParse(lastSet['reps']?.toString() ?? '15') ?? 15 : 15;
      final weight = lastSet != null ? double.tryParse(lastSet['kg']?.toString() ?? '10.0') ?? 10.0 : 10.0;

      WorkoutRepository().addSetToExerciseLog(
        logId: logId,
        reps: reps,
        weightKg: weight,
      ).then((result) {
        result.fold(
          (error) {
            print('DEBUG: Error adding set to backend: $error');
            loadActiveSession();
          },
          (successData) {
            print('DEBUG: Successfully added set to backend: $successData');
            loadActiveSession();
          },
        );
      });
    }
  }

  Future<void> addExercise({
    required int id,
    required String title,
    required String subtitle,
    String? videoUrl,
  }) async {
    final updatedExercises = List<Map<String, dynamic>>.from(
      state.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
    updatedExercises.add(<String, dynamic>{
      'id': id.toString(),
      'title': title,
      'subtitle': subtitle,
      'video_url': videoUrl ?? '',
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

    final result = await WorkoutRepository().addExercisesToActiveSession(workoutIds: [id]);
    result.fold(
      (error) {
        print('DEBUG: Error adding exercise to active session: $error');
        loadActiveSession();
      },
      (successData) {
        print('DEBUG: Successfully added exercise to active session on backend!');
        loadActiveSession();
      },
    );
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
          'id': (newExercise.id ?? '').toString(),
          'title': newExercise.name ?? '',
          'subtitle': formattedSub,
        });

        emit(state.copyWith(
          customExercises: updatedCustom,
          isCreatingExercise: false,
        ));

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
        final mappedList = exercisesList.map((model) {
          return {
            'id': (model.id ?? '').toString(),
            'title': model.name ?? '',
            'subtitle': '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
            'video_url': model.videoUrl?.toString() ?? '',
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
        final mappedList = exercisesList.map((model) {
          return {
            'id': (model.id ?? '').toString(),
            'title': model.name ?? '',
            'subtitle': '${model.muscleGroup ?? ''} / ${model.equipment ?? ''} / ${model.type ?? ''}',
            'video_url': model.videoUrl?.toString() ?? '',
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
          title = data['plan_name']?.toString() ??
              data['plan_day_title']?.toString() ??
              data['title']?.toString() ??
              data['name']?.toString() ??
              '';
        }
        final finalTitle = (title.isNotEmpty && title != 'My Session')
            ? title
            : (state.sessionTitle.isNotEmpty ? state.sessionTitle : (title.isNotEmpty ? title : 'My Session'));
        emit(state.copyWith(
          exercises: parsedExercises,
          sessionTitle: finalTitle,
          isLoadingActiveSession: false,
        ));
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

      String? rawMuscle;
      String? rawEquip;
      String? rawType;

      if (item['workout'] is Map<String, dynamic>) {
        final workout = item['workout'] as Map<String, dynamic>;
        title = workout['name'] as String?;
        exerciseId = workout['id'] as int?;
        rawMuscle = workout['primary_muscle_group_name'] as String? ?? workout['muscle_group'] as String?;
        rawEquip = workout['equipment_name'] as String? ?? workout['equipment'] as String?;
        rawType = workout['type'] as String?;
        videoUrl = workout['video_url']?.toString();
      } else if (item['exercise'] is Map<String, dynamic>) {
        final exercise = item['exercise'] as Map<String, dynamic>;
        title = exercise['name'] as String?;
        exerciseId = exercise['id'] as int?;
        rawMuscle = exercise['primary_muscle_group_name'] as String? ?? exercise['muscle_group'] as String?;
        rawEquip = exercise['equipment_name'] as String? ?? exercise['equipment'] as String?;
        rawType = exercise['type'] as String?;
        videoUrl = exercise['video_url']?.toString();
      } else {
        title = item['workout_name']?.toString() ?? item['name']?.toString() ?? item['title']?.toString();
        exerciseId = item['id'] as int? ?? item['plan_exercise'] as int? ?? item['workout_id'] as int?;
        rawMuscle = item['muscle']?.toString() ?? item['primary_muscle_group_name']?.toString() ?? item['muscle_group']?.toString();
        rawEquip = item['equipment_name']?.toString() ?? item['equipment']?.toString();
        rawType = item['type']?.toString();
        videoUrl = item['video_url']?.toString();
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
        if (foundEx != null && foundEx['subtitle'] != null) {
          final parts = foundEx['subtitle']!.split('/');
          if (parts.length >= 3) {
            resolvedMuscle = parts[0].trim();
            resolvedEquip = parts[1].trim();
            resolvedType = parts[2].trim();
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
        if (foundEx != null && foundEx['subtitle'] != null) {
          final parts = foundEx['subtitle']!.split('/');
          if (parts.length >= 3) {
            resolvedMuscle = parts[0].trim();
            resolvedEquip = parts[1].trim();
            resolvedType = parts[2].trim();
          }
        }
      }

      final List<String> subtitleParts = [];
      if (resolvedMuscle != null && resolvedMuscle.isNotEmpty) subtitleParts.add(resolvedMuscle);
      if (resolvedEquip != null && resolvedEquip.isNotEmpty) subtitleParts.add(resolvedEquip);
      if (resolvedType != null && resolvedType.isNotEmpty) subtitleParts.add(resolvedType);

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
            final kgVal = s['weight_kg'] ?? s['weight'] ?? s['kg'] ?? '10';
            final repsVal = s['reps'] ?? '15';
            final prevVal = s['previous_weight_kg'] ?? s['previous'];
            sets.add({
              'setNum': s['set_number'] ?? s['set_num'] ?? s['setNum'] ?? (i + 1),
              'previous': prevVal?.toString() ?? '10kg×15',
              'kg': kgVal.toString(),
              'reps': repsVal.toString(),
              'checked': s['is_completed'] ?? s['checked'] ?? false,
            });
          }
        }
      }

      if (sets.isEmpty) {
        sets.add({
          'setNum': 1,
          'previous': '10kg×15',
          'kg': '10',
          'reps': '15',
          'checked': false,
        });
      }

      result.add({
        'id': exerciseId?.toString() ?? '',
        'title': title,
        'subtitle': subtitle ?? '',
        'video_url': videoUrl ?? '',
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
      final exercisesData = data['logs'] ?? data['exercises'] ?? data['session_exercises'] ?? data['results'];
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
    final List<Map<String, dynamic>> exercises = preset.exercises.map((ex) {
      final List<Map<String, dynamic>> sets = ex.sets.map((s) => {
        'setNum': s.setNumber,
        'previous': '10kg×15',
        'kg': s.weight.toString(),
        'reps': s.reps.toString(),
        'checked': false,
      }).toList();
      return {
        'id': ex.workoutId.toString(),
        'title': ex.name,
        'subtitle': ex.muscleGroup,
        'sets': sets,
      };
    }).toList();
    emit(state.copyWith(exercises: exercises, sessionTitle: preset.title));
  }
}
