import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

@immutable
final class HomeRepository {
  ///* This constructor body for creating singleton widget
  factory HomeRepository() {
    _instance ??= HomeRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  HomeRepository._internal();

  //* This variable for store this class object globally
  static HomeRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/customer-homepage} https://discipl-backend.onrender.com/api/v1/customer/customer-homepage
  /// @apiName home
  /// @apiGroup Home

  /// @apiSuccess {HomeModel} response Success response

  Future<Either<ApiException, HomeModel>> home() async {
    print('api ---is ${ ApiUris.home}');
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.home,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),

        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                HomeModel.fromJson(res.data as Map<String, dynamic>),
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
