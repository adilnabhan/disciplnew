import 'package:flutter/foundation.dart';

@immutable
class PersonalRecordsResponse {
  const PersonalRecordsResponse({
    required this.status,
    required this.data,
  });

  factory PersonalRecordsResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    return PersonalRecordsResponse(
      status: json['status']?.toString() ?? '',
      data: PersonalRecordsData.fromJson(dataMap),
    );
  }

  final String status;
  final PersonalRecordsData data;
}

@immutable
class PersonalRecordsData {
  const PersonalRecordsData({
    this.userId,
    this.customerId,
    this.userName,
    this.totalPrsCount = 0,
    this.thisMonthPrsCount,
    this.categories = const ['All'],
    this.categoryCounts = const {},
    this.activeCategory = 'All',
    this.records = const [],
  });

  factory PersonalRecordsData.fromJson(Map<String, dynamic> json) {
    final categoriesList = (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['All'];

    final categoryCountsMap = <String, int>{};
    if (json['category_counts'] is Map) {
      (json['category_counts'] as Map).forEach((key, value) {
        categoryCountsMap[key.toString()] =
            int.tryParse(value?.toString() ?? '0') ?? 0;
      });
    }

    final recordsList = <PersonalRecordItemModel>[];
    if (json['records'] is List) {
      for (final item in json['records'] as List) {
        if (item is Map<String, dynamic>) {
          recordsList.add(PersonalRecordItemModel.fromJson(item));
        }
      }
    }

    return PersonalRecordsData(
      userId: int.tryParse(json['user_id']?.toString() ?? ''),
      customerId: int.tryParse(json['customer_id']?.toString() ?? ''),
      userName: json['user_name']?.toString(),
      totalPrsCount: int.tryParse(json['total_prs_count']?.toString() ?? '0') ??
          recordsList.length,
      thisMonthPrsCount:
          int.tryParse(json['this_month_prs_count']?.toString() ?? ''),
      categories: categoriesList.isEmpty ? ['All'] : categoriesList,
      categoryCounts: categoryCountsMap,
      activeCategory: json['active_category']?.toString() ?? 'All',
      records: recordsList,
    );
  }

  final int? userId;
  final int? customerId;
  final String? userName;
  final int totalPrsCount;
  final int? thisMonthPrsCount;
  final List<String> categories;
  final Map<String, int> categoryCounts;
  final String activeCategory;
  final List<PersonalRecordItemModel> records;
}

@immutable
class PersonalRecordItemModel {
  const PersonalRecordItemModel({
    required this.workoutId,
    required this.name,
    required this.category,
    this.majorMuscle,
    this.thumbnail,
    this.maxWeight,
    this.bestReps,
    this.totalVolume,
  });

  factory PersonalRecordItemModel.fromJson(Map<String, dynamic> json) {
    return PersonalRecordItemModel(
      workoutId: int.tryParse(json['workout_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      majorMuscle: json['major_muscle']?.toString() ?? json['category']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      maxWeight: json['max_weight'] is Map<String, dynamic>
          ? PRMetricValue.fromJson(json['max_weight'] as Map<String, dynamic>)
          : null,
      bestReps: json['best_reps'] is Map<String, dynamic>
          ? PRMetricValue.fromJson(json['best_reps'] as Map<String, dynamic>)
          : null,
      totalVolume: json['total_volume'] is Map<String, dynamic>
          ? PRMetricValue.fromJson(json['total_volume'] as Map<String, dynamic>)
          : null,
    );
  }

  final int workoutId;
  final String name;
  final String category;
  final String? majorMuscle;
  final String? thumbnail;
  final PRMetricValue? maxWeight;
  final PRMetricValue? bestReps;
  final PRMetricValue? totalVolume;
}

@immutable
class PRMetricValue {
  const PRMetricValue({
    this.value,
    this.weight,
    this.formatted,
    this.unit,
    this.reps,
    this.subtext,
    this.displayText,
    this.date,
  });

  factory PRMetricValue.fromJson(Map<String, dynamic> json) {
    return PRMetricValue(
      value: num.tryParse(json['value']?.toString() ?? ''),
      weight: num.tryParse(json['weight']?.toString() ?? ''),
      formatted: json['formatted']?.toString(),
      unit: json['unit']?.toString(),
      reps: int.tryParse(json['reps']?.toString() ?? ''),
      subtext: json['subtext']?.toString(),
      displayText: json['display_text']?.toString() ??
          json['formatted']?.toString() ??
          '',
      date: json['date']?.toString(),
    );
  }

  final num? value;
  final num? weight;
  final String? formatted;
  final String? unit;
  final int? reps;
  final String? subtext;
  final String? displayText;
  final String? date;
}
