import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_details_model.freezed.dart';
part 'payment_history_details_model.g.dart';

@freezed
class PaymentHistoryDetailsModel with _$PaymentHistoryDetailsModel {
  const factory PaymentHistoryDetailsModel({
    @JsonKey(name: 'customer_id') int? customerId,
    @JsonKey(name: 'memberships') List<Membershipes>? memberships,
  }) = _PaymentHistoryDetailsModel;

  factory PaymentHistoryDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryDetailsModelFromJson(json);
}

@freezed
class Membershipes with _$Membershipes {
  const factory Membershipes({
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
  }) = _Membershipes;

  factory Membershipes.fromJson(Map<String, dynamic> json) =>
      _$MembershipesFromJson(json);
}

@freezed
class EmiInstallment with _$EmiInstallment {
  const factory EmiInstallment({
    @JsonKey(name: 'period') int? period,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'period_label') String? periodLabel,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  }) = _EmiInstallment;

  factory EmiInstallment.fromJson(Map<String, dynamic> json) =>
      _$EmiInstallmentFromJson(json);
}

@freezed
class EmiPlanDetails with _$EmiPlanDetails {
  const factory EmiPlanDetails({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'emi_name') String? emiName,
    @JsonKey(name: 'number_of_installments') int? numberOfInstallments,
    @JsonKey(name: 'emi_amount_per_cycle') String? emiAmountPerCycle,
    @JsonKey(name: 'total_emi_amount') String? totalEmiAmount,
    @JsonKey(name: 'razorpay_plan_id') String? razorpayPlanId,
  }) = _EmiPlanDetails;

  factory EmiPlanDetails.fromJson(Map<String, dynamic> json) =>
      _$EmiPlanDetailsFromJson(json);
}

@freezed
class FullPayment with _$FullPayment {
  const factory FullPayment({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'paid_amount') String? paidAmount,
    @JsonKey(name: 'total_amount') String? totalAmount,
    @JsonKey(name: 'payment_date') String? paymentDate,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'transaction_id') int? transactionId,
  }) = _FullPayment;

  factory FullPayment.fromJson(Map<String, dynamic> json) =>
      _$FullPaymentFromJson(json);
}

@freezed
class Summaryy with _$Summaryy {
  const factory Summaryy({
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
  }) = _Summaryy;

  factory Summaryy.fromJson(Map<String, dynamic> json) =>
      _$SummaryyFromJson(json);
}
