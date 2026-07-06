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
    @JsonKey(name: 'google_maps_url') String? googleMapsUrl,
    @JsonKey(name: 'working_days') List<WorkingDay>? workingDays,
    @JsonKey(name: 'time_slots') List<GymTimeSlot>? timeSlots,
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
    @JsonKey(name: 'trainers') List<GymTrainer>? trainers,
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
    @JsonKey(name: 'ladies_opening_time') String? ladiesOpeningTime,
    @JsonKey(name: 'ladies_closing_time') String? ladiesClosingTime,
  }) = _WorkingDay;

  factory WorkingDay.fromJson(Map<String, dynamic> json) => _$WorkingDayFromJson(json);
}

@freezed
class GymTimeSlot with _$GymTimeSlot {
  const factory GymTimeSlot({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_currently_active') bool? isCurrentlyActive,
  }) = _GymTimeSlot;

  factory GymTimeSlot.fromJson(Map<String, dynamic> json) => _$GymTimeSlotFromJson(json);
}

@freezed
class GymTrainer with _$GymTrainer {
  const factory GymTrainer({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'user_type') String? userType,
    @JsonKey(name: 'bio') String? bio,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'experience_years') int? experienceYears,
    @JsonKey(name: 'average_rating') dynamic averageRating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'specializations') List<String>? specializations,
    @JsonKey(name: 'clients_count') int? clientsCount,
    @JsonKey(name: 'verified_workouts_count') int? verifiedWorkoutsCount,
    @JsonKey(name: 'transformations') List<GymTransformation>? transformations,
    @JsonKey(name: 'certifications') List<Certification>? certifications,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'gender') String? gender,
  }) = _GymTrainer;

  factory GymTrainer.fromJson(Map<String, dynamic> json) => _$GymTrainerFromJson(json);
}

@freezed
class GymTransformation with _$GymTransformation {
  const factory GymTransformation({
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'before_image') String? beforeImage,
    @JsonKey(name: 'after_image') String? afterImage,
  }) = _GymTransformation;

  factory GymTransformation.fromJson(Map<String, dynamic> json) => _$GymTransformationFromJson(json);
}

@freezed
class Certification with _$Certification {
  const factory Certification({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'issued_by') String? issuedBy,
    @JsonKey(name: 'issued_date') String? issuedDate,
    @JsonKey(name: 'file_url') String? fileUrl,
  }) = _Certification;

  factory Certification.fromJson(Map<String, dynamic> json) => _$CertificationFromJson(json);
}

