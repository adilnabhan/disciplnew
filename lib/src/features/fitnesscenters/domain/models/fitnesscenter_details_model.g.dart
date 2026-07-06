// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitnesscenter_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FitnesscenterDetailsModelImpl _$$FitnesscenterDetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$FitnesscenterDetailsModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  isPublic: json['is_public'] as bool?,
  active: json['active'] as bool?,
  isSubscribed: json['is_subscribed'] as bool?,
  takeFreeTrial: json['take_free_trial'] as bool?,
  isOnFreeTrial: json['is_on_free_trial'] as bool?,
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  googleMapsUrl: json['google_maps_url'] as String?,
  workingDays:
      (json['working_days'] as List<dynamic>?)
          ?.map((e) => WorkingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
  timeSlots:
      (json['time_slots'] as List<dynamic>?)
          ?.map((e) => GymTimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
  socialMedia:
      (json['social_media'] as List<dynamic>?)
          ?.map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
  amenities:
      (json['amenities'] as List<dynamic>?)
          ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
          .toList(),
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
          .toList(),
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
  packages:
      (json['packages'] as List<dynamic>?)
          ?.map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
  subscriptionDetails: json['subscription_details'],
  birthdayWishMessage: json['birthday_wish_message'],
  anniversaryWishMessage: json['anniversary_wish_message'],
  logo: json['logo'] as String?,
  reviewCount: (json['review_count'] as num?)?.toInt(),
  averageRating: json['average_rating'],
  isSlotAvailable: json['is_slot_available'] as bool?,
  trainers:
      (json['trainers'] as List<dynamic>?)
          ?.map((e) => GymTrainer.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$FitnesscenterDetailsModelImplToJson(
  _$FitnesscenterDetailsModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'is_public': instance.isPublic,
  'active': instance.active,
  'is_subscribed': instance.isSubscribed,
  'take_free_trial': instance.takeFreeTrial,
  'is_on_free_trial': instance.isOnFreeTrial,
  'location': instance.location,
  'google_maps_url': instance.googleMapsUrl,
  'working_days': instance.workingDays,
  'time_slots': instance.timeSlots,
  'social_media': instance.socialMedia,
  'amenities': instance.amenities,
  'categories': instance.categories,
  'photos': instance.photos,
  'packages': instance.packages,
  'subscription_details': instance.subscriptionDetails,
  'birthday_wish_message': instance.birthdayWishMessage,
  'anniversary_wish_message': instance.anniversaryWishMessage,
  'logo': instance.logo,
  'review_count': instance.reviewCount,
  'average_rating': instance.averageRating,
  'is_slot_available': instance.isSlotAvailable,
  'trainers': instance.trainers,
};

_$AmenityImpl _$$AmenityImplFromJson(Map<String, dynamic> json) =>
    _$AmenityImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$AmenityImplToJson(_$AmenityImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$PackageImpl _$$PackageImplFromJson(Map<String, dynamic> json) =>
    _$PackageImpl(
      id: (json['id'] as num?)?.toInt(),
      packageType: json['package_type'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      actualPrice: json['actual_price'] as String?,
      offerPrice: json['offer_price'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      features: json['features'] as List<dynamic>?,
      isActive: json['is_active'] as bool?,
      isEmiAvailable: json['is_emi_available'] as bool?,
    );

Map<String, dynamic> _$$PackageImplToJson(_$PackageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'package_type': instance.packageType,
      'name': instance.name,
      'description': instance.description,
      'actual_price': instance.actualPrice,
      'offer_price': instance.offerPrice,
      'duration_days': instance.durationDays,
      'features': instance.features,
      'is_active': instance.isActive,
      'is_emi_available': instance.isEmiAvailable,
    };

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
  id: (json['id'] as num?)?.toInt(),
  image: json['image'] as String?,
  caption: json['caption'] as String?,
  isPrimary: json['is_primary'] as bool?,
);

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'caption': instance.caption,
      'is_primary': instance.isPrimary,
    };

_$SocialMediaImpl _$$SocialMediaImplFromJson(Map<String, dynamic> json) =>
    _$SocialMediaImpl(
      id: (json['id'] as num?)?.toInt(),
      platform: json['platform'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$SocialMediaImplToJson(_$SocialMediaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'url': instance.url,
    };

_$WorkingDayImpl _$$WorkingDayImplFromJson(Map<String, dynamic> json) =>
    _$WorkingDayImpl(
      day: json['day'] as String?,
      isOpen: json['is_open'] as bool?,
      morningOpeningTime: json['morning_opening_time'] as String?,
      morningClosingTime: json['morning_closing_time'] as String?,
      eveningOpeningTime: json['evening_opening_time'] as String?,
      eveningClosingTime: json['evening_closing_time'] as String?,
      ladiesOpeningTime: json['ladies_opening_time'] as String?,
      ladiesClosingTime: json['ladies_closing_time'] as String?,
    );

Map<String, dynamic> _$$WorkingDayImplToJson(_$WorkingDayImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'is_open': instance.isOpen,
      'morning_opening_time': instance.morningOpeningTime,
      'morning_closing_time': instance.morningClosingTime,
      'evening_opening_time': instance.eveningOpeningTime,
      'evening_closing_time': instance.eveningClosingTime,
      'ladies_opening_time': instance.ladiesOpeningTime,
      'ladies_closing_time': instance.ladiesClosingTime,
    };

_$GymTimeSlotImpl _$$GymTimeSlotImplFromJson(Map<String, dynamic> json) =>
    _$GymTimeSlotImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isActive: json['is_active'] as bool?,
      isCurrentlyActive: json['is_currently_active'] as bool?,
    );

Map<String, dynamic> _$$GymTimeSlotImplToJson(_$GymTimeSlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_active': instance.isActive,
      'is_currently_active': instance.isCurrentlyActive,
    };

_$GymTrainerImpl _$$GymTrainerImplFromJson(Map<String, dynamic> json) =>
    _$GymTrainerImpl(
      id: (json['id'] as num?)?.toInt(),
      fullName: json['full_name'] as String?,
      userType: json['user_type'] as String?,
      bio: json['bio'] as String?,
      profileImage: json['profile_image'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt(),
      averageRating: json['average_rating'],
      reviewCount: (json['review_count'] as num?)?.toInt(),
      specializations:
          (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      clientsCount: (json['clients_count'] as num?)?.toInt(),
      verifiedWorkoutsCount: (json['verified_workouts_count'] as num?)?.toInt(),
      transformations:
          (json['transformations'] as List<dynamic>?)
              ?.map(
                (e) => GymTransformation.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => Certification.fromJson(e as Map<String, dynamic>))
              .toList(),
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$$GymTrainerImplToJson(_$GymTrainerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'user_type': instance.userType,
      'bio': instance.bio,
      'profile_image': instance.profileImage,
      'experience_years': instance.experienceYears,
      'average_rating': instance.averageRating,
      'review_count': instance.reviewCount,
      'specializations': instance.specializations,
      'clients_count': instance.clientsCount,
      'verified_workouts_count': instance.verifiedWorkoutsCount,
      'transformations': instance.transformations,
      'certifications': instance.certifications,
      'email': instance.email,
      'mobile': instance.mobile,
      'gender': instance.gender,
    };

_$GymTransformationImpl _$$GymTransformationImplFromJson(
  Map<String, dynamic> json,
) => _$GymTransformationImpl(
  description: json['description'] as String?,
  beforeImage: json['before_image'] as String?,
  afterImage: json['after_image'] as String?,
);

Map<String, dynamic> _$$GymTransformationImplToJson(
  _$GymTransformationImpl instance,
) => <String, dynamic>{
  'description': instance.description,
  'before_image': instance.beforeImage,
  'after_image': instance.afterImage,
};

_$CertificationImpl _$$CertificationImplFromJson(Map<String, dynamic> json) =>
    _$CertificationImpl(
      name: json['name'] as String?,
      issuedBy: json['issued_by'] as String?,
      issuedDate: json['issued_date'] as String?,
      fileUrl: json['file_url'] as String?,
    );

Map<String, dynamic> _$$CertificationImplToJson(_$CertificationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'issued_by': instance.issuedBy,
      'issued_date': instance.issuedDate,
      'file_url': instance.fileUrl,
    };
