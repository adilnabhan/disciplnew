// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentsState {
  ({Option<Either<ApiException, PaymentHistoryModel>> data, bool isPagination})
  get paymentHistory => throw _privateConstructorUsedError;
  ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
  get paymentHistoryDetails => throw _privateConstructorUsedError;

  /// Create a copy of PaymentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentsStateCopyWith<PaymentsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentsStateCopyWith<$Res> {
  factory $PaymentsStateCopyWith(
    PaymentsState value,
    $Res Function(PaymentsState) then,
  ) = _$PaymentsStateCopyWithImpl<$Res, PaymentsState>;
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
    ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
    paymentHistoryDetails,
  });
}

/// @nodoc
class _$PaymentsStateCopyWithImpl<$Res, $Val extends PaymentsState>
    implements $PaymentsStateCopyWith<$Res> {
  _$PaymentsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentHistory = null,
    Object? paymentHistoryDetails = null,
  }) {
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
            paymentHistoryDetails:
                null == paymentHistoryDetails
                    ? _value.paymentHistoryDetails
                    : paymentHistoryDetails // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<
                            Either<ApiException, PaymentHistoryDetailsModel>
                          >
                          data,
                        }),
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentsStateImplCopyWith<$Res>
    implements $PaymentsStateCopyWith<$Res> {
  factory _$$PaymentsStateImplCopyWith(
    _$PaymentsStateImpl value,
    $Res Function(_$PaymentsStateImpl) then,
  ) = __$$PaymentsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
    ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
    paymentHistoryDetails,
  });
}

/// @nodoc
class __$$PaymentsStateImplCopyWithImpl<$Res>
    extends _$PaymentsStateCopyWithImpl<$Res, _$PaymentsStateImpl>
    implements _$$PaymentsStateImplCopyWith<$Res> {
  __$$PaymentsStateImplCopyWithImpl(
    _$PaymentsStateImpl _value,
    $Res Function(_$PaymentsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentHistory = null,
    Object? paymentHistoryDetails = null,
  }) {
    return _then(
      _$PaymentsStateImpl(
        paymentHistory:
            null == paymentHistory
                ? _value.paymentHistory
                : paymentHistory // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, PaymentHistoryModel>> data,
                      bool isPagination,
                    }),
        paymentHistoryDetails:
            null == paymentHistoryDetails
                ? _value.paymentHistoryDetails
                : paymentHistoryDetails // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, PaymentHistoryDetailsModel>>
                      data,
                    }),
      ),
    );
  }
}

/// @nodoc

class _$PaymentsStateImpl implements _PaymentsState {
  const _$PaymentsStateImpl({
    this.paymentHistory = const (data: None(), isPagination: false),
    this.paymentHistoryDetails = const (data: None()),
  });

  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, PaymentHistoryModel>> data,
    bool isPagination,
  })
  paymentHistory;
  @override
  @JsonKey()
  final ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
  paymentHistoryDetails;

  @override
  String toString() {
    return 'PaymentsState(paymentHistory: $paymentHistory, paymentHistoryDetails: $paymentHistoryDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentsStateImpl &&
            (identical(other.paymentHistory, paymentHistory) ||
                other.paymentHistory == paymentHistory) &&
            (identical(other.paymentHistoryDetails, paymentHistoryDetails) ||
                other.paymentHistoryDetails == paymentHistoryDetails));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, paymentHistory, paymentHistoryDetails);

  /// Create a copy of PaymentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentsStateImplCopyWith<_$PaymentsStateImpl> get copyWith =>
      __$$PaymentsStateImplCopyWithImpl<_$PaymentsStateImpl>(this, _$identity);
}

abstract class _PaymentsState implements PaymentsState {
  const factory _PaymentsState({
    final ({
      Option<Either<ApiException, PaymentHistoryModel>> data,
      bool isPagination,
    })
    paymentHistory,
    final ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
    paymentHistoryDetails,
  }) = _$PaymentsStateImpl;

  @override
  ({Option<Either<ApiException, PaymentHistoryModel>> data, bool isPagination})
  get paymentHistory;
  @override
  ({Option<Either<ApiException, PaymentHistoryDetailsModel>> data})
  get paymentHistoryDetails;

  /// Create a copy of PaymentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentsStateImplCopyWith<_$PaymentsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
