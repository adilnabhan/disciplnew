// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_with_otp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginSuccessModel _$LoginSuccessModelFromJson(Map<String, dynamic> json) {
  return _LoginWithOtpEntity.fromJson(json);
}

/// @nodoc
mixin _$LoginSuccessModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'access')
  String? get access => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh')
  String? get refresh => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'blood_group')
  String? get bloodGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer')
  CustomerDataModel? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_profile_complete')
  bool? get isProfileCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_guest')
  bool? get isGuest => throw _privateConstructorUsedError;

  /// Serializes this LoginSuccessModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginSuccessModelCopyWith<LoginSuccessModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginSuccessModelCopyWith<$Res> {
  factory $LoginSuccessModelCopyWith(
    LoginSuccessModel value,
    $Res Function(LoginSuccessModel) then,
  ) = _$LoginSuccessModelCopyWithImpl<$Res, LoginSuccessModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'customer') CustomerDataModel? customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
    @JsonKey(name: 'is_guest') bool? isGuest,
  });

  $CustomerDataModelCopyWith<$Res>? get customer;
}

/// @nodoc
class _$LoginSuccessModelCopyWithImpl<$Res, $Val extends LoginSuccessModel>
    implements $LoginSuccessModelCopyWith<$Res> {
  _$LoginSuccessModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? access = freezed,
    Object? refresh = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? bloodGroup = freezed,
    Object? lastLogin = freezed,
    Object? customer = freezed,
    Object? profilePicture = freezed,
    Object? warnings = freezed,
    Object? isProfileCompleted = freezed,
    Object? isGuest = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            access:
                freezed == access
                    ? _value.access
                    : access // ignore: cast_nullable_to_non_nullable
                        as String?,
            refresh:
                freezed == refresh
                    ? _value.refresh
                    : refresh // ignore: cast_nullable_to_non_nullable
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
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            bloodGroup:
                freezed == bloodGroup
                    ? _value.bloodGroup
                    : bloodGroup // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastLogin:
                freezed == lastLogin
                    ? _value.lastLogin
                    : lastLogin // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            customer:
                freezed == customer
                    ? _value.customer
                    : customer // ignore: cast_nullable_to_non_nullable
                        as CustomerDataModel?,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            warnings:
                freezed == warnings
                    ? _value.warnings
                    : warnings // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
            isProfileCompleted:
                freezed == isProfileCompleted
                    ? _value.isProfileCompleted
                    : isProfileCompleted // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isGuest:
                freezed == isGuest
                    ? _value.isGuest
                    : isGuest // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerDataModelCopyWith<$Res>? get customer {
    if (_value.customer == null) {
      return null;
    }

    return $CustomerDataModelCopyWith<$Res>(_value.customer!, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginWithOtpEntityImplCopyWith<$Res>
    implements $LoginSuccessModelCopyWith<$Res> {
  factory _$$LoginWithOtpEntityImplCopyWith(
    _$LoginWithOtpEntityImpl value,
    $Res Function(_$LoginWithOtpEntityImpl) then,
  ) = __$$LoginWithOtpEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'customer') CustomerDataModel? customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
    @JsonKey(name: 'is_guest') bool? isGuest,
  });

  @override
  $CustomerDataModelCopyWith<$Res>? get customer;
}

