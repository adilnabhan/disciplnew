// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitnesscenter_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FitnesscenterDetailsModel _$FitnesscenterDetailsModelFromJson(
  Map<String, dynamic> json,
) {
  return _FitnesscenterDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$FitnesscenterDetailsModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool? get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'active')
  bool? get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed => throw _privateConstructorUsedError;
  @JsonKey(name: 'take_free_trial')
  bool? get takeFreeTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_on_free_trial')
  bool? get isOnFreeTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  Location? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'google_maps_url')
  String? get googleMapsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_days')
  List<WorkingDay>? get workingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_slots')
  List<GymTimeSlot>? get timeSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia => throw _privateConstructorUsedError;
  @JsonKey(name: 'amenities')
  List<Amenity>? get amenities => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<Amenity>? get categories => throw _privateConstructorUsedError;
  @JsonKey(name: 'photos')
  List<Photo>? get photos => throw _privateConstructorUsedError;
  @JsonKey(name: 'packages')
  List<Package>? get packages => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_details')
  dynamic get subscriptionDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'birthday_wish_message')
  dynamic get birthdayWishMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'anniversary_wish_message')
  dynamic get anniversaryWishMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  dynamic get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_slot_available')
  bool? get isSlotAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'trainers')
  List<GymTrainer>? get trainers => throw _privateConstructorUsedError;

  /// Serializes this FitnesscenterDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnesscenterDetailsModelCopyWith<FitnesscenterDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnesscenterDetailsModelCopyWith<$Res> {
  factory $FitnesscenterDetailsModelCopyWith(
    FitnesscenterDetailsModel value,
    $Res Function(FitnesscenterDetailsModel) then,
  ) = _$FitnesscenterDetailsModelCopyWithImpl<$Res, FitnesscenterDetailsModel>;
  @useResult
  $Res call({
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
  });

  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$FitnesscenterDetailsModelCopyWithImpl<
  $Res,
  $Val extends FitnesscenterDetailsModel
