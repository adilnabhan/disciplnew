// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'initiate_razorpay_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InitiateRazorpayOrderModel _$InitiateRazorpayOrderModelFromJson(
  Map<String, dynamic> json,
) {
  return _InitiateRazorpayOrderModel.fromJson(json);
}

/// @nodoc
mixin _$InitiateRazorpayOrderModel {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  User? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_id')
  String? get subscriptionId => throw _privateConstructorUsedError;

  /// Serializes this InitiateRazorpayOrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InitiateRazorpayOrderModelCopyWith<InitiateRazorpayOrderModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitiateRazorpayOrderModelCopyWith<$Res> {
  factory $InitiateRazorpayOrderModelCopyWith(
    InitiateRazorpayOrderModel value,
    $Res Function(InitiateRazorpayOrderModel) then,
  ) =
      _$InitiateRazorpayOrderModelCopyWithImpl<
        $Res,
        InitiateRazorpayOrderModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'subscription_id') String? subscriptionId,
  });

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$InitiateRazorpayOrderModelCopyWithImpl<
  $Res,
  $Val extends InitiateRazorpayOrderModel
>
    implements $InitiateRazorpayOrderModelCopyWith<$Res> {
  _$InitiateRazorpayOrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderId = freezed,
    Object? user = freezed,
    Object? amount = freezed,
    Object? subscriptionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            user:
                freezed == user
                    ? _value.user
                    : user // ignore: cast_nullable_to_non_nullable
                        as User?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            subscriptionId:
                freezed == subscriptionId
                    ? _value.subscriptionId
                    : subscriptionId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InitiateRazorpayOrderModelImplCopyWith<$Res>
    implements $InitiateRazorpayOrderModelCopyWith<$Res> {
  factory _$$InitiateRazorpayOrderModelImplCopyWith(
    _$InitiateRazorpayOrderModelImpl value,
    $Res Function(_$InitiateRazorpayOrderModelImpl) then,
  ) = __$$InitiateRazorpayOrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'subscription_id') String? subscriptionId,
  });

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$InitiateRazorpayOrderModelImplCopyWithImpl<$Res>
    extends
        _$InitiateRazorpayOrderModelCopyWithImpl<
          $Res,
          _$InitiateRazorpayOrderModelImpl
        >
    implements _$$InitiateRazorpayOrderModelImplCopyWith<$Res> {
  __$$InitiateRazorpayOrderModelImplCopyWithImpl(
    _$InitiateRazorpayOrderModelImpl _value,
    $Res Function(_$InitiateRazorpayOrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderId = freezed,
    Object? user = freezed,
    Object? amount = freezed,
    Object? subscriptionId = freezed,
  }) {
    return _then(
      _$InitiateRazorpayOrderModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        user:
            freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as User?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        subscriptionId:
            freezed == subscriptionId
                ? _value.subscriptionId
                : subscriptionId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InitiateRazorpayOrderModelImpl implements _InitiateRazorpayOrderModel {
  const _$InitiateRazorpayOrderModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'user') this.user,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'subscription_id') this.subscriptionId,
  });

  factory _$InitiateRazorpayOrderModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$InitiateRazorpayOrderModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'user')
  final User? user;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'subscription_id')
  final String? subscriptionId;

  @override
  String toString() {
    return 'InitiateRazorpayOrderModel(id: $id, orderId: $orderId, user: $user, amount: $amount, subscriptionId: $subscriptionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitiateRazorpayOrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, orderId, user, amount, subscriptionId);

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitiateRazorpayOrderModelImplCopyWith<_$InitiateRazorpayOrderModelImpl>
  get copyWith => __$$InitiateRazorpayOrderModelImplCopyWithImpl<
    _$InitiateRazorpayOrderModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InitiateRazorpayOrderModelImplToJson(this);
  }
}

abstract class _InitiateRazorpayOrderModel
    implements InitiateRazorpayOrderModel {
  const factory _InitiateRazorpayOrderModel({
    @JsonKey(name: 'id') final String? id,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'user') final User? user,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'subscription_id') final String? subscriptionId,
  }) = _$InitiateRazorpayOrderModelImpl;

  factory _InitiateRazorpayOrderModel.fromJson(Map<String, dynamic> json) =
      _$InitiateRazorpayOrderModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'user')
  User? get user;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'subscription_id')
  String? get subscriptionId;

  /// Create a copy of InitiateRazorpayOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitiateRazorpayOrderModelImplCopyWith<_$InitiateRazorpayOrderModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            firstName:
                freezed == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastName:
                freezed == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobileNumber:
                freezed == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
  }) {
    return _then(
      _$UserImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        firstName:
            freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastName:
            freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobileNumber:
            freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;

  @override
  String toString() {
    return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, firstName, lastName, mobileNumber);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
