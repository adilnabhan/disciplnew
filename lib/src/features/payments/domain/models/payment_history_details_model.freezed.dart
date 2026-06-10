// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_history_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentHistoryDetailsModel _$PaymentHistoryDetailsModelFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentHistoryDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentHistoryDetailsModel {
  @JsonKey(name: 'customer_id')
  int? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'memberships')
  List<Membershipes>? get memberships => throw _privateConstructorUsedError;

  /// Serializes this PaymentHistoryDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentHistoryDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentHistoryDetailsModelCopyWith<PaymentHistoryDetailsModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentHistoryDetailsModelCopyWith<$Res> {
  factory $PaymentHistoryDetailsModelCopyWith(
    PaymentHistoryDetailsModel value,
    $Res Function(PaymentHistoryDetailsModel) then,
  ) =
      _$PaymentHistoryDetailsModelCopyWithImpl<
        $Res,
        PaymentHistoryDetailsModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'memberships') List<Membershipes>? memberships,
  });
}

/// @nodoc
class _$PaymentHistoryDetailsModelCopyWithImpl<
  $Res,
  $Val extends PaymentHistoryDetailsModel
>
    implements $PaymentHistoryDetailsModelCopyWith<$Res> {
  _$PaymentHistoryDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentHistoryDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? customerId = freezed, Object? memberships = freezed}) {
    return _then(
      _value.copyWith(
            customerId:
                freezed == customerId
                    ? _value.customerId
                    : customerId // ignore: cast_nullable_to_non_nullable
                        as int?,
            memberships:
                freezed == memberships
                    ? _value.memberships
                    : memberships // ignore: cast_nullable_to_non_nullable
                        as List<Membershipes>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentHistoryDetailsModelImplCopyWith<$Res>
    implements $PaymentHistoryDetailsModelCopyWith<$Res> {
  factory _$$PaymentHistoryDetailsModelImplCopyWith(
    _$PaymentHistoryDetailsModelImpl value,
    $Res Function(_$PaymentHistoryDetailsModelImpl) then,
  ) = __$$PaymentHistoryDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'memberships') List<Membershipes>? memberships,
  });
}

/// @nodoc
class __$$PaymentHistoryDetailsModelImplCopyWithImpl<$Res>
    extends
        _$PaymentHistoryDetailsModelCopyWithImpl<
          $Res,
          _$PaymentHistoryDetailsModelImpl
        >
    implements _$$PaymentHistoryDetailsModelImplCopyWith<$Res> {
  __$$PaymentHistoryDetailsModelImplCopyWithImpl(
    _$PaymentHistoryDetailsModelImpl _value,
    $Res Function(_$PaymentHistoryDetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentHistoryDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? customerId = freezed, Object? memberships = freezed}) {
    return _then(
      _$PaymentHistoryDetailsModelImpl(
        customerId:
            freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                    as int?,
        memberships:
            freezed == memberships
                ? _value._memberships
                : memberships // ignore: cast_nullable_to_non_nullable
                    as List<Membershipes>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentHistoryDetailsModelImpl implements _PaymentHistoryDetailsModel {
  const _$PaymentHistoryDetailsModelImpl({
    @JsonKey(name: 'customer_id') this.customerId,
    @JsonKey(name: 'memberships') final List<Membershipes>? memberships,
  }) : _memberships = memberships;

  factory _$PaymentHistoryDetailsModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PaymentHistoryDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: 'customer_id')
  final int? customerId;
  final List<Membershipes>? _memberships;
  @override
  @JsonKey(name: 'memberships')
  List<Membershipes>? get memberships {
    final value = _memberships;
    if (value == null) return null;
    if (_memberships is EqualUnmodifiableListView) return _memberships;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PaymentHistoryDetailsModel(customerId: $customerId, memberships: $memberships)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentHistoryDetailsModelImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            const DeepCollectionEquality().equals(
              other._memberships,
              _memberships,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerId,
    const DeepCollectionEquality().hash(_memberships),
  );

  /// Create a copy of PaymentHistoryDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentHistoryDetailsModelImplCopyWith<_$PaymentHistoryDetailsModelImpl>
  get copyWith => __$$PaymentHistoryDetailsModelImplCopyWithImpl<
    _$PaymentHistoryDetailsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentHistoryDetailsModelImplToJson(this);
  }
}

abstract class _PaymentHistoryDetailsModel
    implements PaymentHistoryDetailsModel {
  const factory _PaymentHistoryDetailsModel({
    @JsonKey(name: 'customer_id') final int? customerId,
    @JsonKey(name: 'memberships') final List<Membershipes>? memberships,
  }) = _$PaymentHistoryDetailsModelImpl;

  factory _PaymentHistoryDetailsModel.fromJson(Map<String, dynamic> json) =
      _$PaymentHistoryDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: 'customer_id')
  int? get customerId;
  @override
  @JsonKey(name: 'memberships')
  List<Membershipes>? get memberships;

  /// Create a copy of PaymentHistoryDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentHistoryDetailsModelImplCopyWith<_$PaymentHistoryDetailsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Membershipes _$MembershipesFromJson(Map<String, dynamic> json) {
  return _Membershipes.fromJson(json);
}

/// @nodoc
mixin _$Membershipes {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_name')
  String? get membershipName => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_name')
  String? get organizationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'assign_free')
  bool? get assignFree => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_trial')
  bool? get isTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_emi')
  bool? get isEmi => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String? get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'summary')
  Summaryy? get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_payment')
  FullPayment? get fullPayment => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_plan_details')
  EmiPlanDetails? get emiPlanDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_installments')
  List<EmiInstallment>? get emiInstallments =>
      throw _privateConstructorUsedError;

  /// Serializes this Membershipes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipesCopyWith<Membershipes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipesCopyWith<$Res> {
  factory $MembershipesCopyWith(
    Membershipes value,
    $Res Function(Membershipes) then,
  ) = _$MembershipesCopyWithImpl<$Res, Membershipes>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'is_emi') bool? isEmi,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'summary') Summaryy? summary,
    @JsonKey(name: 'full_payment') FullPayment? fullPayment,
    @JsonKey(name: 'emi_plan_details') EmiPlanDetails? emiPlanDetails,
    @JsonKey(name: 'emi_installments') List<EmiInstallment>? emiInstallments,
  });

  $SummaryyCopyWith<$Res>? get summary;
  $FullPaymentCopyWith<$Res>? get fullPayment;
  $EmiPlanDetailsCopyWith<$Res>? get emiPlanDetails;
}