>
    implements $FitnesscenterDetailsModelCopyWith<$Res> {
  _$FitnesscenterDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isPublic = freezed,
    Object? active = freezed,
    Object? isSubscribed = freezed,
    Object? takeFreeTrial = freezed,
    Object? isOnFreeTrial = freezed,
    Object? location = freezed,
    Object? googleMapsUrl = freezed,
    Object? workingDays = freezed,
    Object? timeSlots = freezed,
    Object? socialMedia = freezed,
    Object? amenities = freezed,
    Object? categories = freezed,
    Object? photos = freezed,
    Object? packages = freezed,
    Object? subscriptionDetails = freezed,
    Object? birthdayWishMessage = freezed,
    Object? anniversaryWishMessage = freezed,
    Object? logo = freezed,
    Object? reviewCount = freezed,
    Object? averageRating = freezed,
    Object? isSlotAvailable = freezed,
    Object? trainers = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            isPublic:
                freezed == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
                        as bool?,
            active:
                freezed == active
                    ? _value.active
                    : active // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isSubscribed:
                freezed == isSubscribed
                    ? _value.isSubscribed
                    : isSubscribed // ignore: cast_nullable_to_non_nullable
                        as bool?,
            takeFreeTrial:
                freezed == takeFreeTrial
                    ? _value.takeFreeTrial
                    : takeFreeTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isOnFreeTrial:
                freezed == isOnFreeTrial
                    ? _value.isOnFreeTrial
                    : isOnFreeTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as Location?,
            googleMapsUrl:
                freezed == googleMapsUrl
                    ? _value.googleMapsUrl
                    : googleMapsUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            workingDays:
                freezed == workingDays
                    ? _value.workingDays
                    : workingDays // ignore: cast_nullable_to_non_nullable
                        as List<WorkingDay>?,
            timeSlots:
                freezed == timeSlots
                    ? _value.timeSlots
                    : timeSlots // ignore: cast_nullable_to_non_nullable
                        as List<GymTimeSlot>?,
            socialMedia:
                freezed == socialMedia
                    ? _value.socialMedia
                    : socialMedia // ignore: cast_nullable_to_non_nullable
                        as List<SocialMedia>?,
            amenities:
                freezed == amenities
                    ? _value.amenities
                    : amenities // ignore: cast_nullable_to_non_nullable
                        as List<Amenity>?,
            categories:
                freezed == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<Amenity>?,
            photos:
                freezed == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<Photo>?,
            packages:
                freezed == packages
                    ? _value.packages
                    : packages // ignore: cast_nullable_to_non_nullable
                        as List<Package>?,
            subscriptionDetails:
                freezed == subscriptionDetails
                    ? _value.subscriptionDetails
                    : subscriptionDetails // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            birthdayWishMessage:
                freezed == birthdayWishMessage
                    ? _value.birthdayWishMessage
                    : birthdayWishMessage // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            anniversaryWishMessage:
                freezed == anniversaryWishMessage
                    ? _value.anniversaryWishMessage
                    : anniversaryWishMessage // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            averageRating:
                freezed == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            isSlotAvailable:
                freezed == isSlotAvailable
                    ? _value.isSlotAvailable
                    : isSlotAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
            trainers:
                freezed == trainers
                    ? _value.trainers
                    : trainers // ignore: cast_nullable_to_non_nullable
                        as List<GymTrainer>?,
          )
          as $Val,
    );
  }

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FitnesscenterDetailsModelImplCopyWith<$Res>
    implements $FitnesscenterDetailsModelCopyWith<$Res> {
  factory _$$FitnesscenterDetailsModelImplCopyWith(
    _$FitnesscenterDetailsModelImpl value,
    $Res Function(_$FitnesscenterDetailsModelImpl) then,
  ) = __$$FitnesscenterDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });

  @override
  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$FitnesscenterDetailsModelImplCopyWithImpl<$Res>
    extends
        _$FitnesscenterDetailsModelCopyWithImpl<
          $Res,
          _$FitnesscenterDetailsModelImpl
        >
    implements _$$FitnesscenterDetailsModelImplCopyWith<$Res> {
  __$$FitnesscenterDetailsModelImplCopyWithImpl(
    _$FitnesscenterDetailsModelImpl _value,
    $Res Function(_$FitnesscenterDetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isPublic = freezed,
    Object? active = freezed,
    Object? isSubscribed = freezed,
    Object? takeFreeTrial = freezed,
    Object? isOnFreeTrial = freezed,
    Object? location = freezed,
    Object? googleMapsUrl = freezed,
    Object? workingDays = freezed,
    Object? timeSlots = freezed,
    Object? socialMedia = freezed,
    Object? amenities = freezed,
    Object? categories = freezed,
    Object? photos = freezed,
    Object? packages = freezed,
    Object? subscriptionDetails = freezed,
    Object? birthdayWishMessage = freezed,
    Object? anniversaryWishMessage = freezed,
    Object? logo = freezed,
    Object? reviewCount = freezed,
    Object? averageRating = freezed,
    Object? isSlotAvailable = freezed,
    Object? trainers = freezed,
  }) {
    return _then(
      _$FitnesscenterDetailsModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        isPublic:
            freezed == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                    as bool?,
        active:
            freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isSubscribed:
            freezed == isSubscribed
                ? _value.isSubscribed
                : isSubscribed // ignore: cast_nullable_to_non_nullable
                    as bool?,
        takeFreeTrial:
            freezed == takeFreeTrial
                ? _value.takeFreeTrial
                : takeFreeTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isOnFreeTrial:
            freezed == isOnFreeTrial
                ? _value.isOnFreeTrial
                : isOnFreeTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as Location?,
        googleMapsUrl:
            freezed == googleMapsUrl
                ? _value.googleMapsUrl
                : googleMapsUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        workingDays:
            freezed == workingDays
                ? _value._workingDays
                : workingDays // ignore: cast_nullable_to_non_nullable
                    as List<WorkingDay>?,
        timeSlots:
            freezed == timeSlots
                ? _value._timeSlots
                : timeSlots // ignore: cast_nullable_to_non_nullable
                    as List<GymTimeSlot>?,
        socialMedia:
            freezed == socialMedia
                ? _value._socialMedia
                : socialMedia // ignore: cast_nullable_to_non_nullable
                    as List<SocialMedia>?,
        amenities:
            freezed == amenities
                ? _value._amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                    as List<Amenity>?,
        categories:
            freezed == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<Amenity>?,
        photos:
            freezed == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<Photo>?,
        packages:
            freezed == packages
                ? _value._packages
                : packages // ignore: cast_nullable_to_non_nullable
                    as List<Package>?,
        subscriptionDetails:
            freezed == subscriptionDetails
                ? _value.subscriptionDetails
                : subscriptionDetails // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        birthdayWishMessage:
            freezed == birthdayWishMessage
                ? _value.birthdayWishMessage
                : birthdayWishMessage // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        anniversaryWishMessage:
            freezed == anniversaryWishMessage
                ? _value.anniversaryWishMessage
                : anniversaryWishMessage // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        averageRating:
            freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        isSlotAvailable:
            freezed == isSlotAvailable
                ? _value.isSlotAvailable
                : isSlotAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
        trainers:
            freezed == trainers
                ? _value._trainers
                : trainers // ignore: cast_nullable_to_non_nullable
                    as List<GymTrainer>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FitnesscenterDetailsModelImpl implements _FitnesscenterDetailsModel {
  const _$FitnesscenterDetailsModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'phone_number') this.phoneNumber,
    @JsonKey(name: 'is_public') this.isPublic,
    @JsonKey(name: 'active') this.active,
    @JsonKey(name: 'is_subscribed') this.isSubscribed,
    @JsonKey(name: 'take_free_trial') this.takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') this.isOnFreeTrial,
    @JsonKey(name: 'location') this.location,
    @JsonKey(name: 'google_maps_url') this.googleMapsUrl,
    @JsonKey(name: 'working_days') final List<WorkingDay>? workingDays,
    @JsonKey(name: 'time_slots') final List<GymTimeSlot>? timeSlots,
    @JsonKey(name: 'social_media') final List<SocialMedia>? socialMedia,
    @JsonKey(name: 'amenities') final List<Amenity>? amenities,
    @JsonKey(name: 'categories') final List<Amenity>? categories,
    @JsonKey(name: 'photos') final List<Photo>? photos,
    @JsonKey(name: 'packages') final List<Package>? packages,
    @JsonKey(name: 'subscription_details') this.subscriptionDetails,
    @JsonKey(name: 'birthday_wish_message') this.birthdayWishMessage,
    @JsonKey(name: 'anniversary_wish_message') this.anniversaryWishMessage,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'is_slot_available') this.isSlotAvailable,
    @JsonKey(name: 'trainers') final List<GymTrainer>? trainers,
  }) : _workingDays = workingDays,
       _timeSlots = timeSlots,
       _socialMedia = socialMedia,
       _amenities = amenities,
       _categories = categories,
       _photos = photos,
       _packages = packages,
       _trainers = trainers;

  factory _$FitnesscenterDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FitnesscenterDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  @override
  @JsonKey(name: 'active')
  final bool? active;
  @override
  @JsonKey(name: 'is_subscribed')
  final bool? isSubscribed;
  @override
  @JsonKey(name: 'take_free_trial')
  final bool? takeFreeTrial;
  @override
  @JsonKey(name: 'is_on_free_trial')
  final bool? isOnFreeTrial;
  @override
  @JsonKey(name: 'location')
  final Location? location;
  @override
  @JsonKey(name: 'google_maps_url')
  final String? googleMapsUrl;
  final List<WorkingDay>? _workingDays;
  @override
  @JsonKey(name: 'working_days')
  List<WorkingDay>? get workingDays {
    final value = _workingDays;
    if (value == null) return null;
    if (_workingDays is EqualUnmodifiableListView) return _workingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<GymTimeSlot>? _timeSlots;
  @override
  @JsonKey(name: 'time_slots')
  List<GymTimeSlot>? get timeSlots {
    final value = _timeSlots;
    if (value == null) return null;
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SocialMedia>? _socialMedia;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia {
    final value = _socialMedia;
    if (value == null) return null;
    if (_socialMedia is EqualUnmodifiableListView) return _socialMedia;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Amenity>? _amenities;
  @override
  @JsonKey(name: 'amenities')
  List<Amenity>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Amenity>? _categories;
  @override
  @JsonKey(name: 'categories')
  List<Amenity>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Photo>? _photos;
  @override
  @JsonKey(name: 'photos')
  List<Photo>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Package>? _packages;
  @override
  @JsonKey(name: 'packages')
  List<Package>? get packages {
    final value = _packages;
    if (value == null) return null;
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'subscription_details')
  final dynamic subscriptionDetails;
  @override
  @JsonKey(name: 'birthday_wish_message')
  final dynamic birthdayWishMessage;
  @override
  @JsonKey(name: 'anniversary_wish_message')
  final dynamic anniversaryWishMessage;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  final dynamic averageRating;
  @override
  @JsonKey(name: 'is_slot_available')
  final bool? isSlotAvailable;
  final List<GymTrainer>? _trainers;
  @override
  @JsonKey(name: 'trainers')
  List<GymTrainer>? get trainers {
    final value = _trainers;
    if (value == null) return null;
    if (_trainers is EqualUnmodifiableListView) return _trainers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FitnesscenterDetailsModel(id: $id, name: $name, description: $description, email: $email, phoneNumber: $phoneNumber, isPublic: $isPublic, active: $active, isSubscribed: $isSubscribed, takeFreeTrial: $takeFreeTrial, isOnFreeTrial: $isOnFreeTrial, location: $location, googleMapsUrl: $googleMapsUrl, workingDays: $workingDays, timeSlots: $timeSlots, socialMedia: $socialMedia, amenities: $amenities, categories: $categories, photos: $photos, packages: $packages, subscriptionDetails: $subscriptionDetails, birthdayWishMessage: $birthdayWishMessage, anniversaryWishMessage: $anniversaryWishMessage, logo: $logo, reviewCount: $reviewCount, averageRating: $averageRating, isSlotAvailable: $isSlotAvailable, trainers: $trainers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnesscenterDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.isSubscribed, isSubscribed) ||
                other.isSubscribed == isSubscribed) &&
            (identical(other.takeFreeTrial, takeFreeTrial) ||
                other.takeFreeTrial == takeFreeTrial) &&
            (identical(other.isOnFreeTrial, isOnFreeTrial) ||
                other.isOnFreeTrial == isOnFreeTrial) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.googleMapsUrl, googleMapsUrl) ||
                other.googleMapsUrl == googleMapsUrl) &&
            const DeepCollectionEquality().equals(
              other._workingDays,
              _workingDays,
            ) &&
            const DeepCollectionEquality().equals(
              other._timeSlots,
              _timeSlots,
            ) &&
            const DeepCollectionEquality().equals(
              other._socialMedia,
              _socialMedia,
            ) &&
            const DeepCollectionEquality().equals(
              other._amenities,
              _amenities,
            ) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            const DeepCollectionEquality().equals(
              other.subscriptionDetails,
              subscriptionDetails,
            ) &&
            const DeepCollectionEquality().equals(
              other.birthdayWishMessage,
              birthdayWishMessage,
            ) &&
            const DeepCollectionEquality().equals(
              other.anniversaryWishMessage,
              anniversaryWishMessage,
            ) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            const DeepCollectionEquality().equals(
              other.averageRating,
              averageRating,
            ) &&
            (identical(other.isSlotAvailable, isSlotAvailable) ||
                other.isSlotAvailable == isSlotAvailable) &&
            const DeepCollectionEquality().equals(other._trainers, _trainers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    email,
    phoneNumber,
    isPublic,
    active,
    isSubscribed,
    takeFreeTrial,
    isOnFreeTrial,
    location,
    googleMapsUrl,
    const DeepCollectionEquality().hash(_workingDays),
    const DeepCollectionEquality().hash(_timeSlots),
    const DeepCollectionEquality().hash(_socialMedia),
    const DeepCollectionEquality().hash(_amenities),
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_photos),
    const DeepCollectionEquality().hash(_packages),
    const DeepCollectionEquality().hash(subscriptionDetails),
    const DeepCollectionEquality().hash(birthdayWishMessage),
    const DeepCollectionEquality().hash(anniversaryWishMessage),
    logo,
    reviewCount,
    const DeepCollectionEquality().hash(averageRating),
    isSlotAvailable,
    const DeepCollectionEquality().hash(_trainers),
  ]);

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnesscenterDetailsModelImplCopyWith<_$FitnesscenterDetailsModelImpl>
  get copyWith => __$$FitnesscenterDetailsModelImplCopyWithImpl<
    _$FitnesscenterDetailsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FitnesscenterDetailsModelImplToJson(this);
  }
}

