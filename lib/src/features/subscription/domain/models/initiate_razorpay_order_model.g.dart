// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiate_razorpay_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InitiateRazorpayOrderModelImpl _$$InitiateRazorpayOrderModelImplFromJson(
  Map<String, dynamic> json,
) => _$InitiateRazorpayOrderModelImpl(
  id: json['id'] as String?,
  orderId: json['order_id'] as String?,
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  amount: json['amount'] as String?,
  subscriptionId: json['subscription_id'] as String?,
);

Map<String, dynamic> _$$InitiateRazorpayOrderModelImplToJson(
  _$InitiateRazorpayOrderModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'user': instance.user,
  'amount': instance.amount,
  'subscription_id': instance.subscriptionId,
};

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num?)?.toInt(),
  email: json['email'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile_number': instance.mobileNumber,
    };
