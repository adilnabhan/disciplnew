import 'package:customer_mobile_app/imports_bindings.dart';

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
      return await Feggy.async(
        call: Dio().patch<dynamic>(
          ApiUris.updateReview(id),
          data: body,
          options: _options,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            return right(null);
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
      return await Feggy.async(
        call: Dio().delete<dynamic>(
          ApiUris.deleteReview(id),
          data: body,
          options: _options,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            return right(null);
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
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          ApiUris.fitnessCenterReviews(id),
          queryParameters: queryParameters,
          options: _options,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                FitnessCenterReviewsModel.fromJson(
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