abstract class _FitnesscenterDetailsModel implements FitnesscenterDetailsModel {
  const factory _FitnesscenterDetailsModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'phone_number') final String? phoneNumber,
    @JsonKey(name: 'is_public') final bool? isPublic,
    @JsonKey(name: 'active') final bool? active,
    @JsonKey(name: 'is_subscribed') final bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') final bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') final bool? isOnFreeTrial,
    @JsonKey(name: 'location') final Location? location,
    @JsonKey(name: 'google_maps_url') final String? googleMapsUrl,
    @JsonKey(name: 'working_days') final List<WorkingDay>? workingDays,
    @JsonKey(name: 'time_slots') final List<GymTimeSlot>? timeSlots,
    @JsonKey(name: 'social_media') final List<SocialMedia>? socialMedia,
    @JsonKey(name: 'amenities') final List<Amenity>? amenities,
    @JsonKey(name: 'categories') final List<Amenity>? categories,
    @JsonKey(name: 'photos') final List<Photo>? photos,
    @JsonKey(name: 'packages') final List<Package>? packages,
    @JsonKey(name: 'subscription_details') final dynamic subscriptionDetails,
    @JsonKey(name: 'birthday_wish_message') final dynamic birthdayWishMessage,
    @JsonKey(name: 'anniversary_wish_message')
    final dynamic anniversaryWishMessage,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'average_rating') final dynamic averageRating,
    @JsonKey(name: 'is_slot_available') final bool? isSlotAvailable,
    @JsonKey(name: 'trainers') final List<GymTrainer>? trainers,
  }) = _$FitnesscenterDetailsModelImpl;

  factory _FitnesscenterDetailsModel.fromJson(Map<String, dynamic> json) =
      _$FitnesscenterDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'is_public')
  bool? get isPublic;
  @override
  @JsonKey(name: 'active')
  bool? get active;
  @override
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed;
  @override
  @JsonKey(name: 'take_free_trial')
  bool? get takeFreeTrial;
  @override
  @JsonKey(name: 'is_on_free_trial')
  bool? get isOnFreeTrial;
  @override
  @JsonKey(name: 'location')
  Location? get location;
  @override
  @JsonKey(name: 'google_maps_url')
  String? get googleMapsUrl;
  @override
  @JsonKey(name: 'working_days')
  List<WorkingDay>? get workingDays;
  @override
  @JsonKey(name: 'time_slots')
  List<GymTimeSlot>? get timeSlots;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMedia>? get socialMedia;
  @override
  @JsonKey(name: 'amenities')
  List<Amenity>? get amenities;
  @override
  @JsonKey(name: 'categories')
  List<Amenity>? get categories;
  @override
  @JsonKey(name: 'photos')
  List<Photo>? get photos;
  @override
  @JsonKey(name: 'packages')
  List<Package>? get packages;
  @override
  @JsonKey(name: 'subscription_details')
  dynamic get subscriptionDetails;
  @override
  @JsonKey(name: 'birthday_wish_message')
  dynamic get birthdayWishMessage;
  @override
  @JsonKey(name: 'anniversary_wish_message')
  dynamic get anniversaryWishMessage;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  dynamic get averageRating;
  @override
  @JsonKey(name: 'is_slot_available')
  bool? get isSlotAvailable;
  @override
  @JsonKey(name: 'trainers')
  List<GymTrainer>? get trainers;

  /// Create a copy of FitnesscenterDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnesscenterDetailsModelImplCopyWith<_$FitnesscenterDetailsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Amenity _$AmenityFromJson(Map<String, dynamic> json) {
  return _Amenity.fromJson(json);
}

/// @nodoc
mixin _$Amenity {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this Amenity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Amenity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AmenityCopyWith<Amenity> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AmenityCopyWith<$Res> {
  factory $AmenityCopyWith(Amenity value, $Res Function(Amenity) then) =
      _$AmenityCopyWithImpl<$Res, Amenity>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class _$AmenityCopyWithImpl<$Res, $Val extends Amenity>
    implements $AmenityCopyWith<$Res> {
  _$AmenityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Amenity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AmenityImplCopyWith<$Res> implements $AmenityCopyWith<$Res> {
  factory _$$AmenityImplCopyWith(
    _$AmenityImpl value,
    $Res Function(_$AmenityImpl) then,
  ) = __$$AmenityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class __$$AmenityImplCopyWithImpl<$Res>
    extends _$AmenityCopyWithImpl<$Res, _$AmenityImpl>
    implements _$$AmenityImplCopyWith<$Res> {
  __$$AmenityImplCopyWithImpl(
    _$AmenityImpl _value,
    $Res Function(_$AmenityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Amenity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _$AmenityImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AmenityImpl implements _Amenity {
  const _$AmenityImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
  });

  factory _$AmenityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AmenityImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;

  @override
  String toString() {
    return 'Amenity(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AmenityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Amenity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AmenityImplCopyWith<_$AmenityImpl> get copyWith =>
      __$$AmenityImplCopyWithImpl<_$AmenityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AmenityImplToJson(this);
  }
}

abstract class _Amenity implements Amenity {
  const factory _Amenity({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
  }) = _$AmenityImpl;

  factory _Amenity.fromJson(Map<String, dynamic> json) = _$AmenityImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;

  /// Create a copy of Amenity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AmenityImplCopyWith<_$AmenityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Package _$PackageFromJson(Map<String, dynamic> json) {
  return _Package.fromJson(json);
}

/// @nodoc
mixin _$Package {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'package_type')
  String? get packageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_price')
  String? get actualPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'offer_price')
  String? get offerPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'features')
  List<dynamic>? get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable => throw _privateConstructorUsedError;

  /// Serializes this Package to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageCopyWith<Package> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageCopyWith<$Res> {
  factory $PackageCopyWith(Package value, $Res Function(Package) then) =
      _$PackageCopyWithImpl<$Res, Package>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$PackageCopyWithImpl<$Res, $Val extends Package>
    implements $PackageCopyWith<$Res> {
  _$PackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            packageType:
                freezed == packageType
                    ? _value.packageType
                    : packageType // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            actualPrice:
                freezed == actualPrice
                    ? _value.actualPrice
                    : actualPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            offerPrice:
                freezed == offerPrice
                    ? _value.offerPrice
                    : offerPrice // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationDays:
                freezed == durationDays
                    ? _value.durationDays
                    : durationDays // ignore: cast_nullable_to_non_nullable
                        as int?,
            features:
                freezed == features
                    ? _value.features
                    : features // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isEmiAvailable:
                freezed == isEmiAvailable
                    ? _value.isEmiAvailable
                    : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PackageImplCopyWith<$Res> implements $PackageCopyWith<$Res> {
  factory _$$PackageImplCopyWith(
    _$PackageImpl value,
    $Res Function(_$PackageImpl) then,
  ) = __$$PackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$PackageImplCopyWithImpl<$Res>
    extends _$PackageCopyWithImpl<$Res, _$PackageImpl>
    implements _$$PackageImplCopyWith<$Res> {
  __$$PackageImplCopyWithImpl(
    _$PackageImpl _value,
    $Res Function(_$PackageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? packageType = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? actualPrice = freezed,
    Object? offerPrice = freezed,
    Object? durationDays = freezed,
    Object? features = freezed,
    Object? isActive = freezed,
    Object? isEmiAvailable = freezed,
  }) {
    return _then(
      _$PackageImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        packageType:
            freezed == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        actualPrice:
            freezed == actualPrice
                ? _value.actualPrice
                : actualPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        offerPrice:
            freezed == offerPrice
                ? _value.offerPrice
                : offerPrice // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationDays:
            freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                    as int?,
        features:
            freezed == features
                ? _value._features
                : features // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isEmiAvailable:
            freezed == isEmiAvailable
                ? _value.isEmiAvailable
                : isEmiAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageImpl implements _Package {
  const _$PackageImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'package_type') this.packageType,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'actual_price') this.actualPrice,
    @JsonKey(name: 'offer_price') this.offerPrice,
    @JsonKey(name: 'duration_days') this.durationDays,
    @JsonKey(name: 'features') final List<dynamic>? features,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'is_emi_available') this.isEmiAvailable,
  }) : _features = features;

  factory _$PackageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'package_type')
  final String? packageType;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'actual_price')
  final String? actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  final String? offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  final List<dynamic>? _features;
  @override
  @JsonKey(name: 'features')
  List<dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  final bool? isEmiAvailable;

  @override
  String toString() {
    return 'Package(id: $id, packageType: $packageType, name: $name, description: $description, actualPrice: $actualPrice, offerPrice: $offerPrice, durationDays: $durationDays, features: $features, isActive: $isActive, isEmiAvailable: $isEmiAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actualPrice, actualPrice) ||
                other.actualPrice == actualPrice) &&
            (identical(other.offerPrice, offerPrice) ||
                other.offerPrice == offerPrice) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isEmiAvailable, isEmiAvailable) ||
                other.isEmiAvailable == isEmiAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    packageType,
    name,
    description,
    actualPrice,
    offerPrice,
    durationDays,
    const DeepCollectionEquality().hash(_features),
    isActive,
    isEmiAvailable,
  );

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageImplCopyWith<_$PackageImpl> get copyWith =>
      __$$PackageImplCopyWithImpl<_$PackageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageImplToJson(this);
  }
}

