// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitnesscenter_membership_plans_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FitnesscenterMembershipPlansModel _$FitnesscenterMembershipPlansModelFromJson(
  Map<String, dynamic> json,
) {
  return _FitnesscenterMembershipPlansModel.fromJson(json);
}

/// @nodoc
mixin _$FitnesscenterMembershipPlansModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'package_type')
  String? get packageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_price')
  String? get actualPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'offer_price')
  String? get offerPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'features')
  List<dynamic>? get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_plans')
  List<EmiOptionsModel> get emiPlans => throw _privateConstructorUsedError;

  /// Serializes this FitnesscenterMembershipPlansModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FitnesscenterMembershipPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnesscenterMembershipPlansModelCopyWith<FitnesscenterMembershipPlansModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnesscenterMembershipPlansModelCopyWith<$Res> {
  factory $FitnesscenterMembershipPlansModelCopyWith(
    FitnesscenterMembershipPlansModel value,
    $Res Function(FitnesscenterMembershipPlansModel) then,
  ) =
      _$FitnesscenterMembershipPlansModelCopyWithImpl<
        $Res,
        FitnesscenterMembershipPlansModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<dynamic>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') List<EmiOptionsModel> emiPlans,
  });
}

/// @nodoc
class _$FitnesscenterMembershipPlansModelCopyWithImpl<
  $Res,
  $Val extends FitnesscenterMembershipPlansModel
>
    implements $FitnesscenterMembershipPlansModelCopyWith<$Res> {
  _$FitnesscenterMembershipPlansModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnesscenterMembershipPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
    Object? emiPlans = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            packageType:
                freezed == packageType
                    ? _value.packageType
                    : packageType // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            actualPrice:
                freezed == actualPrice
                    ? _value.actualPrice
                    : actualPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            offerPrice:
                freezed == offerPrice
                    ? _value.offerPrice
                    : offerPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationDays:
                freezed == durationDays
                    ? _value.durationDays
                    : durationDays // ignore: cast_nullable_to_non_nullable
                        as int?,
            features:
                freezed == features
                    ? _value.features
                    : features // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isEmiAvailable:
                freezed == isEmiAvailable
                    ? _value.isEmiAvailable
                    : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
            emiPlans:
                null == emiPlans
                    ? _value.emiPlans
                    : emiPlans // ignore: cast_nullable_to_non_nullable
                        as List<EmiOptionsModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FitnesscenterMembershipPlansModelImplCopyWith<$Res>
    implements $FitnesscenterMembershipPlansModelCopyWith<$Res> {
  factory _$$FitnesscenterMembershipPlansModelImplCopyWith(
    _$FitnesscenterMembershipPlansModelImpl value,
    $Res Function(_$FitnesscenterMembershipPlansModelImpl) then,
  ) = __$$FitnesscenterMembershipPlansModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<dynamic>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') List<EmiOptionsModel> emiPlans,
  });
}

/// @nodoc
class __$$FitnesscenterMembershipPlansModelImplCopyWithImpl<$Res>
    extends
        _$FitnesscenterMembershipPlansModelCopyWithImpl<
          $Res,
          _$FitnesscenterMembershipPlansModelImpl
        >
    implements _$$FitnesscenterMembershipPlansModelImplCopyWith<$Res> {
  __$$FitnesscenterMembershipPlansModelImplCopyWithImpl(
    _$FitnesscenterMembershipPlansModelImpl _value,
    $Res Function(_$FitnesscenterMembershipPlansModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnesscenterMembershipPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
    Object? emiPlans = null,
  }) {
    return _then(
      _$FitnesscenterMembershipPlansModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        packageType:
            freezed == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        actualPrice:
            freezed == actualPrice
                ? _value.actualPrice
                : actualPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        offerPrice:
            freezed == offerPrice
                ? _value.offerPrice
                : offerPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationDays:
            freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                    as int?,
        features:
            freezed == features
                ? _value._features
                : features // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isEmiAvailable:
            freezed == isEmiAvailable
                ? _value.isEmiAvailable
                : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
        emiPlans:
            null == emiPlans
                ? _value._emiPlans
                : emiPlans // ignore: cast_nullable_to_non_nullable
                    as List<EmiOptionsModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FitnesscenterMembershipPlansModelImpl
    implements _FitnesscenterMembershipPlansModel {
  const _$FitnesscenterMembershipPlansModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'package_type') this.packageType,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'actual_price') this.actualPrice,
    @JsonKey(name: 'offer_price') this.offerPrice,
    @JsonKey(name: 'duration_days') this.durationDays,
    @JsonKey(name: 'features') final List<dynamic>? features,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'is_emi_available') this.isEmiAvailable,
    @JsonKey(name: 'emi_plans') final List<EmiOptionsModel> emiPlans = const [],
  }) : _features = features,
       _emiPlans = emiPlans;

  factory _$FitnesscenterMembershipPlansModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$FitnesscenterMembershipPlansModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'package_type')
  final String? packageType;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'actual_price')
  final String? actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  final String? offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  final List<dynamic>? _features;
  @override
  @JsonKey(name: 'features')
  List<dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  final bool? isEmiAvailable;
  final List<EmiOptionsModel> _emiPlans;
  @override
  @JsonKey(name: 'emi_plans')
  List<EmiOptionsModel> get emiPlans {
    if (_emiPlans is EqualUnmodifiableListView) return _emiPlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_emiPlans);
  }

  @override
  String toString() {
    return 'FitnesscenterMembershipPlansModel(id: $id, packageType: $packageType, name: $name, description: $description, actualPrice: $actualPrice, offerPrice: $offerPrice, durationDays: $durationDays, features: $features, isActive: $isActive, isEmiAvailable: $isEmiAvailable, emiPlans: $emiPlans)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnesscenterMembershipPlansModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actualPrice, actualPrice) ||
                other.actualPrice == actualPrice) &&
            (identical(other.offerPrice, offerPrice) ||
                other.offerPrice == offerPrice) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isEmiAvailable, isEmiAvailable) ||
                other.isEmiAvailable == isEmiAvailable) &&
            const DeepCollectionEquality().equals(other._emiPlans, _emiPlans));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    packageType,
    name,
    description,
    actualPrice,
    offerPrice,
    durationDays,
    const DeepCollectionEquality().hash(_features),
    isActive,
    isEmiAvailable,
    const DeepCollectionEquality().hash(_emiPlans),
  );

  /// Create a copy of FitnesscenterMembershipPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnesscenterMembershipPlansModelImplCopyWith<
    _$FitnesscenterMembershipPlansModelImpl
  >
  get copyWith => __$$FitnesscenterMembershipPlansModelImplCopyWithImpl<
    _$FitnesscenterMembershipPlansModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FitnesscenterMembershipPlansModelImplToJson(this);
  }
}

