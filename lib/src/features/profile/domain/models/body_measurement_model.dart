class BodyMeasurementModel {
  final int? id;
  final double? neckCm;
  final double? waistCm;
  final double? hipsCm;
  final double? chestCm;
  final double? bicepsCm;
  final double? thighsCm;
  final double? whr;
  final double? bfPercentage;
  final String? loggedAt;
  final String? createdAt;

  BodyMeasurementModel({
    this.id,
    this.neckCm,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.bicepsCm,
    this.thighsCm,
    this.whr,
    this.bfPercentage,
    this.loggedAt,
    this.createdAt,
  });

  factory BodyMeasurementModel.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return BodyMeasurementModel(
      id: json['id'] as int?,
      neckCm: parseNum(json['neck_cm'] ?? json['neck']),
      waistCm: parseNum(json['waist_cm'] ?? json['waist']),
      hipsCm: parseNum(json['hips_cm'] ?? json['hip'] ?? json['hips']),
      chestCm: parseNum(json['chest_cm'] ?? json['chest']),
      bicepsCm: parseNum(json['biceps_cm'] ?? json['biceps']),
      thighsCm: parseNum(json['thighs_cm'] ?? json['thighs']),
      whr: parseNum(json['whr']),
      bfPercentage: parseNum(json['bf_percentage']),
      loggedAt: json['logged_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (neckCm != null) 'neck_cm': neckCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (bicepsCm != null) 'biceps_cm': bicepsCm,
      if (thighsCm != null) 'thighs_cm': thighsCm,
      if (whr != null) 'whr': whr,
      if (bfPercentage != null) 'bf_percentage': bfPercentage,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

class BodyMeasurementsHistoryModel {
  final List<BodyMeasurementModel> logs;
  final BodyMeasurementModel? latest;

  BodyMeasurementsHistoryModel({
    required this.logs,
    this.latest,
  });

  factory BodyMeasurementsHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('neck') ||
        json.containsKey('neck_cm') ||
        json.containsKey('waist') ||
        json.containsKey('waist_cm') ||
        json.containsKey('hips') ||
        json.containsKey('hips_cm')) {
      final single = BodyMeasurementModel.fromJson(json);
      return BodyMeasurementsHistoryModel(logs: [single], latest: single);
    }

    final rawLogs = (json['logs'] ?? json['results'] ?? json['data']) as List<dynamic>? ?? [];
    final logsList = rawLogs
        .whereType<Map<String, dynamic>>()
        .map((e) => BodyMeasurementModel.fromJson(e))
        .toList();

    BodyMeasurementModel? latestItem;
    if (json['latest'] != null && json['latest'] is Map<String, dynamic>) {
      latestItem = BodyMeasurementModel.fromJson(json['latest'] as Map<String, dynamic>);
    } else if (logsList.isNotEmpty) {
      latestItem = logsList.first;
    }

    return BodyMeasurementsHistoryModel(
      logs: logsList,
      latest: latestItem,
    );
  }

  factory BodyMeasurementsHistoryModel.fromList(List<dynamic> list) {
    final logsList = list
        .whereType<Map<String, dynamic>>()
        .map((e) => BodyMeasurementModel.fromJson(e))
        .toList();
    return BodyMeasurementsHistoryModel(
      logs: logsList,
      latest: logsList.isNotEmpty ? logsList.first : null,
    );
  }
}
