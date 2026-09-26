import 'dart:async';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/models.dart';
import 'package:dio/dio.dart';

final class WorkoutRepository {
  factory WorkoutRepository() {
    _instance ??= WorkoutRepository._internal();
    return _instance!;
  }

  WorkoutRepository._internal();

  static WorkoutRepository? _instance;

  // Caching variables
  List<MuscleGroupModel>? _cachedMuscleGroups;
  List<EquipmentModel>? _cachedEquipment;
  List<ExerciseTypeModel>? _cachedExerciseTypes;
  MuscleClassificationResponse? _cachedMuscleClassification;
  final Map<String, List<ExerciseLibraryModel>> _cachedExerciseLibraries = {};

  // Calendar month cache – key format: "yyyy-MM" (e.g. "2026-07")
  final Map<String, Map<String, dynamic>> _monthCache = {};

  // Broadcast stream that emits a month key ("yyyy-MM") whenever that month
  // is invalidated. Calendar widgets subscribe to this to refresh themselves.
  final StreamController<String> _calendarInvalidationController =
      StreamController<String>.broadcast();

  /// Stream of month-key strings (e.g. "2026-07") that were just invalidated.
  /// Calendar widgets listen to this to trigger an immediate UI refresh.
  Stream<String> get calendarInvalidationStream =>
      _calendarInvalidationController.stream;

