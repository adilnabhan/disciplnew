// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_memberships_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AllMembershipsModel _$AllMembershipsModelFromJson(Map<String, dynamic> json) {
  return _AllMembershipsModel.fromJson(json);
}

/// @nodoc
mixin _$AllMembershipsModel {
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'memberships')
  List<SingleMembershipModel>? get memberships =>
      throw _privateConstructorUsedError;

  /// Serializes this AllMembershipsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AllMembershipsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllMembershipsModelCopyWith<AllMembershipsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllMembershipsModelCopyWith<$Res> {
  factory $AllMembershipsModelCopyWith(
    AllMembershipsModel value,
    $Res Function(AllMembershipsModel) then,
  ) = _$AllMembershipsModelCopyWithImpl<$Res, AllMembershipsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'memberships') List<SingleMembershipModel>? memberships,
  });
}

/// @nodoc
class _$AllMembershipsModelCopyWithImpl<$Res, $Val extends AllMembershipsModel>
    implements $AllMembershipsModelCopyWith<$Res> {
  _$AllMembershipsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllMembershipsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = freezed, Object? memberships = freezed}) {
    return _then(
      _value.copyWith(
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            memberships:
                freezed == memberships
                    ? _value.memberships
                    : memberships // ignore: cast_nullable_to_non_nullable
                        as List<SingleMembershipModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllMembershipsModelImplCopyWith<$Res>
    implements $AllMembershipsModelCopyWith<$Res> {
  factory _$$AllMembershipsModelImplCopyWith(
    _$AllMembershipsModelImpl value,
    $Res Function(_$AllMembershipsModelImpl) then,
  ) = __$$AllMembershipsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'memberships') List<SingleMembershipModel>? memberships,
  });
}

/// @nodoc
class __$$AllMembershipsModelImplCopyWithImpl<$Res>
    extends _$AllMembershipsModelCopyWithImpl<$Res, _$AllMembershipsModelImpl>
    implements _$$AllMembershipsModelImplCopyWith<$Res> {
  __$$AllMembershipsModelImplCopyWithImpl(
    _$AllMembershipsModelImpl _value,
    $Res Function(_$AllMembershipsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllMembershipsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = freezed, Object? memberships = freezed}) {
    return _then(
      _$AllMembershipsModelImpl(
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        memberships:
            freezed == memberships
                ? _value._memberships
                : memberships // ignore: cast_nullable_to_non_nullable
                    as List<SingleMembershipModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AllMembershipsModelImpl implements _AllMembershipsModel {
  const _$AllMembershipsModelImpl({
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'memberships')
    final List<SingleMembershipModel>? memberships,
  }) : _memberships = memberships;

  factory _$AllMembershipsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllMembershipsModelImplFromJson(json);

  @override
  @JsonKey(name: 'status')
  final String? status;
  final List<SingleMembershipModel>? _memberships;
  @override
  @JsonKey(name: 'memberships')
  List<SingleMembershipModel>? get memberships {
    final value = _memberships;
    if (value == null) return null;
    if (_memberships is EqualUnmodifiableListView) return _memberships;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AllMembershipsModel(status: $status, memberships: $memberships)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllMembershipsModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._memberships,
              _memberships,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_memberships),
  );

  /// Create a copy of AllMembershipsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllMembershipsModelImplCopyWith<_$AllMembershipsModelImpl> get copyWith =>
      __$$AllMembershipsModelImplCopyWithImpl<_$AllMembershipsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AllMembershipsModelImplToJson(this);
  }
}

abstract class _AllMembershipsModel implements AllMembershipsModel {
  const factory _AllMembershipsModel({
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'memberships')
    final List<SingleMembershipModel>? memberships,
  }) = _$AllMembershipsModelImpl;

  factory _AllMembershipsModel.fromJson(Map<String, dynamic> json) =
      _$AllMembershipsModelImpl.fromJson;

  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'memberships')
  List<SingleMembershipModel>? get memberships;

  /// Create a copy of AllMembershipsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllMembershipsModelImplCopyWith<_$AllMembershipsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SingleMembershipModel _$SingleMembershipModelFromJson(
  Map<String, dynamic> json,
) {
  return _SingleMembershipModel.fromJson(json);
}

/// @nodoc
mixin _$SingleMembershipModel {
  @JsonKey(name: 'organization_id')
  int? get organizationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_name')
  String? get organizationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_status')
  String? get membershipStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_added')
  bool? get reviewAdded => throw _privateConstructorUsedError;
  @JsonKey(name: 'review')
  dynamic get review => throw _privateConstructorUsedError;

  /// Serializes this SingleMembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleMembershipModelCopyWith<SingleMembershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleMembershipModelCopyWith<$Res> {
  factory $SingleMembershipModelCopyWith(
    SingleMembershipModel value,
    $Res Function(SingleMembershipModel) then,
  ) = _$SingleMembershipModelCopyWithImpl<$Res, SingleMembershipModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'membership_status') String? membershipStatus,
    @JsonKey(name: 'review_added') bool? reviewAdded,
    @JsonKey(name: 'review') dynamic review,
  });
}

/// @nodoc
class _$SingleMembershipModelCopyWithImpl<
  $Res,
  $Val extends SingleMembershipModel
