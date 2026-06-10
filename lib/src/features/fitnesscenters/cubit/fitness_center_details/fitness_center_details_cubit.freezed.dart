// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitness_center_details_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FitnessCenterDetailsState {
  Option<Either<ApiException, FitnesscenterDetailsModel>>
  get fitnessCenterDetails => throw _privateConstructorUsedError;
  Option<Either<ApiException, FitnessCenterReviewsModel>>
  get fitnessCenterReviews => throw _privateConstructorUsedError;

  /// Create a copy of FitnessCenterDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnessCenterDetailsStateCopyWith<FitnessCenterDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnessCenterDetailsStateCopyWith<$Res> {
  factory $FitnessCenterDetailsStateCopyWith(
    FitnessCenterDetailsState value,
    $Res Function(FitnessCenterDetailsState) then,
  ) = _$FitnessCenterDetailsStateCopyWithImpl<$Res, FitnessCenterDetailsState>;
  @useResult
  $Res call({
    Option<Either<ApiException, FitnesscenterDetailsModel>>
    fitnessCenterDetails,
    Option<Either<ApiException, FitnessCenterReviewsModel>>
    fitnessCenterReviews,
  });
}

/// @nodoc
class _$FitnessCenterDetailsStateCopyWithImpl<
  $Res,
  $Val extends FitnessCenterDetailsState
>
    implements $FitnessCenterDetailsStateCopyWith<$Res> {
  _$FitnessCenterDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnessCenterDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fitnessCenterDetails = null,
    Object? fitnessCenterReviews = null,
  }) {
    return _then(
      _value.copyWith(
            fitnessCenterDetails:
                null == fitnessCenterDetails
                    ? _value.fitnessCenterDetails
                    : fitnessCenterDetails // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, FitnesscenterDetailsModel>
                        >,
            fitnessCenterReviews:
                null == fitnessCenterReviews
                    ? _value.fitnessCenterReviews
                    : fitnessCenterReviews // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, FitnessCenterReviewsModel>
                        >,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FitnessCenterDetailsStateImplCopyWith<$Res>
    implements $FitnessCenterDetailsStateCopyWith<$Res> {
  factory _$$FitnessCenterDetailsStateImplCopyWith(
    _$FitnessCenterDetailsStateImpl value,
    $Res Function(_$FitnessCenterDetailsStateImpl) then,
  ) = __$$FitnessCenterDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, FitnesscenterDetailsModel>>
    fitnessCenterDetails,
    Option<Either<ApiException, FitnessCenterReviewsModel>>
    fitnessCenterReviews,
  });
}

/// @nodoc
class __$$FitnessCenterDetailsStateImplCopyWithImpl<$Res>
    extends
        _$FitnessCenterDetailsStateCopyWithImpl<
          $Res,
          _$FitnessCenterDetailsStateImpl
        >
    implements _$$FitnessCenterDetailsStateImplCopyWith<$Res> {
  __$$FitnessCenterDetailsStateImplCopyWithImpl(
    _$FitnessCenterDetailsStateImpl _value,
    $Res Function(_$FitnessCenterDetailsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnessCenterDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fitnessCenterDetails = null,
    Object? fitnessCenterReviews = null,
  }) {
    return _then(
      _$FitnessCenterDetailsStateImpl(
        fitnessCenterDetails:
            null == fitnessCenterDetails
                ? _value.fitnessCenterDetails
                : fitnessCenterDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, FitnesscenterDetailsModel>>,
        fitnessCenterReviews:
            null == fitnessCenterReviews
                ? _value.fitnessCenterReviews
                : fitnessCenterReviews // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, FitnessCenterReviewsModel>>,
      ),
    );
  }
}

/// @nodoc

class _$FitnessCenterDetailsStateImpl implements _FitnessCenterDetailsState {
  const _$FitnessCenterDetailsStateImpl({
    this.fitnessCenterDetails = const None(),
    this.fitnessCenterReviews = const None(),
  });

  @override
  @JsonKey()
  final Option<Either<ApiException, FitnesscenterDetailsModel>>
  fitnessCenterDetails;
  @override
  @JsonKey()
  final Option<Either<ApiException, FitnessCenterReviewsModel>>
  fitnessCenterReviews;

  @override
  String toString() {
    return 'FitnessCenterDetailsState(fitnessCenterDetails: $fitnessCenterDetails, fitnessCenterReviews: $fitnessCenterReviews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnessCenterDetailsStateImpl &&
            (identical(other.fitnessCenterDetails, fitnessCenterDetails) ||
                other.fitnessCenterDetails == fitnessCenterDetails) &&
            (identical(other.fitnessCenterReviews, fitnessCenterReviews) ||
                other.fitnessCenterReviews == fitnessCenterReviews));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, fitnessCenterDetails, fitnessCenterReviews);

  /// Create a copy of FitnessCenterDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnessCenterDetailsStateImplCopyWith<_$FitnessCenterDetailsStateImpl>
  get copyWith => __$$FitnessCenterDetailsStateImplCopyWithImpl<
    _$FitnessCenterDetailsStateImpl
  >(this, _$identity);
}

abstract class _FitnessCenterDetailsState implements FitnessCenterDetailsState {
  const factory _FitnessCenterDetailsState({
    final Option<Either<ApiException, FitnesscenterDetailsModel>>
    fitnessCenterDetails,
    final Option<Either<ApiException, FitnessCenterReviewsModel>>
    fitnessCenterReviews,
  }) = _$FitnessCenterDetailsStateImpl;

  @override
  Option<Either<ApiException, FitnesscenterDetailsModel>>
  get fitnessCenterDetails;
  @override
  Option<Either<ApiException, FitnessCenterReviewsModel>>
  get fitnessCenterReviews;

  /// Create a copy of FitnessCenterDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnessCenterDetailsStateImplCopyWith<_$FitnessCenterDetailsStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
