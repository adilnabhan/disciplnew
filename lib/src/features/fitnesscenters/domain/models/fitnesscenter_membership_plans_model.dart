// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fitnesscenter_membership_plans_model.freezed.dart';
part 'fitnesscenter_membership_plans_model.g.dart';

@freezed
class FitnesscenterMembershipPlansModel
    with _$FitnesscenterMembershipPlansModel {
  const factory FitnesscenterMembershipPlansModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<dynamic>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
    @JsonKey(name: 'emi_plans') @Default([]) List<EmiOptionsModel> emiPlans,
  }) = _FitnesscenterMembershipPlansModel;

  factory FitnesscenterMembershipPlansModel.fromJson(
    Map<String, dynamic> json,
  ) => _$FitnesscenterMembershipPlansModelFromJson(json);
}

@freezed
class EmiOptionsModel with _$EmiOptionsModel {
  const factory EmiOptionsModel({
    required int id,
    @JsonKey(name: 'number_of_installments') required int month,
    @JsonKey(
      name: 'emi_amount_per_cycle',
      fromJson: StringToDoubleConverter.fromJsonStatic,
      toJson: StringToDoubleConverter.toJsonStatic,
    )
    required double price,
  }) = _EmiOptionsModel;

  factory EmiOptionsModel.fromJson(Map<String, dynamic> json) =>
      _$EmiOptionsModelFromJson(json);
}

class StringToDoubleConverter {
  const StringToDoubleConverter();

  static double fromJsonStatic(Object? json) {
    if (json == null) return 0;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0;
  }

  static Object toJsonStatic(double object) => object;
}
