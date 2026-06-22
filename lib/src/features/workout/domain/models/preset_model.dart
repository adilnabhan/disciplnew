class PresetModel {
  final int id;
  final String title;
  final String? createdAt;
  final int? planDayId;
  final List<PresetExerciseModel> exercises;

  PresetModel({
    required this.id,
    required this.title,
    this.createdAt,
    this.planDayId,
    required this.exercises,
  });

  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] as int? ?? 0,
      title: json['plan_name'] as String? ?? json['title'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      planDayId: json['plan_day_id'] as int?,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => PresetExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'plan_name': title,
      if (createdAt != null) 'created_at': createdAt,
      if (planDayId != null) 'plan_day_id': planDayId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class PresetExerciseModel {
  final int id;
  final int workoutId;
  final String name;
  final String muscleGroup;
  final int orderIndex;
  final List<PresetSetModel> sets;

  PresetExerciseModel({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.muscleGroup,
    required this.orderIndex,
    required this.sets,
  });

  factory PresetExerciseModel.fromJson(Map<String, dynamic> json) {
    return PresetExerciseModel(
      id: json['id'] as int? ?? 0,
      workoutId: json['workout_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
      sets: (json['sets'] as List? ?? [])
          .map((e) => PresetSetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'muscle_group': muscleGroup,
      'order_index': orderIndex,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class PresetSetModel {
  final int setNumber;
  final int reps;
  final double weight;

  PresetSetModel({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory PresetSetModel.fromJson(Map<String, dynamic> json) {
    return PresetSetModel(
      setNumber: json['set_number'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
    };
  }
}
