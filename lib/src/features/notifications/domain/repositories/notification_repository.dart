import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/notifications/domain/models/notification_model.dart';

@immutable
final class NotificationRepository {
  factory NotificationRepository() {
    _instance ??= NotificationRepository._internal();
    return _instance!;
  }

  NotificationRepository._internal();
  static NotificationRepository? _instance;

  final Dio _dio = DioClient().dio;
  final Set<int> _readNotificationIds = {};

  /// GET /api/v1/customer/notifications/
  Future<Either<ApiException, List<NotificationModel>>> getNotifications() async {
    List<NotificationModel> apiNotifications = [];
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.notificationsList,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> dynamicList = [];
        if (response.data is List) {
          dynamicList = response.data as List<dynamic>;
        } else if (response.data is Map && (response.data as Map)['results'] is List) {
          dynamicList = (response.data as Map)['results'] as List<dynamic>;
        }
        apiNotifications = dynamicList
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .map((n) => _readNotificationIds.contains(n.id) ? n.copyWith(isRead: true) : n)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching notifications from backend API: $e');
    }

    final conditionalNotifications = _generateConditionBasedNotifications();
    for (final item in conditionalNotifications) {
      if (item.type == 'membership_approved' &&
          !apiNotifications.any((n) => n.type == 'membership_approved')) {
        apiNotifications.add(item);
      }
    }

    return right(apiNotifications);
  }

  List<NotificationModel> _generateConditionBasedNotifications() {
    final List<NotificationModel> list = [];
    try {
      final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
      final customerDetails = currentUser?.customer;

      if (currentUser != null && customerDetails != null) {
        final bool hasAssignedGym = customerDetails.assignedFitnessCenter != null ||
            customerDetails.isActiveMember == true;

        if (hasAssignedGym) {
          final String gymName = customerDetails.assignedFitnessCenter?['name']?.toString() ??
              customerDetails.assignedFitnessCenter?['center_name']?.toString() ??
              'your gym';

          list.add(
            NotificationModel(
              id: 9002,
              title: 'Gym Membership Active',
              message: 'Your membership at $gymName is active. Check out your workout goals for today!',
              type: 'membership_approved',
              isRead: _readNotificationIds.contains(9002) || true,
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error generating condition-based notifications: $e');
    }
    return list;
  }

  /// GET /api/v1/customer/notifications/unread-count/
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.unreadNotificationsCount,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data['unread_count'] != null) {
          return response.data['unread_count'] as int;
        } else if (response.data is Map && response.data['count'] != null) {
          return response.data['count'] as int;
        } else if (response.data is int) {
          return response.data as int;
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }

    // Fallback unread count from condition-based notifications
    final list = _generateConditionBasedNotifications();
    return list.where((n) => !n.isRead && !_readNotificationIds.contains(n.id)).length;
  }

  /// PATCH /api/v1/customer/notifications/{id}/read/
  Future<bool> markAsRead(int notificationId) async {
    _readNotificationIds.add(notificationId);
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.markNotificationRead(notificationId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error marking notification $notificationId as read: $e');
      return true;
    }
  }

  /// PATCH /api/v1/customer/notifications/read-all/
  Future<bool> markAllAsRead() async {
    _readNotificationIds.addAll([9001, 9002]);
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.markAllNotificationsRead,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return true;
    }
  }
}
