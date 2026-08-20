import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:dio/dio.dart';

@immutable
final class ScoreCardRepository {
  factory ScoreCardRepository() {
    _instance ??= ScoreCardRepository._internal();
    return _instance!;
  }

  ScoreCardRepository._internal();

  static ScoreCardRepository? _instance;

  final Dio _dio = DioClient().dio;

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

  Future<Either<ApiException, ScoreCardResponseModel>> getScoreCard({
    String timeframe = 'monthly',
    int page = 1,
    int pageSize = 20,
    int? gymId,
  }) async {
    try {
      final String url = gymId != null ? ApiUris.gymScoreCard(gymId) : ApiUris.scoreCard;
      return await Feggy.async(
        call: _dio.get<dynamic>(
          url,
          queryParameters: {
            'timeframe': timeframe,
            'page': page,
            'page_size': pageSize,
          },
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) => _handleMapResponse(res, ScoreCardResponseModel.fromJson),
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('Error fetching score card: $e');
      return left(const ApiException.unknown());
    }
  }
}
