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

  factory FitnesscenterDetailsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(json);
    if (map['trainers'] != null && map['trainers'] is List) {
      map['trainers'] = (map['trainers'] as List).map((t) {
        if (t is Map) {
          final tMap = Map<String, dynamic>.from(t);
          return GymTrainer.fromApiJson(tMap).toJson();
        }
        return t;
      }).toList();
    }
    return _$FitnesscenterDetailsModelFromJson(map);
  }
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
    @JsonKey(name: 'banner_image') String? bannerImage,
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
    @JsonKey(name: 'place') String? place,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'social_media') List<SocialMedia>? socialMedia,
  }) = _GymTrainer;

  factory GymTrainer.fromJson(Map<String, dynamic> json) => _$GymTrainerFromJson(json);

  static GymTrainer fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(json);

    if (!map.containsKey('full_name') || map['full_name'] == null || (map['full_name'] as String).isEmpty) {
      final firstName = map['first_name']?.toString() ?? '';
      final lastName = map['last_name']?.toString() ?? '';
      final name = '$firstName $lastName'.trim();
      if (name.isNotEmpty) {
        map['full_name'] = name;
      }
    }

    if (map['average_rating'] == null && map.containsKey('rating')) {
      map['average_rating'] = map['rating'];
    }

    if (map['review_count'] == null && map.containsKey('ratings_count')) {
      map['review_count'] = map['ratings_count'];
    }

    if ((map['social_media'] == null || (map['social_media'] is List && (map['social_media'] as List).isEmpty)) &&
        map['social_links'] != null &&
        map['social_links'] is Map) {
      final Map<String, dynamic> links = map['social_links'] as Map<String, dynamic>;
      final List<Map<String, dynamic>> socialList = [];
      links.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          socialList.add({
            'platform': key,
            'url': value.toString(),
          });
        }
      });
      map['social_media'] = socialList;
    }

    if ((map['place'] == null || map['place'].toString().trim().isEmpty) && map['location'] == null) {
      if (map['address'] != null && map['address'].toString().trim().isNotEmpty) {
        map['place'] = map['address'].toString().trim();
      } else if (map['city'] != null && map['city'].toString().trim().isNotEmpty) {
        map['place'] = map['city'].toString().trim();
      } else if (map['area'] != null && map['area'].toString().trim().isNotEmpty) {
        map['place'] = map['area'].toString().trim();
      }
    }

    if (!map.containsKey('bio') || map['bio'] == null || map['bio'].toString().trim().isEmpty) {
      if (map['description'] != null && map['description'].toString().trim().isNotEmpty) {
        map['bio'] = map['description'].toString().trim();
      } else if (map['about'] != null && map['about'].toString().trim().isNotEmpty) {
        map['bio'] = map['about'].toString().trim();
      }
    }

    if (map['mobile'] == null || map['mobile'].toString().trim().isEmpty) {
      map['mobile'] = map['mobile_number'] ?? map['phone_number'] ?? map['phone'];
    }

    int? clientsCount = (map['clients_count'] as num?)?.toInt() ??
        int.tryParse(map['clients_count']?.toString() ?? '') ??
        (map['client_count'] as num?)?.toInt() ??
        int.tryParse(map['client_count']?.toString() ?? '') ??
        (map['total_clients'] as num?)?.toInt() ??
        int.tryParse(map['total_clients']?.toString() ?? '') ??
        (map['active_clients'] as num?)?.toInt() ??
        (map['assigned_clients_count'] as num?)?.toInt();

    if (clientsCount == null) {
      if (map['clients'] is num) {
        clientsCount = (map['clients'] as num).toInt();
      } else if (map['clients'] is String) {
        clientsCount = int.tryParse(map['clients'].toString());
      } else if (map['clients'] is List) {
        clientsCount = (map['clients'] as List).length;
      } else if (map['assigned_clients'] is List) {
        clientsCount = (map['assigned_clients'] as List).length;
      } else if (map['customers'] is List) {
        clientsCount = (map['customers'] as List).length;
      }
    }
    if (clientsCount != null) {
      map['clients_count'] = clientsCount;
    }

    int? workoutsCount = (map['verified_workouts_count'] as num?)?.toInt() ??
        int.tryParse(map['verified_workouts_count']?.toString() ?? '') ??
        (map['verified_workouts'] as num?)?.toInt() ??
        int.tryParse(map['verified_workouts']?.toString() ?? '') ??
        (map['workouts_count'] as num?)?.toInt();
    if (workoutsCount == null) {
      if (map['workouts'] is num) {
        workoutsCount = (map['workouts'] as num).toInt();
      } else if (map['workouts'] is List) {
        workoutsCount = (map['workouts'] as List).length;
      }
    }
    if (workoutsCount != null) {
      map['verified_workouts_count'] = workoutsCount;
    }

    if (map['specializations'] == null || (map['specializations'] is List && (map['specializations'] as List).isEmpty)) {
      if (map['specialization'] != null) {
        if (map['specialization'] is List) {
          map['specializations'] = map['specialization'];
        } else if (map['specialization'] is String && (map['specialization'] as String).trim().isNotEmpty) {
          map['specializations'] = [(map['specialization'] as String).trim()];
        }
      } else if (map['skills'] != null && map['skills'] is List) {
        map['specializations'] = map['skills'];
      }
    }

    if (map['specializations'] != null && map['specializations'] is List) {
      map['specializations'] = (map['specializations'] as List)
          .map((s) => s is Map ? (s['name'] ?? s['title'] ?? '').toString() : s.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (map['certifications'] != null && map['certifications'] is List) {
      final certsList = (map['certifications'] as List).map((c) {
        if (c is Map) {
          final cMap = Map<String, dynamic>.from(c);
          return Certification.fromApiJson(cMap).toJson();
        }
        return c;
      }).toList();
      map['certifications'] = certsList;
    }

    try {
      return GymTrainer.fromJson(map);
    } catch (e) {
      return GymTrainer(
        id: (map['id'] as num?)?.toInt(),
        fullName: map['full_name']?.toString() ?? map['name']?.toString(),
        userType: map['user_type']?.toString() ?? 'Trainer',
        bio: map['bio']?.toString(),
        profileImage: map['profile_image']?.toString(),
        bannerImage: map['banner_image']?.toString(),
        experienceYears: (map['experience_years'] as num?)?.toInt(),
        averageRating: map['average_rating'],
        reviewCount: (map['review_count'] as num?)?.toInt(),
        specializations: (map['specializations'] is List)
            ? (map['specializations'] as List).map((e) => e.toString()).toList()
            : null,
        clientsCount: (map['clients_count'] as num?)?.toInt() ?? int.tryParse(map['clients_count']?.toString() ?? ''),
        verifiedWorkoutsCount: (map['verified_workouts_count'] as num?)?.toInt() ?? int.tryParse(map['verified_workouts_count']?.toString() ?? ''),
        email: map['email']?.toString(),
        mobile: map['mobile']?.toString() ??
            map['mobile_number']?.toString() ??
            map['phone_number']?.toString() ??
            map['phone']?.toString(),
        gender: map['gender']?.toString(),
        certifications: (map['certifications'] is List)
            ? (map['certifications'] as List).map((c) {
                if (c is Map) {
                  final cMap = Map<String, dynamic>.from(c);
                  return Certification(
                    name: cMap['name']?.toString() ?? cMap['title']?.toString(),
                    issuedBy: cMap['issued_by']?.toString() ?? cMap['institution']?.toString(),
                    issuedDate: cMap['issued_date']?.toString() ?? cMap['issue_date']?.toString(),
                    fileUrl: cMap['file_url']?.toString() ?? cMap['file']?.toString(),
                  );
                }
                return null;
              }).whereType<Certification>().toList()
            : null,
      );
    }
  }
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

  static Certification fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(json);
    if (!map.containsKey('name') || map['name'] == null) {
      map['name'] = map['title'] ?? map['certificate_title'] ?? 'Certification';
    }
    if (!map.containsKey('issued_by') || map['issued_by'] == null) {
      map['issued_by'] = map['institution'] ?? map['issuedBy'];
    }
    if (!map.containsKey('file_url') || map['file_url'] == null) {
      map['file_url'] = map['certificate_image'] ?? map['image'] ?? map['file'];
    }
    if (!map.containsKey('issued_date') || map['issued_date'] == null) {
      map['issued_date'] = map['issue_date'] ?? map['date'];
    }
    return Certification.fromJson(map);
  }
}



