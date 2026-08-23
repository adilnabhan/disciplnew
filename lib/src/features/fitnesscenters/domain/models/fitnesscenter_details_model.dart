// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:customer_mobile_app/imports_bindings.dart';

part 'fitnesscenter_details_model.freezed.dart';
part 'fitnesscenter_details_model.g.dart';

@freezed
class FitnesscenterDetailsModel with _$FitnesscenterDetailsModel {
  const factory FitnesscenterDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') bool? isOnFreeTrial,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'working_days') List<WorkingDay>? workingDays,
    @JsonKey(name: 'time_slots') List<dynamic>? timeSlots,
    @JsonKey(name: 'social_media') List<SocialMedia>? socialMedia,
    @JsonKey(name: 'amenities') List<Amenity>? amenities,
    @JsonKey(name: 'categories') List<Amenity>? categories,
    @JsonKey(name: 'photos') List<Photo>? photos,
    @JsonKey(name: 'packages') List<Package>? packages,
    @JsonKey(name: 'subscription_details') dynamic subscriptionDetails,
    @JsonKey(name: 'birthday_wish_message') dynamic birthdayWishMessage,
    @JsonKey(name: 'anniversary_wish_message') dynamic anniversaryWishMessage,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'average_rating') dynamic averageRating,
    @JsonKey(name: 'is_slot_available') bool? isSlotAvailable,
  }) = _FitnesscenterDetailsModel;

  factory FitnesscenterDetailsModel.fromJson(Map<String, dynamic> json) => _$FitnesscenterDetailsModelFromJson(json);
}

@freezed
class Amenity with _$Amenity {
  const factory Amenity({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name}) = _Amenity;

  factory Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);
}

@freezed
class Package with _$Package {
  const factory Package({
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
  }) = _Package;

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);
}

@freezed
class Photo with _$Photo {
  const factory Photo({@JsonKey(name: 'id') int? id, @JsonKey(name: 'image') String? image, @JsonKey(name: 'caption') String? caption, @JsonKey(name: 'is_primary') bool? isPrimary}) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}

@freezed
class SocialMedia with _$SocialMedia {
  const factory SocialMedia({@JsonKey(name: 'id') int? id, @JsonKey(name: 'platform') String? platform, @JsonKey(name: 'url') String? url}) = _SocialMedia;

  factory SocialMedia.fromJson(Map<String, dynamic> json) => _$SocialMediaFromJson(json);
}

@freezed
class WorkingDay with _$WorkingDay {
  const factory WorkingDay({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
  }) = _WorkingDay;

  factory WorkingDay.fromJson(Map<String, dynamic> json) => _$WorkingDayFromJson(json);
}
