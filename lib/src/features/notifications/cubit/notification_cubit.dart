import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_state.dart';
import 'package:customer_mobile_app/src/features/notifications/domain/repositories/notification_repository.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository(),
        super(const NotificationState());

  final NotificationRepository _repository;

  Future<void> fetchUnreadCount() async {
    final count = await _repository.getUnreadCount();
    emit(state.copyWith(unreadCount: count));
  }

  Future<void> fetchNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await _repository.getNotifications();
    result.fold(
      (error) {
        emit(state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Failed to load notifications',
        ));
      },
      (notifications) {
        final unread = notifications.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> refreshNotifications() async {
    final result = await _repository.getNotifications();
    result.fold(
      (_) {},
      (notifications) {
        final unread = notifications.where((n) => !n.isRead).length;
        emit(state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> markAsRead(int id) async {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    final newUnreadCount = updatedList.where((n) => !n.isRead).length;

    emit(state.copyWith(
      notifications: updatedList,
      unreadCount: newUnreadCount,
    ));

    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final updatedList =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
    ));

    await _repository.markAllAsRead();
  }
}
