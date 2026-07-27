import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Dio _dio = DioClient().dio;
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get<dynamic>(
        ApiUris.notifications,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data.containsKey('results')) {
          setState(() {
            _notifications = (data['results'] as List?) ?? [];
            _isLoading = false;
          });
        } else if (data is List) {
          setState(() {
            _notifications = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _notifications = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.markNotificationRead(notificationId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications[index]['is_read'] = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.markAllNotificationsRead,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var item in _notifications) {
            item['is_read'] = true;
          }
        });
      }
    } catch (_) {}
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'streak_warning':
        return Icons.local_fire_department_rounded;
      case 'streak_milestone':
        return Icons.emoji_events_rounded;
      case 'workout_missed':
        return Icons.warning_amber_rounded;
      case 'workout_assigned':
        return Icons.fitness_center_rounded;
      case 'workout_updated':
        return Icons.edit_calendar_rounded;
      case 'membership_approved':
        return Icons.verified_user_rounded;
      case 'membership_rejected':
        return Icons.cancel_rounded;
      case 'achievement':
        return Icons.military_tech_rounded;
      case 'workout_review':
        return Icons.rate_review_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'streak_warning':
        return Colors.orange;
      case 'streak_milestone':
        return Colors.amber;
      case 'workout_missed':
        return Colors.redAccent;
      case 'workout_assigned':
        return AppColors.primary;
      case 'membership_approved':
        return Colors.green;
      case 'membership_rejected':
        return Colors.red;
      case 'achievement':
        return Colors.purple;
      case 'workout_review':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF212121),
          ),
        ),
        actions: [
          if (_notifications.any((item) => item['is_read'] == false))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: AppColors.primary,
        child: _buildBody(isCustomer),
      ),
    );
  }

  Widget _buildBody(bool isCustomer) {
    if (!isCustomer) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_outline, size: 36, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Guest Account',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please log in to see your notifications.",
                textAlign: TextAlign.center,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF7A7A7A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(const SentOtpScreen());
                  },
                  child: const Text('Log In'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Notifications',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up! Notifications will appear here.",
                  textAlign: TextAlign.center,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF7A7A7A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        final id = item['id'] as int? ?? 0;
        final type = item['type'] as String? ?? 'reminder';
        final title = item['title'] as String? ?? 'Notification';
        final message = item['message'] as String? ?? '';
        final isRead = item['is_read'] as bool? ?? false;
        final createdAt = item['created_at'] as String? ?? '';

        final iconData = _getNotificationIcon(type);
        final iconColor = _getNotificationColor(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isRead
                ? null
                : Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () {
              if (!isRead && id > 0) {
                _markAsRead(id, index);
              }
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(createdAt),
                    style: AppStyles.text10Px.poppins.w400.copyWith(
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return rawDate;
    }
  }
}
