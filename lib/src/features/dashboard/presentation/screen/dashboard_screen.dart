import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';

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
      'assets/images/svg/icons/not selected_explore.svg',
      'assets/images/svg/icons/person.svg',
    ];

    _labels = [
      'Home',
      'Workouts',
      'Explore',
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
                          context.push(const NotificationsScreen());
                        },
                        child: SvgPicture.asset(
                          'assets/images/svg/icons/notification_icon.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      const SizedBox(width: 20),
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
                      const SizedBox(width: 20),
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
                FitnessCentersListingScreen(),
                ProfileScreen(),
              ],
            ),
            extendBody: false,
            bottomNavigationBar: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGrey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                List.generate(
                  _icons.length,
                  (i) => Expanded(
                    child: InkWell(
                      onTap:
                          () => context.read<DashboardCubit>().changeNav(
                            index: i,
                          ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i == 3)
                            _buildProfileTabIcon(state.navIndex == i)
                          else
                            SvgPicture.asset(
                              (i == 0 && state.navIndex == i)
                                  ? 'assets/images/svg/icons/new_home_selected.svg'
                                  : (i == 1 && state.navIndex == i)
                                  ? 'assets/images/svg/icons/workout_selected.svg'
                                  : (i == 2 && state.navIndex == i)
                                  ? 'assets/images/svg/icons/selected_explore.svg'
                                  : _icons[i],
                              width: 24,
                              height: 24,
                              color: (i == 0 && state.navIndex == i) || (i == 2 && state.navIndex == i)
                                  ? null
                                  : state.navIndex == i
                                      ? AppColors.primary
                                      : AppColors.textGrey,
                            ),
                          const SizedBox(height: 6),
                          Text(
                            _labels[i],
                            style: AppStyles.text12Px.poppins.copyWith(
                              color:
                                  state.navIndex == i
                                      ? AppColors.primary
                                      : AppColors.textGrey,
                              fontWeight:
                                  state.navIndex == i
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
