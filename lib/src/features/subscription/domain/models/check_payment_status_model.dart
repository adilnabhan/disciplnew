// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_payment_status_model.freezed.dart';
part 'check_payment_status_model.g.dart';

@freezed
class CheckPaymentStatusModel with _$CheckPaymentStatusModel {
  const factory CheckPaymentStatusModel({
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'payment_id') dynamic paymentId,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') int? amount,
  }) = _CheckPaymentStatusModel;

  factory CheckPaymentStatusModel.fromJson(Map<String, dynamic> json) => _$CheckPaymentStatusModelFromJson(json);
}
