// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitness_center_reviews_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FitnessCenterReviewsModel _$FitnessCenterReviewsModelFromJson(
  Map<String, dynamic> json,
) {
  return _FitnessCenterReviewsModel.fromJson(json);
}

/// @nodoc
mixin _$FitnessCenterReviewsModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  FitnessCenterReviewsResultsModel? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this FitnessCenterReviewsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnessCenterReviewsModelCopyWith<FitnessCenterReviewsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnessCenterReviewsModelCopyWith<$Res> {
  factory $FitnessCenterReviewsModelCopyWith(
    FitnessCenterReviewsModel value,
    $Res Function(FitnessCenterReviewsModel) then,
  ) = _$FitnessCenterReviewsModelCopyWithImpl<$Res, FitnessCenterReviewsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') FitnessCenterReviewsResultsModel? results,
  });

  $FitnessCenterReviewsResultsModelCopyWith<$Res>? get results;
}

/// @nodoc
class _$FitnessCenterReviewsModelCopyWithImpl<
  $Res,
  $Val extends FitnessCenterReviewsModel
>
    implements $FitnessCenterReviewsModelCopyWith<$Res> {
  _$FitnessCenterReviewsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _value.copyWith(
            count:
                freezed == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int?,
            next:
                freezed == next
                    ? _value.next
                    : next // ignore: cast_nullable_to_non_nullable
                        as String?,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as String?,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as FitnessCenterReviewsResultsModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FitnessCenterReviewsResultsModelCopyWith<$Res>? get results {
    if (_value.results == null) {
      return null;
    }

    return $FitnessCenterReviewsResultsModelCopyWith<$Res>(_value.results!, (
      value,
    ) {
      return _then(_value.copyWith(results: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FitnessCenterReviewsModelImplCopyWith<$Res>
    implements $FitnessCenterReviewsModelCopyWith<$Res> {
  factory _$$FitnessCenterReviewsModelImplCopyWith(
    _$FitnessCenterReviewsModelImpl value,
    $Res Function(_$FitnessCenterReviewsModelImpl) then,
  ) = __$$FitnessCenterReviewsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') FitnessCenterReviewsResultsModel? results,
  });

  @override
  $FitnessCenterReviewsResultsModelCopyWith<$Res>? get results;
}

/// @nodoc
class __$$FitnessCenterReviewsModelImplCopyWithImpl<$Res>
    extends
        _$FitnessCenterReviewsModelCopyWithImpl<
          $Res,
          _$FitnessCenterReviewsModelImpl
        >
    implements _$$FitnessCenterReviewsModelImplCopyWith<$Res> {
  __$$FitnessCenterReviewsModelImplCopyWithImpl(
    _$FitnessCenterReviewsModelImpl _value,
    $Res Function(_$FitnessCenterReviewsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _$FitnessCenterReviewsModelImpl(
        count:
            freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int?,
        next:
            freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                    as String?,
        previous:
            freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                    as String?,
        results:
            freezed == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                    as FitnessCenterReviewsResultsModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FitnessCenterReviewsModelImpl implements _FitnessCenterReviewsModel {
  const _$FitnessCenterReviewsModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') this.results,
  });

  factory _$FitnessCenterReviewsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FitnessCenterReviewsModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  @override
  @JsonKey(name: 'results')
  final FitnessCenterReviewsResultsModel? results;

  @override
  String toString() {
    return 'FitnessCenterReviewsModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnessCenterReviewsModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.results, results) || other.results == results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, count, next, previous, results);

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnessCenterReviewsModelImplCopyWith<_$FitnessCenterReviewsModelImpl>
  get copyWith => __$$FitnessCenterReviewsModelImplCopyWithImpl<
    _$FitnessCenterReviewsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FitnessCenterReviewsModelImplToJson(this);
  }
}

abstract class _FitnessCenterReviewsModel implements FitnessCenterReviewsModel {
  const factory _FitnessCenterReviewsModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: 'results') final FitnessCenterReviewsResultsModel? results,
  }) = _$FitnessCenterReviewsModelImpl;

  factory _FitnessCenterReviewsModel.fromJson(Map<String, dynamic> json) =
      _$FitnessCenterReviewsModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;
  @override
  @JsonKey(name: 'results')
  FitnessCenterReviewsResultsModel? get results;

  /// Create a copy of FitnessCenterReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnessCenterReviewsModelImplCopyWith<_$FitnessCenterReviewsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

FitnessCenterReviewsResultsModel _$FitnessCenterReviewsResultsModelFromJson(
  Map<String, dynamic> json,
) {
  return _FitnessCenterReviewsResultsModel.fromJson(json);
}

/// @nodoc
mixin _$FitnessCenterReviewsResultsModel {
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_rating')
  int? get avgRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviews')
  List<SingleFitnessCenterReviewModel>? get reviews =>
      throw _privateConstructorUsedError;

  /// Serializes this FitnessCenterReviewsResultsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FitnessCenterReviewsResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnessCenterReviewsResultsModelCopyWith<FitnessCenterReviewsResultsModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnessCenterReviewsResultsModelCopyWith<$Res> {
  factory $FitnessCenterReviewsResultsModelCopyWith(
    FitnessCenterReviewsResultsModel value,
    $Res Function(FitnessCenterReviewsResultsModel) then,
  ) =
      _$FitnessCenterReviewsResultsModelCopyWithImpl<
        $Res,
        FitnessCenterReviewsResultsModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'avg_rating') int? avgRating,
    @JsonKey(name: 'reviews') List<SingleFitnessCenterReviewModel>? reviews,
  });
}

/// @nodoc
class _$FitnessCenterReviewsResultsModelCopyWithImpl<
  $Res,
  $Val extends FitnessCenterReviewsResultsModel
>
    implements $FitnessCenterReviewsResultsModelCopyWith<$Res> {
  _$FitnessCenterReviewsResultsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnessCenterReviewsResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviewCount = freezed,
    Object? avgRating = freezed,
    Object? reviews = freezed,
  }) {
    return _then(
      _value.copyWith(
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            avgRating:
                freezed == avgRating
                    ? _value.avgRating
                    : avgRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            reviews:
                freezed == reviews
                    ? _value.reviews
                    : reviews // ignore: cast_nullable_to_non_nullable
                        as List<SingleFitnessCenterReviewModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FitnessCenterReviewsResultsModelImplCopyWith<$Res>
    implements $FitnessCenterReviewsResultsModelCopyWith<$Res> {
  factory _$$FitnessCenterReviewsResultsModelImplCopyWith(
    _$FitnessCenterReviewsResultsModelImpl value,
    $Res Function(_$FitnessCenterReviewsResultsModelImpl) then,
  ) = __$$FitnessCenterReviewsResultsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'avg_rating') int? avgRating,
    @JsonKey(name: 'reviews') List<SingleFitnessCenterReviewModel>? reviews,
  });
}

/// @nodoc
class __$$FitnessCenterReviewsResultsModelImplCopyWithImpl<$Res>
    extends
        _$FitnessCenterReviewsResultsModelCopyWithImpl<
          $Res,
          _$FitnessCenterReviewsResultsModelImpl
        >
    implements _$$FitnessCenterReviewsResultsModelImplCopyWith<$Res> {
  __$$FitnessCenterReviewsResultsModelImplCopyWithImpl(
    _$FitnessCenterReviewsResultsModelImpl _value,
    $Res Function(_$FitnessCenterReviewsResultsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnessCenterReviewsResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviewCount = freezed,
    Object? avgRating = freezed,
    Object? reviews = freezed,
  }) {
    return _then(
      _$FitnessCenterReviewsResultsModelImpl(
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        avgRating:
            freezed == avgRating
                ? _value.avgRating
                : avgRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        reviews:
            freezed == reviews
                ? _value._reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                    as List<SingleFitnessCenterReviewModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FitnessCenterReviewsResultsModelImpl
    implements _FitnessCenterReviewsResultsModel {
  const _$FitnessCenterReviewsResultsModelImpl({
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'avg_rating') this.avgRating,
    @JsonKey(name: 'reviews')
    final List<SingleFitnessCenterReviewModel>? reviews,
  }) : _reviews = reviews;

  factory _$FitnessCenterReviewsResultsModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$FitnessCenterReviewsResultsModelImplFromJson(json);

  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'avg_rating')
  final int? avgRating;
  final List<SingleFitnessCenterReviewModel>? _reviews;
  @override
  @JsonKey(name: 'reviews')
  List<SingleFitnessCenterReviewModel>? get reviews {
    final value = _reviews;
    if (value == null) return null;
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FitnessCenterReviewsResultsModel(reviewCount: $reviewCount, avgRating: $avgRating, reviews: $reviews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnessCenterReviewsResultsModelImpl &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    reviewCount,
    avgRating,
    const DeepCollectionEquality().hash(_reviews),
  );

  /// Create a copy of FitnessCenterReviewsResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnessCenterReviewsResultsModelImplCopyWith<
    _$FitnessCenterReviewsResultsModelImpl
  >
  get copyWith => __$$FitnessCenterReviewsResultsModelImplCopyWithImpl<
    _$FitnessCenterReviewsResultsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FitnessCenterReviewsResultsModelImplToJson(this);
  }
}

abstract class _FitnessCenterReviewsResultsModel
    implements FitnessCenterReviewsResultsModel {
  const factory _FitnessCenterReviewsResultsModel({
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'avg_rating') final int? avgRating,
    @JsonKey(name: 'reviews')
    final List<SingleFitnessCenterReviewModel>? reviews,
  }) = _$FitnessCenterReviewsResultsModelImpl;

  factory _FitnessCenterReviewsResultsModel.fromJson(
    Map<String, dynamic> json,
  ) = _$FitnessCenterReviewsResultsModelImpl.fromJson;

  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'avg_rating')
  int? get avgRating;
  @override
  @JsonKey(name: 'reviews')
  List<SingleFitnessCenterReviewModel>? get reviews;

  /// Create a copy of FitnessCenterReviewsResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnessCenterReviewsResultsModelImplCopyWith<
    _$FitnessCenterReviewsResultsModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

SingleFitnessCenterReviewModel _$SingleFitnessCenterReviewModelFromJson(
  Map<String, dynamic> json,
) {
  return _SingleFitnessCenterReviewModel.fromJson(json);
}

/// @nodoc
mixin _$SingleFitnessCenterReviewModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating')
  int? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment')
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created')
  DateTime? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;

  /// Serializes this SingleFitnessCenterReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleFitnessCenterReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleFitnessCenterReviewModelCopyWith<SingleFitnessCenterReviewModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleFitnessCenterReviewModelCopyWith<$Res> {
  factory $SingleFitnessCenterReviewModelCopyWith(
    SingleFitnessCenterReviewModel value,
    $Res Function(SingleFitnessCenterReviewModel) then,
  ) =
      _$SingleFitnessCenterReviewModelCopyWithImpl<
        $Res,
        SingleFitnessCenterReviewModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
  });
}