/// @nodoc
class _$MembershipesCopyWithImpl<$Res, $Val extends Membershipes>
    implements $MembershipesCopyWith<$Res> {
  _$MembershipesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? membershipName = freezed,
    Object? organizationName = freezed,
    Object? status = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? amount = freezed,
    Object? assignFree = freezed,
    Object? isTrial = freezed,
    Object? isEmi = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? summary = freezed,
    Object? fullPayment = freezed,
    Object? emiPlanDetails = freezed,
    Object? emiInstallments = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            membershipName:
                freezed == membershipName
                    ? _value.membershipName
                    : membershipName // ignore: cast_nullable_to_non_nullable
                        as String?,
            organizationName:
                freezed == organizationName
                    ? _value.organizationName
                    : organizationName // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            assignFree:
                freezed == assignFree
                    ? _value.assignFree
                    : assignFree // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isTrial:
                freezed == isTrial
                    ? _value.isTrial
                    : isTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isEmi:
                freezed == isEmi
                    ? _value.isEmi
                    : isEmi // ignore: cast_nullable_to_non_nullable
                        as bool?,
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
            summary:
                freezed == summary
                    ? _value.summary
                    : summary // ignore: cast_nullable_to_non_nullable
                        as Summaryy?,
            fullPayment:
                freezed == fullPayment
                    ? _value.fullPayment
                    : fullPayment // ignore: cast_nullable_to_non_nullable
                        as FullPayment?,
            emiPlanDetails:
                freezed == emiPlanDetails
                    ? _value.emiPlanDetails
                    : emiPlanDetails // ignore: cast_nullable_to_non_nullable
                        as EmiPlanDetails?,
            emiInstallments:
                freezed == emiInstallments
                    ? _value.emiInstallments
                    : emiInstallments // ignore: cast_nullable_to_non_nullable
                        as List<EmiInstallment>?,
          )
          as $Val,
    );
  }

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryyCopyWith<$Res>? get summary {
    if (_value.summary == null) {
      return null;
    }

    return $SummaryyCopyWith<$Res>(_value.summary!, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FullPaymentCopyWith<$Res>? get fullPayment {
    if (_value.fullPayment == null) {
      return null;
    }

    return $FullPaymentCopyWith<$Res>(_value.fullPayment!, (value) {
      return _then(_value.copyWith(fullPayment: value) as $Val);
    });
  }

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmiPlanDetailsCopyWith<$Res>? get emiPlanDetails {
    if (_value.emiPlanDetails == null) {
      return null;
    }

    return $EmiPlanDetailsCopyWith<$Res>(_value.emiPlanDetails!, (value) {
      return _then(_value.copyWith(emiPlanDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MembershipesImplCopyWith<$Res>
    implements $MembershipesCopyWith<$Res> {
  factory _$$MembershipesImplCopyWith(
    _$MembershipesImpl value,
    $Res Function(_$MembershipesImpl) then,
  ) = __$$MembershipesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'is_emi') bool? isEmi,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'summary') Summaryy? summary,
    @JsonKey(name: 'full_payment') FullPayment? fullPayment,
    @JsonKey(name: 'emi_plan_details') EmiPlanDetails? emiPlanDetails,
    @JsonKey(name: 'emi_installments') List<EmiInstallment>? emiInstallments,
  });

  @override
  $SummaryyCopyWith<$Res>? get summary;
  @override
  $FullPaymentCopyWith<$Res>? get fullPayment;
  @override
  $EmiPlanDetailsCopyWith<$Res>? get emiPlanDetails;
}

/// @nodoc
class __$$MembershipesImplCopyWithImpl<$Res>
    extends _$MembershipesCopyWithImpl<$Res, _$MembershipesImpl>
    implements _$$MembershipesImplCopyWith<$Res> {
  __$$MembershipesImplCopyWithImpl(
    _$MembershipesImpl _value,
    $Res Function(_$MembershipesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? membershipName = freezed,
    Object? organizationName = freezed,
    Object? status = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? amount = freezed,
    Object? assignFree = freezed,
    Object? isTrial = freezed,
    Object? isEmi = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? summary = freezed,
    Object? fullPayment = freezed,
    Object? emiPlanDetails = freezed,
    Object? emiInstallments = freezed,
  }) {
    return _then(
      _$MembershipesImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        membershipName:
            freezed == membershipName
                ? _value.membershipName
                : membershipName // ignore: cast_nullable_to_non_nullable
                    as String?,
        organizationName:
            freezed == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        assignFree:
            freezed == assignFree
                ? _value.assignFree
                : assignFree // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isTrial:
            freezed == isTrial
                ? _value.isTrial
                : isTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isEmi:
            freezed == isEmi
                ? _value.isEmi
                : isEmi // ignore: cast_nullable_to_non_nullable
                    as bool?,
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
        summary:
            freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                    as Summaryy?,
        fullPayment:
            freezed == fullPayment
                ? _value.fullPayment
                : fullPayment // ignore: cast_nullable_to_non_nullable
                    as FullPayment?,
        emiPlanDetails:
            freezed == emiPlanDetails
                ? _value.emiPlanDetails
                : emiPlanDetails // ignore: cast_nullable_to_non_nullable
                    as EmiPlanDetails?,
        emiInstallments:
            freezed == emiInstallments
                ? _value._emiInstallments
                : emiInstallments // ignore: cast_nullable_to_non_nullable
                    as List<EmiInstallment>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipesImpl implements _Membershipes {
  const _$MembershipesImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'membership_name') this.membershipName,
    @JsonKey(name: 'organization_name') this.organizationName,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'assign_free') this.assignFree,
    @JsonKey(name: 'is_trial') this.isTrial,
    @JsonKey(name: 'is_emi') this.isEmi,
    @JsonKey(name: 'payment_status') this.paymentStatus,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'summary') this.summary,
    @JsonKey(name: 'full_payment') this.fullPayment,
    @JsonKey(name: 'emi_plan_details') this.emiPlanDetails,
    @JsonKey(name: 'emi_installments')
    final List<EmiInstallment>? emiInstallments,
  }) : _emiInstallments = emiInstallments;

  factory _$MembershipesImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipesImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'membership_name')
  final String? membershipName;
  @override
  @JsonKey(name: 'organization_name')
  final String? organizationName;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'assign_free')
  final bool? assignFree;
  @override
  @JsonKey(name: 'is_trial')
  final bool? isTrial;
  @override
  @JsonKey(name: 'is_emi')
  final bool? isEmi;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'summary')
  final Summaryy? summary;
  @override
  @JsonKey(name: 'full_payment')
  final FullPayment? fullPayment;
  @override
  @JsonKey(name: 'emi_plan_details')
  final EmiPlanDetails? emiPlanDetails;
  final List<EmiInstallment>? _emiInstallments;
  @override
  @JsonKey(name: 'emi_installments')
  List<EmiInstallment>? get emiInstallments {
    final value = _emiInstallments;
    if (value == null) return null;
    if (_emiInstallments is EqualUnmodifiableListView) return _emiInstallments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Membershipes(id: $id, membershipName: $membershipName, organizationName: $organizationName, status: $status, startDate: $startDate, endDate: $endDate, amount: $amount, assignFree: $assignFree, isTrial: $isTrial, isEmi: $isEmi, paymentStatus: $paymentStatus, isActive: $isActive, summary: $summary, fullPayment: $fullPayment, emiPlanDetails: $emiPlanDetails, emiInstallments: $emiInstallments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.membershipName, membershipName) ||
                other.membershipName == membershipName) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.assignFree, assignFree) ||
                other.assignFree == assignFree) &&
            (identical(other.isTrial, isTrial) || other.isTrial == isTrial) &&
            (identical(other.isEmi, isEmi) || other.isEmi == isEmi) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.fullPayment, fullPayment) ||
                other.fullPayment == fullPayment) &&
            (identical(other.emiPlanDetails, emiPlanDetails) ||
                other.emiPlanDetails == emiPlanDetails) &&
            const DeepCollectionEquality().equals(
              other._emiInstallments,
              _emiInstallments,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    membershipName,
    organizationName,
    status,
    startDate,
    endDate,
    amount,
    assignFree,
    isTrial,
    isEmi,
    paymentStatus,
    isActive,
    summary,
    fullPayment,
    emiPlanDetails,
    const DeepCollectionEquality().hash(_emiInstallments),
  );

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipesImplCopyWith<_$MembershipesImpl> get copyWith =>
      __$$MembershipesImplCopyWithImpl<_$MembershipesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipesImplToJson(this);
  }
}

