import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';

enum HealthSourceType {
  none,
  pedometerSensor,
  googleFitHealthConnect,
}

class HealthActivityData {
  final int steps;
  final int calories;
  final double distanceKm;
  final int heartRate;
  final HealthSourceType sourceType;
  final bool isConnected;

  const HealthActivityData({
    required this.steps,
    required this.calories,
    required this.distanceKm,
    required this.heartRate,
    required this.sourceType,
    required this.isConnected,
  });

  factory HealthActivityData.initial() {
    return const HealthActivityData(
      steps: 0,
      calories: 0,
      distanceKm: 0.0,
      heartRate: 74,
      sourceType: HealthSourceType.none,
      isConnected: false,
    );
  }

  HealthActivityData copyWith({
    int? steps,
    int? calories,
    double? distanceKm,
    int? heartRate,
    HealthSourceType? sourceType,
    bool? isConnected,
  }) {
    return HealthActivityData(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      heartRate: heartRate ?? this.heartRate,
      sourceType: sourceType ?? this.sourceType,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class HealthSyncService {
  static final HealthSyncService _instance = HealthSyncService._internal();
  factory HealthSyncService() => _instance;
  HealthSyncService._internal();

  final Health _health = Health();
  StreamSubscription<StepCount>? _stepSubscription;
  Timer? _periodicSyncTimer;

  final _activityController = StreamController<HealthActivityData>.broadcast();
  Stream<HealthActivityData> get activityStream => _activityController.stream;

  HealthActivityData _currentData = HealthActivityData.initial();
  HealthActivityData get currentData => _currentData;

  static const List<HealthDataType> _healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.HEART_RATE,
  ];

  static const List<HealthDataAccess> _healthPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Initialize health sync & live step sensors
  Future<void> initialize() async {
    try {
      await _health.configure();
    } catch (e) {
      debugPrint("Health configure error: $e");
    }

    // Start hardware pedometer live stream
    await _initHardwarePedometer();

    // Attempt Google Fit / Health Connect sync
    await syncHealthData();

    // Schedule periodic background sync every 30 seconds
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncHealthData();
    });
  }

  /// Request Permissions for Google Fit / Health Connect / Activity Recognition
  Future<bool> connectGoogleFitOrHealthConnect() async {
    bool granted = false;
    try {
      // 1. Request Activity Recognition permission
      final activityStatus = await Permission.activityRecognition.request();
      if (!activityStatus.isGranted) {
        debugPrint("Activity recognition permission denied.");
      }

      // 2. Request Health Connect / Google Fit authorization
      await _health.configure();
      granted = await _health.requestAuthorization(
        _healthTypes,
        permissions: _healthPermissions,
      );

      if (granted) {
        await syncHealthData();
      } else {
        // Check if Health Connect prompt is needed
        try {
          final status = await _health.getHealthConnectSdkStatus();
          if (status == HealthConnectSdkStatus.sdkAvailable) {
            granted = await _health.requestAuthorization(_healthTypes);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Error connecting to Google Fit / Health Connect: $e");
    }

    return granted;
  }

  /// Sync today's activity from Google Fit / Health Connect
  Future<void> syncHealthData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day, 0, 0, 0);

      bool? hasPerms;
      try {
        hasPerms = await _health.hasPermissions(_healthTypes, permissions: _healthPermissions);
      } catch (_) {
        hasPerms = false;
      }

      if (hasPerms == true) {
        int steps = 0;
        final int? googleSteps = await _health.getTotalStepsInInterval(midnight, now);
        if (googleSteps != null && googleSteps > 0) {
          steps = googleSteps;
        } else {
          // Query raw step points from midnight to now
          final points = await _health.getHealthDataFromTypes(
            types: [HealthDataType.STEPS],
            startTime: midnight,
            endTime: now,
          );
          for (final p in points) {
            final val = p.value;
            if (val is NumericHealthValue) {
              steps += val.numericValue.round();
            }
          }
        }

        int heartRate = 74;
        try {
          final hrPoints = await _health.getHealthDataFromTypes(
            types: [HealthDataType.HEART_RATE],
            startTime: midnight,
            endTime: now,
          );
          if (hrPoints.isNotEmpty) {
            final lastHr = hrPoints.last.value;
            if (lastHr is NumericHealthValue) {
              heartRate = lastHr.numericValue.round();
            }
          }
        } catch (_) {}

        if (steps > 0) {
          final int calories = (steps * 0.045).round();
          final double distance = double.parse((steps * 0.00075).toStringAsFixed(2));

          _updateData(
            steps: steps,
            calories: calories,
            distanceKm: distance,
            sourceType: HealthSourceType.googleFitHealthConnect,
            isConnected: true,
            heartRate: heartRate,
          );

          // Save today's steps to persistent prefs
          final prefs = await SharedPreferences.getInstance();
          final todayKey = DateFormat('yyyy-MM-dd').format(now);
          prefs.setInt('saved_steps_$todayKey', steps);

          // Sync with backend API in background
          _syncWithBackend(steps, distance, calories, heartRate);
          return;
        }
      }
    } catch (e) {
      debugPrint("Error syncing Health Data from Google Fit: $e");
    }

    _syncWithHardwareSensor();
  }

