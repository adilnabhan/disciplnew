import 'package:flutter/foundation.dart';

@immutable
class PersonalRecordDetailResponse {
  const PersonalRecordDetailResponse({
    required this.status,
    required this.data,
  });

  factory PersonalRecordDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    return PersonalRecordDetailResponse(
      status: json['status']?.toString() ?? '',
      data: PersonalRecordDetailData.fromJson(dataMap),
    );
  }

  final String status;
  final PersonalRecordDetailData data;
}

@immutable
class PersonalRecordDetailData {
  const PersonalRecordDetailData({
    required this.workoutId,
    required this.name,
    required this.category,
    this.thumbnail,
    this.videoUrl,
    this.instructions,
    this.bestPerformance,
    this.progressOverTime,
    this.allTimeBests = const [],
    this.prHistory = const [],
    this.insights,
  });

  factory PersonalRecordDetailData.fromJson(Map<String, dynamic> json) {
    final allTimeBestsList = <PRAllTimeBestItem>[];
    if (json['all_time_bests'] is List) {
      for (final item in json['all_time_bests'] as List) {
        if (item is Map<String, dynamic>) {
          allTimeBestsList.add(PRAllTimeBestItem.fromJson(item));
        }
      }
    }

    final prHistoryList = <PRHistoryItem>[];
    if (json['pr_history'] is List) {
      for (final item in json['pr_history'] as List) {
        if (item is Map<String, dynamic>) {
          prHistoryList.add(PRHistoryItem.fromJson(item));
        }
      }
    }

    return PersonalRecordDetailData(
      workoutId: int.tryParse(json['workout_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      videoUrl: json['video_url']?.toString(),
      instructions: json['instructions']?.toString(),
      bestPerformance: json['best_performance'] is Map<String, dynamic>
          ? PRBestPerformance.fromJson(
              json['best_performance'] as Map<String, dynamic>)
          : null,
      progressOverTime: json['progress_over_time'] is Map<String, dynamic>
          ? PRProgressOverTime.fromJson(
              json['progress_over_time'] as Map<String, dynamic>)
          : null,
      allTimeBests: allTimeBestsList,
      prHistory: prHistoryList,
      insights: json['insights']?.toString(),
    );
  }

  final int workoutId;
  final String name;
  final String category;
  final String? thumbnail;
  final String? videoUrl;
  final String? instructions;
  final PRBestPerformance? bestPerformance;
  final PRProgressOverTime? progressOverTime;
  final List<PRAllTimeBestItem> allTimeBests;
  final List<PRHistoryItem> prHistory;
  final String? insights;
}

@immutable
class PRBestPerformance {
  const PRBestPerformance({
    this.maxWeight,
    this.bestReps,
    this.totalVolume,
  });

  factory PRBestPerformance.fromJson(Map<String, dynamic> json) {
    return PRBestPerformance(
      maxWeight: json['max_weight'] is Map<String, dynamic>
          ? PRPerformanceMetric.fromJson(
              json['max_weight'] as Map<String, dynamic>)
          : null,
      bestReps: json['best_reps'] is Map<String, dynamic>
          ? PRPerformanceMetric.fromJson(
              json['best_reps'] as Map<String, dynamic>)
          : null,
      totalVolume: json['total_volume'] is Map<String, dynamic>
          ? PRPerformanceMetric.fromJson(
              json['total_volume'] as Map<String, dynamic>)
          : null,
    );
  }

  final PRPerformanceMetric? maxWeight;
  final PRPerformanceMetric? bestReps;
  final PRPerformanceMetric? totalVolume;
}

@immutable
class PRPerformanceMetric {
  const PRPerformanceMetric({
    this.title,
    this.valueText,
    this.repsText,
    this.date,
  });

  factory PRPerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PRPerformanceMetric(
      title: json['title']?.toString(),
      valueText: json['value_text']?.toString() ??
          json['formatted']?.toString() ??
          json['value']?.toString(),
      repsText: json['reps_text']?.toString() ??
          json['subtext']?.toString() ??
          (json['reps'] != null ? '× ${json['reps']} reps' : null),
      date: json['date']?.toString(),
    );
  }

  final String? title;
  final String? valueText;
  final String? repsText;
  final String? date;
}

@immutable
class PRProgressOverTime {
  const PRProgressOverTime({
    this.metric,
    this.chartMeta,
    this.timeline = const [],
  });

