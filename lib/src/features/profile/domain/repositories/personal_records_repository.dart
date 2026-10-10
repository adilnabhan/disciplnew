import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

final class PersonalRecordsRepository {
  factory PersonalRecordsRepository() {
    _instance ??= PersonalRecordsRepository._internal();
    return _instance!;
  }

  PersonalRecordsRepository._internal();

  static PersonalRecordsRepository? _instance;
  final Dio _dio = DioClient().dio;

  Options _buildOptions() {
    final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
    final headers = <String, dynamic>{
      'X-Platform': platformSource,
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return Options(headers: headers);
  }

  /// GET /api/v1/customer/personal-records/
  /// or GET /api/v1/customer/personal-records/<user_id>/
  Future<Either<ApiException, PersonalRecordsData>> fetchPersonalRecords({
    String? category,
    String? search,
    dynamic userId,
    dynamic workoutId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (workoutId != null) {
        queryParams['workout_id'] = workoutId;
      }

      final url = userId != null
          ? ApiUris.personalRecordsForUser(userId)
          : ApiUris.personalRecords;

      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: _buildOptions(),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 && response.data != null) {
        final dataMap = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};

        final prResponse = PersonalRecordsResponse.fromJson(dataMap);
        return right(prResponse.data);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server ($statusCode)',
        ),
      );
    } on DioException catch (e) {
      debugPrint('PersonalRecordsRepository fetchPersonalRecords dio error: $e');
      final msg = e.response?.data is Map &&
              (e.response?.data as Map)['message'] != null
          ? (e.response?.data as Map)['message'].toString()
          : (e.message ?? 'Failed to fetch personal records.');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      debugPrint('PersonalRecordsRepository fetchPersonalRecords error: $e');
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// GET /api/v1/customer/personal-records/exercise/<workout_id>/
  /// or GET /api/v1/customer/personal-records/<user_id>/exercise/<workout_id>/
  Future<Either<ApiException, PersonalRecordDetailData>>
      fetchPersonalRecordDetail({
    required dynamic workoutId,
    dynamic userId,
    String? metric,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (metric != null && metric.isNotEmpty) {
        queryParams['metric'] = metric;
      }

      final url = userId != null
          ? ApiUris.personalRecordUserExercise(userId, workoutId)
          : ApiUris.personalRecordExercise(workoutId);

      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: _buildOptions(),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 && response.data != null) {
        final dataMap = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};

        final detailResponse = PersonalRecordDetailResponse.fromJson(dataMap);
        return right(detailResponse.data);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server ($statusCode)',
        ),
      );
    } on DioException catch (e) {
      debugPrint(
          'PersonalRecordsRepository fetchPersonalRecordDetail dio error: $e');
      final msg = e.response?.data is Map &&
              (e.response?.data as Map)['message'] != null
          ? (e.response?.data as Map)['message'].toString()
          : (e.message ?? 'Failed to fetch exercise PR details.');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      debugPrint('PersonalRecordsRepository fetchPersonalRecordDetail error: $e');
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// POST /api/v1/customer/personal-records/
  Future<Either<ApiException, bool>> logPersonalRecord({
    required int workoutId,
    required num weightKg,
    required int reps,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.personalRecords,
        data: {
          'workout_id': workoutId,
          'weight_kg': weightKg,
          'reps': reps,
        },
        options: _buildOptions(),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return right(true);
      }

      return left(
        ApiException.unknown(
          msg: 'Failed to log personal record ($statusCode)',
        ),
      );
    } on DioException catch (e) {
      debugPrint('PersonalRecordsRepository logPersonalRecord dio error: $e');
      final msg = e.response?.data is Map &&
              (e.response?.data as Map)['message'] != null
          ? (e.response?.data as Map)['message'].toString()
          : (e.message ?? 'Failed to log personal record.');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      debugPrint('PersonalRecordsRepository logPersonalRecord error: $e');
      return left(ApiException.unknown(msg: e.toString()));
    }
  }
}