abstract class _FitnesscenterMembershipPlansModel
    implements FitnesscenterMembershipPlansModel {
  const factory _FitnesscenterMembershipPlansModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'package_type') final String? packageType,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'actual_price') final String? actualPrice,
    @JsonKey(name: 'offer_price') final String? offerPrice,
    @JsonKey(name: 'duration_days') final int? durationDays,
    @JsonKey(name: 'features') final List<dynamic>? features,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'is_emi_available') final bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') final List<EmiOptionsModel> emiPlans,
  }) = _$FitnesscenterMembershipPlansModelImpl;

  factory _FitnesscenterMembershipPlansModel.fromJson(
    Map<String, dynamic> json,
  ) = _$FitnesscenterMembershipPlansModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'package_type')
  String? get packageType;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'actual_price')
  String? get actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  String? get offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'features')
  List<dynamic>? get features;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable;
  @override
  @JsonKey(name: 'emi_plans')
  List<EmiOptionsModel> get emiPlans;

  /// Create a copy of FitnesscenterMembershipPlansModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnesscenterMembershipPlansModelImplCopyWith<
    _$FitnesscenterMembershipPlansModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

EmiOptionsModel _$EmiOptionsModelFromJson(Map<String, dynamic> json) {
  return _EmiOptionsModel.fromJson(json);
}

/// @nodoc
mixin _$EmiOptionsModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_of_installments')
  int get month => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  double get price => throw _privateConstructorUsedError;

  /// Serializes this EmiOptionsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmiOptionsModelCopyWith<EmiOptionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiOptionsModelCopyWith<$Res> {
  factory $EmiOptionsModelCopyWith(
    EmiOptionsModel value,
    $Res Function(EmiOptionsModel) then,
  ) = _$EmiOptionsModelCopyWithImpl<$Res, EmiOptionsModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'number_of_installments') int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    double price,
  });
}

/// @nodoc
class _$EmiOptionsModelCopyWithImpl<$Res, $Val extends EmiOptionsModel>
    implements $EmiOptionsModelCopyWith<$Res> {
  _$EmiOptionsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? month = null, Object? price = null}) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            month:
                null == month
                    ? _value.month
                    : month // ignore: cast_nullable_to_non_nullable
                        as int,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmiOptionsModelImplCopyWith<$Res>
    implements $EmiOptionsModelCopyWith<$Res> {
  factory _$$EmiOptionsModelImplCopyWith(
    _$EmiOptionsModelImpl value,
    $Res Function(_$EmiOptionsModelImpl) then,
  ) = __$$EmiOptionsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'number_of_installments') int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    double price,
  });
}

/// @nodoc
class __$$EmiOptionsModelImplCopyWithImpl<$Res>
    extends _$EmiOptionsModelCopyWithImpl<$Res, _$EmiOptionsModelImpl>
    implements _$$EmiOptionsModelImplCopyWith<$Res> {
  __$$EmiOptionsModelImplCopyWithImpl(
    _$EmiOptionsModelImpl _value,
    $Res Function(_$EmiOptionsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? month = null, Object? price = null}) {
    return _then(
      _$EmiOptionsModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        month:
            null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                    as int,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiOptionsModelImpl implements _EmiOptionsModel {
  const _$EmiOptionsModelImpl({
    required this.id,
    @JsonKey(name: 'number_of_installments') required this.month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    required this.price,
  });

  factory _$EmiOptionsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiOptionsModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'number_of_installments')
  final int month;
  @override
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  final double price;

  @override
  String toString() {
    return 'EmiOptionsModel(id: $id, month: $month, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiOptionsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, month, price);

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiOptionsModelImplCopyWith<_$EmiOptionsModelImpl> get copyWith =>
      __$$EmiOptionsModelImplCopyWithImpl<_$EmiOptionsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiOptionsModelImplToJson(this);
  }
}

abstract class _EmiOptionsModel implements EmiOptionsModel {
  const factory _EmiOptionsModel({
    required final int id,
    @JsonKey(name: 'number_of_installments') required final int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    required final double price,
  }) = _$EmiOptionsModelImpl;

  factory _EmiOptionsModel.fromJson(Map<String, dynamic> json) =
      _$EmiOptionsModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'number_of_installments')
  int get month;
  @override
  @JsonKey(
    name: 'emi_amount_per_cycle',
    fromJson: StringToDoubleConverter.fromJsonStatic,
    toJson: StringToDoubleConverter.toJsonStatic,
  )
  double get price;

  /// Create a copy of EmiOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmiOptionsModelImplCopyWith<_$EmiOptionsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
