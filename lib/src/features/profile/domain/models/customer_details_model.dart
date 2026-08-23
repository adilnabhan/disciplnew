// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_details_model.freezed.dart';
part 'customer_details_model.g.dart';

@freezed
class CustomerDetailsModel with _$CustomerDetailsModel {
  const factory CustomerDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'emergency_contact_name') dynamic emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') String? emergencyContactNumber,
    @JsonKey(name: 'height') String? height,
    @JsonKey(name: 'weight') String? weight,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'profession') String? profession,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'memberships') List<Membership>? memberships,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'is_healthy') bool? isHealthy,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'job_satisfaction') int? jobSatisfaction,
    @JsonKey(name: 'active_scale') int? activeScale,
    @JsonKey(name: 'average_working_hours') String? averageWorkingHours,
    @JsonKey(name: 'average_sleep_hours') String? averageSleepingHours,
    @JsonKey(name: 'fitness_level') dynamic fitnessLevel,
    @JsonKey(name: 'stress_level') dynamic stressLevel,
    @JsonKey(name: 'weight_goal') dynamic weightGoal,
    @JsonKey(name: 'target_weight') dynamic targetWeight,
    @JsonKey(name: 'sleep_goal') dynamic sleepGoal,
    @JsonKey(name: 'bmi') dynamic bmi,
    @JsonKey(name: 'bmr') dynamic bmr,
    @JsonKey(name: 'bf_percentage') dynamic bfPercentage,
    @JsonKey(name: 'injuries') List<dynamic>? injuries,
    @JsonKey(name: 'medical_conditions') List<dynamic>? medicalConditions,
    @JsonKey(name: 'health_conditions') List<String>? healthConditions,
    @JsonKey(name: 'target_goal') List<String>? targetGoal,

    @JsonKey(name: 'health_conditions_other') String? healthConditionsOther,
    @JsonKey(name: 'target_goal_other') String? targetGoalOther,
    @JsonKey(name: 'assigned_fitness_center') Map<String, dynamic>? assignedFitnessCenter,
    @JsonKey(name: 'assigned_trainer') Map<String, dynamic>? assignedTrainer,
    @JsonKey(name: 'trainer_notes') String? trainerNotes,
  }) = _CustomerDetailsModel;

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailsModelFromJson(json);
}

@freezed
class Membership with _$Membership {
  const factory Membership({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership') int? membership,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'trial_start_at') DateTime? trialStartAt,
    @JsonKey(name: 'trial_end_at') DateTime? trialEndAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
