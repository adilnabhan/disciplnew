// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActiveMembershipModel _$ActiveMembershipModelFromJson(
  Map<String, dynamic> json,
) {
  return _ActiveMembershipModel.fromJson(json);
}

/// @nodoc
mixin _$ActiveMembershipModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  OrganizationModel? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_id')
  int? get planId => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_name')
  String? get planName => throw _privateConstructorUsedError;
  @JsonKey(name: 'package_type')
  String? get packageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_type')
  String? get paymentType => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String? get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ActiveMembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveMembershipModelCopyWith<ActiveMembershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveMembershipModelCopyWith<$Res> {
  factory $ActiveMembershipModelCopyWith(
    ActiveMembershipModel value,
    $Res Function(ActiveMembershipModel) then,
  ) = _$ActiveMembershipModelCopyWithImpl<$Res, ActiveMembershipModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') OrganizationModel? organization,
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_type') String? paymentType,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });

  $OrganizationModelCopyWith<$Res>? get organization;
}

/// @nodoc
class _$ActiveMembershipModelCopyWithImpl<
  $Res,
  $Val extends ActiveMembershipModel
>
    implements $ActiveMembershipModelCopyWith<$Res> {
  _$ActiveMembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? planId = freezed,
    Object? planName = freezed,
    Object? packageType = freezed,
    Object? amount = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isEmiAvailable = freezed,
    Object? status = freezed,
    Object? paymentType = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            organization:
                freezed == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as OrganizationModel?,
            planId:
                freezed == planId
                    ? _value.planId
                    : planId // ignore: cast_nullable_to_non_nullable
                        as int?,
            planName:
                freezed == planName
                    ? _value.planName
                    : planName // ignore: cast_nullable_to_non_nullable
                        as String?,
            packageType:
                freezed == packageType
                    ? _value.packageType
                    : packageType // ignore: cast_nullable_to_non_nullable
                        as String?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isEmiAvailable:
                freezed == isEmiAvailable
                    ? _value.isEmiAvailable
                    : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentType:
                freezed == paymentType
                    ? _value.paymentType
                    : paymentType // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentStatus:
                freezed == paymentStatus
                    ? _value.paymentStatus
                    : paymentStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationModelCopyWith<$Res>? get organization {
    if (_value.organization == null) {
      return null;
    }

    return $OrganizationModelCopyWith<$Res>(_value.organization!, (value) {
      return _then(_value.copyWith(organization: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActiveMembershipModelImplCopyWith<$Res>
    implements $ActiveMembershipModelCopyWith<$Res> {
  factory _$$ActiveMembershipModelImplCopyWith(
    _$ActiveMembershipModelImpl value,
    $Res Function(_$ActiveMembershipModelImpl) then,
  ) = __$$ActiveMembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') OrganizationModel? organization,
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_type') String? paymentType,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });

  @override
  $OrganizationModelCopyWith<$Res>? get organization;
}

/// @nodoc
class __$$ActiveMembershipModelImplCopyWithImpl<$Res>
    extends
        _$ActiveMembershipModelCopyWithImpl<$Res, _$ActiveMembershipModelImpl>
    implements _$$ActiveMembershipModelImplCopyWith<$Res> {
  __$$ActiveMembershipModelImplCopyWithImpl(
    _$ActiveMembershipModelImpl _value,
    $Res Function(_$ActiveMembershipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? planId = freezed,
    Object? planName = freezed,
    Object? packageType = freezed,
    Object? amount = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isEmiAvailable = freezed,
    Object? status = freezed,
    Object? paymentType = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ActiveMembershipModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        organization:
            freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as OrganizationModel?,
        planId:
            freezed == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                    as int?,
        planName:
            freezed == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                    as String?,
        packageType:
            freezed == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                    as String?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isEmiAvailable:
            freezed == isEmiAvailable
                ? _value.isEmiAvailable
                : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentType:
            freezed == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentStatus:
            freezed == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActiveMembershipModelImpl implements _ActiveMembershipModel {
  const _$ActiveMembershipModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'organization') this.organization,
    @JsonKey(name: 'plan_id') this.planId,
    @JsonKey(name: 'plan_name') this.planName,
    @JsonKey(name: 'package_type') this.packageType,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'is_emi_available') this.isEmiAvailable,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'payment_type') this.paymentType,
    @JsonKey(name: 'payment_status') this.paymentStatus,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$ActiveMembershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveMembershipModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'organization')
  final OrganizationModel? organization;
  @override
  @JsonKey(name: 'plan_id')
  final int? planId;
  @override
  @JsonKey(name: 'plan_name')
  final String? planName;
  @override
  @JsonKey(name: 'package_type')
  final String? packageType;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'is_emi_available')
  final bool? isEmiAvailable;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'payment_type')
  final String? paymentType;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ActiveMembershipModel(id: $id, organization: $organization, planId: $planId, planName: $planName, packageType: $packageType, amount: $amount, startDate: $startDate, endDate: $endDate, isEmiAvailable: $isEmiAvailable, status: $status, paymentType: $paymentType, paymentStatus: $paymentStatus, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveMembershipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isEmiAvailable, isEmiAvailable) ||
                other.isEmiAvailable == isEmiAvailable) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organization,
    planId,
    planName,
    packageType,
    amount,
    startDate,
    endDate,
    isEmiAvailable,
    status,
    paymentType,
    paymentStatus,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveMembershipModelImplCopyWith<_$ActiveMembershipModelImpl>
  get copyWith =>
      __$$ActiveMembershipModelImplCopyWithImpl<_$ActiveMembershipModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveMembershipModelImplToJson(this);
  }
}

abstract class _ActiveMembershipModel implements ActiveMembershipModel {
  const factory _ActiveMembershipModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'organization') final OrganizationModel? organization,
    @JsonKey(name: 'plan_id') final int? planId,
    @JsonKey(name: 'plan_name') final String? planName,
    @JsonKey(name: 'package_type') final String? packageType,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'is_emi_available') final bool? isEmiAvailable,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'payment_type') final String? paymentType,
    @JsonKey(name: 'payment_status') final String? paymentStatus,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$ActiveMembershipModelImpl;

  factory _ActiveMembershipModel.fromJson(Map<String, dynamic> json) =
      _$ActiveMembershipModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'organization')
  OrganizationModel? get organization;
  @override
  @JsonKey(name: 'plan_id')
  int? get planId;
  @override
  @JsonKey(name: 'plan_name')
  String? get planName;
  @override
  @JsonKey(name: 'package_type')
  String? get packageType;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'payment_type')
  String? get paymentType;
  @override
  @JsonKey(name: 'payment_status')
  String? get paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ActiveMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveMembershipModelImplCopyWith<_$ActiveMembershipModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OrganizationModel _$OrganizationModelFromJson(Map<String, dynamic> json) {
  return _OrganizationModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  Location? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_time')
  List<WorkingDay>? get workingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'review')
  Review? get review => throw _privateConstructorUsedError;
  @JsonKey(name: 'category')
  List<String>? get category => throw _privateConstructorUsedError;

  /// Serializes this OrganizationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationModelCopyWith<OrganizationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationModelCopyWith<$Res> {
  factory $OrganizationModelCopyWith(
    OrganizationModel value,
    $Res Function(OrganizationModel) then,
  ) = _$OrganizationModelCopyWithImpl<$Res, OrganizationModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'social_media') List<SocialMedia>? socialMedia,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'working_time') List<WorkingDay>? workingTime,
    @JsonKey(name: 'review') Review? review,
    @JsonKey(name: 'category') List<String>? category,
  });

  $LocationCopyWith<$Res>? get location;
  $ReviewCopyWith<$Res>? get review;
}

