// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WorkoutLogState {
  ({Option<Either<ApiException, PaymentHistoryModel>> data, bool isPagination})
  get paymentHistory => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutLogStateCopyWith<WorkoutLogState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutLogStateCopyWith<$Res> {
  factory $WorkoutLogStateCopyWith(
    WorkoutLogState value,
    $Res Function(WorkoutLogState) then,
  ) = _$WorkoutLogStateCopyWithImpl<$Res, WorkoutLogState>;
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
  });
}

/// @nodoc
class _$WorkoutLogStateCopyWithImpl<$Res, $Val extends WorkoutLogState>
    implements $WorkoutLogStateCopyWith<$Res> {
  _$WorkoutLogStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentHistory = null}) {
    return _then(
      _value.copyWith(
            paymentHistory:
                null == paymentHistory
                    ? _value.paymentHistory
                    : paymentHistory // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<Either<ApiException, PaymentHistoryModel>>
                          data,
                          bool isPagination,
                        }),
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutLogStateImplCopyWith<$Res>
    implements $WorkoutLogStateCopyWith<$Res> {
  factory _$$WorkoutLogStateImplCopyWith(
    _$WorkoutLogStateImpl value,
    $Res Function(_$WorkoutLogStateImpl) then,
  ) = __$$WorkoutLogStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
  });
}

/// @nodoc
class __$$WorkoutLogStateImplCopyWithImpl<$Res>
    extends _$WorkoutLogStateCopyWithImpl<$Res, _$WorkoutLogStateImpl>
    implements _$$WorkoutLogStateImplCopyWith<$Res> {
  __$$WorkoutLogStateImplCopyWithImpl(
    _$WorkoutLogStateImpl _value,
    $Res Function(_$WorkoutLogStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentHistory = null}) {
    return _then(
      _$WorkoutLogStateImpl(
        paymentHistory:
            null == paymentHistory
                ? _value.paymentHistory
                : paymentHistory // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, PaymentHistoryModel>> data,
                      bool isPagination,
                    }),
      ),
    );
  }
}

/// @nodoc

class _$WorkoutLogStateImpl implements _WorkoutLogState {
  const _$WorkoutLogStateImpl({
    this.paymentHistory = const (data: None(), isPagination: false),
  });

  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, PaymentHistoryModel>> data,
    bool isPagination,
  })
  paymentHistory;

  @override
  String toString() {
    return 'WorkoutLogState(paymentHistory: $paymentHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutLogStateImpl &&
            (identical(other.paymentHistory, paymentHistory) ||
                other.paymentHistory == paymentHistory));
  }

  @override
  int get hashCode => Object.hash(runtimeType, paymentHistory);

  /// Create a copy of WorkoutLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutLogStateImplCopyWith<_$WorkoutLogStateImpl> get copyWith =>
      __$$WorkoutLogStateImplCopyWithImpl<_$WorkoutLogStateImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkoutLogState implements WorkoutLogState {
  const factory _WorkoutLogState({
    final ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
  }) = _$WorkoutLogStateImpl;

  @override
  ({Option<Either<ApiException, PaymentHistoryModel>> data, bool isPagination})
  get paymentHistory;

  /// Create a copy of WorkoutLogState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutLogStateImplCopyWith<_$WorkoutLogStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
