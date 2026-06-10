// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) {
  return _PaymentHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentHistoryModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<SinglePaymentHistoryModel>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this PaymentHistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentHistoryModelCopyWith<PaymentHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentHistoryModelCopyWith<$Res> {
  factory $PaymentHistoryModelCopyWith(
    PaymentHistoryModel value,
    $Res Function(PaymentHistoryModel) then,
  ) = _$PaymentHistoryModelCopyWithImpl<$Res, PaymentHistoryModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SinglePaymentHistoryModel>? results,
  });
}

/// @nodoc
class _$PaymentHistoryModelCopyWithImpl<$Res, $Val extends PaymentHistoryModel>
    implements $PaymentHistoryModelCopyWith<$Res> {
  _$PaymentHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _value.copyWith(
            count:
                freezed == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int?,
            next:
                freezed == next
                    ? _value.next
                    : next // ignore: cast_nullable_to_non_nullable
                        as String?,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as String?,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<SinglePaymentHistoryModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentHistoryModelImplCopyWith<$Res>
    implements $PaymentHistoryModelCopyWith<$Res> {
  factory _$$PaymentHistoryModelImplCopyWith(
    _$PaymentHistoryModelImpl value,
    $Res Function(_$PaymentHistoryModelImpl) then,
  ) = __$$PaymentHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SinglePaymentHistoryModel>? results,
  });
}

/// @nodoc
class __$$PaymentHistoryModelImplCopyWithImpl<$Res>
    extends _$PaymentHistoryModelCopyWithImpl<$Res, _$PaymentHistoryModelImpl>
    implements _$$PaymentHistoryModelImplCopyWith<$Res> {
  __$$PaymentHistoryModelImplCopyWithImpl(
    _$PaymentHistoryModelImpl _value,
    $Res Function(_$PaymentHistoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _$PaymentHistoryModelImpl(
        count:
            freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int?,
        next:
            freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                    as String?,
        previous:
            freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                    as String?,
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<SinglePaymentHistoryModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentHistoryModelImpl implements _PaymentHistoryModel {
  const _$PaymentHistoryModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') final List<SinglePaymentHistoryModel>? results,
  }) : _results = results;

  factory _$PaymentHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentHistoryModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  final List<SinglePaymentHistoryModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<SinglePaymentHistoryModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PaymentHistoryModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentHistoryModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    next,
    previous,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of PaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentHistoryModelImplCopyWith<_$PaymentHistoryModelImpl> get copyWith =>
      __$$PaymentHistoryModelImplCopyWithImpl<_$PaymentHistoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentHistoryModelImplToJson(this);
  }
}

abstract class _PaymentHistoryModel implements PaymentHistoryModel {
  const factory _PaymentHistoryModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: 'results') final List<SinglePaymentHistoryModel>? results,
  }) = _$PaymentHistoryModelImpl;

  factory _PaymentHistoryModel.fromJson(Map<String, dynamic> json) =
      _$PaymentHistoryModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;
  @override
  @JsonKey(name: 'results')
  List<SinglePaymentHistoryModel>? get results;

  /// Create a copy of PaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentHistoryModelImplCopyWith<_$PaymentHistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SinglePaymentHistoryModel _$SinglePaymentHistoryModelFromJson(
  Map<String, dynamic> json,
) {
  return _SinglePaymentHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$SinglePaymentHistoryModel {
  @JsonKey(name: 'organization')
  String? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  DateTime? get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_type')
  String? get paymentType => throw _privateConstructorUsedError;

  /// Serializes this SinglePaymentHistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SinglePaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SinglePaymentHistoryModelCopyWith<SinglePaymentHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SinglePaymentHistoryModelCopyWith<$Res> {
  factory $SinglePaymentHistoryModelCopyWith(
    SinglePaymentHistoryModel value,
    $Res Function(SinglePaymentHistoryModel) then,
  ) = _$SinglePaymentHistoryModelCopyWithImpl<$Res, SinglePaymentHistoryModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'payment_date') DateTime? paymentDate,
    @JsonKey(name: 'payment_type') String? paymentType,
  });
}

