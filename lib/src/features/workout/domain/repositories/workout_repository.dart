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
}