abstract class _Membershipes implements Membershipes {
  const factory _Membershipes({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'membership_name') final String? membershipName,
    @JsonKey(name: 'organization_name') final String? organizationName,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'start_date') final String? startDate,
    @JsonKey(name: 'end_date') final String? endDate,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'assign_free') final bool? assignFree,
    @JsonKey(name: 'is_trial') final bool? isTrial,
    @JsonKey(name: 'is_emi') final bool? isEmi,
    @JsonKey(name: 'payment_status') final String? paymentStatus,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'summary') final Summaryy? summary,
    @JsonKey(name: 'full_payment') final FullPayment? fullPayment,
    @JsonKey(name: 'emi_plan_details') final EmiPlanDetails? emiPlanDetails,
    @JsonKey(name: 'emi_installments')
    final List<EmiInstallment>? emiInstallments,
  }) = _$MembershipesImpl;

  factory _Membershipes.fromJson(Map<String, dynamic> json) =
      _$MembershipesImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'membership_name')
  String? get membershipName;
  @override
  @JsonKey(name: 'organization_name')
  String? get organizationName;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'start_date')
  String? get startDate;
  @override
  @JsonKey(name: 'end_date')
  String? get endDate;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'assign_free')
  bool? get assignFree;
  @override
  @JsonKey(name: 'is_trial')
  bool? get isTrial;
  @override
  @JsonKey(name: 'is_emi')
  bool? get isEmi;
  @override
  @JsonKey(name: 'payment_status')
  String? get paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'summary')
  Summaryy? get summary;
  @override
  @JsonKey(name: 'full_payment')
  FullPayment? get fullPayment;
  @override
  @JsonKey(name: 'emi_plan_details')
  EmiPlanDetails? get emiPlanDetails;
  @override
  @JsonKey(name: 'emi_installments')
  List<EmiInstallment>? get emiInstallments;

  /// Create a copy of Membershipes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipesImplCopyWith<_$MembershipesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmiInstallment _$EmiInstallmentFromJson(Map<String, dynamic> json) {
  return _EmiInstallment.fromJson(json);
}