abstract class _Package implements Package {
  const factory _Package({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'package_type') final String? packageType,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'actual_price') final String? actualPrice,
    @JsonKey(name: 'offer_price') final String? offerPrice,
    @JsonKey(name: 'duration_days') final int? durationDays,
    @JsonKey(name: 'features') final List<dynamic>? features,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'is_emi_available') final bool? isEmiAvailable,
  }) = _$PackageImpl;

  factory _Package.fromJson(Map<String, dynamic> json) = _$PackageImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'package_type')
  String? get packageType;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'actual_price')
  String? get actualPrice;
  @override
  @JsonKey(name: 'offer_price')
  String? get offerPrice;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'features')
  List<dynamic>? get features;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'is_emi_available')
  bool? get isEmiAvailable;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageImplCopyWith<_$PackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image')
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'caption')
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool? get isPrimary => throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'caption') String? caption,
    @JsonKey(name: 'is_primary') bool? isPrimary,
  });
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? image = freezed,
    Object? caption = freezed,
    Object? isPrimary = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            image:
                freezed == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String?,
            caption:
                freezed == caption
                    ? _value.caption
                    : caption // ignore: cast_nullable_to_non_nullable
                        as String?,
            isPrimary:
                freezed == isPrimary
                    ? _value.isPrimary
                    : isPrimary // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
    _$PhotoImpl value,
    $Res Function(_$PhotoImpl) then,
  ) = __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'caption') String? caption,
    @JsonKey(name: 'is_primary') bool? isPrimary,
  });
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
    _$PhotoImpl _value,
    $Res Function(_$PhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? image = freezed,
    Object? caption = freezed,
    Object? isPrimary = freezed,
  }) {
    return _then(
      _$PhotoImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        image:
            freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String?,
        caption:
            freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                    as String?,
        isPrimary:
            freezed == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl implements _Photo {
  const _$PhotoImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'image') this.image,
    @JsonKey(name: 'caption') this.caption,
    @JsonKey(name: 'is_primary') this.isPrimary,
  });

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'image')
  final String? image;
  @override
  @JsonKey(name: 'caption')
  final String? caption;
  @override
  @JsonKey(name: 'is_primary')
  final bool? isPrimary;

  @override
  String toString() {
    return 'Photo(id: $id, image: $image, caption: $caption, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, image, caption, isPrimary);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(this);
  }
}

abstract class _Photo implements Photo {
  const factory _Photo({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'image') final String? image,
    @JsonKey(name: 'caption') final String? caption,
    @JsonKey(name: 'is_primary') final bool? isPrimary,
  }) = _$PhotoImpl;

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'image')
  String? get image;
  @override
  @JsonKey(name: 'caption')
  String? get caption;
  @override
  @JsonKey(name: 'is_primary')
  bool? get isPrimary;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SocialMedia _$SocialMediaFromJson(Map<String, dynamic> json) {
  return _SocialMedia.fromJson(json);
}

/// @nodoc
mixin _$SocialMedia {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform')
  String? get platform => throw _privateConstructorUsedError;
  @JsonKey(name: 'url')
  String? get url => throw _privateConstructorUsedError;

  /// Serializes this SocialMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialMediaCopyWith<SocialMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialMediaCopyWith<$Res> {
  factory $SocialMediaCopyWith(
    SocialMedia value,
    $Res Function(SocialMedia) then,
  ) = _$SocialMediaCopyWithImpl<$Res, SocialMedia>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'platform') String? platform,
    @JsonKey(name: 'url') String? url,
  });
}

/// @nodoc
class _$SocialMediaCopyWithImpl<$Res, $Val extends SocialMedia>
    implements $SocialMediaCopyWith<$Res> {
  _$SocialMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? platform = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            platform:
                freezed == platform
                    ? _value.platform
                    : platform // ignore: cast_nullable_to_non_nullable
                        as String?,
            url:
                freezed == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocialMediaImplCopyWith<$Res>
    implements $SocialMediaCopyWith<$Res> {
  factory _$$SocialMediaImplCopyWith(
    _$SocialMediaImpl value,
    $Res Function(_$SocialMediaImpl) then,
  ) = __$$SocialMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'platform') String? platform,
    @JsonKey(name: 'url') String? url,
  });
}

/// @nodoc
class __$$SocialMediaImplCopyWithImpl<$Res>
    extends _$SocialMediaCopyWithImpl<$Res, _$SocialMediaImpl>
    implements _$$SocialMediaImplCopyWith<$Res> {
  __$$SocialMediaImplCopyWithImpl(
    _$SocialMediaImpl _value,
    $Res Function(_$SocialMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? platform = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _$SocialMediaImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        platform:
            freezed == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                    as String?,
        url:
            freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialMediaImpl implements _SocialMedia {
  const _$SocialMediaImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'platform') this.platform,
    @JsonKey(name: 'url') this.url,
  });

  factory _$SocialMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialMediaImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'platform')
  final String? platform;
  @override
  @JsonKey(name: 'url')
  final String? url;

  @override
  String toString() {
    return 'SocialMedia(id: $id, platform: $platform, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialMediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, platform, url);

  /// Create a copy of SocialMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialMediaImplCopyWith<_$SocialMediaImpl> get copyWith =>
      __$$SocialMediaImplCopyWithImpl<_$SocialMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialMediaImplToJson(this);
  }
}

abstract class _SocialMedia implements SocialMedia {
  const factory _SocialMedia({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'platform') final String? platform,
    @JsonKey(name: 'url') final String? url,
  }) = _$SocialMediaImpl;

  factory _SocialMedia.fromJson(Map<String, dynamic> json) =
      _$SocialMediaImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'platform')
  String? get platform;
  @override
  @JsonKey(name: 'url')
  String? get url;

  /// Create a copy of SocialMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialMediaImplCopyWith<_$SocialMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkingDay _$WorkingDayFromJson(Map<String, dynamic> json) {
  return _WorkingDay.fromJson(json);
}

