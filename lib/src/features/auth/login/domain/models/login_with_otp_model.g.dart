// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_with_otp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginWithOtpEntityImpl _$$LoginWithOtpEntityImplFromJson(
  Map<String, dynamic> json,
) => _$LoginWithOtpEntityImpl(
  id: (json['id'] as num?)?.toInt(),
  access: json['access'] as String?,
  refresh: json['refresh'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  email: json['email'] as String?,
  bloodGroup: json['blood_group'] as String?,
  lastLogin:
      json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
  customer:
      json['customer'] == null
          ? null
          : CustomerDataModel.fromJson(
            json['customer'] as Map<String, dynamic>,
          ),
  profilePicture: json['profile_picture'],
  warnings: json['warnings'] as List<dynamic>?,
  isProfileCompleted: json['is_profile_complete'] as bool?,
  isGuest: json['is_guest'] as bool?,
);

Map<String, dynamic> _$$LoginWithOtpEntityImplToJson(
  _$LoginWithOtpEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'access': instance.access,
  'refresh': instance.refresh,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'mobile_number': instance.mobileNumber,
  'email': instance.email,
  'blood_group': instance.bloodGroup,
  'last_login': instance.lastLogin?.toIso8601String(),
  'customer': instance.customer,
  'profile_picture': instance.profilePicture,
  'warnings': instance.warnings,
  'is_profile_complete': instance.isProfileCompleted,
  'is_guest': instance.isGuest,
};

_$CustomerDataModelImpl _$$CustomerDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerDataModelImpl(
  id: (json['id'] as num?)?.toInt(),
  isActiveMember: json['is_active_member'] as bool?,
  profileCompleteness: (json['profile_completeness'] as num?)?.toInt(),
  organizationId: (json['organization_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CustomerDataModelImplToJson(
  _$CustomerDataModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'is_active_member': instance.isActiveMember,
  'profile_completeness': instance.profileCompleteness,
  'organization_id': instance.organizationId,
};
