class ExerciseLibraryModel {
  ExerciseLibraryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.muscleGroup,
    required this.equipment,
    required this.videoUrl,
    this.trackBy,
  });

  final int? id;
  final String? name;
  final String? type;
  final String? muscleGroup;
  final String? equipment;
  final dynamic videoUrl;
  final String? trackBy;

  factory ExerciseLibraryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseLibraryModel(
      id: json["id"] as int?,
      name: json["name"] as String?,
      type: json["type"] as String?,
      muscleGroup: json["primary_muscle_group_name"] as String? ?? json["muscle_group"] as String?,
      equipment: json["equipment_name"] as String? ?? json["equipment"] as String?,
      videoUrl: json["video_url"],
      trackBy: json["track_by"] as String?,
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
      };
}

typedef ExerciseLibrarymodel = ExerciseLibraryModel;