/// @nodoc
class _$SingleFitnessCenterReviewModelCopyWithImpl<
  $Res,
  $Val extends SingleFitnessCenterReviewModel
>
    implements $SingleFitnessCenterReviewModelCopyWith<$Res> {
  _$SingleFitnessCenterReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleFitnessCenterReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rating = freezed,
    Object? comment = freezed,
    Object? created = freezed,
    Object? customerName = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            rating:
                freezed == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int?,
            comment:
                freezed == comment
                    ? _value.comment
                    : comment // ignore: cast_nullable_to_non_nullable
                        as String?,
            created:
                freezed == created
                    ? _value.created
                    : created // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            customerName:
                freezed == customerName
                    ? _value.customerName
                    : customerName // ignore: cast_nullable_to_non_nullable
                        as String?,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SingleFitnessCenterReviewModelImplCopyWith<$Res>
    implements $SingleFitnessCenterReviewModelCopyWith<$Res> {
  factory _$$SingleFitnessCenterReviewModelImplCopyWith(
    _$SingleFitnessCenterReviewModelImpl value,
    $Res Function(_$SingleFitnessCenterReviewModelImpl) then,
  ) = __$$SingleFitnessCenterReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
  });
}

/// @nodoc
class __$$SingleFitnessCenterReviewModelImplCopyWithImpl<$Res>
    extends
        _$SingleFitnessCenterReviewModelCopyWithImpl<
          $Res,
          _$SingleFitnessCenterReviewModelImpl
        >
    implements _$$SingleFitnessCenterReviewModelImplCopyWith<$Res> {
  __$$SingleFitnessCenterReviewModelImplCopyWithImpl(
    _$SingleFitnessCenterReviewModelImpl _value,
    $Res Function(_$SingleFitnessCenterReviewModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleFitnessCenterReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rating = freezed,
    Object? comment = freezed,
    Object? created = freezed,
    Object? customerName = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(
      _$SingleFitnessCenterReviewModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        rating:
            freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int?,
        comment:
            freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                    as String?,
        created:
            freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        customerName:
            freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                    as String?,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleFitnessCenterReviewModelImpl
    implements _SingleFitnessCenterReviewModel {
  const _$SingleFitnessCenterReviewModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'rating') this.rating,
    @JsonKey(name: 'comment') this.comment,
    @JsonKey(name: 'created') this.created,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'profile_picture') this.profilePicture,
  });

  factory _$SingleFitnessCenterReviewModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SingleFitnessCenterReviewModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'rating')
  final int? rating;
  @override
  @JsonKey(name: 'comment')
  final String? comment;
  @override
  @JsonKey(name: 'created')
  final DateTime? created;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;

  @override
  String toString() {
    return 'SingleFitnessCenterReviewModel(id: $id, rating: $rating, comment: $comment, created: $created, customerName: $customerName, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleFitnessCenterReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            const DeepCollectionEquality().equals(
              other.profilePicture,
              profilePicture,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rating,
    comment,
    created,
    customerName,
    const DeepCollectionEquality().hash(profilePicture),
  );

  /// Create a copy of SingleFitnessCenterReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleFitnessCenterReviewModelImplCopyWith<
    _$SingleFitnessCenterReviewModelImpl
  >
  get copyWith => __$$SingleFitnessCenterReviewModelImplCopyWithImpl<
    _$SingleFitnessCenterReviewModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleFitnessCenterReviewModelImplToJson(this);
  }
}

abstract class _SingleFitnessCenterReviewModel
    implements SingleFitnessCenterReviewModel {
  const factory _SingleFitnessCenterReviewModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'rating') final int? rating,
    @JsonKey(name: 'comment') final String? comment,
    @JsonKey(name: 'created') final DateTime? created,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'profile_picture') final dynamic profilePicture,
  }) = _$SingleFitnessCenterReviewModelImpl;

  factory _SingleFitnessCenterReviewModel.fromJson(Map<String, dynamic> json) =
      _$SingleFitnessCenterReviewModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'rating')
  int? get rating;
  @override
  @JsonKey(name: 'comment')
  String? get comment;
  @override
  @JsonKey(name: 'created')
  DateTime? get created;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;

  /// Create a copy of SingleFitnessCenterReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleFitnessCenterReviewModelImplCopyWith<
    _$SingleFitnessCenterReviewModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