  /// Removes a single month from the calendar cache and notifies any
  /// listening calendar widgets to refresh immediately.
  void invalidateCalendarMonth(int year, int month) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    _monthCache.remove(key);
    if (!_calendarInvalidationController.isClosed) {
      _calendarInvalidationController.add(key);
    }
    debugPrint('[CalendarCache] Invalidated month: $key');
  }

  /// Clears the entire calendar cache (e.g. on logout).
  void clearCalendarCache() => _monthCache.clear();

  /// Checks if the calendar cache contains the specified month key ("yyyy-MM").
  bool hasCalendarCache(String key) => _monthCache.containsKey(key);

  /// Retrieves the cached data for the specified month key ("yyyy-MM").
  Map<String, dynamic>? getCalendarCache(String key) => _monthCache[key];

  final Dio _dio = DioClient().dio;

  Either<ApiException, List<T>> _handleListResponse<T>(
    Response<dynamic> res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (res.statusCode == 200 && res.data != null && res.data is List) {
      return right(
        (res.data as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return left(const ApiException.unknown());
  }

  Future<Either<ApiException, List<ExerciseLibraryModel>>> getExerciseLibrary({
    Map<String, dynamic>? queryParameters,
  }) async {
    final cacheKey = queryParameters?.toString() ?? 'default';
    if (_cachedExerciseLibraries.containsKey(cacheKey)) {
      return right(_cachedExerciseLibraries[cacheKey]!);
    }
    try {
      final response = await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.exercises,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess:
            (res) => _handleListResponse(res, ExerciseLibraryModel.fromJson),
      );
      response.fold(
        (_) => null,
        (list) => _cachedExerciseLibraries[cacheKey] = list,
      );
      return response;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, MuscleClassificationResponse>> getMuscleClassification({
    String? majorMuscle,
    bool forceRefresh = false,
  }) async {
    if (_cachedMuscleClassification != null &&
        (majorMuscle == null || majorMuscle.isEmpty || majorMuscle == 'All') &&
        !forceRefresh) {
      return right(_cachedMuscleClassification!);
    }
    try {
      final queryParams = <String, dynamic>{};
      if (majorMuscle != null && majorMuscle.isNotEmpty && majorMuscle != 'All') {
        queryParams['major_muscle'] = majorMuscle;
      }
      final response = await Feggy.async<Response<dynamic>, Either<ApiException, MuscleClassificationResponse>>(
        call: _dio.get<dynamic>(
          ApiUris.muscleClassification,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null) {
            final parsed = MuscleClassificationResponse.fromJson(
              res.data as Map<String, dynamic>,
            );
            if (majorMuscle == null || majorMuscle.isEmpty || majorMuscle == 'All') {
              _cachedMuscleClassification = parsed;
            }
            return right(parsed);
          }
          return left(const ApiException.unknown());
        },
      );
      return response;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<MuscleGroupModel>>> getMuscleGroups() async {
    if (_cachedMuscleGroups != null) {
      return right(_cachedMuscleGroups!);
    }
    try {
      final response = await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.muscleGroups,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) => _handleListResponse(res, MuscleGroupModel.fromJson),
      );
      response.fold((_) => null, (list) => _cachedMuscleGroups = list);
      return response;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<EquipmentModel>>> getEquipment() async {
    if (_cachedEquipment != null) {
      return right(_cachedEquipment!);
    }
    try {
      final response = await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.equipment,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) => _handleListResponse(res, EquipmentModel.fromJson),
      );
      response.fold((_) => null, (list) => _cachedEquipment = list);
      return response;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<ExerciseTypeModel>>>
  getExerciseTypes() async {
    if (_cachedExerciseTypes != null) {
      return right(_cachedExerciseTypes!);
    }
    try {
      final response = await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.exerciseTypes,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess:
            (res) => _handleListResponse(res, ExerciseTypeModel.fromJson),
      );
      response.fold((_) => null, (list) => _cachedExerciseTypes = list);
      return response;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, MuscleGroupModel>> createMuscleGroup({
    required String name,
  }) async {
    _cachedMuscleGroups = null;
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.customerMuscleGroups,
          data: {'name': name},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.data != null) {
            return right(MuscleGroupModel.fromJson(res.data as Map<String, dynamic>));
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, EquipmentModel>> createEquipment({
    required String name,
  }) async {
    _cachedEquipment = null;
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.customerEquipment,
          data: {'name': name},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.data != null) {
            return right(EquipmentModel.fromJson(res.data as Map<String, dynamic>));
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, ExerciseLibraryModel>> createCustomExercise({
    required Map<String, dynamic> body,
  }) async {
    _cachedExerciseLibraries.clear();
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.exercises,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 201 || res.statusCode == 200) &&
              res.data != null) {
            return right(
              ExerciseLibraryModel.fromJson(res.data as Map<String, dynamic>),
            );
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> getExerciseDetails({
    int? id,
    String? title,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (id != null) {
        queryParams['id'] = id;
      }
      if (title != null) {
        queryParams['title'] = title;
      }

      final res = await _dio.get<dynamic>(
        ApiUris.exerciseDetail,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (res.statusCode == 200 &&
          res.data != null &&
          res.data is Map<String, dynamic>) {
        return right(res.data as Map<String, dynamic>);
      }
      return left(const ApiException.unknown());
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> getExerciseDetailsById(
    int id,
  ) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiUris.exerciseDetailById(id),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 200 &&
          res.data != null &&
          res.data is Map<String, dynamic>) {
        return right(res.data as Map<String, dynamic>);
      }
      return left(const ApiException.unknown());
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> getActiveSession() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.activeSession,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSessionDetails({
    required int sessionId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.sessionDetails(sessionId),
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 &&
              res.data != null &&
              res.data is Map<String, dynamic>) {
            return right(res.data as Map<String, dynamic>);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> addExercisesToActiveSession({
    required List<int> workoutIds,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.activeSessionExercises,
          data: {'workout_ids': workoutIds},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> startSession({
    required String title,
    int? presetId,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        if (presetId != null) 'preset_id': presetId,
      };
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.startSession,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> finishSession({
    required int sessionId,
    required String title,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final baseUrl = ApiUris.activeSession.split('/sessions/')[0];
      final url = '$baseUrl/sessions/$sessionId/finish/';
      final res = await _dio.post<dynamic>(
        url,
        data: payload ?? {'title': title},
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        return right(res.data);
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      debugPrint('finishSession DioException: $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final errorMsg = data['error'] ?? data['detail'] ?? data['message'];
          if (errorMsg != null) {
            return left(ApiException.unknown(msg: errorMsg.toString()));
          }
          final firstKey = data.keys.first;
          final val = data[firstKey];
          if (val is List && val.isNotEmpty) {
            return left(ApiException.unknown(msg: val[0].toString()));
          } else {
            return left(ApiException.unknown(msg: val.toString()));
          }
        }
      }
      return left(ApiException.unknown(msg: e.message ?? 'Something went wrong.'));
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> syncSession({
    required int sessionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final baseUrl = ApiUris.activeSession.split('/sessions/')[0];
      final url = '$baseUrl/sessions/$sessionId/sync/';
      final res = await _dio.patch<dynamic>(
        url,
        data: payload,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        return right(res.data as Map<String, dynamic>);
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      debugPrint('syncSession DioException: $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final errorMsg = data['error'] ?? data['detail'] ?? data['message'];
          if (errorMsg != null) {
            return left(ApiException.unknown(msg: errorMsg.toString()));
          }
          final firstKey = data.keys.first;
          final val = data[firstKey];
          if (val is List && val.isNotEmpty) {
            return left(ApiException.unknown(msg: val[0].toString()));
          } else {
            return left(ApiException.unknown(msg: val.toString()));
          }
        }
      }
      return left(ApiException.unknown(msg: e.message ?? 'Something went wrong.'));
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> reorderExercises({
    required int sessionId,
    required List<Map<String, dynamic>> logs,
  }) async {
    try {
      final baseUrl = ApiUris.activeSession.split('/sessions/')[0];
      final url = '$baseUrl/sessions/$sessionId/reorder-exercises/';
      final res = await _dio.patch<dynamic>(
        url,
        data: {'logs': logs},
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        return right(res.data);
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      debugPrint('reorderExercises DioException: $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final errorMsg = data['error'] ?? data['detail'] ?? data['message'];
          if (errorMsg != null) {
            return left(ApiException.unknown(msg: errorMsg.toString()));
          }
        }
      }
      return left(const ApiException.unknown());
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> deleteActiveSession() async {
    try {
      return await Feggy.async(
        call: _dio.delete<dynamic>(
          ApiUris.activeSession,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 || res.statusCode == 204) {
            return right(null);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> addSetToExerciseLog({
    required int logId,
    required int reps,
    required double weightKg,
    bool? isCompleted,
  }) async {
    try {
      final body = <String, dynamic>{'reps': reps, 'weight_kg': weightKg};
      if (isCompleted != null) {
        body['is_completed'] = isCompleted;
      }
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.addSetToLog(logId),
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> updateWorkoutLogWeightType({
    required int logId,
    required String weightType,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.deleteWorkoutLog(logId),
          data: {'weight_type': weightType},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> updateWorkoutLogTrackBy({
    required int logId,
    required String trackBy,
  }) async {
    try {
      final normTrack = trackBy.toLowerCase() == 'sec' ||
              trackBy.toLowerCase() == 'secs' ||
              trackBy.toLowerCase() == 'seconds' ||
              trackBy.toLowerCase() == 'time'
          ? 'time'
          : (trackBy.toLowerCase() == 'distance' ||
                  trackBy.toLowerCase() == 'dist' ||
                  trackBy.toLowerCase() == 'km' ||
                  trackBy.toLowerCase() == 'm'
              ? 'distance'
              : 'rep');
      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.deleteWorkoutLog(logId),
          data: {'track_by': normTrack},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> updateWorkoutLogOrder({
    required int logId,
    required int orderIndex,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.deleteWorkoutLog(logId),
          data: {'order_index': orderIndex},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data != null) {
            return right(res.data);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, dynamic>> updateSetLog({
    required int setLogId,
    int? reps,
    dynamic value,
    String? inputType,
    double? weightKg,
    bool? isCompleted,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (weightKg != null) body['weight_kg'] = weightKg;
      if (isCompleted != null) body['is_completed'] = isCompleted;

      if (inputType != null && inputType.isNotEmpty) {
        final normInput = inputType.toLowerCase() == 'sec' ||
                inputType.toLowerCase() == 'secs' ||
                inputType.toLowerCase() == 'seconds' ||
                inputType.toLowerCase() == 'time'
            ? 'time'
            : (inputType.toLowerCase() == 'distance' ||
                    inputType.toLowerCase() == 'dist' ||
                    inputType.toLowerCase() == 'km' ||
                    inputType.toLowerCase() == 'm'
                ? 'distance'
                : 'rep');
        body['input_type'] = normInput;
        if (normInput == 'rep') {
          if (reps != null) {
            body['reps'] = reps;
          } else if (value != null) {
            body['reps'] = (value is num) ? value.toInt() : (int.tryParse(value.toString()) ?? value);
          }
        } else {
          if (value != null) {
            body['value'] = value;
          } else if (reps != null) {
            body['value'] = reps;
          }
        }
      } else {
        if (reps != null) body['reps'] = reps;
        if (value != null) body['value'] = value;
      }

      final res = await _dio.patch<dynamic>(
        ApiUris.updateSetLog(setLogId),
        data: body,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        return right(res.data);
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      debugPrint('updateSetLog DioException: $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final errorMsg = data['error'] ?? data['detail'] ?? data['message'];
          if (errorMsg != null) {
            return left(ApiException.unknown(msg: errorMsg.toString()));
          }
          final firstKey = data.keys.first;
          final val = data[firstKey];
          if (val is List && val.isNotEmpty) {
            return left(ApiException.unknown(msg: val[0].toString()));
          } else {
            return left(ApiException.unknown(msg: val.toString()));
          }
        }
      }
      return left(ApiException.unknown(msg: e.message ?? 'Something went wrong.'));
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> deleteSetLog({
    required int setLogId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.delete<dynamic>(
          ApiUris.updateSetLog(setLogId),
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 ||
              res.statusCode == 204 ||
              res.statusCode == 201) {
            return right(null);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> deleteWorkoutLog({
    required int logId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.delete<dynamic>(
          ApiUris.deleteWorkoutLog(logId),
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 ||
              res.statusCode == 204 ||
              res.statusCode == 201) {
            return right(null);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<dynamic>>> getWorkoutLogForDate({
    required String date,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.workoutLog,
          queryParameters: {'date': date},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null) {
            if (res.data is List) {
              return right(res.data as List);
            } else if (res.data is Map) {
              return right([res.data]);
            }
          }
          return right([]);
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>>
  getWorkoutCalendarForMonth({
    required int year,
    required int month,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$year-${month.toString().padLeft(2, '0')}';

    // Return cached data if available and not forced to refresh
    if (!forceRefresh && _monthCache.containsKey(cacheKey)) {
      debugPrint('[CalendarCache] Cache hit for month: $cacheKey');
      return right(_monthCache[cacheKey]!);
    }

    try {
      final result = await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.workoutCalendar,
          queryParameters: {'year': year, 'month': month},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 &&
              res.data != null &&
              res.data is Map<String, dynamic>) {
            return right<ApiException, Map<String, dynamic>>(
              res.data as Map<String, dynamic>,
            );
          }
          return left<ApiException, Map<String, dynamic>>(
            const ApiException.unknown(),
          );
        },
      ) as Either<ApiException, Map<String, dynamic>>;

      // Store successful response in cache
      result.fold(
        (_) => null,
        (data) {
          _monthCache[cacheKey] = data as Map<String, dynamic>;
          debugPrint('[CalendarCache] Cached month: $cacheKey');
        },
      );

      return result;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<PresetModel>>> getPresets() async {
    try {
      final res = await _dio.get<dynamic>(
        ApiUris.presets,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 200 && res.data != null && res.data is List) {
        final list =
            (res.data as List)
                .map((e) => PresetModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return right(list);
      }
      return right([]);
    } catch (e) {
      debugPrint('API Error loading presets: $e');
      return right([]);
    }
  }

  Future<Either<ApiException, PresetModel>> createPreset({
    required String title,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final body = {'title': title, 'exercises': exercises};
    try {
      final res = await _dio.post<dynamic>(
        ApiUris.presets,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        return right(PresetModel.fromJson(res.data as Map<String, dynamic>));
      }
      return left(const ApiException.unknown());
    } catch (e) {
      debugPrint('API Error creating preset: $e');
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> getPresetDetail(
    int id,
  ) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiUris.presetDetail(id),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 200 &&
          res.data != null &&
          res.data is Map<String, dynamic>) {
        return right(res.data as Map<String, dynamic>);
      }
      return left(const ApiException.unknown());
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> updatePlanName({
    required int planId,
    required String newName,
  }) async {
    try {
      final detailRes = await _dio.get<dynamic>(
        ApiUris.presetDetail(planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (detailRes.statusCode == 200 && detailRes.data != null) {
        final data = detailRes.data as Map<String, dynamic>;
        data['plan_name'] = newName;
        data['title'] = newName;

        await _dio.put<dynamic>(
          ApiUris.presetDetail(planId),
          data: data,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }
      return right(null);
    } catch (e) {
      debugPrint("Error updating plan name: $e");
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, PresetModel>> updatePreset({
    required int presetId,
    required String title,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final body = {'title': title, 'exercises': exercises};
    try {
      final res = await _dio.put<dynamic>(
        ApiUris.presetDetail(presetId),
        data: body,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 200 && res.data != null) {
        return right(PresetModel.fromJson(res.data as Map<String, dynamic>));
      }
      return left(const ApiException.unknown());
    } catch (e) {
      debugPrint('API Error updating preset: $e');
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> deletePreset({
    required int presetId,
  }) async {
    try {
      final res = await _dio.delete<dynamic>(
        ApiUris.presetDetail(presetId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (res.statusCode == 204 || res.statusCode == 200) {
        return right(null);
      }
      return left(const ApiException.unknown());
    } catch (e) {
      debugPrint('API Error deleting preset: $e');
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> toggleRestDay({
    required int planDayId,
    required String date,
    required bool isRestDay,
    int? customerWorkoutPlanId,
  }) async {
    try {
      final data = <String, dynamic>{
        'plan_day_id': planDayId,
        'date': date,
        'is_rest_day': isRestDay,
      };
      if (customerWorkoutPlanId != null) {
        data['customer_workout_plan_id'] = customerWorkoutPlanId;
      }

      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.restDay,
          data: data,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 &&
              res.data != null &&
              res.data is Map<String, dynamic>) {
            return right(res.data as Map<String, dynamic>);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>>> updateRestDaysBulk({
    required int customerWorkoutPlanId,
    required List<Map<String, dynamic>> restDays,
  }) async {
    try {
      final data = <String, dynamic>{
        'customer_workout_plan_id': customerWorkoutPlanId,
        'rest_days': restDays,
      };

      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.restDay,
          data: data,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 &&
              res.data != null &&
              res.data is Map<String, dynamic>) {
            return right(res.data as Map<String, dynamic>);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, void>> postGymLead({
    required String gymName,
    required int userId,
    required String userName,
  }) async {
    try {
      final data = <String, dynamic>{
        'gym_name': gymName,
        'user_id': userId,
        'user_name': userName,
      };

      return await Feggy.async(
        call: _dio.post<dynamic>(
          '/api/v1/gym-leads/',
          data: data,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 || res.statusCode == 201) {
            return right(null);
          }
          return left(const ApiException.unknown());
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }
}
