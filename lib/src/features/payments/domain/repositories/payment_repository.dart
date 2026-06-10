import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
final class PaymentRepository {
  ///* This constructor body for creating singleton widget
  factory PaymentRepository() {
    _instance ??= const PaymentRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const PaymentRepository._internal();

  //* This variable for store this class object globally
  static PaymentRepository? _instance;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/payment-history} https://discipl-backend.onrender.com/api/v1/customer/payment-history
  /// @apiName payment_history
  /// @apiGroup Payment

  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// sort=custom, year=2025, start_date=2023-05-01, end_date=2025-09-30
  /// ```

  /// @apiSuccess {PaymentHistoryModel} response Success response

  Future<Either<ApiException, PaymentHistoryModel>> paymentHistory({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          nextUrl ?? ApiUris.paymentHistory,
          options: Options(headers: {'X-Platform': platformSource}).token,
          queryParameters: queryParameters,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                PaymentHistoryModel.fromJson(res.data as Map<String, dynamic>),
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

  Future<Either<ApiException, PaymentHistoryDetailsModel>>
  paymentHistoryDetails({
    // required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          nextUrl ?? ApiUris.paymentDetailsHistory,
          options: Options(headers: {'X-Platform': platformSource}).token,
          // queryParameters: queryParameters,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              print('the history responce is---${res.data}');
              return right(
                PaymentHistoryDetailsModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
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
}