/// @nodoc
mixin _$WorkingDay {
  @JsonKey(name: 'day')
  String? get day => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_open')
  bool? get isOpen => throw _privateConstructorUsedError;
  @JsonKey(name: 'morning_opening_time')
  String? get morningOpeningTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'morning_closing_time')
  String? get morningClosingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'evening_opening_time')
  String? get eveningOpeningTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'evening_closing_time')
  String? get eveningClosingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'ladies_opening_time')
  String? get ladiesOpeningTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'ladies_closing_time')
  String? get ladiesClosingTime => throw _privateConstructorUsedError;

  /// Serializes this WorkingDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkingDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkingDayCopyWith<WorkingDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingDayCopyWith<$Res> {
  factory $WorkingDayCopyWith(
    WorkingDay value,
    $Res Function(WorkingDay) then,
  ) = _$WorkingDayCopyWithImpl<$Res, WorkingDay>;
  @useResult
  $Res call({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
    @JsonKey(name: 'ladies_opening_time') String? ladiesOpeningTime,
    @JsonKey(name: 'ladies_closing_time') String? ladiesClosingTime,
  });
}

/// @nodoc
class _$WorkingDayCopyWithImpl<$Res, $Val extends WorkingDay>
    implements $WorkingDayCopyWith<$Res> {
  _$WorkingDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkingDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = freezed,
    Object? isOpen = freezed,
    Object? morningOpeningTime = freezed,
    Object? morningClosingTime = freezed,
    Object? eveningOpeningTime = freezed,
    Object? eveningClosingTime = freezed,
    Object? ladiesOpeningTime = freezed,
    Object? ladiesClosingTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            day:
                freezed == day
                    ? _value.day
                    : day // ignore: cast_nullable_to_non_nullable
                        as String?,
            isOpen:
                freezed == isOpen
                    ? _value.isOpen
                    : isOpen // ignore: cast_nullable_to_non_nullable
                        as bool?,
            morningOpeningTime:
                freezed == morningOpeningTime
                    ? _value.morningOpeningTime
                    : morningOpeningTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            morningClosingTime:
                freezed == morningClosingTime
                    ? _value.morningClosingTime
                    : morningClosingTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            eveningOpeningTime:
                freezed == eveningOpeningTime
                    ? _value.eveningOpeningTime
                    : eveningOpeningTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            eveningClosingTime:
                freezed == eveningClosingTime
                    ? _value.eveningClosingTime
                    : eveningClosingTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            ladiesOpeningTime:
                freezed == ladiesOpeningTime
                    ? _value.ladiesOpeningTime
                    : ladiesOpeningTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            ladiesClosingTime:
                freezed == ladiesClosingTime
                    ? _value.ladiesClosingTime
                    : ladiesClosingTime // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkingDayImplCopyWith<$Res>
    implements $WorkingDayCopyWith<$Res> {
  factory _$$WorkingDayImplCopyWith(
    _$WorkingDayImpl value,
    $Res Function(_$WorkingDayImpl) then,
  ) = __$$WorkingDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
    @JsonKey(name: 'ladies_opening_time') String? ladiesOpeningTime,
    @JsonKey(name: 'ladies_closing_time') String? ladiesClosingTime,
  });
}

/// @nodoc
class __$$WorkingDayImplCopyWithImpl<$Res>
    extends _$WorkingDayCopyWithImpl<$Res, _$WorkingDayImpl>
    implements _$$WorkingDayImplCopyWith<$Res> {
  __$$WorkingDayImplCopyWithImpl(
    _$WorkingDayImpl _value,
    $Res Function(_$WorkingDayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkingDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = freezed,
    Object? isOpen = freezed,
    Object? morningOpeningTime = freezed,
    Object? morningClosingTime = freezed,
    Object? eveningOpeningTime = freezed,
    Object? eveningClosingTime = freezed,
    Object? ladiesOpeningTime = freezed,
    Object? ladiesClosingTime = freezed,
  }) {
    return _then(
      _$WorkingDayImpl(
        day:
            freezed == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                    as String?,
        isOpen:
            freezed == isOpen
                ? _value.isOpen
                : isOpen // ignore: cast_nullable_to_non_nullable
                    as bool?,
        morningOpeningTime:
            freezed == morningOpeningTime
                ? _value.morningOpeningTime
                : morningOpeningTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        morningClosingTime:
            freezed == morningClosingTime
                ? _value.morningClosingTime
                : morningClosingTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        eveningOpeningTime:
            freezed == eveningOpeningTime
                ? _value.eveningOpeningTime
                : eveningOpeningTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        eveningClosingTime:
            freezed == eveningClosingTime
                ? _value.eveningClosingTime
                : eveningClosingTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        ladiesOpeningTime:
            freezed == ladiesOpeningTime
                ? _value.ladiesOpeningTime
                : ladiesOpeningTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        ladiesClosingTime:
            freezed == ladiesClosingTime
                ? _value.ladiesClosingTime
                : ladiesClosingTime // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingDayImpl implements _WorkingDay {
  const _$WorkingDayImpl({
    @JsonKey(name: 'day') this.day,
    @JsonKey(name: 'is_open') this.isOpen,
    @JsonKey(name: 'morning_opening_time') this.morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') this.morningClosingTime,
    @JsonKey(name: 'evening_opening_time') this.eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') this.eveningClosingTime,
    @JsonKey(name: 'ladies_opening_time') this.ladiesOpeningTime,
    @JsonKey(name: 'ladies_closing_time') this.ladiesClosingTime,
  });

  factory _$WorkingDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingDayImplFromJson(json);

  @override
  @JsonKey(name: 'day')
  final String? day;
  @override
  @JsonKey(name: 'is_open')
  final bool? isOpen;
  @override
  @JsonKey(name: 'morning_opening_time')
  final String? morningOpeningTime;
  @override
  @JsonKey(name: 'morning_closing_time')
  final String? morningClosingTime;
  @override
  @JsonKey(name: 'evening_opening_time')
  final String? eveningOpeningTime;
  @override
  @JsonKey(name: 'evening_closing_time')
  final String? eveningClosingTime;
  @override
  @JsonKey(name: 'ladies_opening_time')
  final String? ladiesOpeningTime;
  @override
  @JsonKey(name: 'ladies_closing_time')
  final String? ladiesClosingTime;

  @override
  String toString() {
    return 'WorkingDay(day: $day, isOpen: $isOpen, morningOpeningTime: $morningOpeningTime, morningClosingTime: $morningClosingTime, eveningOpeningTime: $eveningOpeningTime, eveningClosingTime: $eveningClosingTime, ladiesOpeningTime: $ladiesOpeningTime, ladiesClosingTime: $ladiesClosingTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingDayImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.morningOpeningTime, morningOpeningTime) ||
                other.morningOpeningTime == morningOpeningTime) &&
            (identical(other.morningClosingTime, morningClosingTime) ||
                other.morningClosingTime == morningClosingTime) &&
            (identical(other.eveningOpeningTime, eveningOpeningTime) ||
                other.eveningOpeningTime == eveningOpeningTime) &&
            (identical(other.eveningClosingTime, eveningClosingTime) ||
                other.eveningClosingTime == eveningClosingTime) &&
            (identical(other.ladiesOpeningTime, ladiesOpeningTime) ||
                other.ladiesOpeningTime == ladiesOpeningTime) &&
            (identical(other.ladiesClosingTime, ladiesClosingTime) ||
                other.ladiesClosingTime == ladiesClosingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    day,
    isOpen,
    morningOpeningTime,
    morningClosingTime,
    eveningOpeningTime,
    eveningClosingTime,
    ladiesOpeningTime,
    ladiesClosingTime,
  );

  /// Create a copy of WorkingDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingDayImplCopyWith<_$WorkingDayImpl> get copyWith =>
      __$$WorkingDayImplCopyWithImpl<_$WorkingDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingDayImplToJson(this);
  }
}

abstract class _WorkingDay implements WorkingDay {
  const factory _WorkingDay({
    @JsonKey(name: 'day') final String? day,
    @JsonKey(name: 'is_open') final bool? isOpen,
    @JsonKey(name: 'morning_opening_time') final String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') final String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') final String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') final String? eveningClosingTime,
    @JsonKey(name: 'ladies_opening_time') final String? ladiesOpeningTime,
    @JsonKey(name: 'ladies_closing_time') final String? ladiesClosingTime,
  }) = _$WorkingDayImpl;

  factory _WorkingDay.fromJson(Map<String, dynamic> json) =
      _$WorkingDayImpl.fromJson;

  @override
  @JsonKey(name: 'day')
  String? get day;
  @override
  @JsonKey(name: 'is_open')
  bool? get isOpen;
  @override
  @JsonKey(name: 'morning_opening_time')
  String? get morningOpeningTime;
  @override
  @JsonKey(name: 'morning_closing_time')
  String? get morningClosingTime;
  @override
  @JsonKey(name: 'evening_opening_time')
  String? get eveningOpeningTime;
  @override
  @JsonKey(name: 'evening_closing_time')
  String? get eveningClosingTime;
  @override
  @JsonKey(name: 'ladies_opening_time')
  String? get ladiesOpeningTime;
  @override
  @JsonKey(name: 'ladies_closing_time')
  String? get ladiesClosingTime;

  /// Create a copy of WorkingDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkingDayImplCopyWith<_$WorkingDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GymTimeSlot _$GymTimeSlotFromJson(Map<String, dynamic> json) {
  return _GymTimeSlot.fromJson(json);
}

/// @nodoc
mixin _$GymTimeSlot {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String? get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_currently_active')
  bool? get isCurrentlyActive => throw _privateConstructorUsedError;

  /// Serializes this GymTimeSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GymTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymTimeSlotCopyWith<GymTimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymTimeSlotCopyWith<$Res> {
  factory $GymTimeSlotCopyWith(
    GymTimeSlot value,
    $Res Function(GymTimeSlot) then,
  ) = _$GymTimeSlotCopyWithImpl<$Res, GymTimeSlot>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_currently_active') bool? isCurrentlyActive,
  });
}

