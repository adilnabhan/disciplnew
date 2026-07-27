import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

@immutable
final class ReviewsAndReatingRepository {
  ///* This constructor body for creating singleton widget
  factory ReviewsAndReatingRepository() {
    _instance ??= const ReviewsAndReatingRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const ReviewsAndReatingRepository._internal();

  //* This variable for store this class object globally
  static ReviewsAndReatingRepository? _instance;

  static final Map<String, FitnessCenterReviewsModel> _gymReviewsCache = {};
  static final Map<String, TrainerReviewsModel> _trainerReviewsAllCache = {};
  static final Map<int, Map<String, dynamic>?> _trainerMyReviewCache = {};

  Options get _options {
    final token = Feggy.read<AppCubit>()?.state.currentUser?.access;
    final options = Options(headers: {'X-Platform': platformSource});
    if (token != null && token.isNotEmpty) {
      return options.token;
    }
    return options;
  }

  /// @api {POST https://discipl-backend.onrender.com/api/v1/customer/reviews} https://discipl-backend.onrender.com/api/v1/customer/reviews
  /// @apiName add_review
  /// @apiGroup ReviewsAndReating

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "organization": 4,
  ///   "rating": 5,
  ///   "comment": "Amazing facilities!"
  /// }
  ///
  /// ```

  /// @apiSuccess {AddReviewModel} response Success response

  Future<Either<ApiException, SingleReviewModel>> addReview({
    required Map<String, dynamic> body,
  }) async {
    try {
      final options = _options;
      options.method = 'POST';
      options.headers ??= {};
      options.headers!['Content-Type'] = 'application/json';

      final response = await Dio().request<dynamic>(
        ApiUris.addReview,
        data: body,
        options: options,
      );

      print('Add Review Status Code → ${response.statusCode}');
      final statusCode = response.statusCode ?? 0;

      // SUCCESS CHECK
      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        try {
          final model = SingleReviewModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          _gymReviewsCache.clear();
          return right(model);
        } catch (e) {
          return left(
            ApiException.unknown(
              msg: 'Failed to parse review response: ${e.toString()}',
            ),
          );
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected server response. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Add review error → $e');

      // HANDLE STRUCTURED API ERRORS
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

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/customer/reviews/1} https://discipl-backend.onrender.com/api/v1/customer/reviews/1
  /// @apiName update_review
  /// @apiGroup ReviewsAndReating

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///     "rating": 4,
  ///     "comment": "Amazing facilities!"
  /// }
  /// ```

  /// @apiSuccess {void} response Success response

  Future<Either<ApiException, void>> updateReview({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final options = _options;
      options.method = 'PATCH';
      options.headers ??= {};
      options.headers!['Content-Type'] = 'application/json';

      final url = ApiUris.updateReview(id);
      print('Update Review URL: $url');
      print('Update Review Body: $body');
      print('Update Review Headers: ${options.headers}');

      final response = await Dio().request<dynamic>(
        url,
        data: body,
        options: options,
      );

      print('Update Review Response Status Code: ${response.statusCode}');
      print('Update Review Response Data: ${response.data}');

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201 || statusCode == 204) {
        _gymReviewsCache.clear();
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Update review error → $e');
      print('Update review error response data → ${e.response?.data}');
      print('Update review error response statusCode → ${e.response?.statusCode}');
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
      print('Update review general catch error → $e');
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/customer/reviews} https://discipl-backend.onrender.com/api/v1/customer/reviews
  /// @apiName customer_posted_reviews
  /// @apiGroup ReviewsAndReating

  /// @apiBody {json} body Request payload
  /// ```json
  ///
  /// ```

  /// @apiSuccess {CustomerPostedReviewsModel} response Success response

  Future<Either<ApiException, CustomerPostedReviewsModel>>
  customerPostedReviews({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          nextUrl ?? ApiUris.customerPostedReviews,
          queryParameters: queryParameters,
          options: _options,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                CustomerPostedReviewsModel.fromJson(
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

  /// @api {DELETE https://discipl-backend.onrender.com/api/v1/customer/reviews/1} https://discipl-backend.onrender.com/api/v1/customer/reviews/1
  /// @apiName delete_review
  /// @apiGroup ReviewsAndReating

  /// @apiBody {json} body Request payload
  /// ```json
  ///
  /// ```

  /// @apiSuccess {void} response Success response

  Future<Either<ApiException, void>> deleteReview({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final options = _options;
      options.method = 'DELETE';
      options.headers ??= {};
      options.headers!['Content-Type'] = 'application/json';

      final url = ApiUris.deleteReview(id);
      print('Delete Review URL: $url');
      print('Delete Review Body: $body');
      print('Delete Review Headers: ${options.headers}');

      final response = await Dio().request<dynamic>(
        url,
        data: body,
        options: options,
      );

      print('Delete Review Response Status Code: ${response.statusCode}');
      print('Delete Review Response Data: ${response.data}');

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 204) {
        _gymReviewsCache.clear();
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Delete review error → $e');
      print('Delete review error response data → ${e.response?.data}');
      print('Delete review error response statusCode → ${e.response?.statusCode}');
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
      print('Delete review general catch error → $e');
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/organization/4/reviews} https://discipl-backend.onrender.com/api/v1/fitnesscenter/organization/4/reviews
  /// @apiName fitness_center_reviews
  /// @apiGroup ReviewsAndReating

  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// period=latest, =
  /// ```

  /// @apiSuccess {FitnessCenterReviewsModel} response Success response

  Future<Either<ApiException, FitnessCenterReviewsModel>> fitnessCenterReviews({
    required int id,
    required Map<String, dynamic> queryParameters,
  }) async {
    final cacheKey = '${id}_${queryParameters.toString()}';
    if (_gymReviewsCache.containsKey(cacheKey)) {
      return right(_gymReviewsCache[cacheKey]!);
    }
    try {
      final res = await Feggy.async<Response<dynamic>, Either<ApiException, FitnessCenterReviewsModel>>(
        call: Dio().get<dynamic>(
          ApiUris.fitnessCenterReviews(id),
          queryParameters: queryParameters,
          options: _options,
        ),
        onSuccess: (res) {
          if (res != null && res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              final model = FitnessCenterReviewsModel.fromJson(
                res.data as Map<String, dynamic>,
              );
              _gymReviewsCache[cacheKey] = model;
              return right(model);
            }
          }
          return left(const ApiException.unknown());
        },
      );
      return res;
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, Map<String, dynamic>?>> getTrainerReview({
    required int trainerId,
  }) async {
    if (_trainerMyReviewCache.containsKey(trainerId)) {
      return right(_trainerMyReviewCache[trainerId]);
    }
    try {
      final options = _options;
      options.method = 'GET';
      options.headers ??= {};

      final response = await Dio().request<dynamic>(
        ApiUris.trainerReviews(trainerId),
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        _trainerMyReviewCache[trainerId] = data;
        return right(data);
      }
      _trainerMyReviewCache[trainerId] = null;
      return right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _trainerMyReviewCache[trainerId] = null;
        return right(null);
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

  Future<Either<ApiException, void>> addTrainerReview({
    required int trainerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final options = _options;
      options.method = 'POST';
      options.headers ??= {};
      options.headers!['Content-Type'] = 'application/json';

      final body = {
        'rating': rating,
        'comment': comment,
      };

      print('Add Trainer Review URL → ${ApiUris.trainerReviews(trainerId)}');
      print('Add Trainer Review Body → $body');
      print('Add Trainer Review Headers → ${options.headers}');

      final response = await Dio().request<dynamic>(
        ApiUris.trainerReviews(trainerId),
        data: body,
        options: options,
      );

      print('Add Trainer Review Status Code → ${response.statusCode}');
      print('Add Trainer Review Response Data → ${response.data}');
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200 || statusCode == 201) {
        _trainerReviewsAllCache.clear();
        _trainerMyReviewCache.clear();
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected server response. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Add Trainer Review error → $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstVal = data[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return left(ApiException.unknown(msg: firstVal[0].toString()));
          }
          return left(ApiException.unknown(msg: firstVal.toString()));
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

  Future<Either<ApiException, void>> updateTrainerReview({
    required int trainerId,
    int? rating,
    String? comment,
  }) async {
    try {
      final options = _options;
      options.method = 'PATCH';
      options.headers ??= {};
      options.headers!['Content-Type'] = 'application/json';

      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (comment != null) body['comment'] = comment;

      print('Update Trainer Review URL → ${ApiUris.trainerReviews(trainerId)}');
      print('Update Trainer Review Body → $body');

      final response = await Dio().request<dynamic>(
        ApiUris.trainerReviews(trainerId),
        data: body,
        options: options,
      );

      print('Update Trainer Review Status Code → ${response.statusCode}');
      print('Update Trainer Review Response Data → ${response.data}');
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200 || statusCode == 201) {
        _trainerReviewsAllCache.clear();
        _trainerMyReviewCache.clear();
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected server response. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Update Trainer Review error → $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstVal = data[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return left(ApiException.unknown(msg: firstVal[0].toString()));
          }
          return left(ApiException.unknown(msg: firstVal.toString()));
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

  Future<Either<ApiException, void>> deleteTrainerReview({
    required int trainerId,
  }) async {
    try {
      final options = _options;
      options.method = 'DELETE';
      options.headers ??= {};

      print('Delete Trainer Review URL → ${ApiUris.trainerReviews(trainerId)}');

      final response = await Dio().request<dynamic>(
        ApiUris.trainerReviews(trainerId),
        options: options,
      );

      print('Delete Trainer Review Status Code → ${response.statusCode}');
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200 || statusCode == 204) {
        _trainerReviewsAllCache.clear();
        _trainerMyReviewCache.clear();
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected server response. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Delete Trainer Review error → $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstVal = data[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return left(ApiException.unknown(msg: firstVal[0].toString()));
          }
          return left(ApiException.unknown(msg: firstVal.toString()));
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

  Future<Either<ApiException, TrainerReviewsModel>> getTrainerReviewsAll({
    required int trainerId,
    required Map<String, dynamic> queryParameters,
  }) async {
    final cacheKey = '${trainerId}_${queryParameters.toString()}';
    if (_trainerReviewsAllCache.containsKey(cacheKey)) {
      return right(_trainerReviewsAllCache[cacheKey]!);
    }
    try {
      final options = _options;
      options.method = 'GET';
      options.headers ??= {};

      final response = await Dio().request<dynamic>(
        ApiUris.allTrainerReviews(trainerId),
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data is Map) {
          final model = TrainerReviewsModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          _trainerReviewsAllCache[cacheKey] = model;
          return right(model);
        }
      }
      return left(const ApiException.unknown());
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      debugPrint(e.toString());
      return left(const ApiException.unknown());
    }
  }
}
