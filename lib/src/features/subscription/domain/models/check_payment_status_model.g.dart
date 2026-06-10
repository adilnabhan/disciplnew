// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckPaymentStatusModelImpl _$$CheckPaymentStatusModelImplFromJson(
  Map<String, dynamic> json,
) => _$CheckPaymentStatusModelImpl(
  orderId: json['order_id'] as String?,
  paymentId: json['payment_id'],
  status: json['status'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CheckPaymentStatusModelImplToJson(
  _$CheckPaymentStatusModelImpl instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'payment_id': instance.paymentId,
  'status': instance.status,
  'amount': instance.amount,
};
