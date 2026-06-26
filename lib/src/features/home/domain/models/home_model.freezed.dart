// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HomeModel _$HomeModelFromJson(Map<String, dynamic> json) {
  return _HomeModel.fromJson(json);
}

/// @nodoc
mixin _$HomeModel {
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription')
  Subscription? get subscription => throw _privateConstructorUsedError;
  @JsonKey(name: 'banners')
  List<String>? get banners => throw _privateConstructorUsedError;
  @JsonKey(name: 'fitness_center_banners')
  List<String>? get fitnessCenterBanners => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_trainer')
  AssignedTrainerModel? get assignedTrainer =>
      throw _privateConstructorUsedError;

  /// Serializes this HomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeModelCopyWith<HomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeModelCopyWith<$Res> {
  factory $HomeModelCopyWith(HomeModel value, $Res Function(HomeModel) then) =
      _$HomeModelCopyWithImpl<$Res, HomeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'subscription') Subscription? subscription,
    @JsonKey(name: 'banners') List<String>? banners,
    @JsonKey(name: 'fitness_center_banners') List<String>? fitnessCenterBanners,
    @JsonKey(name: 'assigned_trainer') AssignedTrainerModel? assignedTrainer,
  });

  $SubscriptionCopyWith<$Res>? get subscription;
  $AssignedTrainerModelCopyWith<$Res>? get assignedTrainer;
}

