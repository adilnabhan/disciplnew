import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/app_season_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/banner_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_challenge_model.dart';
import 'package:dio/dio.dart';

@immutable
final class HomeRepository {
  ///* This constructor body for creating singleton widget
  factory HomeRepository() {
    _instance ??= HomeRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  HomeRepository._internal();

  //* This variable for store this class object globally
  static HomeRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/customer-homepage} https://discipl-backend.onrender.com/api/v1/customer/customer-homepage
  /// @apiName home
  /// @apiGroup Home

  /// @apiSuccess {HomeModel} response Success response

  Future<Either<ApiException, HomeModel>> home() async {
    print('api ---is ${ ApiUris.home}');
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.home,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),

        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                HomeModel.fromJson(res.data as Map<String, dynamic>),
              );
            }
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

  /// GET /api/v1/fitnesscenter/gym-banners/?organization_id=<id>
  Future<List<BannerModel>> fetchGymBanners(int organizationId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.gymBanners(organizationId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is List) {
        final list = (response.data as List)
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .where((b) => b.isActive ?? true)
            .where((b) =>
                b.visibility == null ||
                b.visibility == 'both' ||
                b.visibility == 'customer')
            .toList();
        list.sort(
          (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
        );
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching gym banners: $e');
    }
    return [];
  }

  /// GET /api/v1/fitnesscenter/global-banners/
  Future<List<BannerModel>> fetchGlobalBanners() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.globalBanners,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is List) {
        final list = (response.data as List)
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .where((b) => b.isActive ?? true)
            .where((b) =>
                b.visibility == null ||
                b.visibility == 'both' ||
                b.visibility == 'customer')
            .toList();
        list.sort(
          (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
        );
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching global banners: $e');
    }
    return [];
  }

  /// GET /api/v1/fitnesscenter/banners/
  Future<List<BannerModel>> fetchPromotionalBanners({
    int? organizationId,
    String? bannerType,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (organizationId != null) queryParams['organization_id'] = organizationId;
      if (bannerType != null) queryParams['banner_type'] = bannerType;

      final response = await _dio.get<dynamic>(
        ApiUris.promotionalBanners,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is List) {
        final list = (response.data as List)
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .where((b) => b.isActive ?? true)
            .toList();
        list.sort(
          (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
        );
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching promotional banners: $e');
    }
    return [];
  }

  /// GET /api/v1/customer/gym-trainers/
  Future<List<AssignedTrainerModel>> fetchAssignedGymTrainers() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.assignedGymTrainers,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 && response.data != null && response.data is Map) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        if (data.containsKey('trainers') && data['trainers'] is List) {
          return (data['trainers'] as List).map((json) {
            final t = json as Map<String, dynamic>;
            return AssignedTrainerModel(
              id: t['id'] as int?,
              name: (t['full_name'] as String?) ??
                  '${t['first_name'] ?? ''} ${t['last_name'] ?? ''}'.trim(),
              profileImage: t['profile_image'] as String?,
              mobile: t['mobile'] as String?,
              experienceYears: t['experience_years'] as int?,
              bio: t['bio'] as String?,
              specializations: (t['specializations'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList(),
              userType: t['user_type'] as String?,
              rating: (t['rating'] as num?)?.toDouble(),
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching assigned gym trainers: $e');
    }
    return [];
  }

  /// GET /api/v1/customer/challenges/home/
  Future<List<HomeChallenge>> getHomeChallenges() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.homeChallenges,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final challengeResponse = HomeChallengeResponse.fromJson(data);
        return challengeResponse.results ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching home challenges: $e');
    }
    return [];
  }

  static AppSeasonModel? cachedSeasonModel;

  /// GET /api/v1/customer/app-season/
  Future<AppSeasonModel> fetchAppSeason() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.appSeason,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final model =
            AppSeasonModel.fromJson(response.data as Map<String, dynamic>);
        cachedSeasonModel = model;
        return model;
      }
    } catch (e) {
      debugPrint('Error fetching app season: $e');
    }
    return cachedSeasonModel ?? const AppSeasonModel(isActive: false);
  }
}