/// @nodoc
class _$OrganizationModelCopyWithImpl<$Res, $Val extends OrganizationModel>
    implements $OrganizationModelCopyWith<$Res> {
  _$OrganizationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? socialMedia = freezed,
    Object? location = freezed,
    Object? workingTime = freezed,
    Object? review = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            socialMedia:
                freezed == socialMedia
                    ? _value.socialMedia
                    : socialMedia // ignore: cast_nullable_to_non_nullable
                        as List<SocialMedia>?,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as Location?,
            workingTime:
                freezed == workingTime
                    ? _value.workingTime
                    : workingTime // ignore: cast_nullable_to_non_nullable
                        as List<WorkingDay>?,
            review:
                freezed == review
                    ? _value.review
                    : review // ignore: cast_nullable_to_non_nullable
                        as Review?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
          )
          as $Val,
    );
  }

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReviewCopyWith<$Res>? get review {
    if (_value.review == null) {
      return null;
    }

    return $ReviewCopyWith<$Res>(_value.review!, (value) {
      return _then(_value.copyWith(review: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrganizationModelImplCopyWith<$Res>
    implements $OrganizationModelCopyWith<$Res> {
  factory _$$OrganizationModelImplCopyWith(
    _$OrganizationModelImpl value,
    $Res Function(_$OrganizationModelImpl) then,
  ) = __$$OrganizationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'social_media') List<SocialMedia>? socialMedia,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'working_time') List<WorkingDay>? workingTime,
    @JsonKey(name: 'review') Review? review,
    @JsonKey(name: 'category') List<String>? category,
  });

  @override
  $LocationCopyWith<$Res>? get location;
  @override
  $ReviewCopyWith<$Res>? get review;
}

/// @nodoc
class __$$OrganizationModelImplCopyWithImpl<$Res>
    extends _$OrganizationModelCopyWithImpl<$Res, _$OrganizationModelImpl>
    implements _$$OrganizationModelImplCopyWith<$Res> {
  __$$OrganizationModelImplCopyWithImpl(
    _$OrganizationModelImpl _value,
    $Res Function(_$OrganizationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? socialMedia = freezed,
    Object? location = freezed,
    Object? workingTime = freezed,
    Object? review = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _$OrganizationModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        socialMedia:
            freezed == socialMedia
                ? _value._socialMedia
                : socialMedia // ignore: cast_nullable_to_non_nullable
                    as List<SocialMedia>?,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as Location?,
        workingTime:
            freezed == workingTime
                ? _value._workingTime
                : workingTime // ignore: cast_nullable_to_non_nullable
                    as List<WorkingDay>?,
        review:
            freezed == review
                ? _value.review
                : review // ignore: cast_nullable_to_non_nullable
                    as Review?,
        category:
            freezed == category
                ? _value._category
                : category // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationModelImpl implements _OrganizationModel {
  const _$OrganizationModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'social_media') final List<SocialMedia>? socialMedia,
    @JsonKey(name: 'location') this.location,
    @JsonKey(name: 'working_time') final List<WorkingDay>? workingTime,
    @JsonKey(name: 'review') this.review,
    @JsonKey(name: 'category') final List<String>? category,
  }) : _socialMedia = socialMedia,
       _workingTime = workingTime,
       _category = category;

  factory _$OrganizationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  final List<SocialMedia>? _socialMedia;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia {
    final value = _socialMedia;
    if (value == null) return null;
    if (_socialMedia is EqualUnmodifiableListView) return _socialMedia;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'location')
  final Location? location;
  final List<WorkingDay>? _workingTime;
  @override
  @JsonKey(name: 'working_time')
  List<WorkingDay>? get workingTime {
    final value = _workingTime;
    if (value == null) return null;
    if (_workingTime is EqualUnmodifiableListView) return _workingTime;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'review')
  final Review? review;
  final List<String>? _category;
  @override
  @JsonKey(name: 'category')
  List<String>? get category {
    final value = _category;
    if (value == null) return null;
    if (_category is EqualUnmodifiableListView) return _category;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrganizationModel(id: $id, name: $name, logo: $logo, socialMedia: $socialMedia, location: $location, workingTime: $workingTime, review: $review, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            const DeepCollectionEquality().equals(
              other._socialMedia,
              _socialMedia,
            ) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(
              other._workingTime,
              _workingTime,
            ) &&
            (identical(other.review, review) || other.review == review) &&
            const DeepCollectionEquality().equals(other._category, _category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    logo,
    const DeepCollectionEquality().hash(_socialMedia),
    location,
    const DeepCollectionEquality().hash(_workingTime),
    review,
    const DeepCollectionEquality().hash(_category),
  );

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationModelImplCopyWith<_$OrganizationModelImpl> get copyWith =>
      __$$OrganizationModelImplCopyWithImpl<_$OrganizationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationModelImplToJson(this);
  }
}

abstract class _OrganizationModel implements OrganizationModel {
  const factory _OrganizationModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'social_media') final List<SocialMedia>? socialMedia,
    @JsonKey(name: 'location') final Location? location,
    @JsonKey(name: 'working_time') final List<WorkingDay>? workingTime,
    @JsonKey(name: 'review') final Review? review,
    @JsonKey(name: 'category') final List<String>? category,
  }) = _$OrganizationModelImpl;

  factory _OrganizationModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia;
  @override
  @JsonKey(name: 'location')
  Location? get location;
  @override
  @JsonKey(name: 'working_time')
  List<WorkingDay>? get workingTime;
  @override
  @JsonKey(name: 'review')
  Review? get review;
  @override
  @JsonKey(name: 'category')
  List<String>? get category;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationModelImplCopyWith<_$OrganizationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  @JsonKey(name: 'building_name')
  String? get buildingName => throw _privateConstructorUsedError;
  @JsonKey(name: 'street')
  String? get street => throw _privateConstructorUsedError;
  @JsonKey(name: 'city')
  String? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'state')
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'pin_code')
  String? get pinCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  dynamic get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  dynamic get longitude => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  });
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buildingName = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            buildingName:
                freezed == buildingName
                    ? _value.buildingName
                    : buildingName // ignore: cast_nullable_to_non_nullable
                        as String?,
            street:
                freezed == street
                    ? _value.street
                    : street // ignore: cast_nullable_to_non_nullable
                        as String?,
            city:
                freezed == city
                    ? _value.city
                    : city // ignore: cast_nullable_to_non_nullable
                        as String?,
            state:
                freezed == state
                    ? _value.state
                    : state // ignore: cast_nullable_to_non_nullable
                        as String?,
            pinCode:
                freezed == pinCode
                    ? _value.pinCode
                    : pinCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
    _$LocationImpl value,
    $Res Function(_$LocationImpl) then,
  ) = __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  });
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
    _$LocationImpl _value,
    $Res Function(_$LocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buildingName = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$LocationImpl(
        buildingName:
            freezed == buildingName
                ? _value.buildingName
                : buildingName // ignore: cast_nullable_to_non_nullable
                    as String?,
        street:
            freezed == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                    as String?,
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        state:
            freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                    as String?,
        pinCode:
            freezed == pinCode
                ? _value.pinCode
                : pinCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl({
    @JsonKey(name: 'building_name') this.buildingName,
    @JsonKey(name: 'street') this.street,
    @JsonKey(name: 'city') this.city,
    @JsonKey(name: 'state') this.state,
    @JsonKey(name: 'pin_code') this.pinCode,
    @JsonKey(name: 'latitude') this.latitude,
    @JsonKey(name: 'longitude') this.longitude,
  });

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  @JsonKey(name: 'building_name')
  final String? buildingName;
  @override
  @JsonKey(name: 'street')
  final String? street;
  @override
  @JsonKey(name: 'city')
  final String? city;
  @override
  @JsonKey(name: 'state')
  final String? state;
  @override
  @JsonKey(name: 'pin_code')
  final String? pinCode;
  @override
  @JsonKey(name: 'latitude')
  final dynamic latitude;
  @override
  @JsonKey(name: 'longitude')
  final dynamic longitude;

  @override
  String toString() {
    return 'Location(buildingName: $buildingName, street: $street, city: $city, state: $state, pinCode: $pinCode, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.buildingName, buildingName) ||
                other.buildingName == buildingName) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode) &&
            const DeepCollectionEquality().equals(other.latitude, latitude) &&
            const DeepCollectionEquality().equals(other.longitude, longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    buildingName,
    street,
    city,
    state,
    pinCode,
    const DeepCollectionEquality().hash(latitude),
    const DeepCollectionEquality().hash(longitude),
  );

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(this);
  }
}

