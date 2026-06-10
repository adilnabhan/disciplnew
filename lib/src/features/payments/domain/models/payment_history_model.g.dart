// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentHistoryModelImpl _$$PaymentHistoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentHistoryModelImpl(
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map(
            (e) =>
                SinglePaymentHistoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$$PaymentHistoryModelImplToJson(
  _$PaymentHistoryModelImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$SinglePaymentHistoryModelImpl _$$SinglePaymentHistoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$SinglePaymentHistoryModelImpl(
  organization: json['organization'] as String?,
  amount: json['amount'] as String?,
  paymentDate:
      json['payment_date'] == null
          ? null
          : DateTime.parse(json['payment_date'] as String),
  paymentType: json['payment_type'] as String?,
);

Map<String, dynamic> _$$SinglePaymentHistoryModelImplToJson(
  _$SinglePaymentHistoryModelImpl instance,
) => <String, dynamic>{
  'organization': instance.organization,
  'amount': instance.amount,
  'payment_date': instance.paymentDate?.toIso8601String(),
  'payment_type': instance.paymentType,
};
