class MarketplaceTrainerModel {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? bannerImage;
  final int experienceYears;
  final String? bio;
  final String? bioSnippet;
  final List<String> specialties;
  final List<String> gymAffiliations;
  final String? gender;
  final bool isPremium;
  final String? whatsappNumber;
  final String? whatsappUrl;
  final List<TrainerExperienceModel> experiences;

  MarketplaceTrainerModel({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.bannerImage,
    this.experienceYears = 0,
    this.bio,
    this.bioSnippet,
    this.specialties = const [],
    this.gymAffiliations = const [],
    this.gender,
    this.isPremium = true,
    this.whatsappNumber,
    this.whatsappUrl,
    this.experiences = const [],
  });

  factory MarketplaceTrainerModel.fromJson(Map<String, dynamic> json) {
    var rawSpecs = json['specialties'];
    List<String> specsList = [];
    if (rawSpecs is List) {
      specsList = rawSpecs.map((e) => e.toString()).toList();
    }

    var rawGyms = json['gym_affiliations'] ?? json['gyms'];
    List<String> gymsList = [];
    if (rawGyms is List) {
      gymsList = rawGyms.map((e) => e.toString()).toList();
    }

    var rawExp = json['experiences'];
    List<TrainerExperienceModel> expList = [];
    if (rawExp is List) {
      expList = rawExp.map((e) => TrainerExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return MarketplaceTrainerModel(
      id: json['id'] ?? json['trainer_id'] ?? 0,
      name: json['name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'] ?? json['profile_picture'],
      bannerImage: json['banner_image'],
      experienceYears: json['experience_years'] ?? 0,
      bio: json['bio'],
      bioSnippet: json['bio_snippet'],
      specialties: specsList,
      gymAffiliations: gymsList,
      gender: json['gender'],
      isPremium: json['is_premium'] ?? false,
      whatsappNumber: json['whatsapp_number'],
      whatsappUrl: json['whatsapp_url'],
      experiences: expList,
    );
  }
}

class TrainerExperienceModel {
  final int id;
  final String organizationName;
  final String designation;
  final String? startDate;
  final String? endDate;
  final bool currentlyWorking;
  final String? description;

  TrainerExperienceModel({
    required this.id,
    required this.organizationName,
    required this.designation,
    this.startDate,
    this.endDate,
    this.currentlyWorking = false,
    this.description,
  });

  factory TrainerExperienceModel.fromJson(Map<String, dynamic> json) {
    return TrainerExperienceModel(
      id: json['id'] ?? 0,
      organizationName: json['organization_name'] ?? '',
      designation: json['designation'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      currentlyWorking: json['currently_working'] ?? false,
      description: json['description'],
    );
  }
}
