import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

@immutable
final class SubscriptionRepository {
  ///* This constructor body for creating singleton widget
  factory SubscriptionRepository() {
    _instance ??= SubscriptionRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  SubscriptionRepository._internal();

  //* This variable for store this class object globally
  static SubscriptionRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// Helper for map-based responses
  Either<ApiException, T> _handleMapResponse<T>(
    Response<dynamic> res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if ([200, 201].contains(res.statusCode) &&
        res.data != null &&
        res.data is Map) {
      return right(fromJson(res.data as Map<String, dynamic>));
    }
    return left(const ApiException.unknown());
  }

  /// @api {POST https://discipl-backend.onrender.com/api/v1/subscription/customer/create-order} https://discipl-backend.onrender.com/api/v1/subscription/customer/create-order
  /// @apiName initiate_razorpay_order
  /// @apiGroup Subscription
  ///
  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "plan_id": 6
  /// }
  /// ```
  ///
  /// @apiSuccess {InitiateRazorpayOrderModel} response Success response
  // Future<Either<ApiException, InitiateRazorpayOrderModel>>
  // initiateRazorpayOrder({required Map<String, dynamic> body}) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.post<dynamic>(
  //         ApiUris.initiateRazorpayOrder,
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess:
  //           (res) =>
  //               _handleMapResponse(res, InitiateRazorpayOrderModel.fromJson),
  //     );
  //   } on ApiException catch (e) {
  //     return left(e);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return left(ApiException.unknown(msg: e.toString()));
  //   }
  // }

  Future<Either<ApiException, InitiateRazorpayOrderModel>>
  initiateRazorpayOrder({required Map<String, dynamic> body}) async {
    try {
      final response = await Dio().request<dynamic>(
        ApiUris.initiateRazorpayOrder,
        data: body,
        options:
            Options(
              method: 'POST',
              headers: {
                'X-Platform': platformSource,
                'Content-Type': 'application/json',
              },
            ).token,
      );

      final statusCode = response.statusCode ?? 0;
      print("initiate razorpay response code -- $statusCode");

      // SUCCESS RESPONSE
      if ([200, 201].contains(response.statusCode) &&
          response.data != null &&
          response.data is Map) {
        return right(
          InitiateRazorpayOrderModel.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print("initiate razorpay dio error -- $e");
      print("initiate razorpay dio error -- ${e.response?.data}");

      // Structured API Error
      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstMessage =
              data[firstKey] is List ? data[firstKey][0] : data[firstKey];

          return left(ApiException.unknown(msg: firstMessage.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong during request.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/subscription/payment/status} https://discipl-backend.onrender.com/api/v1/subscription/payment/status
  /// @apiName check_payment_status
  /// @apiGroup Subscription
  ///
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// order_id=order_QuqM72SXctN770
  /// ```
  ///
  /// @apiSuccess {CheckPaymentStatusModel} response Success response
  Future<Either<ApiException, CheckPaymentStatusModel>> checkPaymentStatus({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.checkPaymentStatus,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleMapResponse(res, CheckPaymentStatusModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }
}
