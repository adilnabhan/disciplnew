// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_with_otp_model.g.dart';
part 'login_with_otp_model.freezed.dart';

@freezed
class LoginSuccessModel with _$LoginSuccessModel {
  const factory LoginSuccessModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'customer') CustomerDataModel? customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
    @JsonKey(name: 'is_guest') bool? isGuest,
  }) = _LoginWithOtpEntity;

  factory LoginSuccessModel.fromJson(Map<String, dynamic> json) =>
      _$LoginSuccessModelFromJson(json);
}

@freezed
class CustomerDataModel with _$CustomerDataModel {
  const factory CustomerDataModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
  }) = _CustomerDataModel;

  factory CustomerDataModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerDataModelFromJson(json);
}
