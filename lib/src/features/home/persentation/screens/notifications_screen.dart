import 'package:customer_mobile_app/imports_bindings.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/svg/icons/notification_icon.svg',
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Main Empty Text
              Text(
                'No Notifications',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                "You don't have any notifications at the moment. We'll let you know when updates arrive.",
                textAlign: TextAlign.center,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF7A7A7A),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