/// @nodoc
class _$GymTimeSlotCopyWithImpl<$Res, $Val extends GymTimeSlot>
    implements $GymTimeSlotCopyWith<$Res> {
  _$GymTimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isActive = freezed,
    Object? isCurrentlyActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            startTime:
                freezed == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            endTime:
                freezed == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isCurrentlyActive:
                freezed == isCurrentlyActive
                    ? _value.isCurrentlyActive
                    : isCurrentlyActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymTimeSlotImplCopyWith<$Res>
    implements $GymTimeSlotCopyWith<$Res> {
  factory _$$GymTimeSlotImplCopyWith(
    _$GymTimeSlotImpl value,
    $Res Function(_$GymTimeSlotImpl) then,
  ) = __$$GymTimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_currently_active') bool? isCurrentlyActive,
  });
}

/// @nodoc
class __$$GymTimeSlotImplCopyWithImpl<$Res>
    extends _$GymTimeSlotCopyWithImpl<$Res, _$GymTimeSlotImpl>
    implements _$$GymTimeSlotImplCopyWith<$Res> {
  __$$GymTimeSlotImplCopyWithImpl(
    _$GymTimeSlotImpl _value,
    $Res Function(_$GymTimeSlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isActive = freezed,
    Object? isCurrentlyActive = freezed,
  }) {
    return _then(
      _$GymTimeSlotImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        startTime:
            freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        endTime:
            freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isCurrentlyActive:
            freezed == isCurrentlyActive
                ? _value.isCurrentlyActive
                : isCurrentlyActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GymTimeSlotImpl implements _GymTimeSlot {
  const _$GymTimeSlotImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'start_time') this.startTime,
    @JsonKey(name: 'end_time') this.endTime,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'is_currently_active') this.isCurrentlyActive,
  });

  factory _$GymTimeSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$GymTimeSlotImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'start_time')
  final String? startTime;
  @override
  @JsonKey(name: 'end_time')
  final String? endTime;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'is_currently_active')
  final bool? isCurrentlyActive;

  @override
  String toString() {
    return 'GymTimeSlot(id: $id, name: $name, startTime: $startTime, endTime: $endTime, isActive: $isActive, isCurrentlyActive: $isCurrentlyActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymTimeSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isCurrentlyActive, isCurrentlyActive) ||
                other.isCurrentlyActive == isCurrentlyActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    startTime,
    endTime,
    isActive,
    isCurrentlyActive,
  );

  /// Create a copy of GymTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymTimeSlotImplCopyWith<_$GymTimeSlotImpl> get copyWith =>
      __$$GymTimeSlotImplCopyWithImpl<_$GymTimeSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GymTimeSlotImplToJson(this);
  }
}

abstract class _GymTimeSlot implements GymTimeSlot {
  const factory _GymTimeSlot({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'start_time') final String? startTime,
    @JsonKey(name: 'end_time') final String? endTime,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'is_currently_active') final bool? isCurrentlyActive,
  }) = _$GymTimeSlotImpl;

  factory _GymTimeSlot.fromJson(Map<String, dynamic> json) =
      _$GymTimeSlotImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'start_time')
  String? get startTime;
  @override
  @JsonKey(name: 'end_time')
  String? get endTime;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'is_currently_active')
  bool? get isCurrentlyActive;

  /// Create a copy of GymTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymTimeSlotImplCopyWith<_$GymTimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GymTrainer _$GymTrainerFromJson(Map<String, dynamic> json) {
  return _GymTrainer.fromJson(json);
}

