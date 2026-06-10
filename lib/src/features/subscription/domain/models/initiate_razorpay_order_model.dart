// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'initiate_razorpay_order_model.freezed.dart';
part 'initiate_razorpay_order_model.g.dart';

@freezed
class InitiateRazorpayOrderModel with _$InitiateRazorpayOrderModel {
  const factory InitiateRazorpayOrderModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'subscription_id') String? subscriptionId,
  }) = _InitiateRazorpayOrderModel;

  factory InitiateRazorpayOrderModel.fromJson(Map<String, dynamic> json) =>
      _$InitiateRazorpayOrderModelFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
