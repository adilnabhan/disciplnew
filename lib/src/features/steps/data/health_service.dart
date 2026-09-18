import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

enum HealthConnectState {
  notAndroid,
  sdkUnavailable,
  permissionDenied,
  permissionGranted,
  error,
}

class HealthService {
  final Health _health = Health();
  bool _isConfigured = false;

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      await _health.configure();
      _isConfigured = true;
    }
  }

  /// Checks if Health Connect SDK is installed / available on Android.
  Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      debugPrint('HealthService.isHealthConnectAvailable error: $e');
      return false;
    }
  }

  /// Checks if Step reading permission is already granted.
  Future<bool> hasStepPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      await _ensureConfigured();
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];
      final hasPerm = await _health.hasPermissions(types, permissions: permissions);
      return hasPerm ?? false;
    } catch (e) {
      debugPrint('HealthService.hasStepPermission error: $e');
      return false;
    }
  }

  /// Requests permission to read Steps from Health Connect.
  Future<bool> requestStepPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      await _ensureConfigured();
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      return granted;
    } catch (e) {
      debugPrint('HealthService.requestStepPermission error: $e');
      return false;
    }
  }

  /// Fetches today's total steps (00:00:00 to now).
  /// Returns null if error or permission denied, or int count.
  Future<int?> getTodaySteps() async {
    if (!Platform.isAndroid) return null;
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('HealthService.getTodaySteps error: $e');
      return null;
    }
  }
}
