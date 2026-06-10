// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'all_memberships_model.freezed.dart';
part 'all_memberships_model.g.dart';

@freezed
class AllMembershipsModel with _$AllMembershipsModel {
  const factory AllMembershipsModel({@JsonKey(name: 'status') String? status, @JsonKey(name: 'memberships') List<SingleMembershipModel>? memberships}) = _AllMembershipsModel;

  factory AllMembershipsModel.fromJson(Map<String, dynamic> json) => _$AllMembershipsModelFromJson(json);
}

@freezed
class SingleMembershipModel with _$SingleMembershipModel {
  const factory SingleMembershipModel({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'membership_status') String? membershipStatus,
    @JsonKey(name: 'review_added') bool? reviewAdded,
    @JsonKey(name: 'review') dynamic review,
  }) = _SingleMembershipModel;

  factory SingleMembershipModel.fromJson(Map<String, dynamic> json) => _$SingleMembershipModelFromJson(json);
}