/// @nodoc
mixin _$EmiInstallment {
  @JsonKey(name: 'period')
  int? get period => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  String? get dueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_label')
  String? get periodLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  String? get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  String? get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  int? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this EmiInstallment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmiInstallment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmiInstallmentCopyWith<EmiInstallment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiInstallmentCopyWith<$Res> {
  factory $EmiInstallmentCopyWith(
    EmiInstallment value,
    $Res Function(EmiInstallment) then,
  ) = _$EmiInstallmentCopyWithImpl<$Res, EmiInstallment>;
  @useResult
  $Res call({
    @JsonKey(name: 'period') int? period,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'period_label') String? periodLabel,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  });
}

/// @nodoc
class _$EmiInstallmentCopyWithImpl<$Res, $Val extends EmiInstallment>
    implements $EmiInstallmentCopyWith<$Res> {
  _$EmiInstallmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmiInstallment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = freezed,
    Object? amount = freezed,
    Object? dueDate = freezed,
    Object? periodLabel = freezed,
    Object? status = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            period:
                freezed == period
                    ? _value.period
                    : period // ignore: cast_nullable_to_non_nullable
                        as int?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            dueDate:
                freezed == dueDate
                    ? _value.dueDate
                    : dueDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            periodLabel:
                freezed == periodLabel
                    ? _value.periodLabel
                    : periodLabel // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentDate:
                freezed == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentId:
                freezed == paymentId
                    ? _value.paymentId
                    : paymentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            transactionId:
                freezed == transactionId
                    ? _value.transactionId
                    : transactionId // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmiInstallmentImplCopyWith<$Res>
    implements $EmiInstallmentCopyWith<$Res> {
  factory _$$EmiInstallmentImplCopyWith(
    _$EmiInstallmentImpl value,
    $Res Function(_$EmiInstallmentImpl) then,
  ) = __$$EmiInstallmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'period') int? period,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'period_label') String? periodLabel,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  });
}

/// @nodoc
class __$$EmiInstallmentImplCopyWithImpl<$Res>
    extends _$EmiInstallmentCopyWithImpl<$Res, _$EmiInstallmentImpl>
    implements _$$EmiInstallmentImplCopyWith<$Res> {
  __$$EmiInstallmentImplCopyWithImpl(
    _$EmiInstallmentImpl _value,
    $Res Function(_$EmiInstallmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmiInstallment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = freezed,
    Object? amount = freezed,
    Object? dueDate = freezed,
    Object? periodLabel = freezed,
    Object? status = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _$EmiInstallmentImpl(
        period:
            freezed == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                    as int?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        dueDate:
            freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        periodLabel:
            freezed == periodLabel
                ? _value.periodLabel
                : periodLabel // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentDate:
            freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentId:
            freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        transactionId:
            freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiInstallmentImpl implements _EmiInstallment {
  const _$EmiInstallmentImpl({
    @JsonKey(name: 'period') this.period,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'due_date') this.dueDate,
    @JsonKey(name: 'period_label') this.periodLabel,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'payment_date') this.paymentDate,
    @JsonKey(name: 'payment_id') this.paymentId,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'transaction_id') this.transactionId,
  });

  factory _$EmiInstallmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiInstallmentImplFromJson(json);

  @override
  @JsonKey(name: 'period')
  final int? period;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'due_date')
  final String? dueDate;
  @override
  @JsonKey(name: 'period_label')
  final String? periodLabel;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'transaction_id')
  final int? transactionId;

  @override
  String toString() {
    return 'EmiInstallment(period: $period, amount: $amount, dueDate: $dueDate, periodLabel: $periodLabel, status: $status, paymentDate: $paymentDate, paymentId: $paymentId, orderId: $orderId, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiInstallmentImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.periodLabel, periodLabel) ||
                other.periodLabel == periodLabel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    period,
    amount,
    dueDate,
    periodLabel,
    status,
    paymentDate,
    paymentId,
    orderId,
    transactionId,
  );

  /// Create a copy of EmiInstallment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiInstallmentImplCopyWith<_$EmiInstallmentImpl> get copyWith =>
      __$$EmiInstallmentImplCopyWithImpl<_$EmiInstallmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiInstallmentImplToJson(this);
  }
}

abstract class _EmiInstallment implements EmiInstallment {
  const factory _EmiInstallment({
    @JsonKey(name: 'period') final int? period,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'due_date') final String? dueDate,
    @JsonKey(name: 'period_label') final String? periodLabel,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'payment_date') final String? paymentDate,
    @JsonKey(name: 'payment_id') final String? paymentId,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'transaction_id') final int? transactionId,
  }) = _$EmiInstallmentImpl;

  factory _EmiInstallment.fromJson(Map<String, dynamic> json) =
      _$EmiInstallmentImpl.fromJson;

  @override
  @JsonKey(name: 'period')
  int? get period;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'due_date')
  String? get dueDate;
  @override
  @JsonKey(name: 'period_label')
  String? get periodLabel;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'payment_date')
  String? get paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  String? get paymentId;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'transaction_id')
  int? get transactionId;

  /// Create a copy of EmiInstallment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmiInstallmentImplCopyWith<_$EmiInstallmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmiPlanDetails _$EmiPlanDetailsFromJson(Map<String, dynamic> json) {
  return _EmiPlanDetails.fromJson(json);
}

