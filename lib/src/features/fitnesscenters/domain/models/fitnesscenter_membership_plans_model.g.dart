// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitnesscenter_membership_plans_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FitnesscenterMembershipPlansModelImpl
_$$FitnesscenterMembershipPlansModelImplFromJson(Map<String, dynamic> json) =>
    _$FitnesscenterMembershipPlansModelImpl(
      id: (json['id'] as num?)?.toInt(),
      packageType: json['package_type'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      actualPrice: json['actual_price'] as String?,
      offerPrice: json['offer_price'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      features: json['features'] as List<dynamic>?,
      isActive: json['is_active'] as bool?,
      isEmiAvailable: json['is_emi_available'] as bool?,
      emiPlans:
          (json['emi_plans'] as List<dynamic>?)
              ?.map((e) => EmiOptionsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FitnesscenterMembershipPlansModelImplToJson(
  _$FitnesscenterMembershipPlansModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'package_type': instance.packageType,
  'name': instance.name,
  'description': instance.description,
  'actual_price': instance.actualPrice,
  'offer_price': instance.offerPrice,
  'duration_days': instance.durationDays,
  'features': instance.features,
  'is_active': instance.isActive,
  'is_emi_available': instance.isEmiAvailable,
  'emi_plans': instance.emiPlans,
};

_$EmiOptionsModelImpl _$$EmiOptionsModelImplFromJson(
  Map<String, dynamic> json,
) => _$EmiOptionsModelImpl(
  id: (json['id'] as num).toInt(),
  month: (json['number_of_installments'] as num).toInt(),
  price: StringToDoubleConverter.fromJsonStatic(json['emi_amount_per_cycle']),
);

Map<String, dynamic> _$$EmiOptionsModelImplToJson(
  _$EmiOptionsModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'number_of_installments': instance.month,
  'emi_amount_per_cycle': StringToDoubleConverter.toJsonStatic(instance.price),
};