abstract class _Location implements Location {
  const factory _Location({
    @JsonKey(name: 'building_name') final String? buildingName,
    @JsonKey(name: 'street') final String? street,
    @JsonKey(name: 'city') final String? city,
    @JsonKey(name: 'state') final String? state,
    @JsonKey(name: 'pin_code') final String? pinCode,
    @JsonKey(name: 'latitude') final dynamic latitude,
    @JsonKey(name: 'longitude') final dynamic longitude,
  }) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  @JsonKey(name: 'building_name')
  String? get buildingName;
  @override
  @JsonKey(name: 'street')
  String? get street;
  @override
  @JsonKey(name: 'city')
  String? get city;
  @override
  @JsonKey(name: 'state')
  String? get state;
  @override
  @JsonKey(name: 'pin_code')
  String? get pinCode;
  @override
  @JsonKey(name: 'latitude')
  dynamic get latitude;
  @override
  @JsonKey(name: 'longitude')
  dynamic get longitude;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return _Review.fromJson(json);
}

/// @nodoc
mixin _$Review {
  @JsonKey(name: 'has_reviewed')
  bool? get hasReviewed => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating')
  int? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'my_review')
  dynamic get myReview => throw _privateConstructorUsedError;

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCopyWith<Review> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCopyWith<$Res> {
  factory $ReviewCopyWith(Review value, $Res Function(Review) then) =
      _$ReviewCopyWithImpl<$Res, Review>;
  @useResult
  $Res call({
    @JsonKey(name: 'has_reviewed') bool? hasReviewed,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'my_review') dynamic myReview,
  });
}

