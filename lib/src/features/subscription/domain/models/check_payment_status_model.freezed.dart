// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_payment_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CheckPaymentStatusModel _$CheckPaymentStatusModelFromJson(
  Map<String, dynamic> json,
) {
  return _CheckPaymentStatusModel.fromJson(json);
}

/// @nodoc
mixin _$CheckPaymentStatusModel {
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  dynamic get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  int? get amount => throw _privateConstructorUsedError;

  /// Serializes this CheckPaymentStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckPaymentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckPaymentStatusModelCopyWith<CheckPaymentStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckPaymentStatusModelCopyWith<$Res> {
  factory $CheckPaymentStatusModelCopyWith(
    CheckPaymentStatusModel value,
    $Res Function(CheckPaymentStatusModel) then,
  ) = _$CheckPaymentStatusModelCopyWithImpl<$Res, CheckPaymentStatusModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'payment_id') dynamic paymentId,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') int? amount,
  });
}

/// @nodoc
class _$CheckPaymentStatusModelCopyWithImpl<
  $Res,
  $Val extends CheckPaymentStatusModel
>
    implements $CheckPaymentStatusModelCopyWith<$Res> {
  _$CheckPaymentStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckPaymentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = freezed,
    Object? paymentId = freezed,
    Object? status = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _value.copyWith(
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentId:
                freezed == paymentId
                    ? _value.paymentId
                    : paymentId // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CheckPaymentStatusModelImplCopyWith<$Res>
    implements $CheckPaymentStatusModelCopyWith<$Res> {
  factory _$$CheckPaymentStatusModelImplCopyWith(
    _$CheckPaymentStatusModelImpl value,
    $Res Function(_$CheckPaymentStatusModelImpl) then,
  ) = __$$CheckPaymentStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'payment_id') dynamic paymentId,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') int? amount,
  });
}

/// @nodoc
class __$$CheckPaymentStatusModelImplCopyWithImpl<$Res>
    extends
        _$CheckPaymentStatusModelCopyWithImpl<
          $Res,
          _$CheckPaymentStatusModelImpl
        >
    implements _$$CheckPaymentStatusModelImplCopyWith<$Res> {
  __$$CheckPaymentStatusModelImplCopyWithImpl(
    _$CheckPaymentStatusModelImpl _value,
    $Res Function(_$CheckPaymentStatusModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckPaymentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = freezed,
    Object? paymentId = freezed,
    Object? status = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _$CheckPaymentStatusModelImpl(
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentId:
            freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckPaymentStatusModelImpl implements _CheckPaymentStatusModel {
  const _$CheckPaymentStatusModelImpl({
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'payment_id') this.paymentId,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'amount') this.amount,
  });

  factory _$CheckPaymentStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckPaymentStatusModelImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'payment_id')
  final dynamic paymentId;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'amount')
  final int? amount;

  @override
  String toString() {
    return 'CheckPaymentStatusModel(orderId: $orderId, paymentId: $paymentId, status: $status, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckPaymentStatusModelImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            const DeepCollectionEquality().equals(other.paymentId, paymentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    const DeepCollectionEquality().hash(paymentId),
    status,
    amount,
  );

  /// Create a copy of CheckPaymentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckPaymentStatusModelImplCopyWith<_$CheckPaymentStatusModelImpl>
  get copyWith => __$$CheckPaymentStatusModelImplCopyWithImpl<
    _$CheckPaymentStatusModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckPaymentStatusModelImplToJson(this);
  }
}

abstract class _CheckPaymentStatusModel implements CheckPaymentStatusModel {
  const factory _CheckPaymentStatusModel({
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'payment_id') final dynamic paymentId,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'amount') final int? amount,
  }) = _$CheckPaymentStatusModelImpl;

  factory _CheckPaymentStatusModel.fromJson(Map<String, dynamic> json) =
      _$CheckPaymentStatusModelImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'payment_id')
  dynamic get paymentId;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'amount')
  int? get amount;

  /// Create a copy of CheckPaymentStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckPaymentStatusModelImplCopyWith<_$CheckPaymentStatusModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
