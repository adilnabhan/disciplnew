import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Check if Health permissions are available
      bool? hasPerms;
      try {
        hasPerms = await _health.hasPermissions(_healthTypes, permissions: _healthPermissions);
      } catch (_) {
        hasPerms = false;
      }

      if (hasPerms == true) {
        // Fetch total steps for today from Google Fit / Health Connect
        final int? googleSteps = await _health.getTotalStepsInInterval(midnight, now);

        if (googleSteps != null && googleSteps > 0) {
          final int steps = googleSteps;
          final int calories = (steps * 0.045).round();
          final double distance = double.parse((steps * 0.00075).toStringAsFixed(2));

          _updateData(
            steps: steps,
            calories: calories,
            distanceKm: distance,
            sourceType: HealthSourceType.googleFitHealthConnect,
            isConnected: true,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint("Error syncing Health Data from Google Fit: $e");
    }

    // Fallback: If Google Fit has 0 or unavailable, rely on hardware pedometer sensor
    _syncWithHardwareSensor();
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
        // Device rebooted or counter reset
        todaySteps = rawCumulativeSteps;
        await prefs.setInt('pedometer_midnight_baseline', rawCumulativeSteps);
      }

      // If Google Fit is not active or reporting lower, use live hardware count
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
        if (_currentData.steps == 0 && baseline > 0) {
          // If we had steps, calculate
        }
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