/// @nodoc
class __$$LoginWithOtpEntityImplCopyWithImpl<$Res>
    extends _$LoginSuccessModelCopyWithImpl<$Res, _$LoginWithOtpEntityImpl>
    implements _$$LoginWithOtpEntityImplCopyWith<$Res> {
  __$$LoginWithOtpEntityImplCopyWithImpl(
    _$LoginWithOtpEntityImpl _value,
    $Res Function(_$LoginWithOtpEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? access = freezed,
    Object? refresh = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? bloodGroup = freezed,
    Object? lastLogin = freezed,
    Object? customer = freezed,
    Object? profilePicture = freezed,
    Object? warnings = freezed,
    Object? isProfileCompleted = freezed,
    Object? isGuest = freezed,
  }) {
    return _then(
      _$LoginWithOtpEntityImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        access:
            freezed == access
                ? _value.access
                : access // ignore: cast_nullable_to_non_nullable
                    as String?,
        refresh:
            freezed == refresh
                ? _value.refresh
                : refresh // ignore: cast_nullable_to_non_nullable
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
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        bloodGroup:
            freezed == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastLogin:
            freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        customer:
            freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                    as CustomerDataModel?,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        warnings:
            freezed == warnings
                ? _value._warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
        isProfileCompleted:
            freezed == isProfileCompleted
                ? _value.isProfileCompleted
                : isProfileCompleted // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isGuest:
            freezed == isGuest
                ? _value.isGuest
                : isGuest // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginWithOtpEntityImpl implements _LoginWithOtpEntity {
  const _$LoginWithOtpEntityImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'access') this.access,
    @JsonKey(name: 'refresh') this.refresh,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'blood_group') this.bloodGroup,
    @JsonKey(name: 'last_login') this.lastLogin,
    @JsonKey(name: 'customer') this.customer,
    @JsonKey(name: 'profile_picture') this.profilePicture,
    @JsonKey(name: 'warnings') final List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') this.isProfileCompleted,
    @JsonKey(name: 'is_guest') this.isGuest,
  }) : _warnings = warnings;

  factory _$LoginWithOtpEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginWithOtpEntityImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'access')
  final String? access;
  @override
  @JsonKey(name: 'refresh')
  final String? refresh;
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
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  @override
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @override
  @JsonKey(name: 'customer')
  final CustomerDataModel? customer;
  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;
  final List<dynamic>? _warnings;
  @override
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings {
    final value = _warnings;
    if (value == null) return null;
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_profile_complete')
  final bool? isProfileCompleted;
  @override
  @JsonKey(name: 'is_guest')
  final bool? isGuest;

  @override
  String toString() {
    return 'LoginSuccessModel(id: $id, access: $access, refresh: $refresh, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, email: $email, bloodGroup: $bloodGroup, lastLogin: $lastLogin, customer: $customer, profilePicture: $profilePicture, warnings: $warnings, isProfileCompleted: $isProfileCompleted, isGuest: $isGuest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginWithOtpEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.access, access) || other.access == access) &&
            (identical(other.refresh, refresh) || other.refresh == refresh) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            const DeepCollectionEquality().equals(
              other.profilePicture,
              profilePicture,
            ) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.isProfileCompleted, isProfileCompleted) ||
                other.isProfileCompleted == isProfileCompleted) &&
            (identical(other.isGuest, isGuest) || other.isGuest == isGuest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    access,
    refresh,
    firstName,
    lastName,
    mobileNumber,
    email,
    bloodGroup,
    lastLogin,
    customer,
    const DeepCollectionEquality().hash(profilePicture),
    const DeepCollectionEquality().hash(_warnings),
    isProfileCompleted,
    isGuest,
  );

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginWithOtpEntityImplCopyWith<_$LoginWithOtpEntityImpl> get copyWith =>
      __$$LoginWithOtpEntityImplCopyWithImpl<_$LoginWithOtpEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginWithOtpEntityImplToJson(this);
  }
}

abstract class _LoginWithOtpEntity implements LoginSuccessModel {
  const factory _LoginWithOtpEntity({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'access') final String? access,
    @JsonKey(name: 'refresh') final String? refresh,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'blood_group') final String? bloodGroup,
    @JsonKey(name: 'last_login') final DateTime? lastLogin,
    @JsonKey(name: 'customer') final CustomerDataModel? customer,
    @JsonKey(name: 'profile_picture') final dynamic profilePicture,
    @JsonKey(name: 'warnings') final List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') final bool? isProfileCompleted,
    @JsonKey(name: 'is_guest') final bool? isGuest,
  }) = _$LoginWithOtpEntityImpl;

  factory _LoginWithOtpEntity.fromJson(Map<String, dynamic> json) =
      _$LoginWithOtpEntityImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'access')
  String? get access;
  @override
  @JsonKey(name: 'refresh')
  String? get refresh;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'blood_group')
  String? get bloodGroup;
  @override
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin;
  @override
  @JsonKey(name: 'customer')
  CustomerDataModel? get customer;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;
  @override
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings;
  @override
  @JsonKey(name: 'is_profile_complete')
  bool? get isProfileCompleted;
  @override
  @JsonKey(name: 'is_guest')
  bool? get isGuest;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginWithOtpEntityImplCopyWith<_$LoginWithOtpEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerDataModel _$CustomerDataModelFromJson(Map<String, dynamic> json) {
  return _CustomerDataModel.fromJson(json);
}