>
    implements $SingleMembershipModelCopyWith<$Res> {
  _$SingleMembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = freezed,
    Object? organizationName = freezed,
    Object? logo = freezed,
    Object? membershipStatus = freezed,
    Object? reviewAdded = freezed,
    Object? review = freezed,
  }) {
    return _then(
      _value.copyWith(
            organizationId:
                freezed == organizationId
                    ? _value.organizationId
                    : organizationId // ignore: cast_nullable_to_non_nullable
                        as int?,
            organizationName:
                freezed == organizationName
                    ? _value.organizationName
                    : organizationName // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            membershipStatus:
                freezed == membershipStatus
                    ? _value.membershipStatus
                    : membershipStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            reviewAdded:
                freezed == reviewAdded
                    ? _value.reviewAdded
                    : reviewAdded // ignore: cast_nullable_to_non_nullable
                        as bool?,
            review:
                freezed == review
                    ? _value.review
                    : review // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SingleMembershipModelImplCopyWith<$Res>
    implements $SingleMembershipModelCopyWith<$Res> {
  factory _$$SingleMembershipModelImplCopyWith(
    _$SingleMembershipModelImpl value,
    $Res Function(_$SingleMembershipModelImpl) then,
  ) = __$$SingleMembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'membership_status') String? membershipStatus,
    @JsonKey(name: 'review_added') bool? reviewAdded,
    @JsonKey(name: 'review') dynamic review,
  });
}

/// @nodoc
class __$$SingleMembershipModelImplCopyWithImpl<$Res>
    extends
        _$SingleMembershipModelCopyWithImpl<$Res, _$SingleMembershipModelImpl>
    implements _$$SingleMembershipModelImplCopyWith<$Res> {
  __$$SingleMembershipModelImplCopyWithImpl(
    _$SingleMembershipModelImpl _value,
    $Res Function(_$SingleMembershipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = freezed,
    Object? organizationName = freezed,
    Object? logo = freezed,
    Object? membershipStatus = freezed,
    Object? reviewAdded = freezed,
    Object? review = freezed,
  }) {
    return _then(
      _$SingleMembershipModelImpl(
        organizationId:
            freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                    as int?,
        organizationName:
            freezed == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        membershipStatus:
            freezed == membershipStatus
                ? _value.membershipStatus
                : membershipStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        reviewAdded:
            freezed == reviewAdded
                ? _value.reviewAdded
                : reviewAdded // ignore: cast_nullable_to_non_nullable
                    as bool?,
        review:
            freezed == review
                ? _value.review
                : review // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleMembershipModelImpl implements _SingleMembershipModel {
  const _$SingleMembershipModelImpl({
    @JsonKey(name: 'organization_id') this.organizationId,
    @JsonKey(name: 'organization_name') this.organizationName,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'membership_status') this.membershipStatus,
    @JsonKey(name: 'review_added') this.reviewAdded,
    @JsonKey(name: 'review') this.review,
  });

  factory _$SingleMembershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleMembershipModelImplFromJson(json);

  @override
  @JsonKey(name: 'organization_id')
  final int? organizationId;
  @override
  @JsonKey(name: 'organization_name')
  final String? organizationName;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'membership_status')
  final String? membershipStatus;
  @override
  @JsonKey(name: 'review_added')
  final bool? reviewAdded;
  @override
  @JsonKey(name: 'review')
  final dynamic review;

  @override
  String toString() {
    return 'SingleMembershipModel(organizationId: $organizationId, organizationName: $organizationName, logo: $logo, membershipStatus: $membershipStatus, reviewAdded: $reviewAdded, review: $review)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleMembershipModelImpl &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.membershipStatus, membershipStatus) ||
                other.membershipStatus == membershipStatus) &&
            (identical(other.reviewAdded, reviewAdded) ||
                other.reviewAdded == reviewAdded) &&
            const DeepCollectionEquality().equals(other.review, review));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    organizationId,
    organizationName,
    logo,
    membershipStatus,
    reviewAdded,
    const DeepCollectionEquality().hash(review),
  );

  /// Create a copy of SingleMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleMembershipModelImplCopyWith<_$SingleMembershipModelImpl>
  get copyWith =>
      __$$SingleMembershipModelImplCopyWithImpl<_$SingleMembershipModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleMembershipModelImplToJson(this);
  }
}

abstract class _SingleMembershipModel implements SingleMembershipModel {
  const factory _SingleMembershipModel({
    @JsonKey(name: 'organization_id') final int? organizationId,
    @JsonKey(name: 'organization_name') final String? organizationName,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'membership_status') final String? membershipStatus,
    @JsonKey(name: 'review_added') final bool? reviewAdded,
    @JsonKey(name: 'review') final dynamic review,
  }) = _$SingleMembershipModelImpl;

  factory _SingleMembershipModel.fromJson(Map<String, dynamic> json) =
      _$SingleMembershipModelImpl.fromJson;

  @override
  @JsonKey(name: 'organization_id')
  int? get organizationId;
  @override
  @JsonKey(name: 'organization_name')
  String? get organizationName;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'membership_status')
  String? get membershipStatus;
  @override
  @JsonKey(name: 'review_added')
  bool? get reviewAdded;
  @override
  @JsonKey(name: 'review')
  dynamic get review;

  /// Create a copy of SingleMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleMembershipModelImplCopyWith<_$SingleMembershipModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
