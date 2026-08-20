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
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> listData = [];
        if (response.data is List) {
          listData = response.data as List;
        } else if (response.data is Map) {
          final Map<String, dynamic> data = response.data as Map<String, dynamic>;
          if (data.containsKey('trainers') && data['trainers'] is List) {
            listData = data['trainers'] as List;
          } else if (data.containsKey('results') && data['results'] is List) {
            listData = data['results'] as List;
          } else if (data.containsKey('id')) {
            listData = [data];
          }
        }

        return listData.map((json) {
          final Map<String, dynamic> t = Map<String, dynamic>.from(json as Map);
          if (!t.containsKey('name') || t['name'] == null || t['name'].toString().trim().isEmpty) {
            final fullName = t['full_name'] as String?;
            if (fullName != null && fullName.trim().isNotEmpty) {
              t['name'] = fullName;
            } else {
              final firstName = t['first_name']?.toString() ?? '';
              final lastName = t['last_name']?.toString() ?? '';
              final assembled = '$firstName $lastName'.trim();
              if (assembled.isNotEmpty) {
                t['name'] = assembled;
              }
            }
          }

          GymTrainer? fullTrainer;
          try {
            fullTrainer = GymTrainer.fromApiJson(t);
          } catch (e) {
            debugPrint('Error parsing GymTrainer in fetchAssignedGymTrainers: $e');
          }
          final model = AssignedTrainerModel.fromJson(t);
          return model.copyWith(fullGymTrainer: fullTrainer);
        }).toList();
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