/// @nodoc
mixin _$CustomerDataModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active_member')
  bool? get isActiveMember => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_completeness')
  int? get profileCompleteness => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_id')
  int? get organizationId => throw _privateConstructorUsedError;

  /// Serializes this CustomerDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerDataModelCopyWith<CustomerDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerDataModelCopyWith<$Res> {
  factory $CustomerDataModelCopyWith(
    CustomerDataModel value,
    $Res Function(CustomerDataModel) then,
  ) = _$CustomerDataModelCopyWithImpl<$Res, CustomerDataModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
    @JsonKey(name: 'organization_id') int? organizationId,
  });
}

/// @nodoc
class _$CustomerDataModelCopyWithImpl<$Res, $Val extends CustomerDataModel>
    implements $CustomerDataModelCopyWith<$Res> {
  _$CustomerDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? isActiveMember = freezed,
    Object? profileCompleteness = freezed,
    Object? organizationId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            isActiveMember:
                freezed == isActiveMember
                    ? _value.isActiveMember
                    : isActiveMember // ignore: cast_nullable_to_non_nullable
                        as bool?,
            profileCompleteness:
                freezed == profileCompleteness
                    ? _value.profileCompleteness
                    : profileCompleteness // ignore: cast_nullable_to_non_nullable
                        as int?,
            organizationId:
                freezed == organizationId
                    ? _value.organizationId
                    : organizationId // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerDataModelImplCopyWith<$Res>
    implements $CustomerDataModelCopyWith<$Res> {
  factory _$$CustomerDataModelImplCopyWith(
    _$CustomerDataModelImpl value,
    $Res Function(_$CustomerDataModelImpl) then,
  ) = __$$CustomerDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
    @JsonKey(name: 'organization_id') int? organizationId,
  });
}

/// @nodoc
class __$$CustomerDataModelImplCopyWithImpl<$Res>
    extends _$CustomerDataModelCopyWithImpl<$Res, _$CustomerDataModelImpl>
    implements _$$CustomerDataModelImplCopyWith<$Res> {
  __$$CustomerDataModelImplCopyWithImpl(
    _$CustomerDataModelImpl _value,
    $Res Function(_$CustomerDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? isActiveMember = freezed,
    Object? profileCompleteness = freezed,
    Object? organizationId = freezed,
  }) {
    return _then(
      _$CustomerDataModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        isActiveMember:
            freezed == isActiveMember
                ? _value.isActiveMember
                : isActiveMember // ignore: cast_nullable_to_non_nullable
                    as bool?,
        profileCompleteness:
            freezed == profileCompleteness
                ? _value.profileCompleteness
                : profileCompleteness // ignore: cast_nullable_to_non_nullable
                    as int?,
        organizationId:
            freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerDataModelImpl implements _CustomerDataModel {
  const _$CustomerDataModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'is_active_member') this.isActiveMember,
    @JsonKey(name: 'profile_completeness') this.profileCompleteness,
    @JsonKey(name: 'organization_id') this.organizationId,
  });

  factory _$CustomerDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'is_active_member')
  final bool? isActiveMember;
  @override
  @JsonKey(name: 'profile_completeness')
  final int? profileCompleteness;
  @override
  @JsonKey(name: 'organization_id')
  final int? organizationId;

  @override
  String toString() {
    return 'CustomerDataModel(id: $id, isActiveMember: $isActiveMember, profileCompleteness: $profileCompleteness, organizationId: $organizationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isActiveMember, isActiveMember) ||
                other.isActiveMember == isActiveMember) &&
            (identical(other.profileCompleteness, profileCompleteness) ||
                other.profileCompleteness == profileCompleteness) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    isActiveMember,
    profileCompleteness,
    organizationId,
  );

  /// Create a copy of CustomerDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerDataModelImplCopyWith<_$CustomerDataModelImpl> get copyWith =>
      __$$CustomerDataModelImplCopyWithImpl<_$CustomerDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerDataModelImplToJson(this);
  }
}

abstract class _CustomerDataModel implements CustomerDataModel {
  const factory _CustomerDataModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'is_active_member') final bool? isActiveMember,
    @JsonKey(name: 'profile_completeness') final int? profileCompleteness,
    @JsonKey(name: 'organization_id') final int? organizationId,
  }) = _$CustomerDataModelImpl;

  factory _CustomerDataModel.fromJson(Map<String, dynamic> json) =
      _$CustomerDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'is_active_member')
  bool? get isActiveMember;
  @override
  @JsonKey(name: 'profile_completeness')
  int? get profileCompleteness;
  @override
  @JsonKey(name: 'organization_id')
  int? get organizationId;

  /// Create a copy of CustomerDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerDataModelImplCopyWith<_$CustomerDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
