import 'package:customer_mobile_app/imports_bindings.dart';

class GuestLoginSheet extends StatelessWidget {
  const GuestLoginSheet({this.message, super.key});

  final String? message;

  static Future<void> show(BuildContext context, {String? message}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => GuestLoginSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.person_outline_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Guest Account',
            style: AppStyles.text18Px.poppins.w600.dark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Please log in to view and manage your profile details.',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pop();
                context.push(const SentOtpScreen());
              },
              child: const Text('Log In'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