/// @nodoc
mixin _$GymTrainer {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String? get userType => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio')
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience_years')
  int? get experienceYears => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  dynamic get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'specializations')
  List<String>? get specializations => throw _privateConstructorUsedError;
  @JsonKey(name: 'clients_count')
  int? get clientsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_workouts_count')
  int? get verifiedWorkoutsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'transformations')
  List<GymTransformation>? get transformations =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'certifications')
  List<Certification>? get certifications => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile')
  String? get mobile => throw _privateConstructorUsedError;
  @JsonKey(name: 'gender')
  String? get gender => throw _privateConstructorUsedError;

  /// Serializes this GymTrainer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GymTrainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymTrainerCopyWith<GymTrainer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymTrainerCopyWith<$Res> {
  factory $GymTrainerCopyWith(
    GymTrainer value,
    $Res Function(GymTrainer) then,
  ) = _$GymTrainerCopyWithImpl<$Res, GymTrainer>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$GymTrainerCopyWithImpl<$Res, $Val extends GymTrainer>
    implements $GymTrainerCopyWith<$Res> {
  _$GymTrainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymTrainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fullName = freezed,
    Object? userType = freezed,
    Object? bio = freezed,
    Object? profileImage = freezed,
    Object? experienceYears = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = freezed,
    Object? specializations = freezed,
    Object? clientsCount = freezed,
    Object? verifiedWorkoutsCount = freezed,
    Object? transformations = freezed,
    Object? certifications = freezed,
    Object? email = freezed,
    Object? mobile = freezed,
    Object? gender = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            fullName:
                freezed == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String?,
            userType:
                freezed == userType
                    ? _value.userType
                    : userType // ignore: cast_nullable_to_non_nullable
                        as String?,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            profileImage:
                freezed == profileImage
                    ? _value.profileImage
                    : profileImage // ignore: cast_nullable_to_non_nullable
                        as String?,
            experienceYears:
                freezed == experienceYears
                    ? _value.experienceYears
                    : experienceYears // ignore: cast_nullable_to_non_nullable
                        as int?,
            averageRating:
                freezed == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            specializations:
                freezed == specializations
                    ? _value.specializations
                    : specializations // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            clientsCount:
                freezed == clientsCount
                    ? _value.clientsCount
                    : clientsCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            verifiedWorkoutsCount:
                freezed == verifiedWorkoutsCount
                    ? _value.verifiedWorkoutsCount
                    : verifiedWorkoutsCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            transformations:
                freezed == transformations
                    ? _value.transformations
                    : transformations // ignore: cast_nullable_to_non_nullable
                        as List<GymTransformation>?,
            certifications:
                freezed == certifications
                    ? _value.certifications
                    : certifications // ignore: cast_nullable_to_non_nullable
                        as List<Certification>?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobile:
                freezed == mobile
                    ? _value.mobile
                    : mobile // ignore: cast_nullable_to_non_nullable
                        as String?,
            gender:
                freezed == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymTrainerImplCopyWith<$Res>
    implements $GymTrainerCopyWith<$Res> {
  factory _$$GymTrainerImplCopyWith(
    _$GymTrainerImpl value,
    $Res Function(_$GymTrainerImpl) then,
  ) = __$$GymTrainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$GymTrainerImplCopyWithImpl<$Res>
    extends _$GymTrainerCopyWithImpl<$Res, _$GymTrainerImpl>
    implements _$$GymTrainerImplCopyWith<$Res> {
  __$$GymTrainerImplCopyWithImpl(
    _$GymTrainerImpl _value,
    $Res Function(_$GymTrainerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymTrainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fullName = freezed,
    Object? userType = freezed,
    Object? bio = freezed,
    Object? profileImage = freezed,
    Object? experienceYears = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = freezed,
    Object? specializations = freezed,
    Object? clientsCount = freezed,
    Object? verifiedWorkoutsCount = freezed,
    Object? transformations = freezed,
    Object? certifications = freezed,
    Object? email = freezed,
    Object? mobile = freezed,
    Object? gender = freezed,
  }) {
    return _then(
      _$GymTrainerImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        fullName:
            freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String?,
        userType:
            freezed == userType
                ? _value.userType
                : userType // ignore: cast_nullable_to_non_nullable
                    as String?,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        profileImage:
            freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                    as String?,
        experienceYears:
            freezed == experienceYears
                ? _value.experienceYears
                : experienceYears // ignore: cast_nullable_to_non_nullable
                    as int?,
        averageRating:
            freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        specializations:
            freezed == specializations
                ? _value._specializations
                : specializations // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        clientsCount:
            freezed == clientsCount
                ? _value.clientsCount
                : clientsCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        verifiedWorkoutsCount:
            freezed == verifiedWorkoutsCount
                ? _value.verifiedWorkoutsCount
                : verifiedWorkoutsCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        transformations:
            freezed == transformations
                ? _value._transformations
                : transformations // ignore: cast_nullable_to_non_nullable
                    as List<GymTransformation>?,
        certifications:
            freezed == certifications
                ? _value._certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                    as List<Certification>?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobile:
            freezed == mobile
                ? _value.mobile
                : mobile // ignore: cast_nullable_to_non_nullable
                    as String?,
        gender:
            freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GymTrainerImpl implements _GymTrainer {
  const _$GymTrainerImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'full_name') this.fullName,
    @JsonKey(name: 'user_type') this.userType,
    @JsonKey(name: 'bio') this.bio,
    @JsonKey(name: 'profile_image') this.profileImage,
    @JsonKey(name: 'experience_years') this.experienceYears,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'specializations') final List<String>? specializations,
    @JsonKey(name: 'clients_count') this.clientsCount,
    @JsonKey(name: 'verified_workouts_count') this.verifiedWorkoutsCount,
    @JsonKey(name: 'transformations')
    final List<GymTransformation>? transformations,
    @JsonKey(name: 'certifications') final List<Certification>? certifications,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'mobile') this.mobile,
    @JsonKey(name: 'gender') this.gender,
  }) : _specializations = specializations,
       _transformations = transformations,
       _certifications = certifications;

  factory _$GymTrainerImpl.fromJson(Map<String, dynamic> json) =>
      _$$GymTrainerImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'user_type')
  final String? userType;
  @override
  @JsonKey(name: 'bio')
  final String? bio;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @override
  @JsonKey(name: 'experience_years')
  final int? experienceYears;
  @override
  @JsonKey(name: 'average_rating')
  final dynamic averageRating;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  final List<String>? _specializations;
  @override
  @JsonKey(name: 'specializations')
  List<String>? get specializations {
    final value = _specializations;
    if (value == null) return null;
    if (_specializations is EqualUnmodifiableListView) return _specializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'clients_count')
  final int? clientsCount;
  @override
  @JsonKey(name: 'verified_workouts_count')
  final int? verifiedWorkoutsCount;
  final List<GymTransformation>? _transformations;
  @override
  @JsonKey(name: 'transformations')
  List<GymTransformation>? get transformations {
    final value = _transformations;
    if (value == null) return null;
    if (_transformations is EqualUnmodifiableListView) return _transformations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Certification>? _certifications;
  @override
  @JsonKey(name: 'certifications')
  List<Certification>? get certifications {
    final value = _certifications;
    if (value == null) return null;
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'mobile')
  final String? mobile;
  @override
  @JsonKey(name: 'gender')
  final String? gender;

  @override
  String toString() {
    return 'GymTrainer(id: $id, fullName: $fullName, userType: $userType, bio: $bio, profileImage: $profileImage, experienceYears: $experienceYears, averageRating: $averageRating, reviewCount: $reviewCount, specializations: $specializations, clientsCount: $clientsCount, verifiedWorkoutsCount: $verifiedWorkoutsCount, transformations: $transformations, certifications: $certifications, email: $email, mobile: $mobile, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymTrainerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            const DeepCollectionEquality().equals(
              other.averageRating,
              averageRating,
            ) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            const DeepCollectionEquality().equals(
              other._specializations,
              _specializations,
            ) &&
            (identical(other.clientsCount, clientsCount) ||
                other.clientsCount == clientsCount) &&
            (identical(other.verifiedWorkoutsCount, verifiedWorkoutsCount) ||
                other.verifiedWorkoutsCount == verifiedWorkoutsCount) &&
            const DeepCollectionEquality().equals(
              other._transformations,
              _transformations,
            ) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.gender, gender) || other.gender == gender));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    userType,
    bio,
    profileImage,
    experienceYears,
    const DeepCollectionEquality().hash(averageRating),
    reviewCount,
    const DeepCollectionEquality().hash(_specializations),
    clientsCount,
    verifiedWorkoutsCount,
    const DeepCollectionEquality().hash(_transformations),
    const DeepCollectionEquality().hash(_certifications),
    email,
    mobile,
    gender,
  );

  /// Create a copy of GymTrainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymTrainerImplCopyWith<_$GymTrainerImpl> get copyWith =>
      __$$GymTrainerImplCopyWithImpl<_$GymTrainerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GymTrainerImplToJson(this);
  }
}

abstract class _GymTrainer implements GymTrainer {
  const factory _GymTrainer({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'full_name') final String? fullName,
    @JsonKey(name: 'user_type') final String? userType,
    @JsonKey(name: 'bio') final String? bio,
    @JsonKey(name: 'profile_image') final String? profileImage,
    @JsonKey(name: 'experience_years') final int? experienceYears,
    @JsonKey(name: 'average_rating') final dynamic averageRating,
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'specializations') final List<String>? specializations,
    @JsonKey(name: 'clients_count') final int? clientsCount,
    @JsonKey(name: 'verified_workouts_count') final int? verifiedWorkoutsCount,
    @JsonKey(name: 'transformations')
    final List<GymTransformation>? transformations,
    @JsonKey(name: 'certifications') final List<Certification>? certifications,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'mobile') final String? mobile,
    @JsonKey(name: 'gender') final String? gender,
  }) = _$GymTrainerImpl;

  factory _GymTrainer.fromJson(Map<String, dynamic> json) =
      _$GymTrainerImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'user_type')
  String? get userType;
  @override
  @JsonKey(name: 'bio')
  String? get bio;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  @JsonKey(name: 'experience_years')
  int? get experienceYears;
  @override
  @JsonKey(name: 'average_rating')
  dynamic get averageRating;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'specializations')
  List<String>? get specializations;
  @override
  @JsonKey(name: 'clients_count')
  int? get clientsCount;
  @override
  @JsonKey(name: 'verified_workouts_count')
  int? get verifiedWorkoutsCount;
  @override
  @JsonKey(name: 'transformations')
  List<GymTransformation>? get transformations;
  @override
  @JsonKey(name: 'certifications')
  List<Certification>? get certifications;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'mobile')
  String? get mobile;
  @override
  @JsonKey(name: 'gender')
  String? get gender;

  /// Create a copy of GymTrainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymTrainerImplCopyWith<_$GymTrainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GymTransformation _$GymTransformationFromJson(Map<String, dynamic> json) {
  return _GymTransformation.fromJson(json);
}