  factory PRProgressOverTime.fromJson(Map<String, dynamic> json) {
    final timelineList = <PRTimelinePoint>[];
    if (json['timeline'] is List) {
      for (final item in json['timeline'] as List) {
        if (item is Map<String, dynamic>) {
          timelineList.add(PRTimelinePoint.fromJson(item));
        }
      }
    }

    return PRProgressOverTime(
      metric: json['metric']?.toString(),
      chartMeta: json['chart_meta'] is Map<String, dynamic>
          ? PRChartMeta.fromJson(json['chart_meta'] as Map<String, dynamic>)
          : null,
      timeline: timelineList,
    );
  }

  final String? metric;
  final PRChartMeta? chartMeta;
  final List<PRTimelinePoint> timeline;
}

@immutable
class PRChartMeta {
  const PRChartMeta({
    this.minValue = 0,
    this.maxValue = 100,
    this.peakValue = 0,
    this.peakFormatted,
  });

  factory PRChartMeta.fromJson(Map<String, dynamic> json) {
    return PRChartMeta(
      minValue: num.tryParse(json['min_value']?.toString() ?? '0') ?? 0,
      maxValue: num.tryParse(json['max_value']?.toString() ?? '100') ?? 100,
      peakValue: num.tryParse(json['peak_value']?.toString() ?? '0') ?? 0,
      peakFormatted: json['peak_formatted']?.toString(),
    );
  }

  final num minValue;
  final num maxValue;
  final num peakValue;
  final String? peakFormatted;
}

@immutable
class PRTimelinePoint {
  const PRTimelinePoint({
    required this.displayDate,
    required this.value,
    this.reps,
    this.isPeak = false,
  });

  factory PRTimelinePoint.fromJson(Map<String, dynamic> json) {
    return PRTimelinePoint(
      displayDate: json['display_date']?.toString() ?? '',
      value: num.tryParse(json['value']?.toString() ?? '0') ?? 0,
      reps: int.tryParse(json['reps']?.toString() ?? ''),
      isPeak: json['is_peak'] == true ||
          json['is_peak']?.toString().toLowerCase() == 'true',
    );
  }

  final String displayDate;
  final num value;
  final int? reps;
  final bool isPeak;
}

@immutable
class PRAllTimeBestItem {
  const PRAllTimeBestItem({
    this.key,
    this.title,
    this.description,
    this.displayValue,
    this.date,
  });

  factory PRAllTimeBestItem.fromJson(Map<String, dynamic> json) {
    return PRAllTimeBestItem(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      displayValue: json['display_value']?.toString() ??
          json['value_text']?.toString() ??
          '',
      date: json['date']?.toString(),
    );
  }

  final String? key;
  final String? title;
  final String? description;
  final String? displayValue;
  final String? date;
}

@immutable
class PRHistoryItem {
  const PRHistoryItem({
    this.date,
    this.formattedDate,
    this.formattedWeight,
    this.deltaFormatted,
    this.reps,
  });

  factory PRHistoryItem.fromJson(Map<String, dynamic> json) {
    return PRHistoryItem(
      date: json['date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      formattedWeight: json['formatted_weight']?.toString(),
      deltaFormatted: json['delta_formatted']?.toString(),
      reps: int.tryParse(json['reps']?.toString() ?? ''),
    );
  }

  final String? date;
  final String? formattedDate;
  final String? formattedWeight;
  final String? deltaFormatted;
  final int? reps;
}
