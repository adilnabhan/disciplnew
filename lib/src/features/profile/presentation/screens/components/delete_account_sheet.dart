import 'package:customer_mobile_app/imports_bindings.dart';

class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key});

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delete Account',
              style: AppStyles.text18Px.poppins.w600.dark,
            ),
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.close, color: AppColors.textGrey),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Warning text
        Text(
          'Are you sure you want to delete your account?',
          style: AppStyles.text14Px.poppins.w500.dark,
        ),
        const SizedBox(height: 8),
        Text(
          'This action is permanent and cannot be undone. All your data will be removed.',
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Flexible(
              child: Button.filled(
                ontap: context.pop,
                title: 'Cancel',
                style: AppStyles.text14Px.poppins.w500.dark,
                buttonColor: AppColors.disabledButton,
              ).pOnly(right: 8),
            ),
            Flexible(
              child: Button.filled(
                buttonColor: Colors.red,
                ontap: () async {
                  // 1️⃣ Call delete account API
                  // await context.read<AppCubit>().deleteAccount();

                  // 2️⃣ Clear user data
                  context.read<AppCubit>().removeUser();

                  // 3️⃣ Redirect to auth
                  context.pushAndRemoveUntil(const SentOtpScreen());
                },
                title: 'Delete',
                style: AppStyles.text14Px.poppins.w500.light,
              ).pOnly(left: 8),
            ),
          ],
        ),
      ],
    ).pad(16).pOnly(bottom: 32);
  }
}
