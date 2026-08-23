import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _notifications = [
    {
      'title': '🏆 You are Today\'s Champion!',
      'message': 'Congratulations! You placed #1 on the Test Gym Leaderboard today with 5 points!',
      'time': '5m ago',
      'icon': 'trophy',
    },
    {
      'title': 'Workout Assigned',
      'message': 'Jazim J assigned you \'gym plan\'.',
      'time': '32m ago',
      'icon': 'workout',
    },
    {
      'title': 'Workout Assigned',
      'message': 'Jazim J assigned you \'new\'.',
      'time': '37m ago',
      'icon': 'workout',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(ApiUris.notifications);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data['results'] ?? res.data['data'] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            _notifications = list.map((item) {
              return {
                'title': (item['title'] ?? 'Notification').toString(),
                'message': (item['message'] ?? item['body'] ?? '').toString(),
                'time': (item['created_at'] ?? item['time'] ?? 'Just now').toString(),
                'icon': (item['type'] ?? 'general').toString().contains('champion') ? 'trophy' : 'workout',
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final n = _notifications[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE4E6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      n['icon'] == 'trophy' ? Icons.notifications_active : Icons.fitness_center,
                      color: const Color(0xFFE11D48),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title']!,
                          style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n['message']!,
                          style: AppStyles.text12Px.poppins.w400.copyWith(color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n['time']!,
                          style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