  /// Sync data to backend PostgreSQL database
  Future<void> _syncWithBackend(int steps, double distanceKm, int calories, int heartRate) async {
    try {
      final now = DateTime.now();
      await DioClient().dio.post(
        '${DioClient().dio.options.baseUrl}/api/v1/customer/health/sync/',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(now),
          'steps': steps,
          'distance_meters': distanceKm * 1000.0,
          'calories_burned': calories.toDouble(),
          'avg_heart_rate': heartRate,
          'source': 'google_fit',
          'device_platform': 'android',
        },
      );
    } catch (_) {}
  }

  /// Query 7-day week data from Google Fit / Health Connect + Backend API + Local Storage
  Future<List<Map<String, dynamic>>> fetchWeekData(DateTime referenceDate) async {
    final List<Map<String, dynamic>> weekList = [];
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final Map<String, int> dailyAggregatedSteps = {};
    final Map<String, int> dailyHeartRates = {};

    // 1. Query raw Health data points across the 7-day window
    try {
      final weekStart = DateTime(referenceDate.year, referenceDate.month, referenceDate.day - 6, 0, 0, 0);
      final weekEnd = DateTime(referenceDate.year, referenceDate.month, referenceDate.day, 23, 59, 59);

      final List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS, HealthDataType.HEART_RATE],
        startTime: weekStart,
        endTime: weekEnd,
      );

      for (final point in points) {
        final dayKey = DateFormat('yyyy-MM-dd').format(point.dateFrom);
        final val = point.value;
        if (point.type == HealthDataType.STEPS && val is NumericHealthValue) {
          final count = val.numericValue.round();
          dailyAggregatedSteps[dayKey] = (dailyAggregatedSteps[dayKey] ?? 0) + count;
        } else if (point.type == HealthDataType.HEART_RATE && val is NumericHealthValue) {
          dailyHeartRates[dayKey] = val.numericValue.round();
        }
      }
    } catch (e) {
      debugPrint("Error fetching raw week health data points: $e");
    }

    // 2. Query Backend Health History
    try {
      final res = await DioClient().dio.get(
        '${DioClient().dio.options.baseUrl}/api/v1/customer/health/history/',
        queryParameters: {'period': 'weekly'},
      );
      if (res.statusCode == 200 && res.data != null) {
        final List series = res.data['series'] ?? res.data['data'] ?? [];
        for (final item in series) {
          final String d = item['date'] ?? '';
          final int s = (item['steps'] ?? 0) is int ? item['steps'] : (int.tryParse(item['steps'].toString()) ?? 0);
          if (d.isNotEmpty && s > 0) {
            dailyAggregatedSteps[d] = max(dailyAggregatedSteps[d] ?? 0, s);
          }
        }
      }
    } catch (_) {}

    // 3. Build 7-day items
    for (int i = 6; i >= 0; i--) {
      final targetDate = referenceDate.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(targetDate);
      final isToday = targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day;

      int steps = dailyAggregatedSteps[dayKey] ?? 0;

      if (steps == 0) {
        try {
          final sStart = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
          final sEnd = isToday ? now : DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
          final int? qSteps = await _health.getTotalStepsInInterval(sStart, sEnd);
          if (qSteps != null && qSteps > 0) steps = qSteps;
        } catch (_) {}
      }

      if (steps == 0) {
        steps = prefs.getInt('saved_steps_$dayKey') ?? 0;
      }

      if (isToday) {
        if (_currentData.steps > steps) steps = _currentData.steps;
        prefs.setInt('saved_steps_$dayKey', steps);
      }

      final dayLabel = isToday ? 'Today' : DateFormat('E').format(targetDate);
      final hr = dailyHeartRates[dayKey] ?? (_currentData.heartRate > 0 ? _currentData.heartRate : 74);

      weekList.add({
        'date': targetDate,
        'day': dayLabel,
        'steps': steps,
        'pts': (steps * 0.005).round(),
        'hr': hr,
        'calories': (steps * 0.045).round(),
        'distance': (steps * 0.00075),
      });
    }

    return weekList;
  }

  /// Query 24h hourly distribution for a given day
  Future<List<Map<String, dynamic>>> fetchDayHourlyData(DateTime date) async {
    final List<Map<String, dynamic>> hourlyList = [];
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    final hourSlots = [
      {'label': '12 am', 'startH': 0, 'endH': 4},
      {'label': '4 am', 'startH': 4, 'endH': 6},
      {'label': '6 am', 'startH': 6, 'endH': 8},
      {'label': '8 am', 'startH': 8, 'endH': 10},
      {'label': '10 am', 'startH': 10, 'endH': 12},
      {'label': '12 pm', 'startH': 12, 'endH': 14},
      {'label': '2 pm', 'startH': 14, 'endH': 16},
      {'label': '4 pm', 'startH': 16, 'endH': 18},
      {'label': '6 pm', 'startH': 18, 'endH': 20},
      {'label': '8 pm', 'startH': 20, 'endH': 22},
      {'label': '10 pm', 'startH': 22, 'endH': 24},
    ];

    final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final dayEnd = isToday ? now : DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<int> slotSteps = List.filled(hourSlots.length, 0);
    try {
      final List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: dayStart,
        endTime: dayEnd,
      );
      for (final p in points) {
        final val = p.value;
        if (val is NumericHealthValue) {
          final count = val.numericValue.round();
          final hour = p.dateFrom.hour;
          for (int s = 0; s < hourSlots.length; s++) {
            final startH = hourSlots[s]['startH'] as int;
            final endH = hourSlots[s]['endH'] as int;
            if (hour >= startH && hour < endH) {
              slotSteps[s] += count;
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching hourly step points: $e");
    }

    int totalDaySteps = _currentData.steps;

    for (int i = 0; i < hourSlots.length; i++) {
      final slot = hourSlots[i];
      final label = slot['label'] as String;
      final startH = slot['startH'] as int;
      final endH = slot['endH'] as int;

      int steps = slotSteps[i];

      if (steps == 0 && (!isToday || startH < now.hour)) {
        try {
          final sStart = DateTime(date.year, date.month, date.day, startH, 0, 0);
          final sEnd = (endH == 24)
              ? DateTime(date.year, date.month, date.day, 23, 59, 59)
              : DateTime(date.year, date.month, date.day, endH, 0, 0);
          final queryEnd = isToday && sEnd.isAfter(now) ? now : sEnd;
          if (queryEnd.isAfter(sStart)) {
            final int? s = await _health.getTotalStepsInInterval(sStart, queryEnd);
            if (s != null && s > 0) steps = s;
          }
        } catch (_) {}
      }

      if (isToday && slotSteps.every((e) => e == 0) && totalDaySteps > 0) {
        if (now.hour >= startH && now.hour < endH) {
          steps = (totalDaySteps * 0.4).round();
        } else if (startH < now.hour) {
          steps = (totalDaySteps * 0.15).round();
        }
      }

      hourlyList.add({
        'time': label,
        'steps': steps,
        'pts': (steps * 0.005).round(),
        'hr': 70 + (steps > 500 ? 30 : (steps > 50 ? 15 : 0)),
      });
    }

    return hourlyList;
  }

  /// Query 4-week monthly data
  Future<List<Map<String, dynamic>>> fetchMonthData(DateTime referenceDate) async {
    final List<Map<String, dynamic>> monthWeeks = [];
    final now = DateTime.now();

    final Map<String, int> dailySteps = {};
    try {
      final monthStart = referenceDate.subtract(const Duration(days: 28));
      final List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: monthStart,
        endTime: now,
      );
      for (final p in points) {
        final val = p.value;
        if (val is NumericHealthValue) {
          final d = DateFormat('yyyy-MM-dd').format(p.dateFrom);
          dailySteps[d] = (dailySteps[d] ?? 0) + val.numericValue.round();
        }
      }
    } catch (_) {}

    for (int w = 3; w >= 0; w--) {
      final weekStart = referenceDate.subtract(Duration(days: (w + 1) * 7 - 1));
      final weekEnd = referenceDate.subtract(Duration(days: w * 7));

      int steps = 0;
      for (int d = 0; d < 7; d++) {
        final day = weekStart.add(Duration(days: d));
        final dayKey = DateFormat('yyyy-MM-dd').format(day);
        steps += dailySteps[dayKey] ?? 0;
      }

      if (steps == 0) {
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day, 0, 0, 0);
        final end = (w == 0 && weekEnd.isAfter(now))
            ? now
            : DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
        try {
          final int? s = await _health.getTotalStepsInInterval(start, end);
          if (s != null && s > 0) steps = s;
        } catch (_) {}
      }

      if (w == 0 && steps < _currentData.steps) {
        steps += _currentData.steps;
      }

      final label = (w == 0) ? 'Week 4 (Current)' : 'Week ${4 - w}';
      monthWeeks.add({
        'week': label,
        'steps': steps,
        'pts': (steps * 0.005).round(),
        'avgHr': 74,
      });
    }

    return monthWeeks;
  }

  /// Hardware Sensor Tracking with Persistent Midnight Calibration
  Future<void> _initHardwarePedometer() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        _stepSubscription?.cancel();
        _stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) async {
            await _handlePedometerEvent(event.steps);
          },
          onError: (err) {
            debugPrint("Pedometer stream error: $err");
          },
        );
      }
    } catch (e) {
      debugPrint("Hardware pedometer initialization error: $e");
    }
  }

  Future<void> _handlePedometerEvent(int rawCumulativeSteps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString('pedometer_last_date');
      int midnightBaseline = prefs.getInt('pedometer_midnight_baseline') ?? 0;

      if (lastDate != todayStr || midnightBaseline == 0) {
        midnightBaseline = rawCumulativeSteps;
        await prefs.setString('pedometer_last_date', todayStr);
        await prefs.setInt('pedometer_midnight_baseline', midnightBaseline);
      }

      int todaySteps = rawCumulativeSteps - midnightBaseline;
      if (todaySteps < 0) {
        todaySteps = rawCumulativeSteps;
        await prefs.setInt('pedometer_midnight_baseline', rawCumulativeSteps);
      }

      if (_currentData.sourceType != HealthSourceType.googleFitHealthConnect || todaySteps > _currentData.steps) {
        final int calories = (todaySteps * 0.045).round();
        final double distance = double.parse((todaySteps * 0.00075).toStringAsFixed(2));

        _updateData(
          steps: todaySteps,
          calories: calories,
          distanceKm: distance,
          sourceType: HealthSourceType.pedometerSensor,
          isConnected: true,
        );

        prefs.setInt('saved_steps_$todayStr', todaySteps);
      }
    } catch (e) {
      debugPrint("Error handling pedometer step event: $e");
    }
  }

  void _syncWithHardwareSensor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString('pedometer_last_date');
      if (lastDate == todayStr) {
        final baseline = prefs.getInt('pedometer_midnight_baseline') ?? 0;
        if (_currentData.steps == 0 && baseline > 0) {}
      }
    } catch (_) {}
  }

  void _updateData({
    required int steps,
    required int calories,
    required double distanceKm,
    required HealthSourceType sourceType,
    required bool isConnected,
    int? heartRate,
  }) {
    _currentData = HealthActivityData(
      steps: steps,
      calories: calories,
      distanceKm: distanceKm,
      heartRate: heartRate ?? _currentData.heartRate,
      sourceType: sourceType,
      isConnected: isConnected,
    );
    _activityController.add(_currentData);
  }

  void dispose() {
    _stepSubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _activityController.close();
  }
}
