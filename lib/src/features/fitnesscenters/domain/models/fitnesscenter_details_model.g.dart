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
  workingDays:
      (json['working_days'] as List<dynamic>?)
          ?.map((e) => WorkingDay.fromJson(e as Map<String, dynamic>))
          .toList(),
  timeSlots: json['time_slots'] as List<dynamic>?,
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
    );

Map<String, dynamic> _$$WorkingDayImplToJson(_$WorkingDayImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'is_open': instance.isOpen,
      'morning_opening_time': instance.morningOpeningTime,
      'morning_closing_time': instance.morningClosingTime,
      'evening_opening_time': instance.eveningOpeningTime,
      'evening_closing_time': instance.eveningClosingTime,
    };
