// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_memberships_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllMembershipsModelImpl _$$AllMembershipsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AllMembershipsModelImpl(
  status: json['status'] as String?,
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map(
            (e) => SingleMembershipModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$$AllMembershipsModelImplToJson(
  _$AllMembershipsModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'memberships': instance.memberships,
};

_$SingleMembershipModelImpl _$$SingleMembershipModelImplFromJson(
  Map<String, dynamic> json,
) => _$SingleMembershipModelImpl(
  organizationId: (json['organization_id'] as num?)?.toInt(),
  organizationName: json['organization_name'] as String?,
  logo: json['logo'] as String?,
  membershipStatus: json['membership_status'] as String?,
  reviewAdded: json['review_added'] as bool?,
  review: json['review'],
);

Map<String, dynamic> _$$SingleMembershipModelImplToJson(
  _$SingleMembershipModelImpl instance,
) => <String, dynamic>{
  'organization_id': instance.organizationId,
  'organization_name': instance.organizationName,
  'logo': instance.logo,
  'membership_status': instance.membershipStatus,
  'review_added': instance.reviewAdded,
  'review': instance.review,
};
