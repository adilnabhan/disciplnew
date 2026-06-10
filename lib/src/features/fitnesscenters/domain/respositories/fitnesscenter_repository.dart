import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

@immutable
final class FitnesscenterRepository {
  ///* This constructor body for creating singleton widget
  factory FitnesscenterRepository() {
    _instance ??= FitnesscenterRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  FitnesscenterRepository._internal();

  //* This variable for store this class object globally
  static FitnesscenterRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// Helper for map-based responses
  Either<ApiException, T> _handleMapResponse<T>(
    Response<dynamic> res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (res.statusCode == 200 && res.data != null && res.data is Map) {
      return right(fromJson(res.data as Map<String, dynamic>));
    }
    return left(const ApiException.unknown());
  }

  /// Helper for list-based responses
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

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/nearest/fitnesscenter/16} https://discipl-backend.onrender.com/api/v1/customer/nearest/fitnesscenter/16
  /// @apiName fitnesscenter_details
  /// @apiGroup Fitnesscenter
  ///
  /// @apiSuccess {FitnesscenterDetailsModel} response Success response
  Future<Either<ApiException, FitnesscenterDetailsModel>> fitnesscenterDetails({
    required int id,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.fitnesscenterDetails(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) =>
                _handleMapResponse(res, FitnesscenterDetailsModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/membership-plans/16} https://discipl-backend.onrender.com/api/v1/customer/membership-plans/16
  /// @apiName fitnesscenter_membership_plans
  /// @apiGroup Fitnesscenter
  ///
  /// @apiSuccess {List<FitnesscenterMembershipPlansModel>} response Success response
  Future<Either<ApiException, List<FitnesscenterMembershipPlansModel>>>
  fitnesscenterMembershipPlans({required int id}) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.fitnesscenterMembershipPlans(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleListResponse(
              res,
              FitnesscenterMembershipPlansModel.fromJson,
            ),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/categories} https://discipl-backend.onrender.com/api/v1/fitnesscenter/categories
  /// @apiName fitnesscenter_categories
  /// @apiGroup Fitnesscenter
  ///
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// name=gym
  /// ```
  ///
  /// @apiSuccess {FitnesscenterCategoriesModel} response Success response
  Future<Either<ApiException, FitnesscenterCategoriesModel>>
  fitnesscenterCategories({Map<String, dynamic>? queryParameters}) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.fitnesscenterCategories,
          options: Options(headers: {'X-Platform': platformSource}).token,
          queryParameters: queryParameters,
        ),
        onSuccess:
            (res) =>
                _handleMapResponse(res, FitnesscenterCategoriesModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/nearest/fitnesscenter} https://discipl-backend.onrender.com/api/v1/customer/nearest/fitnesscenter
  /// @apiName list_fitnesscenter
  /// @apiGroup Fitnesscenter
  ///
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// lat=40.7128, lon=-74.0060, radius_km=15, category_id=2, search=max fit 66
  /// ```
  ///
  /// @apiSuccess {ListFitnesscenterModel} response Success response
  Future<Either<ApiException, ListFitnesscenterModel>> listFitnesscenter({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          nextUrl ?? ApiUris.listFitnesscenter,
          options: Options(headers: {'X-Platform': platformSource}).token,
          queryParameters: queryParameters,
        ),
        onSuccess:
            (res) => _handleMapResponse(res, ListFitnesscenterModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }
}