/// @nodoc
mixin _$EmiPlanDetails {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_name')
  String? get emiName => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_of_installments')
  int? get numberOfInstallments => throw _privateConstructorUsedError;
  @JsonKey(name: 'emi_amount_per_cycle')
  String? get emiAmountPerCycle => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_emi_amount')
  String? get totalEmiAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'razorpay_plan_id')
  String? get razorpayPlanId => throw _privateConstructorUsedError;

  /// Serializes this EmiPlanDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmiPlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmiPlanDetailsCopyWith<EmiPlanDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiPlanDetailsCopyWith<$Res> {
  factory $EmiPlanDetailsCopyWith(
    EmiPlanDetails value,
    $Res Function(EmiPlanDetails) then,
  ) = _$EmiPlanDetailsCopyWithImpl<$Res, EmiPlanDetails>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'emi_name') String? emiName,
    @JsonKey(name: 'number_of_installments') int? numberOfInstallments,
    @JsonKey(name: 'emi_amount_per_cycle') String? emiAmountPerCycle,
    @JsonKey(name: 'total_emi_amount') String? totalEmiAmount,
    @JsonKey(name: 'razorpay_plan_id') String? razorpayPlanId,
  });
}

/// @nodoc
class _$EmiPlanDetailsCopyWithImpl<$Res, $Val extends EmiPlanDetails>
    implements $EmiPlanDetailsCopyWith<$Res> {
  _$EmiPlanDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmiPlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? emiName = freezed,
    Object? numberOfInstallments = freezed,
    Object? emiAmountPerCycle = freezed,
    Object? totalEmiAmount = freezed,
    Object? razorpayPlanId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            emiName:
                freezed == emiName
                    ? _value.emiName
                    : emiName // ignore: cast_nullable_to_non_nullable
                        as String?,
            numberOfInstallments:
                freezed == numberOfInstallments
                    ? _value.numberOfInstallments
                    : numberOfInstallments // ignore: cast_nullable_to_non_nullable
                        as int?,
            emiAmountPerCycle:
                freezed == emiAmountPerCycle
                    ? _value.emiAmountPerCycle
                    : emiAmountPerCycle // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalEmiAmount:
                freezed == totalEmiAmount
                    ? _value.totalEmiAmount
                    : totalEmiAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            razorpayPlanId:
                freezed == razorpayPlanId
                    ? _value.razorpayPlanId
                    : razorpayPlanId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmiPlanDetailsImplCopyWith<$Res>
    implements $EmiPlanDetailsCopyWith<$Res> {
  factory _$$EmiPlanDetailsImplCopyWith(
    _$EmiPlanDetailsImpl value,
    $Res Function(_$EmiPlanDetailsImpl) then,
  ) = __$$EmiPlanDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'emi_name') String? emiName,
    @JsonKey(name: 'number_of_installments') int? numberOfInstallments,
    @JsonKey(name: 'emi_amount_per_cycle') String? emiAmountPerCycle,
    @JsonKey(name: 'total_emi_amount') String? totalEmiAmount,
    @JsonKey(name: 'razorpay_plan_id') String? razorpayPlanId,
  });
}

/// @nodoc
class __$$EmiPlanDetailsImplCopyWithImpl<$Res>
    extends _$EmiPlanDetailsCopyWithImpl<$Res, _$EmiPlanDetailsImpl>
    implements _$$EmiPlanDetailsImplCopyWith<$Res> {
  __$$EmiPlanDetailsImplCopyWithImpl(
    _$EmiPlanDetailsImpl _value,
    $Res Function(_$EmiPlanDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmiPlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? emiName = freezed,
    Object? numberOfInstallments = freezed,
    Object? emiAmountPerCycle = freezed,
    Object? totalEmiAmount = freezed,
    Object? razorpayPlanId = freezed,
  }) {
    return _then(
      _$EmiPlanDetailsImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        emiName:
            freezed == emiName
                ? _value.emiName
                : emiName // ignore: cast_nullable_to_non_nullable
                    as String?,
        numberOfInstallments:
            freezed == numberOfInstallments
                ? _value.numberOfInstallments
                : numberOfInstallments // ignore: cast_nullable_to_non_nullable
                    as int?,
        emiAmountPerCycle:
            freezed == emiAmountPerCycle
                ? _value.emiAmountPerCycle
                : emiAmountPerCycle // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalEmiAmount:
            freezed == totalEmiAmount
                ? _value.totalEmiAmount
                : totalEmiAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        razorpayPlanId:
            freezed == razorpayPlanId
                ? _value.razorpayPlanId
                : razorpayPlanId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiPlanDetailsImpl implements _EmiPlanDetails {
  const _$EmiPlanDetailsImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'emi_name') this.emiName,
    @JsonKey(name: 'number_of_installments') this.numberOfInstallments,
    @JsonKey(name: 'emi_amount_per_cycle') this.emiAmountPerCycle,
    @JsonKey(name: 'total_emi_amount') this.totalEmiAmount,
    @JsonKey(name: 'razorpay_plan_id') this.razorpayPlanId,
  });

  factory _$EmiPlanDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiPlanDetailsImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'emi_name')
  final String? emiName;
  @override
  @JsonKey(name: 'number_of_installments')
  final int? numberOfInstallments;
  @override
  @JsonKey(name: 'emi_amount_per_cycle')
  final String? emiAmountPerCycle;
  @override
  @JsonKey(name: 'total_emi_amount')
  final String? totalEmiAmount;
  @override
  @JsonKey(name: 'razorpay_plan_id')
  final String? razorpayPlanId;

  @override
  String toString() {
    return 'EmiPlanDetails(id: $id, emiName: $emiName, numberOfInstallments: $numberOfInstallments, emiAmountPerCycle: $emiAmountPerCycle, totalEmiAmount: $totalEmiAmount, razorpayPlanId: $razorpayPlanId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiPlanDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.emiName, emiName) || other.emiName == emiName) &&
            (identical(other.numberOfInstallments, numberOfInstallments) ||
                other.numberOfInstallments == numberOfInstallments) &&
            (identical(other.emiAmountPerCycle, emiAmountPerCycle) ||
                other.emiAmountPerCycle == emiAmountPerCycle) &&
            (identical(other.totalEmiAmount, totalEmiAmount) ||
                other.totalEmiAmount == totalEmiAmount) &&
            (identical(other.razorpayPlanId, razorpayPlanId) ||
                other.razorpayPlanId == razorpayPlanId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    emiName,
    numberOfInstallments,
    emiAmountPerCycle,
    totalEmiAmount,
    razorpayPlanId,
  );

  /// Create a copy of EmiPlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiPlanDetailsImplCopyWith<_$EmiPlanDetailsImpl> get copyWith =>
      __$$EmiPlanDetailsImplCopyWithImpl<_$EmiPlanDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiPlanDetailsImplToJson(this);
  }
}

