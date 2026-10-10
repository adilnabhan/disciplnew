import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/body_measurement_model.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/body_matrix_model.dart';
import 'package:dio/dio.dart';

final class CustomerDetailsRepository {
  ///* This constructor body for creating singleton widget
  factory CustomerDetailsRepository() {
    _instance ??= CustomerDetailsRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  CustomerDetailsRepository._internal();

  //* This variable for store this class object globally
  static CustomerDetailsRepository? _instance;

  // Caching fields
  CustomerDetailsModel? _cachedCustomerDetails;
  DateTime? _lastDetailsFetchTime;

  /// Invalidate/clear the customer details cache
  void invalidateCache() {
    _cachedCustomerDetails = null;
    _lastDetailsFetchTime = null;
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/manage/7} https://discipl-backend.onrender.com/api/v1/customer/manage/7
  /// @apiName customer_details
  /// @apiGroup CustomerDetails

  /// @apiSuccess {CustomerDetailsModel} response Success response

  Future<Either<ApiException, CustomerDetailsModel>> customerDetails({
    required int id,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedCustomerDetails != null &&
        _cachedCustomerDetails!.id == id &&
        _lastDetailsFetchTime != null &&
        now.difference(_lastDetailsFetchTime!).inMinutes < 5) {
      print('CustomerDetailsRepository: returning cached details for id -- $id');
      return right(_cachedCustomerDetails!);
    }

    print('CustomerDetailsRepository: calling API for id -- $id');
    try {
      final response = await Feggy.async<Response<dynamic>, Either<ApiException, CustomerDetailsModel>>(
        call: Dio().get<dynamic>(
          ApiUris.customerDetails(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                CustomerDetailsModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );

      response.fold(
        (_) => null,
        (details) {
          _cachedCustomerDetails = details;
          _lastDetailsFetchTime = DateTime.now();
        },
      );
      return response;
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
                if (body is! FormData) 'Content-Type': 'application/json',
              },
            ).token,
      );

      print('status code is -- ${response.statusCode}');
      final statusCode = response.statusCode ?? 0;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map) {
          return customerDetails(id: id, forceRefresh: true);
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
      final cleanBody = Map<String, dynamic>.from(body);
      cleanBody.removeWhere((key, value) =>
          value == null || (value is String && value.trim().isEmpty));

      final response = await Dio().request<dynamic>(
        ApiUris.updateCustomerProfile,
        data: cleanBody,
        options: Options(
          method: 'PATCH',
          headers: {
            'X-Platform': platformSource,
            'Content-Type': 'application/json',
          },
        ).token,
      );

      print('update health profile status code is -- ${response.statusCode}');

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        if (response.data != null && response.data is Map) {
          return customerDetails(id: id, forceRefresh: true);
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('update health profile dio error -- $e');

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final val = data[firstKey];
          final msgStr = (val is List && val.isNotEmpty)
              ? val.first.toString()
              : val.toString();
          return left(ApiException.unknown(msg: '$firstKey: $msgStr'));
        } else if (data is String && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to update health metrics.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {PATCH /api/v1/customer/profile/}
  Future<Either<ApiException, CustomerDetailsModel>> updateCustomerProfile({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final cleanBody = Map<String, dynamic>.from(body);
      cleanBody.removeWhere((key, value) =>
          value == null || (value is String && value.trim().isEmpty));

      final response = await Dio().request<dynamic>(
        ApiUris.customerProfile,
        data: cleanBody,
        options: Options(
          method: 'PATCH',
          headers: {
            'X-Platform': platformSource,
            'Content-Type': 'application/json',
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        return customerDetails(id: id, forceRefresh: true);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('message')) {
          return left(ApiException.unknown(msg: data['message'].toString()));
        }
      }
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to update customer profile.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/customer/manage/profile/email-update/}
  Future<Either<ApiException, CustomerDetailsModel>> updateEmail({
    required String email,
  }) async {
    final trimmedEmail = email.trim();
    try {
      final response = await Dio().request<dynamic>(
        ApiUris.updateEmail,
        data: {'email': trimmedEmail},
        options: Options(
          method: 'PATCH',
          headers: {
            'X-Platform': platformSource,
            'Content-Type': 'application/json',
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        if (_cachedCustomerDetails != null) {
          _cachedCustomerDetails = _cachedCustomerDetails!.copyWith(email: trimmedEmail);
        }
        final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
        if (id != null) {
          return customerDetails(id: id, forceRefresh: true);
        }
        if (_cachedCustomerDetails != null) {
          return right(_cachedCustomerDetails!);
        }
      }

      return left(
        const ApiException.unknown(
          msg: "Couldn't update your email. Please try again.",
        ),
      );
    } on DioException catch (e) {
      print('update email dio error -- $e');

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final val = data[firstKey];
          final msgStr = (val is List && val.isNotEmpty)
              ? val.first.toString()
              : val.toString();
          return left(ApiException.unknown(msg: msgStr));
        } else if (data is String && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? "Couldn't update your email. Please try again.",
        ),
      );
    } catch (e) {
      return left(
        const ApiException.unknown(
          msg: "Couldn't update your email. Please try again.",
        ),
      );
    }
  }

  Future<Either<ApiException, List<Profession>>> fetchProfessionsList() async {
    try {
      final response = await Feggy.async<Response<dynamic>, Either<ApiException, List<Profession>>>(
        call: DioClient().dio.get<dynamic>(
          ApiUris.professionsList,
          options: Options(headers: {
            'X-Platform': platformSource,
            'Accept': 'application/json',
          }),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              final professionsData = (res.data['data'] ?? res.data['professions']) as List?;
              if (professionsData != null) {
                final list = professionsData
                    .map((e) => Profession.fromJson(e as Map<String, dynamic>))
                    .toList();
                return right(list);
              }
            }
          }
          return left(const ApiException.unknown());
        },
      );
      return response;
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  Future<Either<ApiException, CustomerDetailsModel>> updateProfessionDetails({
    required int id,
    required String profession,
    String? otherProfession,
    int? jobSatisfaction,
    String? workingHours,
  }) async {
    try {
      final body = {
        'profession': profession,
        if (otherProfession != null) 'other_profession': otherProfession,
        if (jobSatisfaction != null) 'job_satisfaction': jobSatisfaction,
        if (workingHours != null) 'working_hours': workingHours,
      };

      final response = await Dio().request<dynamic>(
        ApiUris.updateProfession,
        data: body,
        options: Options(
          method: 'PATCH',
          headers: {
            'X-Platform': platformSource,
            'Content-Type': 'application/json',
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        return customerDetails(id: id, forceRefresh: true);
      }

      return left(
        const ApiException.unknown(
          msg: "Couldn't update your profession. Please try again.",
        ),
      );
    } on DioException catch (e) {
      print('update profession dio error -- $e');

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final val = data[firstKey];
          final msgStr = (val is List && val.isNotEmpty)
              ? val.first.toString()
              : val.toString();
          return left(ApiException.unknown(msg: msgStr));
        } else if (data is String && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? "Couldn't update your profession. Please try again.",
        ),
      );
    } catch (e) {
      return left(
        const ApiException.unknown(
          msg: "Couldn't update your profession. Please try again.",
        ),
      );
    }
  }

  /// @api {POST https://discipl-backend.onrender.com/api/v1/customer/measurements/}
  Future<Either<ApiException, BodyMeasurementModel>> logBodyMeasurements({
    double? neck,
    double? waist,
    double? hip,
    double? chest,
    double? biceps,
    double? thighs,
  }) async {
    try {
      final body = <String, dynamic>{
        if (neck != null) 'neck': neck,
        if (waist != null) 'waist': waist,
        if (hip != null) 'hip': hip,
        if (chest != null) 'chest_cm': chest,
        if (biceps != null) 'biceps_cm': biceps,
        if (thighs != null) 'thighs_cm': thighs,
      };

      final response = await Dio().post<dynamic>(
        ApiUris.bodyMeasurements,
        data: body,
        options: Options(
          headers: {
            'X-Platform': platformSource,
            'Content-Type': 'application/json',
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        if (response.data != null && response.data is Map) {
          final measurement = BodyMeasurementModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
          invalidateCache();
          return right(measurement);
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('log body measurements dio error -- $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final val = data[firstKey];
          final msgStr = (val is List && val.isNotEmpty)
              ? val.first.toString()
              : val.toString();
          return left(ApiException.unknown(msg: '$firstKey: $msgStr'));
        } else if (data is String && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data));
        }
      }
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to log body measurements.',
        ),
      );
    } catch (e) {
      return left(ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'));
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/measurements/}
  Future<Either<ApiException, BodyMeasurementsHistoryModel>> fetchBodyMeasurements() async {
    try {
      final response = await Dio().get<dynamic>(
        ApiUris.bodyMeasurements,
        options: Options(
          headers: {'X-Platform': platformSource},
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200) {
        if (response.data != null) {
          if (response.data is List) {
            return right(
              BodyMeasurementsHistoryModel.fromList(
                (response.data as List).cast<dynamic>(),
              ),
            );
          } else if (response.data is Map) {
            return right(
              BodyMeasurementsHistoryModel.fromJson(
                Map<String, dynamic>.from(response.data as Map),
              ),
            );
          }
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('fetch body measurements dio error -- $e');
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to fetch body measurements.',
        ),
      );
    } catch (e) {
      return left(ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'));
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/body-matrix/}
  Future<Either<ApiException, BodyMatrixModel>> fetchBodyMatrix() async {
    try {
      final response = await Dio().get<dynamic>(
        ApiUris.bodyMatrix,
        options: Options(
          headers: {'X-Platform': platformSource},
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 && response.data != null) {
        final dataMap = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return right(BodyMatrixModel.fromJson(dataMap));
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('fetch body matrix dio error -- $e');
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to fetch body matrix.',
        ),
      );
    } catch (e) {
      return left(ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'));
    }
  }

  /// @api {GET /api/v1/customer/body-metrics/history/ or /<user_id>/}
  Future<Either<ApiException, BodyMetricsHistoryData>> fetchBodyMetricsHistory({
    dynamic userId,
    String? timeframe,
    int? limit,
    String? metric,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (timeframe != null && timeframe.isNotEmpty) {
        queryParams['timeframe'] = timeframe;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (metric != null && metric.isNotEmpty) {
        queryParams['metric'] = metric;
      }

      final url = userId != null
          ? ApiUris.customerUserBodyMetricsHistory(userId)
          : ApiUris.customerBodyMetricsHistory;

      final response = await Dio().get<dynamic>(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          headers: {'X-Platform': platformSource},
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 && response.data != null) {
        final dataMap = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return right(BodyMetricsHistoryResponse.fromJson(dataMap).data);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('fetch body metrics history dio error -- $e');
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Failed to fetch body metrics history.',
        ),
      );
    } catch (e) {
      return left(ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'));
    }
  }
}
