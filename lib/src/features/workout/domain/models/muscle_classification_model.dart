class SubMuscleModel {
  final int id;
  final String name;
  final String? majorMuscle;
  final String? icon;
  final int count;

  SubMuscleModel({
    required this.id,
    required this.name,
    this.majorMuscle,
    this.icon,
    required this.count,
  });

  factory SubMuscleModel.fromJson(Map<String, dynamic> json) {
    return SubMuscleModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      majorMuscle: json['major_muscle'] as String?,
      icon: json['icon'] as String?,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'major_muscle': majorMuscle,
        'icon': icon,
        'count': count,
      };
}

class MajorMuscleCategoryModel {
  final String name;
  final String slug;
  final int count;
  final List<SubMuscleModel> subMuscles;

  MajorMuscleCategoryModel({
    required this.name,
    required this.slug,
    required this.count,
    required this.subMuscles,
  });

  factory MajorMuscleCategoryModel.fromJson(Map<String, dynamic> json) {
    return MajorMuscleCategoryModel(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      subMuscles: (json['sub_muscles'] as List? ?? [])
          .map((e) => SubMuscleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'count': count,
        'sub_muscles': subMuscles.map((e) => e.toJson()).toList(),
      };
}

class MuscleClassificationResponse {
  final List<String> allMajorMuscles;
  final List<MajorMuscleCategoryModel> majorMuscles;
  final List<SubMuscleModel> allSubMuscles;

  MuscleClassificationResponse({
    required this.allMajorMuscles,
    required this.majorMuscles,
    required this.allSubMuscles,
  });

  factory MuscleClassificationResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('name') && !json.containsKey('all_major_muscles')) {
      final singleCat = MajorMuscleCategoryModel.fromJson(json);
      return MuscleClassificationResponse(
        allMajorMuscles: ['All', singleCat.name],
        majorMuscles: [singleCat],
        allSubMuscles: singleCat.subMuscles,
      );
    }

    final rawAllMajor = (json['all_major_muscles'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    return MuscleClassificationResponse(
      allMajorMuscles: rawAllMajor.isEmpty
          ? [
              'All',
              'Abs',
              'Back',
              'Biceps',
              'Chest',
              'Forearms',
              'Legs',
              'Neck',
              'Shoulders',
              'Triceps',
              'Others'
            ]
          : rawAllMajor,
      majorMuscles: (json['major_muscles'] as List? ?? [])
          .map((e) => MajorMuscleCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      allSubMuscles: (json['all_sub_muscles'] as List? ?? [])
          .map((e) => SubMuscleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
