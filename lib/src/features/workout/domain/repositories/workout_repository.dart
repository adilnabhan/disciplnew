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
        onSuccess: (res) => _handleListResponse(
          res,
          ExerciseLibraryModel.fromJson,
        ),
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
        onSuccess: (res) => _handleListResponse(
          res,
          MuscleGroupModel.fromJson,
        ),
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
        onSuccess: (res) => _handleListResponse(
          res,
          EquipmentModel.fromJson,
        ),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, List<ExerciseTypeModel>>> getExerciseTypes() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.exerciseTypes,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) => _handleListResponse(
          res,
          ExerciseTypeModel.fromJson,
        ),
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
          if ((res.statusCode == 201 || res.statusCode == 200) && res.data != null) {
            return right(ExerciseLibraryModel.fromJson(res.data as Map<String, dynamic>));
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
