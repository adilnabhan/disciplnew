class ExerciseLibraryModel {
  ExerciseLibraryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.muscleGroup,
    required this.equipment,
    required this.videoUrl,
    this.trackBy,
    this.majorMuscle,
    this.primaryMuscleGroupId,
    this.subtitle,
    this.source,
    this.thumbnail,
    this.isGlobal,
    this.sortOrder,
  });

  final int? id;
  final String? name;
  final String? type;
  final String? muscleGroup;
  final String? equipment;
  final dynamic videoUrl;
  final String? trackBy;
  final String? majorMuscle;
  final int? primaryMuscleGroupId;
  final String? subtitle;
  final String? source;
  final String? thumbnail;
  final bool? isGlobal;
  final int? sortOrder;

  factory ExerciseLibraryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseLibraryModel(
      id: json["id"] as int?,
      name: json["name"] as String?,
      type: json["type"] as String?,
      muscleGroup: json["primary_muscle_group_name"] as String? ?? json["muscle_group"] as String?,
      equipment: json["equipment_name"] as String? ?? (json["equipment"] is String ? json["equipment"] as String : null),
      videoUrl: json["video_url"],
      trackBy: json["track_by"] as String?,
      majorMuscle: json["major_muscle"] as String?,
      primaryMuscleGroupId: json["primary_muscle_group"] is int ? json["primary_muscle_group"] as int : null,
      subtitle: json["subtitle"] as String?,
      source: json["source"] as String?,
      thumbnail: json["thumbnail"] as String?,
      isGlobal: json["is_global"] as bool?,
      sortOrder: json["sort_order"] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "muscle_group": muscleGroup,
        "primary_muscle_group_name": muscleGroup,
        "equipment": equipment,
        "equipment_name": equipment,
        "video_url": videoUrl,
        "track_by": trackBy,
        "major_muscle": majorMuscle,
        "primary_muscle_group": primaryMuscleGroupId,
        "subtitle": subtitle,
        "source": source,
        "thumbnail": thumbnail,
        "is_global": isGlobal,
        "sort_order": sortOrder,
      };
}

typedef ExerciseLibrarymodel = ExerciseLibraryModel;
