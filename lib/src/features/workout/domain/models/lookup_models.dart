class MuscleGroupModel {
  final int id;
  final String name;

  MuscleGroupModel({required this.id, required this.name});

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) {
    return MuscleGroupModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class EquipmentModel {
  final int id;
  final String name;

  EquipmentModel({required this.id, required this.name});

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ExerciseTypeModel {
  final String id;
  final String name;

  ExerciseTypeModel({required this.id, required this.name});

  factory ExerciseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExerciseTypeModel(
      id: (json['id'] ?? json['value'] ?? '').toString(),
      name: (json['name'] ?? json['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