/// @nodoc
class _$ReviewCopyWithImpl<$Res, $Val extends Review>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasReviewed = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? myReview = freezed,
  }) {
    return _then(
      _value.copyWith(
            hasReviewed:
                freezed == hasReviewed
                    ? _value.hasReviewed
                    : hasReviewed // ignore: cast_nullable_to_non_nullable
                        as bool?,
            rating:
                freezed == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int?,
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            myReview:
                freezed == myReview
                    ? _value.myReview
                    : myReview // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewImplCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$$ReviewImplCopyWith(
    _$ReviewImpl value,
    $Res Function(_$ReviewImpl) then,
  ) = __$$ReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'has_reviewed') bool? hasReviewed,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'my_review') dynamic myReview,
  });
}

/// @nodoc
class __$$ReviewImplCopyWithImpl<$Res>
    extends _$ReviewCopyWithImpl<$Res, _$ReviewImpl>
    implements _$$ReviewImplCopyWith<$Res> {
  __$$ReviewImplCopyWithImpl(
    _$ReviewImpl _value,
    $Res Function(_$ReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasReviewed = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? myReview = freezed,
  }) {
    return _then(
      _$ReviewImpl(
        hasReviewed:
            freezed == hasReviewed
                ? _value.hasReviewed
                : hasReviewed // ignore: cast_nullable_to_non_nullable
                    as bool?,
        rating:
            freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int?,
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        myReview:
            freezed == myReview
                ? _value.myReview
                : myReview // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewImpl implements _Review {
  const _$ReviewImpl({
    @JsonKey(name: 'has_reviewed') this.hasReviewed,
    @JsonKey(name: 'rating') this.rating,
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'my_review') this.myReview,
  });

  factory _$ReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewImplFromJson(json);

  @override
  @JsonKey(name: 'has_reviewed')
  final bool? hasReviewed;
  @override
  @JsonKey(name: 'rating')
  final int? rating;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'my_review')
  final dynamic myReview;

  @override
  String toString() {
    return 'Review(hasReviewed: $hasReviewed, rating: $rating, reviewCount: $reviewCount, myReview: $myReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewImpl &&
            (identical(other.hasReviewed, hasReviewed) ||
                other.hasReviewed == hasReviewed) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            const DeepCollectionEquality().equals(other.myReview, myReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasReviewed,
    rating,
    reviewCount,
    const DeepCollectionEquality().hash(myReview),
  );

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      __$$ReviewImplCopyWithImpl<_$ReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewImplToJson(this);
  }
}

abstract class _Review implements Review {
  const factory _Review({
    @JsonKey(name: 'has_reviewed') final bool? hasReviewed,
    @JsonKey(name: 'rating') final int? rating,
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'my_review') final dynamic myReview,
  }) = _$ReviewImpl;

  factory _Review.fromJson(Map<String, dynamic> json) = _$ReviewImpl.fromJson;

  @override
  @JsonKey(name: 'has_reviewed')
  bool? get hasReviewed;
  @override
  @JsonKey(name: 'rating')
  int? get rating;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'my_review')
  dynamic get myReview;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
