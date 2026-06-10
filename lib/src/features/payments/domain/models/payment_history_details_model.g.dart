// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentHistoryDetailsModelImpl _$$PaymentHistoryDetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentHistoryDetailsModelImpl(
  customerId: (json['customer_id'] as num?)?.toInt(),
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => Membershipes.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$PaymentHistoryDetailsModelImplToJson(
  _$PaymentHistoryDetailsModelImpl instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'memberships': instance.memberships,
};

_$MembershipesImpl _$$MembershipesImplFromJson(Map<String, dynamic> json) =>
    _$MembershipesImpl(
      id: (json['id'] as num?)?.toInt(),
      membershipName: json['membership_name'] as String?,
      organizationName: json['organization_name'] as String?,
      status: json['status'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      amount: json['amount'] as String?,
      assignFree: json['assign_free'] as bool?,
      isTrial: json['is_trial'] as bool?,
      isEmi: json['is_emi'] as bool?,
      paymentStatus: json['payment_status'] as String?,
      isActive: json['is_active'] as bool?,
      summary:
          json['summary'] == null
              ? null
              : Summaryy.fromJson(json['summary'] as Map<String, dynamic>),
      fullPayment:
          json['full_payment'] == null
              ? null
              : FullPayment.fromJson(
                json['full_payment'] as Map<String, dynamic>,
              ),
      emiPlanDetails:
          json['emi_plan_details'] == null
              ? null
              : EmiPlanDetails.fromJson(
                json['emi_plan_details'] as Map<String, dynamic>,
              ),
      emiInstallments:
          (json['emi_installments'] as List<dynamic>?)
              ?.map((e) => EmiInstallment.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$MembershipesImplToJson(_$MembershipesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership_name': instance.membershipName,
      'organization_name': instance.organizationName,
      'status': instance.status,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'amount': instance.amount,
      'assign_free': instance.assignFree,
      'is_trial': instance.isTrial,
      'is_emi': instance.isEmi,
      'payment_status': instance.paymentStatus,
      'is_active': instance.isActive,
      'summary': instance.summary,
      'full_payment': instance.fullPayment,
      'emi_plan_details': instance.emiPlanDetails,
      'emi_installments': instance.emiInstallments,
    };

_$EmiInstallmentImpl _$$EmiInstallmentImplFromJson(Map<String, dynamic> json) =>
    _$EmiInstallmentImpl(
      period: (json['period'] as num?)?.toInt(),
      amount: json['amount'] as String?,
      dueDate: json['due_date'] as String?,
      periodLabel: json['period_label'] as String?,
      status: json['status'] as String?,
      paymentDate: json['payment_date'] as String?,
      paymentId: json['payment_id'] as String?,
      orderId: json['order_id'] as String?,
      transactionId: (json['transaction_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$EmiInstallmentImplToJson(
  _$EmiInstallmentImpl instance,
) => <String, dynamic>{
  'period': instance.period,
  'amount': instance.amount,
  'due_date': instance.dueDate,
  'period_label': instance.periodLabel,
  'status': instance.status,
  'payment_date': instance.paymentDate,
  'payment_id': instance.paymentId,
  'order_id': instance.orderId,
  'transaction_id': instance.transactionId,
};

_$EmiPlanDetailsImpl _$$EmiPlanDetailsImplFromJson(Map<String, dynamic> json) =>
    _$EmiPlanDetailsImpl(
      id: (json['id'] as num?)?.toInt(),
      emiName: json['emi_name'] as String?,
      numberOfInstallments: (json['number_of_installments'] as num?)?.toInt(),
      emiAmountPerCycle: json['emi_amount_per_cycle'] as String?,
      totalEmiAmount: json['total_emi_amount'] as String?,
      razorpayPlanId: json['razorpay_plan_id'] as String?,
    );

Map<String, dynamic> _$$EmiPlanDetailsImplToJson(
  _$EmiPlanDetailsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'emi_name': instance.emiName,
  'number_of_installments': instance.numberOfInstallments,
  'emi_amount_per_cycle': instance.emiAmountPerCycle,
  'total_emi_amount': instance.totalEmiAmount,
  'razorpay_plan_id': instance.razorpayPlanId,
};

_$FullPaymentImpl _$$FullPaymentImplFromJson(Map<String, dynamic> json) =>
    _$FullPaymentImpl(
      status: json['status'] as String?,
      paidAmount: json['paid_amount'] as String?,
      totalAmount: json['total_amount'] as String?,
      paymentDate: json['payment_date'] as String?,
      paymentId: json['payment_id'] as String?,
      orderId: json['order_id'] as String?,
      transactionId: (json['transaction_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$FullPaymentImplToJson(_$FullPaymentImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'paid_amount': instance.paidAmount,
      'total_amount': instance.totalAmount,
      'payment_date': instance.paymentDate,
      'payment_id': instance.paymentId,
      'order_id': instance.orderId,
      'transaction_id': instance.transactionId,
    };

_$SummaryyImpl _$$SummaryyImplFromJson(Map<String, dynamic> json) =>
    _$SummaryyImpl(
      isFullPayment: json['is_full_payment'] as bool?,
      status: json['status'] as String?,
      paidAmount: json['paid_amount'] as String?,
      totalAmount: json['total_amount'] as String?,
      paymentDate: json['payment_date'] as String?,
      paymentId: json['payment_id'] as String?,
      orderId: json['order_id'] as String?,
      paidEmiCount: (json['paid_emi_count'] as num?)?.toInt(),
      totalEmis: (json['total_emis'] as num?)?.toInt(),
      totalPaid: json['total_paid'] as String?,
      nextEmiDueDate: json['next_emi_due_date'] as String?,
      nextEmiAmount: json['next_emi_amount'] as String?,
    );

Map<String, dynamic> _$$SummaryyImplToJson(_$SummaryyImpl instance) =>
    <String, dynamic>{
      'is_full_payment': instance.isFullPayment,
      'status': instance.status,
      'paid_amount': instance.paidAmount,
      'total_amount': instance.totalAmount,
      'payment_date': instance.paymentDate,
      'payment_id': instance.paymentId,
      'order_id': instance.orderId,
      'paid_emi_count': instance.paidEmiCount,
      'total_emis': instance.totalEmis,
      'total_paid': instance.totalPaid,
      'next_emi_due_date': instance.nextEmiDueDate,
      'next_emi_amount': instance.nextEmiAmount,
    };