abstract class _EmiPlanDetails implements EmiPlanDetails {
  const factory _EmiPlanDetails({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'emi_name') final String? emiName,
    @JsonKey(name: 'number_of_installments') final int? numberOfInstallments,
    @JsonKey(name: 'emi_amount_per_cycle') final String? emiAmountPerCycle,
    @JsonKey(name: 'total_emi_amount') final String? totalEmiAmount,
    @JsonKey(name: 'razorpay_plan_id') final String? razorpayPlanId,
  }) = _$EmiPlanDetailsImpl;

  factory _EmiPlanDetails.fromJson(Map<String, dynamic> json) =
      _$EmiPlanDetailsImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'emi_name')
  String? get emiName;
  @override
  @JsonKey(name: 'number_of_installments')
  int? get numberOfInstallments;
  @override
  @JsonKey(name: 'emi_amount_per_cycle')
  String? get emiAmountPerCycle;
  @override
  @JsonKey(name: 'total_emi_amount')
  String? get totalEmiAmount;
  @override
  @JsonKey(name: 'razorpay_plan_id')
  String? get razorpayPlanId;

  /// Create a copy of EmiPlanDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmiPlanDetailsImplCopyWith<_$EmiPlanDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FullPayment _$FullPaymentFromJson(Map<String, dynamic> json) {
  return _FullPayment.fromJson(json);
}

/// @nodoc
mixin _$FullPayment {
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_amount')
  String? get paidAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  String? get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  String? get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  String? get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  int? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this FullPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FullPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FullPaymentCopyWith<FullPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FullPaymentCopyWith<$Res> {
  factory $FullPaymentCopyWith(
    FullPayment value,
    $Res Function(FullPayment) then,
  ) = _$FullPaymentCopyWithImpl<$Res, FullPayment>;
  @useResult
  $Res call({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'paid_amount') String? paidAmount,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  });
}

/// @nodoc
class _$FullPaymentCopyWithImpl<$Res, $Val extends FullPayment>
    implements $FullPaymentCopyWith<$Res> {
  _$FullPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FullPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? paidAmount = freezed,
    Object? totalAmount = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            paidAmount:
                freezed == paidAmount
                    ? _value.paidAmount
                    : paidAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalAmount:
                freezed == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentDate:
                freezed == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentId:
                freezed == paymentId
                    ? _value.paymentId
                    : paymentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            transactionId:
                freezed == transactionId
                    ? _value.transactionId
                    : transactionId // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FullPaymentImplCopyWith<$Res>
    implements $FullPaymentCopyWith<$Res> {
  factory _$$FullPaymentImplCopyWith(
    _$FullPaymentImpl value,
    $Res Function(_$FullPaymentImpl) then,
  ) = __$$FullPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'paid_amount') String? paidAmount,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  });
}

/// @nodoc
class __$$FullPaymentImplCopyWithImpl<$Res>
    extends _$FullPaymentCopyWithImpl<$Res, _$FullPaymentImpl>
    implements _$$FullPaymentImplCopyWith<$Res> {
  __$$FullPaymentImplCopyWithImpl(
    _$FullPaymentImpl _value,
    $Res Function(_$FullPaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FullPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? paidAmount = freezed,
    Object? totalAmount = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _$FullPaymentImpl(
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        paidAmount:
            freezed == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalAmount:
            freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentDate:
            freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentId:
            freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        transactionId:
            freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FullPaymentImpl implements _FullPayment {
  const _$FullPaymentImpl({
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'paid_amount') this.paidAmount,
    @JsonKey(name: 'total_amount') this.totalAmount,
    @JsonKey(name: 'payment_date') this.paymentDate,
    @JsonKey(name: 'payment_id') this.paymentId,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'transaction_id') this.transactionId,
  });

  factory _$FullPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$FullPaymentImplFromJson(json);

  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'paid_amount')
  final String? paidAmount;
  @override
  @JsonKey(name: 'total_amount')
  final String? totalAmount;
  @override
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'transaction_id')
  final int? transactionId;

  @override
  String toString() {
    return 'FullPayment(status: $status, paidAmount: $paidAmount, totalAmount: $totalAmount, paymentDate: $paymentDate, paymentId: $paymentId, orderId: $orderId, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FullPaymentImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    paidAmount,
    totalAmount,
    paymentDate,
    paymentId,
    orderId,
    transactionId,
  );

  /// Create a copy of FullPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FullPaymentImplCopyWith<_$FullPaymentImpl> get copyWith =>
      __$$FullPaymentImplCopyWithImpl<_$FullPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FullPaymentImplToJson(this);
  }
}