/// @nodoc
class _$SinglePaymentHistoryModelCopyWithImpl<
  $Res,
  $Val extends SinglePaymentHistoryModel
>
    implements $SinglePaymentHistoryModelCopyWith<$Res> {
  _$SinglePaymentHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SinglePaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organization = freezed,
    Object? amount = freezed,
    Object? paymentDate = freezed,
    Object? paymentType = freezed,
  }) {
    return _then(
      _value.copyWith(
            organization:
                freezed == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as String?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentDate:
                freezed == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            paymentType:
                freezed == paymentType
                    ? _value.paymentType
                    : paymentType // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SinglePaymentHistoryModelImplCopyWith<$Res>
    implements $SinglePaymentHistoryModelCopyWith<$Res> {
  factory _$$SinglePaymentHistoryModelImplCopyWith(
    _$SinglePaymentHistoryModelImpl value,
    $Res Function(_$SinglePaymentHistoryModelImpl) then,
  ) = __$$SinglePaymentHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'payment_date') DateTime? paymentDate,
    @JsonKey(name: 'payment_type') String? paymentType,
  });
}

/// @nodoc
class __$$SinglePaymentHistoryModelImplCopyWithImpl<$Res>
    extends
        _$SinglePaymentHistoryModelCopyWithImpl<
          $Res,
          _$SinglePaymentHistoryModelImpl
        >
    implements _$$SinglePaymentHistoryModelImplCopyWith<$Res> {
  __$$SinglePaymentHistoryModelImplCopyWithImpl(
    _$SinglePaymentHistoryModelImpl _value,
    $Res Function(_$SinglePaymentHistoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SinglePaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organization = freezed,
    Object? amount = freezed,
    Object? paymentDate = freezed,
    Object? paymentType = freezed,
  }) {
    return _then(
      _$SinglePaymentHistoryModelImpl(
        organization:
            freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as String?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentDate:
            freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        paymentType:
            freezed == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SinglePaymentHistoryModelImpl implements _SinglePaymentHistoryModel {
  const _$SinglePaymentHistoryModelImpl({
    @JsonKey(name: 'organization') this.organization,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'payment_date') this.paymentDate,
    @JsonKey(name: 'payment_type') this.paymentType,
  });

  factory _$SinglePaymentHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SinglePaymentHistoryModelImplFromJson(json);

  @override
  @JsonKey(name: 'organization')
  final String? organization;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'payment_date')
  final DateTime? paymentDate;
  @override
  @JsonKey(name: 'payment_type')
  final String? paymentType;

  @override
  String toString() {
    return 'SinglePaymentHistoryModel(organization: $organization, amount: $amount, paymentDate: $paymentDate, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SinglePaymentHistoryModelImpl &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, organization, amount, paymentDate, paymentType);

  /// Create a copy of SinglePaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SinglePaymentHistoryModelImplCopyWith<_$SinglePaymentHistoryModelImpl>
  get copyWith => __$$SinglePaymentHistoryModelImplCopyWithImpl<
    _$SinglePaymentHistoryModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SinglePaymentHistoryModelImplToJson(this);
  }
}

abstract class _SinglePaymentHistoryModel implements SinglePaymentHistoryModel {
  const factory _SinglePaymentHistoryModel({
    @JsonKey(name: 'organization') final String? organization,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'payment_date') final DateTime? paymentDate,
    @JsonKey(name: 'payment_type') final String? paymentType,
  }) = _$SinglePaymentHistoryModelImpl;

  factory _SinglePaymentHistoryModel.fromJson(Map<String, dynamic> json) =
      _$SinglePaymentHistoryModelImpl.fromJson;

  @override
  @JsonKey(name: 'organization')
  String? get organization;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'payment_date')
  DateTime? get paymentDate;
  @override
  @JsonKey(name: 'payment_type')
  String? get paymentType;

  /// Create a copy of SinglePaymentHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SinglePaymentHistoryModelImplCopyWith<_$SinglePaymentHistoryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
