import 'package:flutter/foundation.dart';

@immutable
class NotificationActionModel {
  const NotificationActionModel({
    this.screen,
    this.id,
    this.data,
  });

  factory NotificationActionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationActionModel();
    return NotificationActionModel(
      screen: json['screen'] as String?,
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final String? screen;
  final int? id;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() {
    return {
      'screen': screen,
      'id': id,
      'data': data,
    };
  }
}

@immutable
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.action,
    this.iconUrl,
    this.status,
    this.remarks,
    this.sessionId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actionObj = json['action'] as Map<String, dynamic>?;
    final actionData = actionObj?['data'] as Map<String, dynamic>?;

    final String? parsedStatus = json['status'] as String? ?? actionData?['status'] as String?;
    final String? parsedRemarks = json['remarks'] as String? ?? actionData?['remarks'] as String?;

    int? parsedSessionId;
    if (json['session_id'] != null) {
      parsedSessionId = json['session_id'] is int
          ? json['session_id'] as int
          : int.tryParse(json['session_id'].toString());
    } else if (actionObj?['id'] != null) {
      parsedSessionId = actionObj!['id'] is int
          ? actionObj['id'] as int
          : int.tryParse(actionObj['id'].toString());
    }

    return NotificationModel(
      id: json['id'] as int? ?? parsedSessionId ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'workout_assigned',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      action: NotificationActionModel.fromJson(actionObj),
      iconUrl: json['icon_url'] as String?,
      status: parsedStatus,
      remarks: parsedRemarks,
      sessionId: parsedSessionId,
    );
  }

  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final NotificationActionModel? action;
  final String? iconUrl;
  final String? status;
  final String? remarks;
  final int? sessionId;

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    NotificationActionModel? action,
    String? iconUrl,
    String? status,
    String? remarks,
    int? sessionId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      iconUrl: iconUrl ?? this.iconUrl,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'action': action?.toJson(),
      'icon_url': iconUrl,
      'status': status,
      'remarks': remarks,
      'session_id': sessionId,
    };
  }
}
