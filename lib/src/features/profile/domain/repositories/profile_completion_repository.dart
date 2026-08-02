import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/profile_completion_model.dart';
import 'package:dio/dio.dart';

@immutable
final class ProfileCompletionRepository {
  factory ProfileCompletionRepository() {
    _instance ??= ProfileCompletionRepository._internal();
    return _instance!;
  }

  ProfileCompletionRepository._internal();

  static ProfileCompletionRepository? _instance;

  final Dio _dio = DioClient().dio;

  Future<Either<ApiException, ProfileCompletionModel>>
  getProfileCompletion() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.profileCompletion,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          debugPrint('📋 Profile Completion API Response: ${res.data}');
          if (res.statusCode == 200 && res.data != null && res.data is Map) {
            return right(
              ProfileCompletionModel.fromJson(
                res.data as Map<String, dynamic>,
              ),
            );
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('ProfileCompletionRepository Error: $e');
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, bool>> dismissProfileCompletion() async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.profileCompletionDismiss,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          debugPrint('📋 Profile Completion Dismiss API Response: ${res.data}');
          if (res.statusCode == 200 || res.statusCode == 201) {
            return right(true);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('ProfileCompletionDismiss Error: $e');
      return left(const ApiException.unknown());
    }
  }
}
