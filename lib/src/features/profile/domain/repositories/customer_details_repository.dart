import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
final class CustomerDetailsRepository {
  ///* This constructor body for creating singleton widget
  factory CustomerDetailsRepository() {
    _instance ??= const CustomerDetailsRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const CustomerDetailsRepository._internal();

  //* This variable for store this class object globally
  static CustomerDetailsRepository? _instance;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/manage/7} https://discipl-backend.onrender.com/api/v1/customer/manage/7
  /// @apiName customer_details
  /// @apiGroup CustomerDetails

  /// @apiSuccess {CustomerDetailsModel} response Success response

  Future<Either<ApiException, CustomerDetailsModel>> customerDetails({
    required int id,
  }) async {
    print('calling--$id}');
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          ApiUris.customerDetails(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                CustomerDetailsModel.fromJson(res.data as Map<String, dynamic>),
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

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/customer/manage/42/update/} https://discipl-backend.onrender.com/api/v1/customer/manage/42/update/
  /// @apiName update_profile_details
  /// @apiGroup CustomerDetails

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "first_name": "John",
  ///   "last_name": "Doe",
  ///   "email": "john.doe@example.com",
  ///   "date_of_birth": "1990-01-15",
  ///   "gender": "male",
  ///   "emergency_contact_number": "+919876543210",
  ///   "profession": "Engineer"
  /// }
  /// ```

  /// @apiSuccess {CustomerDetailsModel} response Success response

  // Future<Either<ApiException, CustomerDetailsModel>> updateProfileDetails({
  //   required int id,
  //   required dynamic body,
  //   // required Map<String, dynamic> body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: Dio().patch<dynamic>(
  //         ApiUris.updateCustomerProfile,
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess: (res) {
  //         if (res.statusCode == 200 || res.statusCode == 201) {
  //           if (res.data != null && res.data is Map) {
  //             return customerDetails(id: id);
  //           }
  //         }
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException catch (e) {
  //     return left(e);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, CustomerDetailsModel>> updateProfileDetails({
    required int id,
    required dynamic body,
  }) async {
    try {
      final response = await Dio().request<dynamic>(
        ApiUris.updateCustomerProfile,
        data: body,
        options:
            Options(
              method: 'PATCH',
              headers: {
                'X-Platform': platformSource,
                'Content-Type': 'application/json',
              },
            ).token,
      );

      print('status code is -- ${response.statusCode}');
      final statusCode = response.statusCode ?? 0;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map) {
          return customerDetails(id: id);
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('update profile dio error -- $e');

      // API returned structured error
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstMessage = data[firstKey][0];
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

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/customer/manage/42/profile/health/} https://discipl-backend.onrender.com/api/v1/customer/manage/42/profile/health/
  /// @apiName update_health_profile
  /// @apiGroup CustomerDetails

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "height": "180",
  ///   "weight": "75",
  ///   "blood_group": "B+",
  ///   "fitness_level": "intermediate",
  ///   "stress_level": "low",
  ///   "weight_goal": "maintain",
  ///   "target_weight": "75",
  ///   "sleep_goal": "8",
  ///   "injuries": [],
  ///   "medical_conditions": []
  /// }
  /// ```

  /// @apiSuccess {CustomerDetailsModel} response Success response

  Future<Either<ApiException, CustomerDetailsModel>> updateHealthProfile({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().patch<dynamic>(
          ApiUris.updateCustomerProfile,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 || res.statusCode == 201) {
            if (res.data != null && res.data is Map) {
              return customerDetails(id: id);
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
