import 'package:freezed_annotation/freezed_annotation.dart';

part 'constant_choices_model.freezed.dart';
part 'constant_choices_model.g.dart';

@freezed
class ConstantChoicesModel with _$ConstantChoicesModel {
  const factory ConstantChoicesModel({
    required bool success,
    required Data data,
  }) = _ConstantChoicesModel;

  factory ConstantChoicesModel.fromJson(Map<String, dynamic> json) =>
      _$ConstantChoicesModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    required List<Profession> professions,
    @JsonKey(name: 'job_satisfactions')
    required List<JobSatisfaction> jobSatisfactions,
    @JsonKey(name: 'working_hours')
    required List<Profession> workingHours,
    @JsonKey(name: 'sleep_hours')
    required List<Profession> sleepHours,
    @JsonKey(name: 'target_goals')
    required List<Profession> targetGoals,
    @JsonKey(name: 'health_conditions')
    required List<Profession> healthConditions,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class JobSatisfaction with _$JobSatisfaction {
  const factory JobSatisfaction({
    required int value,
    required String label,
  }) = _JobSatisfaction;

  factory JobSatisfaction.fromJson(Map<String, dynamic> json) =>
      _$JobSatisfactionFromJson(json);
}

@freezed
class Profession with _$Profession {
  const factory Profession({
    required String value,
    required String label,
  }) = _Profession;

  factory Profession.fromJson(Map<String, dynamic> json) =>
      _$ProfessionFromJson(json);
}
