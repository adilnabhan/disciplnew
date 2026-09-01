import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/nutrition_screen.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/scoreboard_screen.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/partner_qr_pass_screen.dart';
import 'package:customer_mobile_app/src/features/marketplace/presentation/screens/trainer_marketplace_screen.dart';

///* This class contains dashbpard screen
///*eg : Pages manager , bottom nav ...
class DashboardScreen extends StatefulWidget {
  ///*
  const DashboardScreen({this.navIndex, super.key});

  final int? navIndex;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;
  late final List<String> _icons;
  late final List<String> _labels;
  late final PageController _pageController;

  @override
  void initState() {
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;

    _pageController = PageController(initialPage: widget.navIndex ?? 0);
    _cubit = DashboardCubit(navIndex: widget.navIndex);
    _icons = [
      'assets/images/svg/icons/new_home_notselected.svg',
      'assets/images/svg/icons/workout_notseleted.svg',
      'assets/images/svg/icons/workout_notseleted.svg',
      'assets/images/svg/icons/new_home_notselected.svg',
      'assets/images/svg/icons/not selected_explore.svg',
      'assets/images/svg/icons/person.svg',
    ];

    _labels = [
      'Home',
      'Workouts',
      'Trainers',
      'Nutrition',
      'Score Card',
      'Profile',
    ];
    super.initState();
  }

  Widget _buildProfileTabIcon(bool isSelected) {
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final String? profilePicUrl = currentUser?.profilePicture as String?;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: (profilePicUrl != null && profilePicUrl.isNotEmpty)
            ? ImageNetwork(
                profilePicUrl,
                fit: BoxFit.cover,
                errorWidget: SvgPicture.asset(
                  'assets/images/svg/icons/person.svg',
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primary : AppColors.textGrey,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : SvgPicture.asset(
                'assets/images/svg/icons/person.svg',
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.textGrey,
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }



  @override
  void dispose() {
    _cubit.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCustomer;
    if (Feggy.read<AppCubit>()?.state.currentUser == null) {
      isCustomer = false;
    } else {
      isCustomer = true;
    }
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<DashboardCubit, DashboardState>(
        listenWhen: (p, c) => p.navIndex != c.navIndex,
        listener: (context, state) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(state.navIndex);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: state.navIndex == 0
                ? AppBar(
                    title: Image.asset(
                      'assets/images/png/vectors/discipl_spell.png',
                      height: 24,
                    ),
                    centerTitle: false,
                    actions: [
                      GestureDetector(
                        onTap: () {
                          context.push(const PartnerQrPassScreen());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE50914), Color(0xFFB81D24)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x4DE50914), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'QR PASS',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () {
                          context.push(const NotificationsScreen());
                        },
                        child: SvgPicture.asset(
                          'assets/images/svg/icons/notification_icon.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          context.push(const SettingsScreen());
                        },
                        child: SvgPicture.asset(
                          'assets/images/svg/icons/settings _icon.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  )
                : null,
            body: PageView(
              controller: _pageController,
              onPageChanged:
                  (index) => context
                      .read<DashboardCubit>()
                      .changeNav(index: index),
              children: const [
                HomeScreen(),
                WorkoutLogScreen(),
                TrainerMarketplaceScreen(),
                NutritionScreen(),
                ScoreboardScreen(),
                ProfileScreen(),
              ],
            ),
            extendBody: false,
            bottomNavigationBar: Container(
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                border: Border(
                  top: BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  // Top Marigold Floral Garland Trim Line
                  Container(
                    height: 16,
                    color: const Color(0xFFFEF3C7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('🌼 🌸 🌿 🌼 🌸 🌿 🌼 🌸 🌿 🌼', style: TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _icons.length,
                        (i) {
                          final isSelected = state.navIndex == i;
                          final Color activeCol = (i == 0) ? const Color(0xFFDC2626) : const Color(0xFF0D3B2E);
                          return Expanded(
                            child: InkWell(
                              onTap: () => context.read<DashboardCubit>().changeNav(index: i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (i == 5)
                                    _buildProfileTabIcon(isSelected)
                                  else
                                    Icon(
                                      i == 0
                                          ? Icons.home_rounded
                                          : i == 1
                                              ? Icons.fitness_center_rounded
                                              : i == 2
                                                  ? Icons.groups_rounded
                                                  : i == 3
                                                      ? Icons.restaurant_menu_rounded
                                                      : Icons.emoji_events_rounded,
                                      size: 22,
                                      color: isSelected ? activeCol : const Color(0xFF94A3B8),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _labels[i],
                                    style: AppStyles.text10Px.poppins.copyWith(
                                      color: isSelected ? activeCol : const Color(0xFF64748B),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
