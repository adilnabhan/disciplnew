import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/models.dart';
import 'package:dio/dio.dart';

@immutable
final class WorkoutRepository {
  factory WorkoutRepository() {
    _instance ??= WorkoutRepository._internal();
    return _instance!;
  }

  WorkoutRepository._internal();

  static WorkoutRepository? _instance;

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
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.exercises,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess:
            (res) => _handleListResponse(res, ExerciseLibraryModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<MuscleGroupModel>>> getMuscleGroups() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.muscleGroups,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) => _handleListResponse(res, MuscleGroupModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<EquipmentModel>>> getEquipment() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.equipment,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) => _handleListResponse(res, EquipmentModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<ExerciseTypeModel>>>
  getExerciseTypes() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.exerciseTypes,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess:
            (res) => _handleListResponse(res, ExerciseTypeModel.fromJson),
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
  }) async {
    try {
      final baseUrl = ApiUris.activeSession.split('/sessions/')[0];
      final url = '$baseUrl/sessions/$sessionId/finish/';
      return await Feggy.async(
        call: _dio.post<dynamic>(
          url,
          data: {'title': title},
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

  Future<Either<ApiException, dynamic>> updateSetLog({
    required int setLogId,
    int? reps,
    double? weightKg,
    bool? isCompleted,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (reps != null) body['reps'] = reps;
      if (weightKg != null) body['weight_kg'] = weightKg;
      if (isCompleted != null) body['is_completed'] = isCompleted;

      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.updateSetLog(setLogId),
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

  Future<Either<ApiException, Map<String, dynamic>>> getWorkoutCalendarForMonth({
    required int year,
    required int month,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.workoutCalendar,
          queryParameters: {'year': year, 'month': month},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null && res.data is Map<String, dynamic>) {
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
}
