import 'package:flutter/foundation.dart';

@immutable
class BodyMetricsHistoryResponse {
  const BodyMetricsHistoryResponse({
    required this.status,
    required this.data,
  });

  factory BodyMetricsHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json);

    return BodyMetricsHistoryResponse(
      status: json['status']?.toString() ?? '',
      data: BodyMetricsHistoryData.fromJson(dataMap),
    );
  }

  final String status;
  final BodyMetricsHistoryData data;
}

@immutable
class BodyMetricsHistoryData {
  const BodyMetricsHistoryData({
    this.userId,
    this.customerId,
    this.userName,
    this.gender,
    this.age,
    this.heightCm,
    this.currentWeightKg,
    this.timeframe = 'all',
    this.metrics = const BodyMetricsMap(),
  });

  factory BodyMetricsHistoryData.fromJson(Map<String, dynamic> json) {
    final metricsMap = json['metrics'] is Map
        ? Map<String, dynamic>.from(json['metrics'] as Map)
        : <String, dynamic>{};

    final heightCmVal = double.tryParse(json['height_cm']?.toString() ?? '') ??
        double.tryParse(json['height']?.toString() ?? '');
    final weightKgVal =
        double.tryParse(json['current_weight_kg']?.toString() ?? '') ??
            double.tryParse(json['weight']?.toString() ?? '') ??
            double.tryParse(json['weight_kg']?.toString() ?? '');

    return BodyMetricsHistoryData(
      userId: json['user_id'],
      customerId: json['customer_id'],
      userName: json['user_name']?.toString(),
      gender: json['gender']?.toString(),
      age: int.tryParse(json['age']?.toString() ?? ''),
      heightCm: heightCmVal,
      currentWeightKg: weightKgVal,
      timeframe: json['timeframe']?.toString() ?? 'all',
      metrics: BodyMetricsMap.fromJson(
        metricsMap,
        rootJson: json,
        rootHeightCm: heightCmVal,
        rootWeightKg: weightKgVal,
      ),
    );
  }

  final dynamic userId;
  final dynamic customerId;
  final String? userName;
  final String? gender;
  final int? age;
  final double? heightCm;
  final double? currentWeightKg;
  final String timeframe;
  final BodyMetricsMap metrics;

  /// Whether there is at least one metric that has recorded values or history
  bool get hasAnyData =>
      metrics.bmi != null ||
      metrics.bmr != null ||
      metrics.bodyFat != null ||
      metrics.waistHipRatio != null ||
      metrics.waistHeightRatio != null ||
      metrics.weight != null ||
      metrics.height != null;

  /// Returns metrics ordered by user's specification:
  /// 1. BMI, 2. BMR, 3. Body Fat, 4. Weight, 5. Height, 6. Waist Hip Ratio, 7. Waist Height Ratio
  List<BodyMetricItem> get orderedMetrics {
    final list = <BodyMetricItem>[];
    if (metrics.bmi != null) list.add(metrics.bmi!);
    if (metrics.bmr != null) list.add(metrics.bmr!);
    if (metrics.bodyFat != null) list.add(metrics.bodyFat!);
    if (metrics.weight != null) list.add(metrics.weight!);
    if (metrics.height != null) list.add(metrics.height!);
    if (metrics.waistHipRatio != null) list.add(metrics.waistHipRatio!);
    if (metrics.waistHeightRatio != null) list.add(metrics.waistHeightRatio!);
    return list;
  }
}

@immutable
class BodyMetricsMap {
  const BodyMetricsMap({
    this.bmi,
    this.bmr,
    this.bodyFat,
    this.waistHipRatio,
    this.waistHeightRatio,
    this.height,
    this.weight,
  });

