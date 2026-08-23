import 'package:customer_mobile_app/imports_bindings.dart';

class SetupCompleteStep extends StatelessWidget {
  final LoginSuccessModel? login;
  const SetupCompleteStep({this.login});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        /// Right side mascot image
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            'assets/images/png/vectors/registation_complet.png',
            width: 300,
            height: size.height / 1.6,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height / 15),

              /// Title
              Text(
                "You're all set, ${login?.firstName} ${login?.lastName}! 👋",
                style: AppStyles.text36Px.w500.copyWith(color: AppColors.dark),
              ),

              const SizedBox(height: 16),

              /// Subtitle — UPDATED ✅
              LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    'Your new fitness journey begins today. Lets connect you to the right fitness center, the right people, and the right motivation.',
                    textAlign: TextAlign.start,
                    style: AppStyles.text15Px.w400.copyWith(
                      color: AppColors.dark.withOpacity(0.7),
                    ),
                  );
                },
              ),

              const Expanded(child: SizedBox()),

              /// Continue with Google button
              const SizedBox(height: 14),

              /// Continue with OTP button
              const SizedBox(height: 20),
              Button.filled(
                title: 'Find my Fitness Center',
                ontap: () {
                  context.read<AppCubit>().addUser(login!);
                  if (login?.customer?.organizationId == null) {
                    context.pushAndRemoveUntil(const DashboardScreen(navIndex: 2));
                  } else {
                    context.pushAndRemoveUntil(const DashboardScreen());
                  }
                },
              ),
              const SizedBox(height: 20),

              /// Footer text
              Center(
                child: Text(
                  "You've already taken the first step —\nlet’s keep the momentum!",
                  textAlign: TextAlign.center,
                  style: AppStyles.text16Px.w400.copyWith(
                    color: AppColors.dark.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ],
    );
  }
}
