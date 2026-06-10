// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_model.freezed.dart';
part 'payment_history_model.g.dart';

@freezed
class PaymentHistoryModel with _$PaymentHistoryModel {
  const factory PaymentHistoryModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SinglePaymentHistoryModel>? results,
  }) = _PaymentHistoryModel;

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) => _$PaymentHistoryModelFromJson(json);
}

@freezed
class SinglePaymentHistoryModel with _$SinglePaymentHistoryModel {
  const factory SinglePaymentHistoryModel({
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'payment_date') DateTime? paymentDate,
    @JsonKey(name: 'payment_type') String? paymentType,
  }) = _SinglePaymentHistoryModel;

  factory SinglePaymentHistoryModel.fromJson(Map<String, dynamic> json) => _$SinglePaymentHistoryModelFromJson(json);
}