  factory BodyMetricsMap.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? rootJson,
    double? rootHeightCm,
    double? rootWeightKg,
  }) {
    BodyMetricItem? parseItem(
      dynamic raw, {
      String? defaultKey,
      String? defaultTitle,
      String? defaultSubtitle,
      String? defaultUnit,
      double? fallbackValue,
    }) {
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final item = BodyMetricItem.fromJson(map);
        return BodyMetricItem(
          metricKey: item.metricKey.isNotEmpty
              ? item.metricKey
              : (defaultKey ?? ''),
          title: item.title.isNotEmpty ? item.title : (defaultTitle ?? ''),
          subtitle: item.subtitle.isNotEmpty
              ? item.subtitle
              : (defaultSubtitle ?? ''),
          currentValue: item.currentValue != 0.0
              ? item.currentValue
              : (fallbackValue ?? 0.0),
          unit: item.unit.isNotEmpty ? item.unit : (defaultUnit ?? ''),
          delta: item.delta,
          deltaFormatted: item.deltaFormatted,
          deltaDirection: item.deltaDirection,
          sinceDate: item.sinceDate,
          sinceText: item.sinceText,
          status: item.status,
          statusBadge: item.statusBadge,
          statusColor: item.statusColor,
          rangeText: item.rangeText,
          insight: item.insight,
          chartMeta: item.chartMeta,
          history: item.history,
        );
      } else if (raw is List) {
        final historyList = <BodyMetricHistoryPoint>[];
        for (final item in raw) {
          if (item is Map) {
            historyList.add(
              BodyMetricHistoryPoint.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
        final curVal = historyList.isNotEmpty
            ? historyList.last.value
            : (fallbackValue ?? 0.0);
        return BodyMetricItem(
          metricKey: defaultKey ?? '',
          title: defaultTitle ?? '',
          subtitle: defaultSubtitle ?? '',
          currentValue: curVal,
          unit: defaultUnit ?? '',
          history: historyList,
        );
      }
      return null;
    }

    final heightRaw = json['height'] ??
        json['height_history'] ??
        json['height_cm'] ??
        rootJson?['height_history'] ??
        rootJson?['height'] ??
        rootJson?['height_cm'];

    final weightRaw = json['weight'] ??
        json['weight_history'] ??
        json['weight_kg'] ??
        json['current_weight_kg'] ??
        rootJson?['weight_history'] ??
        rootJson?['weight'] ??
        rootJson?['weight_kg'] ??
        rootJson?['current_weight_kg'];

    var parsedHeight = parseItem(
      heightRaw,
      defaultKey: 'height',
      defaultTitle: 'Height',
      defaultSubtitle: 'Stature history',
      defaultUnit: 'cm',
      fallbackValue: rootHeightCm,
    );

    if (parsedHeight == null && rootHeightCm != null && rootHeightCm > 0) {
      parsedHeight = BodyMetricItem(
        metricKey: 'height',
        title: 'Height',
        subtitle: 'Stature history',
        currentValue: rootHeightCm,
        unit: 'cm',
        history: [
          BodyMetricHistoryPoint(date: 'Current', value: rootHeightCm),
        ],
      );
    }

    var parsedWeight = parseItem(
      weightRaw,
      defaultKey: 'weight',
      defaultTitle: 'Weight',
      defaultSubtitle: 'Body weight history',
      defaultUnit: 'kg',
      fallbackValue: rootWeightKg,
    );

    if (parsedWeight == null && rootWeightKg != null && rootWeightKg > 0) {
      parsedWeight = BodyMetricItem(
        metricKey: 'weight',
        title: 'Weight',
        subtitle: 'Body weight history',
        currentValue: rootWeightKg,
        unit: 'kg',
        history: [
          BodyMetricHistoryPoint(date: 'Current', value: rootWeightKg),
        ],
      );
    }

    return BodyMetricsMap(
      bmi: parseItem(json['bmi']),
      bmr: parseItem(json['bmr']),
      bodyFat: parseItem(json['body_fat'] ?? json['bodyFat']),
      waistHipRatio: parseItem(
        json['waist_hip_ratio'] ?? json['waistHipRatio'] ?? json['whr'],
      ),
      waistHeightRatio: parseItem(
        json['waist_height_ratio'] ??
            json['waistHeightRatio'] ??
            json['whtr'] ??
            json['waist_hip_height'],
      ),
      height: parsedHeight,
      weight: parsedWeight,
    );
  }

  final BodyMetricItem? bmi;
  final BodyMetricItem? bmr;
  final BodyMetricItem? bodyFat;
  final BodyMetricItem? waistHipRatio;
  final BodyMetricItem? waistHeightRatio;
  final BodyMetricItem? height;
  final BodyMetricItem? weight;
}

@immutable
class BodyMetricItem {
  const BodyMetricItem({
    required this.metricKey,
    required this.title,
    required this.subtitle,
    required this.currentValue,
    this.unit = '',
    this.delta,
    this.deltaFormatted,
    this.deltaDirection,
    this.sinceDate,
    this.sinceText,
    this.status,
    this.statusBadge,
    this.statusColor,
    this.rangeText,
    this.insight,
    this.chartMeta,
    this.history = const [],
  });

  factory BodyMetricItem.fromJson(Map<String, dynamic> json) {
    final historyList = <BodyMetricHistoryPoint>[];
    if (json['history'] is List) {
      for (final item in json['history'] as List) {
        if (item is Map) {
          historyList.add(
            BodyMetricHistoryPoint.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    BodyMetricChartMeta? chartMeta;
    if (json['chart_meta'] is Map) {
      chartMeta = BodyMetricChartMeta.fromJson(
        Map<String, dynamic>.from(json['chart_meta'] as Map),
      );
    }

    final curVal = (json['current_value'] as num?)?.toDouble() ??
        (json['value'] as num?)?.toDouble() ??
        0.0;

    return BodyMetricItem(
      metricKey: json['metric_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      currentValue: curVal,
      unit: json['unit']?.toString() ?? '',
      delta: (json['delta'] as num?)?.toDouble(),
      deltaFormatted: json['delta_formatted']?.toString(),
      deltaDirection: json['delta_direction']?.toString(),
      sinceDate: json['since_date']?.toString(),
      sinceText: json['since_text']?.toString(),
      status: json['status']?.toString(),
      statusBadge: json['status_badge']?.toString() ?? json['status']?.toString(),
      statusColor: json['status_color']?.toString(),
      rangeText: json['range_text']?.toString(),
      insight: json['insight']?.toString(),
      chartMeta: chartMeta,
      history: historyList,
    );
  }

  final String metricKey;
  final String title;
  final String subtitle;
  final double currentValue;
  final String unit;
  final double? delta;
  final String? deltaFormatted;
  final String? deltaDirection;
  final String? sinceDate;
  final String? sinceText;
  final String? status;
  final String? statusBadge;
  final String? statusColor;
  final String? rangeText;
  final String? insight;
  final BodyMetricChartMeta? chartMeta;
  final List<BodyMetricHistoryPoint> history;

  bool get isIncrease =>
      deltaDirection?.toLowerCase() == 'up' || (delta != null && delta! > 0);
}

@immutable
class BodyMetricChartMeta {
  const BodyMetricChartMeta({
    this.minValue,
    this.maxValue,
    this.healthyMin,
    this.healthyMax,
  });

  factory BodyMetricChartMeta.fromJson(Map<String, dynamic> json) {
    return BodyMetricChartMeta(
      minValue: (json['min_value'] as num?)?.toDouble(),
      maxValue: (json['max_value'] as num?)?.toDouble(),
      healthyMin: (json['healthy_min'] as num?)?.toDouble(),
      healthyMax: (json['healthy_max'] as num?)?.toDouble(),
    );
  }

  final double? minValue;
  final double? maxValue;
  final double? healthyMin;
  final double? healthyMax;
}

@immutable
class BodyMetricHistoryPoint {
  const BodyMetricHistoryPoint({
    required this.date,
    required this.value,
    this.rawDate,
  });

  factory BodyMetricHistoryPoint.fromJson(Map<String, dynamic> json) {
    return BodyMetricHistoryPoint(
      date: json['date']?.toString() ?? '',
      rawDate: json['raw_date']?.toString(),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String date;
  final String? rawDate;
  final double value;
}
