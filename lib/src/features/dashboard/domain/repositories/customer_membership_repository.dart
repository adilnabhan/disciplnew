import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

@immutable
final class CustomerMembershipRepository {
  ///* This constructor body for creating singleton widget
  factory CustomerMembershipRepository() {
    _instance ??= CustomerMembershipRepository._internal();
    return _instance!;
  }

  CustomerMembershipRepository._internal();

  static CustomerMembershipRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// Helper for map-based responses
  Either<ApiException, T> _handleMapResponse<T>(
    Response<dynamic> res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (res.statusCode == 200 &&
        res.data != null &&
        res.data is Map<String, dynamic>) {
      return right(fromJson(res.data as Map<String, dynamic>));
    }
    return left(const ApiException.unknown());
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/manage/7/active-membership} https://discipl-backend.onrender.com/api/v1/customer/manage/7/active-membership
  /// @apiName active_membership
  /// @apiGroup CustomerMembership
  ///
  /// @apiSuccess {ActiveMembershipModel} response Success response
  Future<Either<ApiException, ActiveMembershipModel?>> activeMembership({
    required int id,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.activeMembership(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleMapResponse(res, ActiveMembershipModel.fromJson),
        customHandler: (e) {
          debugPrint("activeMembership customHandler: statusCode=${e.response?.statusCode}, data=${e.response?.data}");
          if (e.response?.statusCode == 404) {
            return const ApiException.notFound(
              msg: 'No active membership found',
            );
          }
          return null;
        },
      );
    } on ApiException catch (e) {
      if (e.msg.toString().toLowerCase().contains('no active membership')) {
        return right(null);
      }
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  // Future<Either<ApiException, ActiveMembershipModel?>> activeMembership({
  //   required int id,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.get<dynamic>(
  //         ApiUris.activeMembership(id),
  //       ),
  //       onSuccess:
  //           (res) => _handleMapResponse(res, ActiveMembershipModel.fromJson),
  //       customHandler: (e) {
  //         if (e.response?.statusCode == 404 &&
  //             (e.response?.data is Map) &&
  //             (e.response?.data as Map<String, dynamic>)['detail']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains('no active membership')) {
  //           return const ApiException.notFound(
  //             msg: 'No active membership found',
  //           );
  //         }
  //         return null;
  //       },
  //     );
  //   } on ApiException catch (e) {
  //     if (e.msg == 'No active membership found') {
  //       return right(null);
  //     }
  //     return left(e);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return left(const ApiException.unknown());
  //   }
  // }




  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/membership-org} https://discipl-backend.onrender.com/api/v1/customer/membership-org
  /// @apiName all_memberships
  /// @apiGroup CustomerMembership
  ///
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// status=active
  /// ```
  ///
  /// @apiSuccess {AllMembershipsModel} response Success response
  Future<Either<ApiException, AllMembershipsModel>> allMemberships({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.allMemberships,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleMapResponse(res, AllMembershipsModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }
}





