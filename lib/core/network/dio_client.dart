import 'dart:convert';
import 'package:customer_mobile_app/core/network/authInterceptor.dart';
import 'package:customer_mobile_app/src/app/cubit/app_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio();
    _dio.interceptors.addAll([
      PrettyDioLogger(requestHeader: true, requestBody: true),
      CurlLoggerInterceptor(),
    ]);
  }

  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;
  bool _authInterceptorAdded = false;

  Dio get dio => _dio;

  /// Register AuthInterceptor once AppCubit is available
  void registerAuthInterceptor(AppCubit appCubit) {
    if (!_authInterceptorAdded) {
      _dio.interceptors.add(AuthInterceptor(appCubit, _dio));
      _authInterceptorAdded = true;
      print('✅ AuthInterceptor registered with DioClient');
    }
  }
}

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final url = options.uri.toString();

    final headers = options.headers.entries
        .map((e) => '-H "${e.key}: ${e.value}"')
        .join(' \\\n  ');

    var data = "";
    if (options.data != null) {
      try {
        data = "-d '${jsonEncode(options.data)}'";
      } catch (_) {
        data = "-d '${options.data}'";
      }
    }

    final curl = '''
curl -X $method "$url" \\
  $headers \\
  $data
''';

    if (kDebugMode) {
      print('===== CURL REQUEST =====');
    }
    if (kDebugMode) {
      print(curl);
    }
    if (kDebugMode) {
      print('========================');
    }

    super.onRequest(options, handler);
  }
}

//
// import 'dart:convert';
//
// import 'package:customer_mobile_app/imports_bindings.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//
// class DioClient {
//   factory DioClient() => _instance;
//
//   DioClient._internal() {
//     _dio = Dio();
//
//     _dio.interceptors.addAll([
//       /// 🔐 AUTH + PLATFORM INTERCEPTOR (IMPORTANT)
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           final cubit = Feggy.read<AppCubit>();
//           final token = cubit?.state.currentUser?.access;
//
//           if (token != null && token.isNotEmpty) {
//             options.headers['Authorization'] = 'JWT $token';
//           }
//
//           options.headers['X-Platform'] = platformSource;
//
//           handler.next(options);
//         },
//       ),
//
//       /// 🧾 LOGGERS
//       PrettyDioLogger(
//         requestHeader: true,
//         requestBody: true,
//       ),
//       CurlLoggerInterceptor(),
//     ]);
//   }
//
//   static final DioClient _instance = DioClient._internal();
//
//   late final Dio _dio;
//
//   Dio get dio => _dio;
// }
//
// class CurlLoggerInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     final method = options.method;
//     final url = options.uri.toString();
//
//     final headers = options.headers.entries
//         .map((e) => '-H "${e.key}: ${e.value}"')
//         .join(' \\\n  ');
//
//     var data = "";
//     if (options.data != null) {
//       try {
//         data = "-d '${jsonEncode(options.data)}'";
//       } catch (_) {
//         data = "-d '${options.data}'";
//       }
//     }
//
//     final curl = '''
// curl -X $method "$url" \\
//   $headers \\
//   $data
// ''';
//
//     if (kDebugMode) {
//       print('===== CURL REQUEST =====');
//       print(curl);
//       print('========================');
//     }
//
//     super.onRequest(options, handler);
//   }
// }
