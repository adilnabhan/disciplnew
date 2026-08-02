import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/dashboard/logic/dashboard/dashboard_cubit.dart';
import 'package:customer_mobile_app/src/features/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_cubit.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_state.dart';
import 'package:customer_mobile_app/src/features/notifications/domain/models/notification_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_details_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_log_screen.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationCubit _cubit;
  bool _shouldDisposeCubit = false;

  @override
  void initState() {
    super.initState();
    try {
      _cubit = context.read<NotificationCubit>();
      _shouldDisposeCubit = false;
    } catch (_) {
      _cubit = NotificationCubit();
      _shouldDisposeCubit = true;
    }
    _cubit.fetchNotifications();
  }

  @override
  void dispose() {
    if (_shouldDisposeCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final diff = now.difference(local);

    final hourString = (local.hour % 12 == 0 ? 12 : local.hour % 12).toString().padLeft(2, '0');
    final minuteString = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hourString:$minuteString $period';

    if (diff.inDays == 0 && now.day == local.day) {
      return 'Today • $timeStr';
    } else if (diff.inDays == 1 || (now.day - local.day == 1 && diff.inHours < 48)) {
      return 'Yesterday • $timeStr';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[local.month - 1]} ${local.day} • $timeStr';
    }
  }

  Widget _buildTypeIcon(NotificationModel item) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    final type = item.type.toLowerCase();
    final status = (item.status ?? '').toLowerCase();
    final title = item.title.toLowerCase();

    final isRejected = status == 'rejected' || title.contains('reject') || type.contains('reject');
    final isApproved = status == 'verified' || status == 'approved' || title.contains('approve') || type.contains('approve');

    if (type.contains('workout_review') || isRejected || isApproved || title.contains('feedback')) {
      if (isRejected) {
        icon = Icons.cancel_rounded;
        iconColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
      } else if (isApproved) {
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
      } else {
        icon = Icons.rate_review_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.1);
      }
    } else {
      switch (type) {
        case 'workout_assigned':
          icon = Icons.fitness_center_rounded;
          iconColor = AppColors.primary;
          bgColor = AppColors.primary.withOpacity(0.1);
          break;
        case 'workout_updated':
          icon = Icons.edit_note_rounded;
          iconColor = Colors.orange;
          bgColor = Colors.orange.withOpacity(0.1);
          break;
        case 'workout_removed':
          icon = Icons.delete_outline_rounded;
          iconColor = Colors.redAccent;
          bgColor = Colors.redAccent.withOpacity(0.1);
          break;
        case 'trainer_message':
          icon = Icons.chat_bubble_outline_rounded;
          iconColor = Colors.blue;
          bgColor = Colors.blue.withOpacity(0.1);
          break;
        case 'membership_approved':
          icon = Icons.verified_rounded;
          iconColor = Colors.green;
          bgColor = Colors.green.withOpacity(0.1);
          break;
        case 'membership_rejected':
          icon = Icons.warning_amber_rounded;
          iconColor = Colors.deepOrange;
          bgColor = Colors.deepOrange.withOpacity(0.1);
          break;
        case 'gym_announcement':
          icon = Icons.campaign_rounded;
          iconColor = Colors.purple;
          bgColor = Colors.purple.withOpacity(0.1);
          break;
        case 'progress_achievement':
          icon = Icons.emoji_events_rounded;
          iconColor = Colors.amber.shade700;
          bgColor = Colors.amber.withOpacity(0.1);
          break;
        default:
          icon = Icons.notifications_active_rounded;
          iconColor = AppColors.primary;
          bgColor = AppColors.primary.withOpacity(0.1);
      }
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  void _onNotificationTap(BuildContext context, NotificationModel item) {
    if (!item.isRead) {
      _cubit.markAsRead(item.id);
    }

    final type = item.type.toLowerCase();

    // If workout review, show dedicated bottom sheet details
    if (type.contains('workout_review')) {
      _showWorkoutReviewBottomSheet(context, item);
      return;
    }

    // Stay on current screen for membership/gym notifications
    if (type.contains('membership') || type.contains('announcement') || type.contains('gym')) {
      return;
    }

    try {
      context.read<DashboardCubit>().changeNav(index: 1);
      Navigator.of(context).pop();
    } catch (_) {
      context.pushAndRemoveUntil(const DashboardScreen(navIndex: 1));
    }
  }

  void _showWorkoutReviewBottomSheet(BuildContext context, NotificationModel item) {
    final status = (item.status ?? '').toLowerCase();
    final title = item.title.toLowerCase();
    final type = item.type.toLowerCase();

    final isRejected = status == 'rejected' || title.contains('reject') || type.contains('reject');
    final isApproved = status == 'verified' || status == 'approved' || title.contains('approve') || type.contains('approve');

    Color themeColor;
    Color lightBgColor;
    IconData headerIcon;
    String statusBadgeLabel;

    if (isRejected) {
      themeColor = const Color(0xFFEF4444);
      lightBgColor = const Color(0xFFFEF2F2);
      headerIcon = Icons.cancel_rounded;
      statusBadgeLabel = 'WORKOUT REJECTED';
    } else if (isApproved) {
      themeColor = const Color(0xFF10B981);
      lightBgColor = const Color(0xFFECFDF5);
      headerIcon = Icons.task_alt_rounded;
      statusBadgeLabel = 'WORKOUT APPROVED';
    } else {
      themeColor = AppColors.primary;
      lightBgColor = AppColors.primary.withOpacity(0.08);
      headerIcon = Icons.rate_review_rounded;
      statusBadgeLabel = 'FEEDBACK RECEIVED';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status Icon Circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: lightBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    headerIcon,
                    color: themeColor,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: lightBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusBadgeLabel,
                  style: AppStyles.text12Px.poppins.w700.copyWith(
                    color: themeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: AppStyles.text18Px.poppins.w700.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),

              // Message Body
              Text(
                item.message,
                textAlign: TextAlign.center,
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Remarks Box (if available)
              if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeColor.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment_rounded, size: 16, color: themeColor),
                          const SizedBox(width: 6),
                          Text(
                            'TRAINER FEEDBACK & REMARKS',
                            style: AppStyles.text10Px.poppins.w700.copyWith(
                              color: themeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.remarks!,
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: const Color(0xFF1F2937),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Session ID Tag
              if (item.sessionId != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      'Session #${item.sessionId}',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        try {
                          context.read<DashboardCubit>().changeNav(index: 1);
                          Navigator.of(context).pop();
                        } catch (_) {
                          context.pushAndRemoveUntil(const DashboardScreen(navIndex: 1));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Workout Log',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
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
                    color: Color(0xFFF0F2F5),
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
        ),
        body: !isCustomer
            ? _buildGuestView(context)
            : BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state.status == NotificationStatus.loading) {
                    return _buildShimmerLoading();
                  }

                  if (state.status == NotificationStatus.error) {
                    return _buildErrorState();
                  }

                  if (state.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => _cubit.refreshNotifications(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.notifications[index];
                        return _buildNotificationCard(context, item);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item) {
    final bool isUnread = !item.isRead;
    final String type = item.type.toLowerCase();
    final String status = (item.status ?? '').toLowerCase();
    final String title = item.title.toLowerCase();

    final isRejected = status == 'rejected' || title.contains('reject') || type.contains('reject');
    final isApproved = status == 'verified' || status == 'approved' || title.contains('approve') || type.contains('approve');
    final isWorkoutReview = type.contains('workout_review') || isRejected || isApproved || title.contains('feedback');

    Color statusBadgeColor = AppColors.primary;
    String? statusBadgeLabel;

    if (isWorkoutReview) {
      if (isRejected) {
        statusBadgeColor = const Color(0xFFEF4444);
        statusBadgeLabel = 'REJECTED';
      } else if (isApproved) {
        statusBadgeColor = const Color(0xFF10B981);
        statusBadgeLabel = 'APPROVED';
      } else {
        statusBadgeColor = AppColors.primary;
        statusBadgeLabel = 'FEEDBACK';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF6F6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? const Color(0xFFFFD6D6) : const Color(0xFFEEEEEE),
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onNotificationTap(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                _buildTypeIcon(item),
                const SizedBox(width: 14),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          if (statusBadgeLabel != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusBadgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusBadgeColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                statusBadgeLabel,
                                style: AppStyles.text10Px.poppins.w700.copyWith(
                                  color: statusBadgeColor,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (isUnread) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: AppStyles.text10Px.poppins.w700.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: AppStyles.text13Px.poppins.w400.copyWith(
                          color: const Color(0xFF555555),
                          height: 1.4,
                        ),
                      ),
                      if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusBadgeColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(color: statusBadgeColor, width: 3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.comment_rounded, size: 14, color: statusBadgeColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.remarks!,
                                  style: AppStyles.text12Px.poppins.w500.copyWith(
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(item.createdAt),
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Tap to view',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: isWorkoutReview ? statusBadgeColor : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: isWorkoutReview ? statusBadgeColor : AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Notifications Yet",
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll notify you when your trainer assigns workouts or sends updates.",
              textAlign: TextAlign.center,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: const Color(0xFF7A7A7A),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while connecting to the server.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _cubit.fetchNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                  Icons.person_outline_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Guest Account',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to see your notifications.',
              textAlign: TextAlign.center,
              style: AppStyles.text13Px.poppins.w400.copyWith(
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
}
