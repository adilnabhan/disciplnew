import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/customer_membership_details_screen.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/fitness_centers_listing_screen.dart';
import 'package:customer_mobile_app/src/features/home/cubit/app_season_cubit.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_cubit.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_state.dart';
import 'package:customer_mobile_app/src/features/scorecard/presentation/screens/score_card_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/all_challenges_screen.dart';
// ignore: unused_import
import 'package:customer_mobile_app/src/features/steps/presentation/screens/steps_screen.dart'; // Preserved: Steps feature can be toggled back in later

///* This class contains dashboard screen
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
  late final NotificationCubit _notificationCubit;
  late final AppSeasonCubit _appSeasonCubit = AppSeasonCubit();

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit(navIndex: widget.navIndex)..fetchActiveMembership();
    _notificationCubit = NotificationCubit()..fetchUnreadCount();
    _appSeasonCubit.fetchAppSeason();
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
    _notificationCubit.close();
    _appSeasonCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _appSeasonCubit),
      ],
      child: BlocBuilder<AppSeasonCubit, AppSeasonState>(
        bloc: _appSeasonCubit,
        builder: (context, seasonState) {
          final bool isSeasonalActive = seasonState.isActive;
          return BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              // Determine if user has an active gym/membership
              final bool hasActiveGym = state.activeMembershipData.fold(
                () {
                  // Instant fallback evaluation while activeMembershipData is loading (0ms delay)
                  final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
                  if (currentUser?.customer != null) {
                    final c = currentUser!.customer!;
                    if (c.isActiveMember == true ||
                        c.organizationId != null ||
                        c.assignedFitnessCenter != null) {
                      return true;
                    }
                  }
                  return false;
                },
                (either) => either.fold(
                  (error) => false,
                  (activeMembership) =>
                      activeMembership != null &&
                      (activeMembership.isActive == true ||
                          activeMembership.organization != null ||
                          activeMembership.id != null),
                ),
              );

              final List<Widget> tabPages = hasActiveGym
                  ? const [
                      HomeScreen(),
                      WorkoutLogScreen(),
                      ScoreCardScreen(),
                      AllChallengesScreen(isFromBottomNav: true),
                      // StepsScreen(), // Preserved: Steps feature can be toggled back in later
                      ProfileScreen(),
                    ]
                  : const [
                      HomeScreen(),
                      WorkoutLogScreen(),
                      FitnessCentersListingScreen(isFromBottomNav: true),
                      ProfileScreen(),
                    ];

              final List<String> tabLabels = hasActiveGym
                  ? [
                      'Home',
                      'Workouts',
                      'Score Card',
                      'Challenges', // 'Steps',
                      'Profile',
                    ]
                  : ['Home', 'Workouts', 'Explore', 'Profile'];

              int currentIndex = state.navIndex;
              if (currentIndex >= tabPages.length) {
                currentIndex = tabPages.length - 1;
              }

              return Scaffold(
                backgroundColor: isSeasonalActive && currentIndex == 0
                    ? const Color(0xFFFCF2E3)
                    : const Color(0xFFF7F7F7),
                appBar:
                    currentIndex == 0
                        ? (isSeasonalActive
                            ? SeasonalAppBar(
                              seasonName: seasonState.seasonModel.name ?? 'Onam',
                              notificationCubit: _notificationCubit,
                              dashboardCubit: _cubit,
                            )
                            : AppBar(
                              backgroundColor: AppColors.light,
                              surfaceTintColor: Colors.transparent,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              title: Image.asset(
                                'assets/images/png/vectors/discipl_spell.png',
                                height: 24,
                              ),
                              centerTitle: false,
                              actions: [
                                _GymActionIcon(cubit: _cubit),
                                const SizedBox(width: 10),
                                BlocBuilder<NotificationCubit, NotificationState>(
                                  bloc: _notificationCubit,
                                  builder: (context, notificationState) {
                                    final int unreadCount =
                                        notificationState.unreadCount;
                                    return GestureDetector(
                                      onTap: () {
                                        context.push(
                                          MultiBlocProvider(
                                            providers: [
                                              BlocProvider.value(
                                                value: _notificationCubit,
                                              ),
                                              BlocProvider.value(value: _cubit),
                                            ],
                                            child: const NotificationsScreen(),
                                          ),
                                        );
                                        _notificationCubit.fetchUnreadCount();
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEEEEEE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/svg/icons/notification_icon.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            if (unreadCount > 0)
                                              Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 1,
                                                  ),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 16,
                                                    minHeight: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(
                                                      10,
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      unreadCount >= 100
                                                          ? '99+'
                                                          : '$unreadCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                        height: 1.0,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    context.push(const SettingsScreen());
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      'assets/images/svg/icons/settings _icon.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ))
                        : null,
                body: LazyIndexedStack(
                  index: currentIndex,
                  children: tabPages,
                ),
                extendBody: false,
                bottomNavigationBar: Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          top: BorderSide(color: AppColors.borderGrey, width: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(tabLabels.length, (i) {
                          final bool isSelected = currentIndex == i;
                          Widget iconWidget;

                          if (hasActiveGym) {
                            // Active Member Tab Icons (5 tabs: Home, Workouts, Score Card, Challenges, Profile)
                            switch (i) {
                              case 0:
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/new_home_selected.svg'
                                      : 'assets/images/svg/icons/new_home_notselected.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: isSelected
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.textGrey,
                                          BlendMode.srcIn,
                                        ),
                                );
                                break;
                              case 1:
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/workout_selected.svg'
                                      : 'assets/images/svg/icons/workout_notseleted.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(
                                    isSelected ? AppColors.primary : AppColors.textGrey,
                                    BlendMode.srcIn,
                                  ),
                                );
                                break;
                              case 2: // Score Card
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/selected_scorecard.svg'
                                      : 'assets/images/svg/icons/scorecard_notselected.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: isSelected
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.textGrey,
                                          BlendMode.srcIn,
                                        ),
                                );
                                break;
                              case 3: // Challenges (Steps preserved for later use)
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/challenge_selected.svg'
                                      : 'assets/images/svg/icons/challenge_notselected.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: isSelected
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.textGrey,
                                          BlendMode.srcIn,
                                        ),
                                );
                                /*
                                // Preserved Steps icon for later use:
                                iconWidget = Icon(
                                  Icons.directions_walk_rounded,
                                  size: 22,
                                  color: isSelected ? AppColors.primary : AppColors.textGrey,
                                );
                                */
                                break;
                              case 4: // Profile
                                iconWidget = _buildProfileTabIcon(isSelected);
                                break;
                              default:
                                iconWidget = const SizedBox.shrink();
                            }
                          } else {
                            // Regular Tab Icons (4 tabs: Home, Workouts, Explore, Profile)
                            switch (i) {
                              case 0:
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/new_home_selected.svg'
                                      : 'assets/images/svg/icons/new_home_notselected.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: isSelected
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.textGrey,
                                          BlendMode.srcIn,
                                        ),
                                );
                                break;
                              case 1:
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/workout_selected.svg'
                                      : 'assets/images/svg/icons/workout_notseleted.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(
                                    isSelected ? AppColors.primary : AppColors.textGrey,
                                    BlendMode.srcIn,
                                  ),
                                );
                                break;
                              case 2:
                                iconWidget = SvgPicture.asset(
                                  isSelected
                                      ? 'assets/images/svg/icons/selected_explore.svg'
                                      : 'assets/images/svg/icons/not selected_explore.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: isSelected
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.textGrey,
                                          BlendMode.srcIn,
                                        ),
                                );
                                break;
                              case 3:
                                iconWidget = _buildProfileTabIcon(isSelected);
                                break;
                              default:
                                iconWidget = const SizedBox.shrink();
                            }
                          }

                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                context.read<DashboardCubit>().changeNav(index: i);
                                _notificationCubit.fetchUnreadCount();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: isSelected
                                    ? BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    iconWidget,
                                    const SizedBox(height: 4),
                                    Text(
                                      tabLabels[i],
                                      style: AppStyles.text12Px.poppins.copyWith(
                                        fontSize: 10,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textGrey,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              );
            },
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
    if (widget.index >= 0 && widget.index < _activated.length && !_activated[widget.index]) {
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

class SeasonalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SeasonalAppBar({
    required this.seasonName,
    required this.notificationCubit,
    required this.dashboardCubit,
    super.key,
  });

  final String seasonName;
  final NotificationCubit notificationCubit;
  final DashboardCubit dashboardCubit;

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: preferredSize.height + topPadding,
      width: double.infinity,
      color: const Color(0xFFFCF2E3),
      child: Stack(
        children: [
          // Single Seasonal Asset Image (onam_home_2.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/png/vectors/onam_home_2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Header Top Action Row (DISCIPL Logo + Notifications + Settings)
          Positioned(
            left: 20,
            top: topPadding + 8,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/png/vectors/discipl_spell.png',
                  height: 24,
                ),
                Row(
                  children: [
                    _GymActionIcon(cubit: dashboardCubit),
                    const SizedBox(width: 10),
                    BlocBuilder<NotificationCubit, NotificationState>(
                      bloc: notificationCubit,
                      builder: (context, notificationState) {
                        final int unreadCount = notificationState.unreadCount;
                        return GestureDetector(
                          onTap: () {
                            context.push(
                              MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: notificationCubit,
                                  ),
                                  BlocProvider.value(value: dashboardCubit),
                                ],
                                child: const NotificationsScreen(),
                              ),
                            );
                            notificationCubit.fetchUnreadCount();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEEEEE),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/svg/icons/notification_icon.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadCount >= 100
                                              ? '99+'
                                              : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        context.push(const SettingsScreen());
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/images/svg/icons/settings _icon.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showActiveGymBottomSheet(
  BuildContext context,
  ActiveMembershipModel activeMembership,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final bool isPending =
          activeMembership.status?.toLowerCase() == 'pending';
      final now = DateTime.now();
      final localEndDate = activeMembership.endDate?.toLocal();
      final bool isExpired =
          activeMembership.status?.toLowerCase() == 'expired' ||
          (localEndDate != null && localEndDate.isBefore(now));

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Fitness Center',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: const Color(0xFF222222),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    CustomerMembershipDetailsScreen(
                      membership: activeMembership,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfileImage(
                            isEdit: false,
                            radius: 48,
                            url: activeMembership.organization?.logo,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activeMembership.organization?.name ??
                                            'Discipl Fitness Gym',
                                        style: AppStyles
                                            .text15Px
                                            .poppins
                                            .w600
                                            .copyWith(
                                              color: const Color(0xFF111111),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPending
                                            ? const Color(0xFFFFF3E0)
                                            : (isExpired
                                                ? const Color(0xFFFFEBEE)
                                                : const Color(0xFFE8F5E9)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isPending
                                            ? 'Pending'
                                            : (isExpired ? 'Expired' : 'Active'),
                                        style: AppStyles
                                            .text10Px
                                            .poppins
                                            .w600
                                            .copyWith(
                                              color: isPending
                                                  ? const Color(0xFFE65100)
                                                  : (isExpired
                                                      ? const Color(
                                                          0xFFD30C15,
                                                        )
                                                      : const Color(
                                                          0xFF2E7D32,
                                                        )),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeMembership.organization?.location?.place ??
                                      activeMembership.organization?.location?.city ??
                                      'Location N/A',
                                  style: AppStyles
                                      .text12Px
                                      .poppins
                                      .w400
                                      .copyWith(
                                        color: const Color(0xFF666666),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEEEEEE),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Plan',
                                  style: AppStyles
                                      .text12Px
                                      .poppins
                                      .w500
                                      .copyWith(
                                        color: const Color(0xFF888888),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeMembership.planName ?? 'Standard',
                                  style: AppStyles
                                      .text13Px
                                      .poppins
                                      .w600
                                      .copyWith(
                                        color: const Color(0xFF222222),
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'View Details',
                                  style: AppStyles
                                      .text12Px
                                      .poppins
                                      .w600
                                      .copyWith(color: AppColors.primary),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: AppColors.primary,
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
          ],
        ),
      );
    },
  );
}

class _GymActionIcon extends StatelessWidget {
  const _GymActionIcon({required this.cubit});

  final DashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      bloc: cubit,
      builder: (context, state) {
        ActiveMembershipModel? activeMembership = state.activeMembershipData.fold(
          () => null,
          (either) => either.fold((_) => null, (r) => r),
        );

        final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
        if (activeMembership == null && currentUser != null) {
          final c = currentUser.customer;
          final gymMap = c?.assignedFitnessCenter is Map ? (c!.assignedFitnessCenter as Map) : null;
          final dynamic gymId = gymMap?['id'] ?? c?.organizationId ?? 1;
          final int parsedId = gymId is int ? gymId : (int.tryParse(gymId.toString()) ?? 1);
          final String gymName = gymMap?['name']?.toString() ?? 'Discipl Fitness Gym';
          final String? gymLogo = gymMap?['logo']?.toString();

          activeMembership = ActiveMembershipModel(
            id: parsedId,
            organization: OrganizationModel(
              id: parsedId,
              name: gymName,
              logo: gymLogo,
              location: const Location(
                place: 'Kochi, Kerala',
              ),
            ),
            planName: 'Active Membership Plan',
            status: 'active',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 30)),
          );
        }

        final String? logoUrl = activeMembership?.organization?.logo;
        final Widget gymChild = (logoUrl != null && logoUrl.isNotEmpty)
            ? ClipOval(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: ImageNetwork(
                    logoUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorWidget: const Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFF222222),
                      size: 20,
                    ),
                  ),
                ),
              )
            : const Icon(
                Icons.fitness_center_rounded,
                color: Color(0xFF222222),
                size: 20,
              );

        return GestureDetector(
          onTap: () {
            if (activeMembership != null) {
              _showActiveGymBottomSheet(context, activeMembership);
            } else {
              context.push(const FitnessCentersListingScreen());
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: gymChild,
          ),
        );
      },
    );
  }
}
