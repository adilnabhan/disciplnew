import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_shop_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/qr_history_model.dart';

@immutable
final class RewardsRepository {
  factory RewardsRepository() {
    _instance ??= RewardsRepository._internal();
    return _instance!;
  }

  RewardsRepository._internal();

  static RewardsRepository? _instance;
  final Dio _dio = DioClient().dio;

  /// GET /api/v1/partners/my-qr/
  Future<PartnerQrModel> getMyPartnerQr() async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final headers = <String, dynamic>{'X-Platform': platformSource};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get<dynamic>(
        ApiUris.myPartnerQr,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return PartnerQrModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching my-qr from backend: $e');
    }

    // Fallback default model for instant UI testing if backend endpoint is unavailable
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final fullName =
        '${currentUser?.firstName ?? "Member"} ${currentUser?.lastName ?? ""}'
            .trim();
    final customerId = currentUser?.id ?? 12;

    return PartnerQrModel(
      qrToken:
          'eyJjaWQiOi${customerId}LCJ0cyI6MTcyNjM0MTkyMCwiZXhwIjoxNzI2MzQyNTIwfXw4NmY5ZjhhN2IyYzQ=',
      memberCode: 'DISC-${customerId.toString().padLeft(6, '0')}',
      customerId: customerId,
      customerName: fullName.isNotEmpty ? fullName : 'Discipl Member',
      isActiveMember: true,
      isWorkoutCompleted: true,
      isStepsCompleted: true,
      isEligibleForDiscount: true,
      eligibilityStatus: 'eligible',
      eligibilityReason: 'Workout completed today! Eligible for discount.',
      membershipStatus: 'active',
      expiresInSeconds: 600,
      generatedAt: DateTime.now(),
    );
  }

  /// GET /api/v1/partners/qr-shops/
  /// Optional parameters: city, category, search, sort
  Future<List<PartnerShop>> getQrAvailableShops({
    String? city,
    String? category,
    String? search,
    String? sort,
  }) async {
    try {
      final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
      final headers = <String, dynamic>{'X-Platform': platformSource};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final queryParams = <String, dynamic>{};
      if (city != null && city.isNotEmpty && city != 'All') {
        queryParams['city'] = city;
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category.toLowerCase();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final response = await _dio.get<dynamic>(
        ApiUris.partnerQrShops,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic>? resultsList;
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['results'] is List) {
            resultsList = data['results'] as List<dynamic>;
          }
        } else if (response.data is List) {
          resultsList = response.data as List<dynamic>;
        }

        if (resultsList != null && resultsList.isNotEmpty) {
          final shops =
              resultsList
                  .whereType<Map<String, dynamic>>()
                  .map(PartnerShop.fromJson)
                  .toList();
          return shops;
        }
      }
    } catch (e) {
      debugPrint('Error fetching qr-shops from backend: $e');
    }

    // Return empty list if no partner shops found from API
    return <PartnerShop>[];
  }

  /// GET /api/v1/partners/my-transactions/
  /// Optional parameters: shopId, search, customerId
  Future<PartnerTransactionsResponse> getMyPartnerTransactions({
    int? shopId,
    String? search,
    int? customerId,
  }) async {
    try {
      final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
      final token = currentUser?.access;
      final headers = <String, dynamic>{'X-Platform': platformSource};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final queryParams = <String, dynamic>{};
      if (shopId != null) {
        queryParams['shop_id'] = shopId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      final resolvedCustomerId = customerId ?? currentUser?.id;
      if (resolvedCustomerId != null) {
        queryParams['customer_id'] = resolvedCustomerId;
      }

      final response = await _dio.get<dynamic>(
        ApiUris.partnerMyTransactions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return PartnerTransactionsResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching my-transactions from backend: $e');
    }

    // Return empty transactions response if no data returned from backend
    return const PartnerTransactionsResponse(
      summary: UserSavingsSummaryModel.empty,
      items: [],
    );
  }
}
