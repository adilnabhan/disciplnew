// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerDetailsModelImpl _$$CustomerDetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerDetailsModelImpl(
  id: (json['id'] as num?)?.toInt(),
  emergencyContactName: json['emergency_contact_name'],
  emergencyContactNumber: json['emergency_contact_number'] as String?,
  height: json['height'] as String?,
  weight: json['weight'] as String?,
  profilePicture: json['profile_picture'],
  profession: json['profession'] as String?,
  isActiveMember: json['is_active_member'] as bool?,
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => Membership.fromJson(e as Map<String, dynamic>))
          .toList(),
  fullName: json['full_name'] as String?,
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  modified:
      json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
  mobileNumber: json['mobile_number'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  isHealthy: json['is_healthy'] as bool?,
  dateOfBirth:
      json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
  gender: json['gender'] as String?,
  bloodGroup: json['blood_group'] as String?,
  jobSatisfaction: (json['job_satisfaction'] as num?)?.toInt(),
  activeScale: (json['active_scale'] as num?)?.toInt(),
  averageWorkingHours: json['average_working_hours'] as String?,
  averageSleepingHours: json['average_sleep_hours'] as String?,
  fitnessLevel: json['fitness_level'],
  stressLevel: json['stress_level'],
  weightGoal: json['weight_goal'],
  targetWeight: json['target_weight'],
  sleepGoal: json['sleep_goal'],
  bmi: json['bmi'],
  bmr: json['bmr'],
  bfPercentage: json['bf_percentage'],
  injuries: json['injuries'] as List<dynamic>?,
  medicalConditions: json['medical_conditions'] as List<dynamic>?,
  healthConditions:
      (json['health_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  targetGoal:
      (json['target_goal'] as List<dynamic>?)?.map((e) => e as String).toList(),
  healthConditionsOther: json['health_conditions_other'] as String?,
  targetGoalOther: json['target_goal_other'] as String?,
);

Map<String, dynamic> _$$CustomerDetailsModelImplToJson(
  _$CustomerDetailsModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'emergency_contact_name': instance.emergencyContactName,
  'emergency_contact_number': instance.emergencyContactNumber,
  'height': instance.height,
  'weight': instance.weight,
  'profile_picture': instance.profilePicture,
  'profession': instance.profession,
  'is_active_member': instance.isActiveMember,
  'memberships': instance.memberships,
  'full_name': instance.fullName,
  'created': instance.created?.toIso8601String(),
  'modified': instance.modified?.toIso8601String(),
  'mobile_number': instance.mobileNumber,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'is_healthy': instance.isHealthy,
  'date_of_birth': instance.dateOfBirth?.toIso8601String(),
  'gender': instance.gender,
  'blood_group': instance.bloodGroup,
  'job_satisfaction': instance.jobSatisfaction,
  'active_scale': instance.activeScale,
  'average_working_hours': instance.averageWorkingHours,
  'average_sleep_hours': instance.averageSleepingHours,
  'fitness_level': instance.fitnessLevel,
  'stress_level': instance.stressLevel,
  'weight_goal': instance.weightGoal,
  'target_weight': instance.targetWeight,
  'sleep_goal': instance.sleepGoal,
  'bmi': instance.bmi,
  'bmr': instance.bmr,
  'bf_percentage': instance.bfPercentage,
  'injuries': instance.injuries,
  'medical_conditions': instance.medicalConditions,
  'health_conditions': instance.healthConditions,
  'target_goal': instance.targetGoal,
  'health_conditions_other': instance.healthConditionsOther,
  'target_goal_other': instance.targetGoalOther,
};

_$MembershipImpl _$$MembershipImplFromJson(Map<String, dynamic> json) =>
    _$MembershipImpl(
      id: (json['id'] as num?)?.toInt(),
      membership: (json['membership'] as num?)?.toInt(),
      membershipName: json['membership_name'] as String?,
      startDate:
          json['start_date'] == null
              ? null
              : DateTime.parse(json['start_date'] as String),
      endDate:
          json['end_date'] == null
              ? null
              : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String?,
      amount: json['amount'] as String?,
      assignFree: json['assign_free'] as bool?,
      isTrial: json['is_trial'] as bool?,
      paymentStatus: json['payment_status'] as String?,
      isActive: json['is_active'] as bool?,
      trialStartAt:
          json['trial_start_at'] == null
              ? null
              : DateTime.parse(json['trial_start_at'] as String),
      trialEndAt:
          json['trial_end_at'] == null
              ? null
              : DateTime.parse(json['trial_end_at'] as String),
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MembershipImplToJson(_$MembershipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership': instance.membership,
      'membership_name': instance.membershipName,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'assign_free': instance.assignFree,
      'is_trial': instance.isTrial,
      'payment_status': instance.paymentStatus,
      'is_active': instance.isActive,
      'trial_start_at': instance.trialStartAt?.toIso8601String(),
      'trial_end_at': instance.trialEndAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
