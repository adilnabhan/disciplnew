import 'dart:io';
import 'package:dio/dio.dart';

/// Centralized utility for sanitizing and formatting errors into user-friendly messages.
class AppErrorHandler {
  const AppErrorHandler._();

  /// Converts any exception or error (DioException, SocketException, String, etc.)
  /// into a sanitized, user-friendly message.
  static String extractSafeMessage(
    dynamic error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error == null) return fallback;

    if (error is DioException) {
      return _handleDioException(error, fallback: fallback);
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is FormatException) {
      return 'Unable to process server response. Please try again later.';
    }

    if (error is String) {
      return formatUserFriendlyMessage(error, fallback: fallback);
    }

    return fallback;
  }

  /// Extracts backend validation messages while preventing internal database schema keys
  /// or unparsed brackets/quotes from reaching users.
  static String extractSafeValidationMessage(
    dynamic data, {
    String fallback = 'Invalid request. Please check your details.',
  }) {
    if (data == null) return fallback;

    if (data is Map && data.isNotEmpty) {
      // 1. Check top-level common message keys
      final explicitMsg = data['message'] ?? data['detail'] ?? data['error'];
      if (explicitMsg != null && explicitMsg is String && explicitMsg.trim().isNotEmpty) {
        if (!containsTechnicalArtifacts(explicitMsg)) {
          return formatUserFriendlyMessage(explicitMsg, fallback: fallback);
        }
      }

      // 2. Extract first field validation message (e.g., {"phone": ["Invalid phone number"]})
      final firstKey = data.keys.first;
      final val = data[firstKey];
      if (val is List && val.isNotEmpty) {
        final firstItem = val.first.toString().trim();
        if (!containsTechnicalArtifacts(firstItem)) {
          return formatUserFriendlyMessage(firstItem, fallback: fallback);
        }
      } else if (val is String && val.trim().isNotEmpty) {
        if (!containsTechnicalArtifacts(val)) {
          return formatUserFriendlyMessage(val, fallback: fallback);
        }
      }
    } else if (data is String && data.trim().isNotEmpty) {
      if (!containsTechnicalArtifacts(data)) {
        return formatUserFriendlyMessage(data, fallback: fallback);
      }
    }

    return fallback;
  }

  /// Sanitizes any string meant for UI display by stripping array brackets,
  /// field prefixes, or low-level exception keywords.
  static String formatUserFriendlyMessage(
    String? raw, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;

    var cleaned = raw.trim();

    // Remove JSON list brackets like ["Invalid code"] or [Invalid code]
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
      if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
          (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
        cleaned = cleaned.substring(1, cleaned.length - 1).trim();
      }
    }

    // Strip internal field prefixes like "phone_number: Enter a valid phone"
    if (cleaned.contains(':') && !cleaned.toLowerCase().contains('http')) {
      final parts = cleaned.split(':');
      if (parts.length >= 2) {
        final candidate = parts.sublist(1).join(':').trim();
        if (candidate.isNotEmpty && !containsTechnicalArtifacts(candidate)) {
          cleaned = candidate;
        }
      }
    }

    // If cleaned string still has technical artifacts or raw exceptions, return fallback
    if (containsTechnicalArtifacts(cleaned)) {
      return fallback;
    }

    return cleaned.isNotEmpty ? cleaned : fallback;
  }

  /// Checks if a string contains technical errors, raw exceptions, or internal server details.
  static bool containsTechnicalArtifacts(String str) {
    final lower = str.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('platformexception') ||
        lower.contains('nullpointerexception') ||
        lower.contains('nosuchmethoderror') ||
        lower.contains('formatexception') ||
        lower.contains('handshakeexception') ||
        lower.contains('stack trace') ||
        lower.contains('failed host lookup') ||
        lower.contains('connecting timed out') ||
        lower.contains('connection refused') ||
        lower.contains('sql') ||
        lower.contains('syntax error') ||
        lower.contains('<html>') ||
        lower.contains('<!doctype') ||
        lower.contains('502 bad gateway') ||
        lower.contains('500 internal server error') ||
        lower.contains('unexpected error:') ||
        lower.contains('unexpected server response. code:');
  }

  static String _handleDioException(DioException e, {required String fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection and try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;

        if (statusCode == 400) {
          return extractSafeValidationMessage(
            data,
            fallback: 'Invalid request. Please check your details.',
          );
        } else if (statusCode == 401) {
          return 'Your session has expired. Please log in again.';
        } else if (statusCode == 403) {
          return "You don't have permission to perform this action.";
        } else if (statusCode == 404) {
          return 'The requested information could not be found.';
        } else if (statusCode >= 500) {
          return 'Our servers are temporarily unavailable. Please try again later.';
        }

        return extractSafeValidationMessage(data, fallback: fallback);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please check your network connection.';

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return 'No internet connection. Please check your network and try again.';
        }
        if (e.response?.data != null) {
          return extractSafeValidationMessage(e.response!.data, fallback: fallback);
        }
        return fallback;
    }
  }
}
