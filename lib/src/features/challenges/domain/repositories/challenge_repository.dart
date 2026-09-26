import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/all_challenge_winners_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_details_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/winner_popup_model.dart';
import 'package:dio/dio.dart';

@immutable
final class ChallengeRepository {
  factory ChallengeRepository() {
    _instance ??= ChallengeRepository._internal();
    return _instance!;
  }

  ChallengeRepository._internal();

  static ChallengeRepository? _instance;
  final Dio _dio = DioClient().dio;

  /// GET /api/v1/customer/challenges/
  Future<ChallengeListResponse> getChallenges({
    int page = 1,
    int pageSize = 10,
    String? status,
    String? challengeType,
    String? category,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status.toLowerCase();
      }
      if (challengeType != null && challengeType.isNotEmpty) {
        String type = challengeType.toLowerCase();
        if (type == 'community') {
          type = 'community_goal';
        }
        queryParams['challenge_type'] = type;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category.toLowerCase();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get<dynamic>(
        ApiUris.challengesList,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return ChallengeListResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching challenges list: $e');
    }
    return const ChallengeListResponse(results: []);
  }

  /// GET /api/v1/customer/challenges/{challenge_id}/
  Future<ChallengeDetailsResponse?> getChallengeDetails(int challengeId) async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = '${ApiUris.challengesList}$challengeId/';
      final response = await _dio.get<dynamic>(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return ChallengeDetailsResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching challenge details for $challengeId: $e');
    }
    return null;
  }

  /// POST /api/v1/customer/challenges/{id}/join/
  Future<JoinChallengeResponse> joinChallenge(int challengeId) async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = '${ApiUris.challengesList}$challengeId/join/';
      final response = await _dio.post<dynamic>(
        url,
        options: Options(headers: headers),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return JoinChallengeResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        return JoinChallengeResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
        );
      }
      debugPrint('Error joining challenge $challengeId: $e');
    } catch (e) {
      debugPrint('Error joining challenge $challengeId: $e');
    }
    return const JoinChallengeResponse(
      status: false,
      error: 'Failed to join challenge. Please try again.',
    );
  }

  /// GET /api/v1/customer/challenges/winner-popup/
  Future<WinnerPopupResponse> getWinnerPopup() async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get<dynamic>(
        ApiUris.winnerPopup,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        return WinnerPopupResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('Error fetching winner popup: $e');
    }
    return const WinnerPopupResponse(showPopup: false);
  }

  /// POST /api/v1/customer/challenges/winner-popup/seen/
  Future<bool> markWinnerPopupSeen(int challengeId) async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post<dynamic>(
        ApiUris.markWinnerPopupSeen,
        data: {'challenge_id': challengeId},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Error marking winner popup seen for $challengeId: $e');
    }
    return false;
  }

  /// GET /api/v1/customer/challenges/all-winners/
  Future<AllChallengeWinnersResponse> getAllChallengeWinners({
    int? challengeId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (challengeId != null && challengeId > 0) {
        queryParams['challenge_id'] = challengeId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final Map<String, dynamic> headers = {
        'X-Platform': platformSource,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get<dynamic>(
        ApiUris.allChallengeWinners,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return AllChallengeWinnersResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching all challenge winners: $e');
    }
    return const AllChallengeWinnersResponse(winners: []);
  }
}