abstract class _FullPayment implements FullPayment {
  const factory _FullPayment({
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'paid_amount') final String? paidAmount,
    @JsonKey(name: 'total_amount') final String? totalAmount,
    @JsonKey(name: 'payment_date') final String? paymentDate,
    @JsonKey(name: 'payment_id') final String? paymentId,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'transaction_id') final int? transactionId,
  }) = _$FullPaymentImpl;

  factory _FullPayment.fromJson(Map<String, dynamic> json) =
      _$FullPaymentImpl.fromJson;

  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'paid_amount')
  String? get paidAmount;
  @override
  @JsonKey(name: 'total_amount')
  String? get totalAmount;
  @override
  @JsonKey(name: 'payment_date')
  String? get paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  String? get paymentId;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'transaction_id')
  int? get transactionId;

  /// Create a copy of FullPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FullPaymentImplCopyWith<_$FullPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Summaryy _$SummaryyFromJson(Map<String, dynamic> json) {
  return _Summaryy.fromJson(json);
}

/// @nodoc
mixin _$Summaryy {
  @JsonKey(name: 'is_full_payment')
  bool? get isFullPayment => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_amount')
  String? get paidAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  String? get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  String? get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_id')
  String? get paymentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_emi_count')
  int? get paidEmiCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_emis')
  int? get totalEmis => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_paid')
  String? get totalPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_emi_due_date')
  String? get nextEmiDueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_emi_amount')
  String? get nextEmiAmount => throw _privateConstructorUsedError;

  /// Serializes this Summaryy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Summaryy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryyCopyWith<Summaryy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryyCopyWith<$Res> {
  factory $SummaryyCopyWith(Summaryy value, $Res Function(Summaryy) then) =
      _$SummaryyCopyWithImpl<$Res, Summaryy>;
  @useResult
  $Res call({
    @JsonKey(name: 'is_full_payment') bool? isFullPayment,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'paid_amount') String? paidAmount,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'paid_emi_count') int? paidEmiCount,
    @JsonKey(name: 'total_emis') int? totalEmis,
    @JsonKey(name: 'total_paid') String? totalPaid,
    @JsonKey(name: 'next_emi_due_date') String? nextEmiDueDate,
    @JsonKey(name: 'next_emi_amount') String? nextEmiAmount,
  });
}

/// @nodoc
class _$SummaryyCopyWithImpl<$Res, $Val extends Summaryy>
    implements $SummaryyCopyWith<$Res> {
  _$SummaryyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Summaryy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFullPayment = freezed,
    Object? status = freezed,
    Object? paidAmount = freezed,
    Object? totalAmount = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? paidEmiCount = freezed,
    Object? totalEmis = freezed,
    Object? totalPaid = freezed,
    Object? nextEmiDueDate = freezed,
    Object? nextEmiAmount = freezed,
  }) {
    return _then(
      _value.copyWith(
            isFullPayment:
                freezed == isFullPayment
                    ? _value.isFullPayment
                    : isFullPayment // ignore: cast_nullable_to_non_nullable
                        as bool?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            paidAmount:
                freezed == paidAmount
                    ? _value.paidAmount
                    : paidAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalAmount:
                freezed == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentDate:
                freezed == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            paymentId:
                freezed == paymentId
                    ? _value.paymentId
                    : paymentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            orderId:
                freezed == orderId
                    ? _value.orderId
                    : orderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            paidEmiCount:
                freezed == paidEmiCount
                    ? _value.paidEmiCount
                    : paidEmiCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            totalEmis:
                freezed == totalEmis
                    ? _value.totalEmis
                    : totalEmis // ignore: cast_nullable_to_non_nullable
                        as int?,
            totalPaid:
                freezed == totalPaid
                    ? _value.totalPaid
                    : totalPaid // ignore: cast_nullable_to_non_nullable
                        as String?,
            nextEmiDueDate:
                freezed == nextEmiDueDate
                    ? _value.nextEmiDueDate
                    : nextEmiDueDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            nextEmiAmount:
                freezed == nextEmiAmount
                    ? _value.nextEmiAmount
                    : nextEmiAmount // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SummaryyImplCopyWith<$Res>
    implements $SummaryyCopyWith<$Res> {
  factory _$$SummaryyImplCopyWith(
    _$SummaryyImpl value,
    $Res Function(_$SummaryyImpl) then,
  ) = __$$SummaryyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'is_full_payment') bool? isFullPayment,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'paid_amount') String? paidAmount,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'paid_emi_count') int? paidEmiCount,
    @JsonKey(name: 'total_emis') int? totalEmis,
    @JsonKey(name: 'total_paid') String? totalPaid,
    @JsonKey(name: 'next_emi_due_date') String? nextEmiDueDate,
    @JsonKey(name: 'next_emi_amount') String? nextEmiAmount,
  });
}

