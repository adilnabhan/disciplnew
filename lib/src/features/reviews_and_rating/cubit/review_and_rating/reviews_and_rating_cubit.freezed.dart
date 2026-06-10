// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviews_and_rating_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReviewsAndRatingState {
  ({
    Option<Either<ApiException, FitnessCenterReviewsModel>> data,
    bool isPagination,
  })
  get fitnessCenterReviews => throw _privateConstructorUsedError;

  /// Create a copy of ReviewsAndRatingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewsAndRatingStateCopyWith<ReviewsAndRatingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewsAndRatingStateCopyWith<$Res> {
  factory $ReviewsAndRatingStateCopyWith(
    ReviewsAndRatingState value,
    $Res Function(ReviewsAndRatingState) then,
  ) = _$ReviewsAndRatingStateCopyWithImpl<$Res, ReviewsAndRatingState>;
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, FitnessCenterReviewsModel>> data,
      bool isPagination,
    })
    fitnessCenterReviews,
  });
}

/// @nodoc
class _$ReviewsAndRatingStateCopyWithImpl<
  $Res,
  $Val extends ReviewsAndRatingState
>
    implements $ReviewsAndRatingStateCopyWith<$Res> {
  _$ReviewsAndRatingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewsAndRatingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fitnessCenterReviews = null}) {
    return _then(
      _value.copyWith(
            fitnessCenterReviews:
                null == fitnessCenterReviews
                    ? _value.fitnessCenterReviews
                    : fitnessCenterReviews // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<
                            Either<ApiException, FitnessCenterReviewsModel>
                          >
                          data,
                          bool isPagination,
                        }),
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewsAndRatingStateImplCopyWith<$Res>
    implements $ReviewsAndRatingStateCopyWith<$Res> {
  factory _$$ReviewsAndRatingStateImplCopyWith(
    _$ReviewsAndRatingStateImpl value,
    $Res Function(_$ReviewsAndRatingStateImpl) then,
  ) = __$$ReviewsAndRatingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, FitnessCenterReviewsModel>> data,
      bool isPagination,
    })
    fitnessCenterReviews,
  });
}

/// @nodoc
class __$$ReviewsAndRatingStateImplCopyWithImpl<$Res>
    extends
        _$ReviewsAndRatingStateCopyWithImpl<$Res, _$ReviewsAndRatingStateImpl>
    implements _$$ReviewsAndRatingStateImplCopyWith<$Res> {
  __$$ReviewsAndRatingStateImplCopyWithImpl(
    _$ReviewsAndRatingStateImpl _value,
    $Res Function(_$ReviewsAndRatingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewsAndRatingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fitnessCenterReviews = null}) {
    return _then(
      _$ReviewsAndRatingStateImpl(
        fitnessCenterReviews:
            null == fitnessCenterReviews
                ? _value.fitnessCenterReviews
                : fitnessCenterReviews // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, FitnessCenterReviewsModel>>
                      data,
                      bool isPagination,
                    }),
      ),
    );
  }
}

/// @nodoc

class _$ReviewsAndRatingStateImpl implements _ReviewsAndRatingState {
  const _$ReviewsAndRatingStateImpl({
    this.fitnessCenterReviews = const (data: None(), isPagination: false),
  });

  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, FitnessCenterReviewsModel>> data,
    bool isPagination,
  })
  fitnessCenterReviews;

  @override
  String toString() {
    return 'ReviewsAndRatingState(fitnessCenterReviews: $fitnessCenterReviews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewsAndRatingStateImpl &&
            (identical(other.fitnessCenterReviews, fitnessCenterReviews) ||
                other.fitnessCenterReviews == fitnessCenterReviews));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fitnessCenterReviews);

  /// Create a copy of ReviewsAndRatingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewsAndRatingStateImplCopyWith<_$ReviewsAndRatingStateImpl>
  get copyWith =>
      __$$ReviewsAndRatingStateImplCopyWithImpl<_$ReviewsAndRatingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ReviewsAndRatingState implements ReviewsAndRatingState {
  const factory _ReviewsAndRatingState({
    final ({
      Option<Either<ApiException, FitnessCenterReviewsModel>> data,
      bool isPagination,
    })
    fitnessCenterReviews,
  }) = _$ReviewsAndRatingStateImpl;

  @override
  ({
    Option<Either<ApiException, FitnessCenterReviewsModel>> data,
    bool isPagination,
  })
  get fitnessCenterReviews;

  /// Create a copy of ReviewsAndRatingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewsAndRatingStateImplCopyWith<_$ReviewsAndRatingStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
