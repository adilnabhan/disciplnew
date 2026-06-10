// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constant_choices_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConstantChoicesModelImpl _$$ConstantChoicesModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConstantChoicesModelImpl(
  success: json['success'] as bool,
  data: Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ConstantChoicesModelImplToJson(
  _$ConstantChoicesModelImpl instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  professions:
      (json['professions'] as List<dynamic>)
          .map((e) => Profession.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobSatisfactions:
      (json['job_satisfactions'] as List<dynamic>)
          .map((e) => JobSatisfaction.fromJson(e as Map<String, dynamic>))
          .toList(),
  workingHours:
      (json['working_hours'] as List<dynamic>)
          .map((e) => Profession.fromJson(e as Map<String, dynamic>))
          .toList(),
  sleepHours:
      (json['sleep_hours'] as List<dynamic>)
          .map((e) => Profession.fromJson(e as Map<String, dynamic>))
          .toList(),
  targetGoals:
      (json['target_goals'] as List<dynamic>)
          .map((e) => Profession.fromJson(e as Map<String, dynamic>))
          .toList(),
  healthConditions:
      (json['health_conditions'] as List<dynamic>)
          .map((e) => Profession.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'professions': instance.professions,
      'job_satisfactions': instance.jobSatisfactions,
      'working_hours': instance.workingHours,
      'sleep_hours': instance.sleepHours,
      'target_goals': instance.targetGoals,
      'health_conditions': instance.healthConditions,
    };

_$JobSatisfactionImpl _$$JobSatisfactionImplFromJson(
  Map<String, dynamic> json,
) => _$JobSatisfactionImpl(
  value: (json['value'] as num).toInt(),
  label: json['label'] as String,
);

Map<String, dynamic> _$$JobSatisfactionImplToJson(
  _$JobSatisfactionImpl instance,
) => <String, dynamic>{'value': instance.value, 'label': instance.label};

_$ProfessionImpl _$$ProfessionImplFromJson(Map<String, dynamic> json) =>
    _$ProfessionImpl(
      value: json['value'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$$ProfessionImplToJson(_$ProfessionImpl instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};