/// @nodoc
class _$HomeModelCopyWithImpl<$Res, $Val extends HomeModel>
    implements $HomeModelCopyWith<$Res> {
  _$HomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSubscribed = freezed,
    Object? subscription = freezed,
    Object? banners = freezed,
    Object? fitnessCenterBanners = freezed,
    Object? assignedTrainer = freezed,
  }) {
    return _then(
      _value.copyWith(
            isSubscribed:
                freezed == isSubscribed
                    ? _value.isSubscribed
                    : isSubscribed // ignore: cast_nullable_to_non_nullable
                        as bool?,
            subscription:
                freezed == subscription
                    ? _value.subscription
                    : subscription // ignore: cast_nullable_to_non_nullable
                        as Subscription?,
            banners:
                freezed == banners
                    ? _value.banners
                    : banners // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            fitnessCenterBanners:
                freezed == fitnessCenterBanners
                    ? _value.fitnessCenterBanners
                    : fitnessCenterBanners // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            assignedTrainer:
                freezed == assignedTrainer
                    ? _value.assignedTrainer
                    : assignedTrainer // ignore: cast_nullable_to_non_nullable
                        as AssignedTrainerModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<$Res>? get subscription {
    if (_value.subscription == null) {
      return null;
    }

    return $SubscriptionCopyWith<$Res>(_value.subscription!, (value) {
      return _then(_value.copyWith(subscription: value) as $Val);
    });
  }

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssignedTrainerModelCopyWith<$Res>? get assignedTrainer {
    if (_value.assignedTrainer == null) {
      return null;
    }

    return $AssignedTrainerModelCopyWith<$Res>(_value.assignedTrainer!, (
      value,
    ) {
      return _then(_value.copyWith(assignedTrainer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeModelImplCopyWith<$Res>
    implements $HomeModelCopyWith<$Res> {
  factory _$$HomeModelImplCopyWith(
    _$HomeModelImpl value,
    $Res Function(_$HomeModelImpl) then,
  ) = __$$HomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'subscription') Subscription? subscription,
    @JsonKey(name: 'banners') List<String>? banners,
    @JsonKey(name: 'fitness_center_banners') List<String>? fitnessCenterBanners,
    @JsonKey(name: 'assigned_trainer') AssignedTrainerModel? assignedTrainer,
  });

  @override
  $SubscriptionCopyWith<$Res>? get subscription;
  @override
  $AssignedTrainerModelCopyWith<$Res>? get assignedTrainer;
}

/// @nodoc
class __$$HomeModelImplCopyWithImpl<$Res>
    extends _$HomeModelCopyWithImpl<$Res, _$HomeModelImpl>
    implements _$$HomeModelImplCopyWith<$Res> {
  __$$HomeModelImplCopyWithImpl(
    _$HomeModelImpl _value,
    $Res Function(_$HomeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSubscribed = freezed,
    Object? subscription = freezed,
    Object? banners = freezed,
    Object? fitnessCenterBanners = freezed,
    Object? assignedTrainer = freezed,
  }) {
    return _then(
      _$HomeModelImpl(
        isSubscribed:
            freezed == isSubscribed
                ? _value.isSubscribed
                : isSubscribed // ignore: cast_nullable_to_non_nullable
                    as bool?,
        subscription:
            freezed == subscription
                ? _value.subscription
                : subscription // ignore: cast_nullable_to_non_nullable
                    as Subscription?,
        banners:
            freezed == banners
                ? _value._banners
                : banners // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        fitnessCenterBanners:
            freezed == fitnessCenterBanners
                ? _value._fitnessCenterBanners
                : fitnessCenterBanners // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        assignedTrainer:
            freezed == assignedTrainer
                ? _value.assignedTrainer
                : assignedTrainer // ignore: cast_nullable_to_non_nullable
                    as AssignedTrainerModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeModelImpl implements _HomeModel {
  const _$HomeModelImpl({
    @JsonKey(name: 'is_subscribed') this.isSubscribed,
    @JsonKey(name: 'subscription') this.subscription,
    @JsonKey(name: 'banners') final List<String>? banners,
    @JsonKey(name: 'fitness_center_banners')
    final List<String>? fitnessCenterBanners,
    @JsonKey(name: 'assigned_trainer') this.assignedTrainer,
  }) : _banners = banners,
       _fitnessCenterBanners = fitnessCenterBanners;

  factory _$HomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeModelImplFromJson(json);

  @override
  @JsonKey(name: 'is_subscribed')
  final bool? isSubscribed;
  @override
  @JsonKey(name: 'subscription')
  final Subscription? subscription;
  final List<String>? _banners;
  @override
  @JsonKey(name: 'banners')
  List<String>? get banners {
    final value = _banners;
    if (value == null) return null;
    if (_banners is EqualUnmodifiableListView) return _banners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _fitnessCenterBanners;
  @override
  @JsonKey(name: 'fitness_center_banners')
  List<String>? get fitnessCenterBanners {
    final value = _fitnessCenterBanners;
    if (value == null) return null;
    if (_fitnessCenterBanners is EqualUnmodifiableListView)
      return _fitnessCenterBanners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'assigned_trainer')
  final AssignedTrainerModel? assignedTrainer;

  @override
  String toString() {
    return 'HomeModel(isSubscribed: $isSubscribed, subscription: $subscription, banners: $banners, fitnessCenterBanners: $fitnessCenterBanners, assignedTrainer: $assignedTrainer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeModelImpl &&
            (identical(other.isSubscribed, isSubscribed) ||
                other.isSubscribed == isSubscribed) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription) &&
            const DeepCollectionEquality().equals(other._banners, _banners) &&
            const DeepCollectionEquality().equals(
              other._fitnessCenterBanners,
              _fitnessCenterBanners,
            ) &&
            (identical(other.assignedTrainer, assignedTrainer) ||
                other.assignedTrainer == assignedTrainer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isSubscribed,
    subscription,
    const DeepCollectionEquality().hash(_banners),
    const DeepCollectionEquality().hash(_fitnessCenterBanners),
    assignedTrainer,
  );

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      __$$HomeModelImplCopyWithImpl<_$HomeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeModelImplToJson(this);
  }
}

abstract class _HomeModel implements HomeModel {
  const factory _HomeModel({
    @JsonKey(name: 'is_subscribed') final bool? isSubscribed,
    @JsonKey(name: 'subscription') final Subscription? subscription,
    @JsonKey(name: 'banners') final List<String>? banners,
    @JsonKey(name: 'fitness_center_banners')
    final List<String>? fitnessCenterBanners,
    @JsonKey(name: 'assigned_trainer')
    final AssignedTrainerModel? assignedTrainer,
  }) = _$HomeModelImpl;

  factory _HomeModel.fromJson(Map<String, dynamic> json) =
      _$HomeModelImpl.fromJson;

  @override
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed;
  @override
  @JsonKey(name: 'subscription')
  Subscription? get subscription;
  @override
  @JsonKey(name: 'banners')
  List<String>? get banners;
  @override
  @JsonKey(name: 'fitness_center_banners')
  List<String>? get fitnessCenterBanners;
  @override
  @JsonKey(name: 'assigned_trainer')
  AssignedTrainerModel? get assignedTrainer;

  /// Create a copy of HomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  @JsonKey(name: 'organization_name')
  String? get organizationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_logo')
  String? get organizationLogo => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_name')
  String? get planName => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationName = freezed,
    Object? organizationLogo = freezed,
    Object? planName = freezed,
    Object? durationDays = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            organizationName:
                freezed == organizationName
                    ? _value.organizationName
                    : organizationName // ignore: cast_nullable_to_non_nullable
                        as String?,
            organizationLogo:
                freezed == organizationLogo
                    ? _value.organizationLogo
                    : organizationLogo // ignore: cast_nullable_to_non_nullable
                        as String?,
            planName:
                freezed == planName
                    ? _value.planName
                    : planName // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationDays:
                freezed == durationDays
                    ? _value.durationDays
                    : durationDays // ignore: cast_nullable_to_non_nullable
                        as int?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationName = freezed,
    Object? organizationLogo = freezed,
    Object? planName = freezed,
    Object? durationDays = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _$SubscriptionImpl(
        organizationName:
            freezed == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                    as String?,
        organizationLogo:
            freezed == organizationLogo
                ? _value.organizationLogo
                : organizationLogo // ignore: cast_nullable_to_non_nullable
                    as String?,
        planName:
            freezed == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationDays:
            freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                    as int?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl({
    @JsonKey(name: 'organization_name') this.organizationName,
    @JsonKey(name: 'organization_logo') this.organizationLogo,
    @JsonKey(name: 'plan_name') this.planName,
    @JsonKey(name: 'duration_days') this.durationDays,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
  });

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  @JsonKey(name: 'organization_name')
  final String? organizationName;
  @override
  @JsonKey(name: 'organization_logo')
  final String? organizationLogo;
  @override
  @JsonKey(name: 'plan_name')
  final String? planName;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @override
  String toString() {
    return 'Subscription(organizationName: $organizationName, organizationLogo: $organizationLogo, planName: $planName, durationDays: $durationDays, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.organizationLogo, organizationLogo) ||
                other.organizationLogo == organizationLogo) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    organizationName,
    organizationLogo,
    planName,
    durationDays,
    startDate,
    endDate,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription({
    @JsonKey(name: 'organization_name') final String? organizationName,
    @JsonKey(name: 'organization_logo') final String? organizationLogo,
    @JsonKey(name: 'plan_name') final String? planName,
    @JsonKey(name: 'duration_days') final int? durationDays,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
  }) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  @JsonKey(name: 'organization_name')
  String? get organizationName;
  @override
  @JsonKey(name: 'organization_logo')
  String? get organizationLogo;
  @override
  @JsonKey(name: 'plan_name')
  String? get planName;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssignedTrainerModel _$AssignedTrainerModelFromJson(Map<String, dynamic> json) {
  return _AssignedTrainerModel.fromJson(json);
}

/// @nodoc
mixin _$AssignedTrainerModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile')
  String? get mobile => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience_years')
  int? get experienceYears => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio')
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'specializations')
  List<String>? get specializations => throw _privateConstructorUsedError;

  /// Serializes this AssignedTrainerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignedTrainerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignedTrainerModelCopyWith<AssignedTrainerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignedTrainerModelCopyWith<$Res> {
  factory $AssignedTrainerModelCopyWith(
    AssignedTrainerModel value,
    $Res Function(AssignedTrainerModel) then,
  ) = _$AssignedTrainerModelCopyWithImpl<$Res, AssignedTrainerModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'experience_years') int? experienceYears,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'specializations') List<String>? specializations,
  });
}

/// @nodoc
class _$AssignedTrainerModelCopyWithImpl<
  $Res,
  $Val extends AssignedTrainerModel
>
    implements $AssignedTrainerModelCopyWith<$Res> {
  _$AssignedTrainerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignedTrainerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? profileImage = freezed,
    Object? mobile = freezed,
    Object? experienceYears = freezed,
    Object? bio = freezed,
    Object? specializations = freezed,
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
            profileImage:
                freezed == profileImage
                    ? _value.profileImage
                    : profileImage // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobile:
                freezed == mobile
                    ? _value.mobile
                    : mobile // ignore: cast_nullable_to_non_nullable
                        as String?,
            experienceYears:
                freezed == experienceYears
                    ? _value.experienceYears
                    : experienceYears // ignore: cast_nullable_to_non_nullable
                        as int?,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            specializations:
                freezed == specializations
                    ? _value.specializations
                    : specializations // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignedTrainerModelImplCopyWith<$Res>
    implements $AssignedTrainerModelCopyWith<$Res> {
  factory _$$AssignedTrainerModelImplCopyWith(
    _$AssignedTrainerModelImpl value,
    $Res Function(_$AssignedTrainerModelImpl) then,
  ) = __$$AssignedTrainerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'experience_years') int? experienceYears,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'specializations') List<String>? specializations,
  });
}

/// @nodoc
class __$$AssignedTrainerModelImplCopyWithImpl<$Res>
    extends _$AssignedTrainerModelCopyWithImpl<$Res, _$AssignedTrainerModelImpl>
    implements _$$AssignedTrainerModelImplCopyWith<$Res> {
  __$$AssignedTrainerModelImplCopyWithImpl(
    _$AssignedTrainerModelImpl _value,
    $Res Function(_$AssignedTrainerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedTrainerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? profileImage = freezed,
    Object? mobile = freezed,
    Object? experienceYears = freezed,
    Object? bio = freezed,
    Object? specializations = freezed,
  }) {
    return _then(
      _$AssignedTrainerModelImpl(
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
        profileImage:
            freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobile:
            freezed == mobile
                ? _value.mobile
                : mobile // ignore: cast_nullable_to_non_nullable
                    as String?,
        experienceYears:
            freezed == experienceYears
                ? _value.experienceYears
                : experienceYears // ignore: cast_nullable_to_non_nullable
                    as int?,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        specializations:
            freezed == specializations
                ? _value._specializations
                : specializations // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedTrainerModelImpl implements _AssignedTrainerModel {
  const _$AssignedTrainerModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'profile_image') this.profileImage,
    @JsonKey(name: 'mobile') this.mobile,
    @JsonKey(name: 'experience_years') this.experienceYears,
    @JsonKey(name: 'bio') this.bio,
    @JsonKey(name: 'specializations') final List<String>? specializations,
  }) : _specializations = specializations;

  factory _$AssignedTrainerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedTrainerModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @override
  @JsonKey(name: 'mobile')
  final String? mobile;
  @override
  @JsonKey(name: 'experience_years')
  final int? experienceYears;
  @override
  @JsonKey(name: 'bio')
  final String? bio;
  final List<String>? _specializations;
  @override
  @JsonKey(name: 'specializations')
  List<String>? get specializations {
    final value = _specializations;
    if (value == null) return null;
    if (_specializations is EqualUnmodifiableListView) return _specializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AssignedTrainerModel(id: $id, name: $name, profileImage: $profileImage, mobile: $mobile, experienceYears: $experienceYears, bio: $bio, specializations: $specializations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedTrainerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(
              other._specializations,
              _specializations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    profileImage,
    mobile,
    experienceYears,
    bio,
    const DeepCollectionEquality().hash(_specializations),
  );

  /// Create a copy of AssignedTrainerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedTrainerModelImplCopyWith<_$AssignedTrainerModelImpl>
  get copyWith =>
      __$$AssignedTrainerModelImplCopyWithImpl<_$AssignedTrainerModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedTrainerModelImplToJson(this);
  }
}

abstract class _AssignedTrainerModel implements AssignedTrainerModel {
  const factory _AssignedTrainerModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'profile_image') final String? profileImage,
    @JsonKey(name: 'mobile') final String? mobile,
    @JsonKey(name: 'experience_years') final int? experienceYears,
    @JsonKey(name: 'bio') final String? bio,
    @JsonKey(name: 'specializations') final List<String>? specializations,
  }) = _$AssignedTrainerModelImpl;

  factory _AssignedTrainerModel.fromJson(Map<String, dynamic> json) =
      _$AssignedTrainerModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  @JsonKey(name: 'mobile')
  String? get mobile;
  @override
  @JsonKey(name: 'experience_years')
  int? get experienceYears;
  @override
  @JsonKey(name: 'bio')
  String? get bio;
  @override
  @JsonKey(name: 'specializations')
  List<String>? get specializations;

  /// Create a copy of AssignedTrainerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedTrainerModelImplCopyWith<_$AssignedTrainerModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
