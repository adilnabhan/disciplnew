import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';
import 'package:customer_mobile_app/src/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:customer_mobile_app/src/features/social/presentation/screens/social_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({this.navIndex, super.key});

  final int? navIndex;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit(navIndex: widget.navIndex);
    _cubit.fetchActiveMembership();
  }

  Widget _buildProfileTabIcon(bool isSelected) {
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final String? profilePicUrl = currentUser?.profilePicture as String?;

    return Container(
      width: 24,
      height: 24,
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
        child:
            (profilePicUrl != null && profilePicUrl.isNotEmpty)
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final currentUser = Feggy.read<AppCubit>()?.state.currentUser;

          // Check if customer is a Gym-Assigned Member
          bool isGymMember = false;
          if (currentUser != null) {
            // Check active membership state
            state.activeMembershipData.fold(() {}, (either) {
              either.fold((_) {}, (activeMembership) {
                if (activeMembership != null) {
                  isGymMember = true;
                }
              });
            });

            // Default logged-in users with customer profile to Gym Member view
            if (!isGymMember && currentUser.customer != null) {
              isGymMember = true;
            }
          }

          // Gym Members get 5 Tabs (Home, Workouts, Nutrition, Score Card, Profile - NO Explore)
          // Individual/Guest Members get 4 Standard Tabs (Home, Workouts, Explore, Profile)
          final List<Widget> pages = isGymMember
              ? const [
                  HomeScreen(),
                  WorkoutLogScreen(),
                  NutritionScreen(),
                  SocialScreen(),
                  ProfileScreen(),
                ]
              : const [
                  HomeScreen(),
                  WorkoutLogScreen(),
                  FitnessCentersListingScreen(),
                  ProfileScreen(),
                ];

          final List<String> labels = isGymMember
              ? ['Home', 'Workouts', 'Nutrition', 'Score Card', 'Profile']
              : ['Home', 'Workouts', 'Explore', 'Profile'];

          final List<String> icons = isGymMember
              ? [
                  'assets/images/svg/icons/new_home_notselected.svg',
                  'assets/images/svg/icons/workout_notseleted.svg',
                  'nutrition',
                  'social',
                  'assets/images/svg/icons/person.svg',
                ]
              : [
                  'assets/images/svg/icons/new_home_notselected.svg',
                  'assets/images/svg/icons/workout_notseleted.svg',
                  'assets/images/svg/icons/not selected_explore.svg',
                  'assets/images/svg/icons/person.svg',
                ];

          final currentIndex = state.navIndex.clamp(0, pages.length - 1);

          return Scaffold(
            appBar: currentIndex == 0
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
            body: LazyIndexedStack(
              index: currentIndex,
              children: pages,
            ),
            extendBody: false,
            bottomNavigationBar: Container(
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGrey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  labels.length,
                  (i) {
                    final isSelected = currentIndex == i;
                    final isProfile = isGymMember ? i == 4 : i == 3;
                    final isNutrition = isGymMember && i == 2;
                    final isScoreCard = isGymMember && i == 3;

                    return Expanded(
                      child: InkWell(
                        onTap: () => context.read<DashboardCubit>().changeNav(index: i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isProfile)
                              _buildProfileTabIcon(isSelected)
                            else if (isNutrition)
                              Icon(
                                Icons.restaurant_menu_rounded,
                                size: 22,
                                color: isSelected ? const Color(0xFF10B981) : AppColors.textGrey,
                              )
                            else if (isScoreCard)
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 22,
                                color: isSelected ? const Color(0xFFF59E0B) : AppColors.textGrey,
                              )
                            else
                              SvgPicture.asset(
                                (i == 0 && isSelected)
                                    ? 'assets/images/svg/icons/new_home_selected.svg'
                                    : (i == 1 && isSelected)
                                        ? 'assets/images/svg/icons/workout_selected.svg'
                                        : (!isGymMember && i == 2 && isSelected)
                                            ? 'assets/images/svg/icons/selected_explore.svg'
                                            : icons[i],
                                width: 22,
                                height: 22,
                                color: (i == 0 && isSelected) || (!isGymMember && i == 2 && isSelected)
                                    ? null
                                    : isSelected
                                        ? AppColors.primary
                                        : AppColors.textGrey,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.text10Px.poppins.copyWith(
                                color: isSelected
                                    ? (isNutrition
                                        ? const Color(0xFF10B981)
                                        : isScoreCard
                                            ? const Color(0xFFF59E0B)
                                            : AppColors.primary)
                                    : AppColors.textGrey,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
          );
        },
      ),
    );
  }
}

class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activated.length != widget.children.length) {
      _activated = List<bool>.generate(
        widget.children.length,
        (i) => i < _activated.length ? _activated[i] : false,
      );
    }
    if (!_activated[widget.index]) {
      setState(() {
        _activated[widget.index] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List<Widget>.generate(widget.children.length, (i) {
        return _activated[i] ? widget.children[i] : const SizedBox.shrink();
      }),
    );
  }
}