/// @nodoc
class __$$SummaryyImplCopyWithImpl<$Res>
    extends _$SummaryyCopyWithImpl<$Res, _$SummaryyImpl>
    implements _$$SummaryyImplCopyWith<$Res> {
  __$$SummaryyImplCopyWithImpl(
    _$SummaryyImpl _value,
    $Res Function(_$SummaryyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Summaryy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFullPayment = freezed,
    Object? status = freezed,
    Object? paidAmount = freezed,
    Object? totalAmount = freezed,
    Object? paymentDate = freezed,
    Object? paymentId = freezed,
    Object? orderId = freezed,
    Object? paidEmiCount = freezed,
    Object? totalEmis = freezed,
    Object? totalPaid = freezed,
    Object? nextEmiDueDate = freezed,
    Object? nextEmiAmount = freezed,
  }) {
    return _then(
      _$SummaryyImpl(
        isFullPayment:
            freezed == isFullPayment
                ? _value.isFullPayment
                : isFullPayment // ignore: cast_nullable_to_non_nullable
                    as bool?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        paidAmount:
            freezed == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalAmount:
            freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentDate:
            freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        paymentId:
            freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        orderId:
            freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        paidEmiCount:
            freezed == paidEmiCount
                ? _value.paidEmiCount
                : paidEmiCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        totalEmis:
            freezed == totalEmis
                ? _value.totalEmis
                : totalEmis // ignore: cast_nullable_to_non_nullable
                    as int?,
        totalPaid:
            freezed == totalPaid
                ? _value.totalPaid
                : totalPaid // ignore: cast_nullable_to_non_nullable
                    as String?,
        nextEmiDueDate:
            freezed == nextEmiDueDate
                ? _value.nextEmiDueDate
                : nextEmiDueDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        nextEmiAmount:
            freezed == nextEmiAmount
                ? _value.nextEmiAmount
                : nextEmiAmount // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryyImpl implements _Summaryy {
  const _$SummaryyImpl({
    @JsonKey(name: 'is_full_payment') this.isFullPayment,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'paid_amount') this.paidAmount,
    @JsonKey(name: 'total_amount') this.totalAmount,
    @JsonKey(name: 'payment_date') this.paymentDate,
    @JsonKey(name: 'payment_id') this.paymentId,
    @JsonKey(name: 'order_id') this.orderId,
    @JsonKey(name: 'paid_emi_count') this.paidEmiCount,
    @JsonKey(name: 'total_emis') this.totalEmis,
    @JsonKey(name: 'total_paid') this.totalPaid,
    @JsonKey(name: 'next_emi_due_date') this.nextEmiDueDate,
    @JsonKey(name: 'next_emi_amount') this.nextEmiAmount,
  });

  factory _$SummaryyImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryyImplFromJson(json);

  @override
  @JsonKey(name: 'is_full_payment')
  final bool? isFullPayment;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'paid_amount')
  final String? paidAmount;
  @override
  @JsonKey(name: 'total_amount')
  final String? totalAmount;
  @override
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  @override
  @JsonKey(name: 'order_id')
  final String? orderId;
  @override
  @JsonKey(name: 'paid_emi_count')
  final int? paidEmiCount;
  @override
  @JsonKey(name: 'total_emis')
  final int? totalEmis;
  @override
  @JsonKey(name: 'total_paid')
  final String? totalPaid;
  @override
  @JsonKey(name: 'next_emi_due_date')
  final String? nextEmiDueDate;
  @override
  @JsonKey(name: 'next_emi_amount')
  final String? nextEmiAmount;

  @override
  String toString() {
    return 'Summaryy(isFullPayment: $isFullPayment, status: $status, paidAmount: $paidAmount, totalAmount: $totalAmount, paymentDate: $paymentDate, paymentId: $paymentId, orderId: $orderId, paidEmiCount: $paidEmiCount, totalEmis: $totalEmis, totalPaid: $totalPaid, nextEmiDueDate: $nextEmiDueDate, nextEmiAmount: $nextEmiAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryyImpl &&
            (identical(other.isFullPayment, isFullPayment) ||
                other.isFullPayment == isFullPayment) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.paidEmiCount, paidEmiCount) ||
                other.paidEmiCount == paidEmiCount) &&
            (identical(other.totalEmis, totalEmis) ||
                other.totalEmis == totalEmis) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.nextEmiDueDate, nextEmiDueDate) ||
                other.nextEmiDueDate == nextEmiDueDate) &&
            (identical(other.nextEmiAmount, nextEmiAmount) ||
                other.nextEmiAmount == nextEmiAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isFullPayment,
    status,
    paidAmount,
    totalAmount,
    paymentDate,
    paymentId,
    orderId,
    paidEmiCount,
    totalEmis,
    totalPaid,
    nextEmiDueDate,
    nextEmiAmount,
  );

  /// Create a copy of Summaryy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryyImplCopyWith<_$SummaryyImpl> get copyWith =>
      __$$SummaryyImplCopyWithImpl<_$SummaryyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryyImplToJson(this);
  }
}

abstract class _Summaryy implements Summaryy {
  const factory _Summaryy({
    @JsonKey(name: 'is_full_payment') final bool? isFullPayment,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'paid_amount') final String? paidAmount,
    @JsonKey(name: 'total_amount') final String? totalAmount,
    @JsonKey(name: 'payment_date') final String? paymentDate,
    @JsonKey(name: 'payment_id') final String? paymentId,
    @JsonKey(name: 'order_id') final String? orderId,
    @JsonKey(name: 'paid_emi_count') final int? paidEmiCount,
    @JsonKey(name: 'total_emis') final int? totalEmis,
    @JsonKey(name: 'total_paid') final String? totalPaid,
    @JsonKey(name: 'next_emi_due_date') final String? nextEmiDueDate,
    @JsonKey(name: 'next_emi_amount') final String? nextEmiAmount,
  }) = _$SummaryyImpl;

  factory _Summaryy.fromJson(Map<String, dynamic> json) =
      _$SummaryyImpl.fromJson;

  @override
  @JsonKey(name: 'is_full_payment')
  bool? get isFullPayment;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'paid_amount')
  String? get paidAmount;
  @override
  @JsonKey(name: 'total_amount')
  String? get totalAmount;
  @override
  @JsonKey(name: 'payment_date')
  String? get paymentDate;
  @override
  @JsonKey(name: 'payment_id')
  String? get paymentId;
  @override
  @JsonKey(name: 'order_id')
  String? get orderId;
  @override
  @JsonKey(name: 'paid_emi_count')
  int? get paidEmiCount;
  @override
  @JsonKey(name: 'total_emis')
  int? get totalEmis;
  @override
  @JsonKey(name: 'total_paid')
  String? get totalPaid;
  @override
  @JsonKey(name: 'next_emi_due_date')
  String? get nextEmiDueDate;
  @override
  @JsonKey(name: 'next_emi_amount')
  String? get nextEmiAmount;

  /// Create a copy of Summaryy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryyImplCopyWith<_$SummaryyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
