import 'package:customer_mobile_app/src/features/notifications/domain/models/notification_model.dart';
import 'package:flutter/foundation.dart';

enum NotificationStatus { initial, loading, loaded, error }

@immutable
class NotificationState {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
