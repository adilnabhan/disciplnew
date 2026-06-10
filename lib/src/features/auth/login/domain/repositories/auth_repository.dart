import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
final class AuthRepository {
  AuthRepository() : _dio = DioClient().dio;

  final Dio _dio;

  Future<Either<ApiException, SentOtpEntity>> sentOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.sentOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(
                SentOtpEntity.fromJson(res.data as Map<String, dynamic>),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, LoginSuccessModel>> loginWithOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.loginWithOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, LoginSuccessModel>> loginAsGuest() async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.loginAsGuest,

          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, LoginSuccessModel>> verifyOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.verifyOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, LoginSuccessModel>> onboarding({
    // required Map<String, dynamic> body,
    required dynamic body,
  }) async {
    return await Feggy.async(
      call: _dio.post<dynamic>(
        ApiUris.onboarding,
        data: body,
        options: Options(
          validateStatus: (_) => true,
          headers: {'X-Platform': platformSource},
        ),
      ),
      onSuccess: (res) {
        if ([200, 201].contains(res.statusCode)) {
          if (res.data != null && res.data is Map) {
            return right(
              LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
            );
          }
        }
        String message = "Something went wrong";

        final data = res.data;
        if (data != null) {
          if (data is Map && data.isNotEmpty) {
            // Take first key
            final firstKey = data.keys.first;

            // Take first error message
            message = data[firstKey][0].toString();

            return left(ApiException.unknown(msg: message));
          }
        }

        // String message = "Something went wrong";
        // if (data is Map<String, dynamic> && data.values.isNotEmpty) {
        //   message = data.values.first.toString();
        //   print('errro---${data.values.first.toString()}');
        // } else if (data is String) {
        //   message = data;
        // }
        return left(ApiException.unknown(msg: message));
      },
    );
  }

  // Future<Either<ApiException, LoginSuccessModel>> onboarding({
  //   required Map<String, dynamic> body,
  // }) async {
  //   try {
  //     final formData = FormData();
  //
  //     body.forEach((key, value) async {
  //       if (value is XFile) {
  //         formData.files.add(
  //           MapEntry(
  //             key,
  //             await MultipartFile.fromFile(value.path, filename: value.name),
  //           ),
  //         );
  //       } else {
  //         formData.fields.add(MapEntry(key, value.toString()));
  //       }
  //     });
  //
  //     return await Feggy.async(
  //       call: _dio.post<dynamic>(
  //         ApiUris.onboarding,
  //         data: formData, // ✅ Send FormData instead of JSON
  //         options: Options(
  //           validateStatus: (_) => true,
  //           headers: {
  //             'X-Platform': platformSource,
  //             'Content-Type': 'multipart/form-data', // ✅ Important
  //           },
  //         ),
  //       ),
  //       onSuccess: (res) {
  //         if ([200, 201].contains(res.statusCode)) {
  //           if (res.data != null && res.data is Map) {
  //             return right(
  //               LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
  //             );
  //           }
  //         }
  //
  //         final data = res.data;
  //         String message = "Something went wrong";
  //         if (data is Map<String, dynamic> && data.values.isNotEmpty) {
  //           message = data.values.first.toString();
  //           print('error---$message');
  //         } else if (data is String) {
  //           message = data;
  //         }
  //         return left(ApiException.unknown(msg: message));
  //       },
  //     );
  //   } catch (e) {
  //     print('Exception during onboarding: $e');
  //     return left(ApiException.unknown(msg: e.toString()));
  //   }
  // }

  Future<Either<ApiException, LoginSuccessModel>> onboardingUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    return await Feggy.async(
      call: _dio.patch<dynamic>(
        ApiUris.onboardingUpdate(id!),
        data: body,

        options: Options(
          validateStatus: (_) => true,
          headers: {'X-Platform': platformSource},
        ),
      ),
      onSuccess: (res) {
        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300) {
          return right(
            LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
          );
        }

        final data = res.data;
        String message = "Something went wrong";
        if (data is Map<String, dynamic> && data.values.isNotEmpty) {
          message = data.values.first.toString();
          print('errro---${data.values.first.toString()}');
        } else if (data is String) {
          message = data;
        }
        return left(ApiException.unknown(msg: message));
      },
    );
  }

  Future<Either<ApiException, void>> logout() async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.logout,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(null);
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, ConstantChoicesModel>> fetchConstChoices() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.constantChoices,
          options: Options(
            headers: {
              'X-Platform': platformSource,
              'Content-Type': 'application/json',
            },
          ),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              print('responce us---${res.data}');
              return right(
                ConstantChoicesModel.fromJson(res.data as Map<String, dynamic>),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  // Future<Either<ApiException, Map<String, dynamic>>> refreshToken(
  //   String refreshToken,
  // ) async {
  //   try {
  //     print('refesh tojken is--$refreshToken');
  //     return await Feggy.async(
  //       call: _dio.post<dynamic>(
  //         ApiUris.tokenRefresh,
  //         data: {"refresh_token": refreshToken},
  //         options: Options(headers: {'X-Platform': platformSource}),
  //       ),
  //       onSuccess: (res) {
  //         if (res.statusCode == 200 && res.data is Map) {
  //           return right(res.data as Map<String, dynamic>);
  //         }
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException catch (e) {
  //     return left(e);
  //   } catch (_) {
  //     return left(const ApiException.unknown());
  //   }
  // }

Future<Either<ApiException, Map<String, dynamic>>> refreshToken(
    String refreshToken,
  ) async {
    try {
      print('🌐 AuthRepository: Calling refresh token API...');
      print('📤 Sending Refresh Token: $refreshToken');
      // print('refesh tojken is--$refreshToken');
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.tokenRefresh,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data is Map) {
            print('✅ AuthRepository: Refresh token API success.');
            return right(res.data as Map<String, dynamic>);
          }
          print(
            '❌ AuthRepository: Refresh token API failed with status ${res.statusCode}',
          );
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      print('❌ AuthRepository: ApiException: $e');
      return left(e);
    } catch (_) {
      print('❌ AuthRepository: Unknown Exception');
      return left(const ApiException.unknown());
    }
  }
}