/// @nodoc
mixin _$GymTransformation {
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'before_image')
  String? get beforeImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'after_image')
  String? get afterImage => throw _privateConstructorUsedError;

  /// Serializes this GymTransformation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GymTransformation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymTransformationCopyWith<GymTransformation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymTransformationCopyWith<$Res> {
  factory $GymTransformationCopyWith(
    GymTransformation value,
    $Res Function(GymTransformation) then,
  ) = _$GymTransformationCopyWithImpl<$Res, GymTransformation>;
  @useResult
  $Res call({
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'before_image') String? beforeImage,
    @JsonKey(name: 'after_image') String? afterImage,
  });
}

/// @nodoc
class _$GymTransformationCopyWithImpl<$Res, $Val extends GymTransformation>
    implements $GymTransformationCopyWith<$Res> {
  _$GymTransformationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymTransformation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? beforeImage = freezed,
    Object? afterImage = freezed,
  }) {
    return _then(
      _value.copyWith(
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            beforeImage:
                freezed == beforeImage
                    ? _value.beforeImage
                    : beforeImage // ignore: cast_nullable_to_non_nullable
                        as String?,
            afterImage:
                freezed == afterImage
                    ? _value.afterImage
                    : afterImage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymTransformationImplCopyWith<$Res>
    implements $GymTransformationCopyWith<$Res> {
  factory _$$GymTransformationImplCopyWith(
    _$GymTransformationImpl value,
    $Res Function(_$GymTransformationImpl) then,
  ) = __$$GymTransformationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'before_image') String? beforeImage,
    @JsonKey(name: 'after_image') String? afterImage,
  });
}

/// @nodoc
class __$$GymTransformationImplCopyWithImpl<$Res>
    extends _$GymTransformationCopyWithImpl<$Res, _$GymTransformationImpl>
    implements _$$GymTransformationImplCopyWith<$Res> {
  __$$GymTransformationImplCopyWithImpl(
    _$GymTransformationImpl _value,
    $Res Function(_$GymTransformationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymTransformation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? beforeImage = freezed,
    Object? afterImage = freezed,
  }) {
    return _then(
      _$GymTransformationImpl(
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        beforeImage:
            freezed == beforeImage
                ? _value.beforeImage
                : beforeImage // ignore: cast_nullable_to_non_nullable
                    as String?,
        afterImage:
            freezed == afterImage
                ? _value.afterImage
                : afterImage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GymTransformationImpl implements _GymTransformation {
  const _$GymTransformationImpl({
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'before_image') this.beforeImage,
    @JsonKey(name: 'after_image') this.afterImage,
  });

  factory _$GymTransformationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GymTransformationImplFromJson(json);

  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'before_image')
  final String? beforeImage;
  @override
  @JsonKey(name: 'after_image')
  final String? afterImage;

  @override
  String toString() {
    return 'GymTransformation(description: $description, beforeImage: $beforeImage, afterImage: $afterImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymTransformationImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.beforeImage, beforeImage) ||
                other.beforeImage == beforeImage) &&
            (identical(other.afterImage, afterImage) ||
                other.afterImage == afterImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, description, beforeImage, afterImage);

  /// Create a copy of GymTransformation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymTransformationImplCopyWith<_$GymTransformationImpl> get copyWith =>
      __$$GymTransformationImplCopyWithImpl<_$GymTransformationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GymTransformationImplToJson(this);
  }
}

abstract class _GymTransformation implements GymTransformation {
  const factory _GymTransformation({
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'before_image') final String? beforeImage,
    @JsonKey(name: 'after_image') final String? afterImage,
  }) = _$GymTransformationImpl;

  factory _GymTransformation.fromJson(Map<String, dynamic> json) =
      _$GymTransformationImpl.fromJson;

  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'before_image')
  String? get beforeImage;
  @override
  @JsonKey(name: 'after_image')
  String? get afterImage;

  /// Create a copy of GymTransformation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymTransformationImplCopyWith<_$GymTransformationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Certification _$CertificationFromJson(Map<String, dynamic> json) {
  return _Certification.fromJson(json);
}

/// @nodoc
mixin _$Certification {
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'issued_by')
  String? get issuedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'issued_date')
  String? get issuedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_url')
  String? get fileUrl => throw _privateConstructorUsedError;

  /// Serializes this Certification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificationCopyWith<Certification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificationCopyWith<$Res> {
  factory $CertificationCopyWith(
    Certification value,
    $Res Function(Certification) then,
  ) = _$CertificationCopyWithImpl<$Res, Certification>;
  @useResult
  $Res call({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'issued_by') String? issuedBy,
    @JsonKey(name: 'issued_date') String? issuedDate,
    @JsonKey(name: 'file_url') String? fileUrl,
  });
}

/// @nodoc
class _$CertificationCopyWithImpl<$Res, $Val extends Certification>
    implements $CertificationCopyWith<$Res> {
  _$CertificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? issuedBy = freezed,
    Object? issuedDate = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            issuedBy:
                freezed == issuedBy
                    ? _value.issuedBy
                    : issuedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            issuedDate:
                freezed == issuedDate
                    ? _value.issuedDate
                    : issuedDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            fileUrl:
                freezed == fileUrl
                    ? _value.fileUrl
                    : fileUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificationImplCopyWith<$Res>
    implements $CertificationCopyWith<$Res> {
  factory _$$CertificationImplCopyWith(
    _$CertificationImpl value,
    $Res Function(_$CertificationImpl) then,
  ) = __$$CertificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'issued_by') String? issuedBy,
    @JsonKey(name: 'issued_date') String? issuedDate,
    @JsonKey(name: 'file_url') String? fileUrl,
  });
}

/// @nodoc
class __$$CertificationImplCopyWithImpl<$Res>
    extends _$CertificationCopyWithImpl<$Res, _$CertificationImpl>
    implements _$$CertificationImplCopyWith<$Res> {
  __$$CertificationImplCopyWithImpl(
    _$CertificationImpl _value,
    $Res Function(_$CertificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? issuedBy = freezed,
    Object? issuedDate = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(
      _$CertificationImpl(
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        issuedBy:
            freezed == issuedBy
                ? _value.issuedBy
                : issuedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        issuedDate:
            freezed == issuedDate
                ? _value.issuedDate
                : issuedDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        fileUrl:
            freezed == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificationImpl implements _Certification {
  const _$CertificationImpl({
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'issued_by') this.issuedBy,
    @JsonKey(name: 'issued_date') this.issuedDate,
    @JsonKey(name: 'file_url') this.fileUrl,
  });

  factory _$CertificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificationImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'issued_by')
  final String? issuedBy;
  @override
  @JsonKey(name: 'issued_date')
  final String? issuedDate;
  @override
  @JsonKey(name: 'file_url')
  final String? fileUrl;

  @override
  String toString() {
    return 'Certification(name: $name, issuedBy: $issuedBy, issuedDate: $issuedDate, fileUrl: $fileUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issuedBy, issuedBy) ||
                other.issuedBy == issuedBy) &&
            (identical(other.issuedDate, issuedDate) ||
                other.issuedDate == issuedDate) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, issuedBy, issuedDate, fileUrl);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      __$$CertificationImplCopyWithImpl<_$CertificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificationImplToJson(this);
  }
}

abstract class _Certification implements Certification {
  const factory _Certification({
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'issued_by') final String? issuedBy,
    @JsonKey(name: 'issued_date') final String? issuedDate,
    @JsonKey(name: 'file_url') final String? fileUrl,
  }) = _$CertificationImpl;

  factory _Certification.fromJson(Map<String, dynamic> json) =
      _$CertificationImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'issued_by')
  String? get issuedBy;
  @override
  @JsonKey(name: 'issued_date')
  String? get issuedDate;
  @override
  @JsonKey(name: 'file_url')
  String? get fileUrl;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
