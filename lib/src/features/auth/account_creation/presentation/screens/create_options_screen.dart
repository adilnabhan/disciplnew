import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/auth/account_creation/cubit/guest_account/guest_account.dart';

class CreateOptionsScreen extends StatelessWidget {
  const CreateOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GuestAccountCubit()),
        BlocProvider(create: (_) => AppCubit()),
      ],
      child: const CreateOptionsPage(),
    );
  }
}

class CreateOptionsPage extends StatefulWidget {
  const CreateOptionsPage({super.key});

  @override
  State<CreateOptionsPage> createState() => _CreateOptionsPageState();
}

class _CreateOptionsPageState extends State<CreateOptionsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// Right side mascot image
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/png/vectors/welcome_discipl.png',
                width: 270,
                height: size.height / 1.4,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height / 7.5),

                  /// Title
                  Text(
                    'Welcome to\nDiscipl 👋',
                    style: AppStyles.text36Px.w500.copyWith(
                      color: AppColors.dark,
                      // height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Subtitle — UPDATED ✅
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        'You’re not just joining an app. You’re choosing a lifestyle. 🎉✨',
                        textAlign: TextAlign.start,
                        style: AppStyles.text15Px.w400.copyWith(
                          color: AppColors.dark.withOpacity(0.7),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  /// Continue with Google button
                  // _LoginButton(
                  //   icon: 'assets/images/png/vectors/image 62.png',
                  //   label: 'Continue with Google',
                  //   onTap: () {},
                  //   outlined: true,
                  // ),
                  const SizedBox(height: 14),

                  /// Continue with OTP button
                  _LoginButton(
                    icon: 'assets/images/png/vectors/Vector.png',
                    label: 'Continue with Mobile OTP',
                    onTap: () {
                      context.push(const SentOtpScreen());
                    },
                    outlined: true,
                  ),

                  const SizedBox(height: 20),

                  /// Footer text
                  Center(
                    child: Text(
                      "You've already taken the first step —\nlet’s keep the momentum!",
                      textAlign: TextAlign.center,
                      style: AppStyles.text15Px.w400.copyWith(
                        color: AppColors.dark.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  BlocBuilder<GuestAccountCubit, GuestAccountState>(
                    builder: (context, state) {
                      return Align(
                        child: InkWell(
                          onTap: () {
                            // context.read<AppCubit>().addUser(r!);
                            context.pushAndRemoveUntil(const DashboardScreen());
                          },
                          child: Text(
                            'Skip login >',
                            style: AppStyles.text16Px.w500.copyWith(
                              color: AppColors.primary,
                              // height: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable button widget
class _LoginButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _LoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: outlined ? Colors.white : AppColors.dark,

          /// ✅ Button shadow instead of border
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.14),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 20, height: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppStyles.text16Px.w600.copyWith(
                color: outlined ? AppColors.dark : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
