import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/workout_history_calendar.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/customer_membership_details_screen.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_cubit.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/banner_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_model.dart';
import 'package:customer_mobile_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:customer_mobile_app/src/features/profile/cubit/profile_completion/profile_completion_cubit.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/profile_completion_banner.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/domain/models/fitnesscenter_details_model.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/screens/trainer_details_screen.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_challenge_cubit.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_challenge_state.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:customer_mobile_app/src/features/home/persentation/widgets/home_challenge_card.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/all_challenges_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/winner_announcement_dialog.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_cubit.dart';
import 'package:customer_mobile_app/src/features/notifications/cubit/notification_state.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/settings_screen.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/notifications_screen.dart';
import 'package:customer_mobile_app/src/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:customer_mobile_app/src/features/scorecard/presentation/screens/score_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;
  late final HomeCubit _homeCubit;
  late final HomeChallengeCubit _homeChallengeCubit;
  late final NotificationCubit _notificationCubit;
  final ProfileCompletionCubit _profileCompletionCubit =
      ProfileCompletionCubit();
  int _calendarRefreshCounter = 0;
  static bool _hasCheckedWinnerPopupInSession = false;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _homeCubit = HomeCubit();
    _homeChallengeCubit = HomeChallengeCubit();
    _notificationCubit = NotificationCubit()..fetchUnreadCount();
    _homeChallengeCubit.loadHomeChallenges();
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    if (!isGuest) {
      _profileCompletionCubit.fetchProfileCompletion();
      _fetchActiveMembership();
      _checkWinnerPopup();
    }
  }

  Future<void> _checkWinnerPopup() async {
    if (_hasCheckedWinnerPopupInSession) return;
    _hasCheckedWinnerPopupInSession = true;

    try {
      final response = await ChallengeRepository().getWinnerPopup();
      if (response.showPopup && response.winner != null && mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            WinnerAnnouncementDialog.show(context, winner: response.winner!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error in _checkWinnerPopup: $e');
    }
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _profileCompletionCubit.close();
    _homeCubit.close();
    _homeChallengeCubit.close();
    _notificationCubit.close();
    super.dispose();
  }

  Future<void> _fetchActiveMembership() async {
    if (mounted) {
      setState(() {
        _calendarRefreshCounter++;
      });
    }
    await Future.wait([
      _dashboardCubit.fetchActiveMembership(),
      _homeChallengeCubit.loadHomeChallenges(),
      if (Feggy.read<AppCubit>()?.state.currentUser != null) ...[
        _homeCubit.fetchHomeData(),
        _profileCompletionCubit.fetchProfileCompletion(),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    const Color bgColor = Color(0xffF7F7F7);

    if (isGuest) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _profileCompletionCubit),
          BlocProvider.value(value: _homeChallengeCubit),
        ],
        child: Scaffold(
          backgroundColor: bgColor,
          body: homeView(),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCompletionCubit),
        BlocProvider.value(value: _homeChallengeCubit),
      ],
      child: BlocListener<DashboardCubit, DashboardState>(
        listenWhen:
            (previous, current) =>
                previous.navIndex != current.navIndex &&
                current.navIndex == 0,
        listener: (context, state) {
          _profileCompletionCubit.fetchProfileCompletion();
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: homeView(),
        ),
      ),
    );
  }

  Widget homeView() {
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;

    return RefreshIndicator(
      onRefresh: _fetchActiveMembership,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expired Warning Banner
            BlocBuilder<DashboardCubit, DashboardState>(
              bloc: _dashboardCubit,
              builder: (context, dashboardState) {
                return dashboardState.activeMembershipData.fold(
                  () => const SizedBox.shrink(),
                  (either) => either.fold((_) => const SizedBox.shrink(), (
                    activeMembership,
                  ) {
                    if (activeMembership == null)
                      return const SizedBox.shrink();
                    final bool isPending =
                        activeMembership.status?.toLowerCase() == 'pending';
                    final now = DateTime.now();
                    final localEndDate = activeMembership.endDate?.toLocal();
                    final remainingDays =
                        isPending
                            ? 0
                            : (localEndDate != null
                                ? DateTime(
                                      localEndDate.year,
                                      localEndDate.month,
                                      localEndDate.day,
                                    )
                                    .difference(
                                      DateTime(now.year, now.month, now.day),
                                    )
                                    .inDays
                                : 0);
                    final bool isExpired =
                        !isPending &&
                        (activeMembership.status?.toLowerCase() == 'expired' ||
                            remainingDays < 0);
                    if (!isExpired) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD1D1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠ ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD30C15),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Your membership plan has expired. Please renew your subscription to continue enjoying premium benefits.',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFFD30C15),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),

            // Profile Completion Banner
            if (!isGuest) const ProfileCompletionBanner(),

            // Carousel Banners (Dynamic API Banners with Fallback)
            BlocBuilder<DashboardCubit, DashboardState>(
              bloc: _dashboardCubit,
              builder: (context, dashboardState) {
                int? orgId;
                dashboardState.activeMembershipData.fold(
                  () {},
                  (either) => either.fold((_) {}, (membership) {
                    if (membership?.organization?.id != null) {
                      orgId = membership!.organization!.id;
                    }
                  }),
                );
                return BannersView(organizationId: orgId).pxy(x: 16);
              },
            ),

            const SizedBox(height: 20),

            // Rewards and Scorecard Quick Action Cards
            if (!isGuest) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRewardsCard(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildScorecardCard(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Challenges Container Section
            BlocBuilder<HomeChallengeCubit, HomeChallengeState>(
              bloc: _homeChallengeCubit,
              builder: (context, challengeState) {
                if (!challengeState.isLoading &&
                    (challengeState.errorMessage != null || challengeState.challenges.isEmpty)) {
                  return const SizedBox.shrink();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HomeChallengeSection().pxy(x: 10),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            if (isGuest)
              _membershipExpireCard(context)
            else
              BlocBuilder<DashboardCubit, DashboardState>(
                bloc: _dashboardCubit,
                builder: (context, state) {
                  return WorkoutHistoryCalendar(
                    key: ValueKey(_calendarRefreshCounter),
                  ).pxy(x: 8);
                },
              ),

            const SizedBox(height: 24),

            // Assigned Gym Trainers Section (after calendar)
            BlocBuilder<DashboardCubit, DashboardState>(
              bloc: _dashboardCubit,
              builder: (context, dashboardState) {
                int? orgId;
                String? gymName;
                dashboardState.activeMembershipData.fold(
                  () {},
                  (either) => either.fold((_) {}, (membership) {
                    if (membership?.organization?.id != null) {
                      orgId = membership!.organization!.id;
                      gymName = membership.organization?.name;
                    }
                  }),
                );
                if (orgId == null) return const SizedBox.shrink();
                return _AssignedGymTrainersSection(
                  organizationId: orgId!,
                  gymName: gymName,
                  homeCubit: _homeCubit,
                  onBuildTrainerCard: _buildTrainerCard,
                ).pxy(x: 16);
              },
            ),

            // Did You Know Section (always shown)
            _buildDidYouKnowSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsCard(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFEEBC8).withOpacity(0.55),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9A7B38).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFDE68A).withOpacity(0.55),
                    const Color(0xFFFDE68A).withOpacity(0.18),
                    const Color(0xFFFDE68A).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFDE68A).withOpacity(0.4),
                    const Color(0xFFFDE68A).withOpacity(0.12),
                    const Color(0xFFFDE68A).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RewardsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFDF58),
                            Color(0xFFFFA000),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA000).withOpacity(0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const CustomPaint(
                        size: Size(22, 22),
                        painter: _GiftBoxPainter(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rewards',
                            style: AppStyles.text14Px.poppins.w700.copyWith(
                              fontSize: 13.5,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Show your QR and\nget discounts',
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              fontSize: 9.5,
                              color: const Color(0xFF64748B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardCard(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFDCFD6).withOpacity(0.55),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE123C).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFECDD3).withOpacity(0.65),
                    const Color(0xFFFECDD3).withOpacity(0.22),
                    const Color(0xFFFECDD3).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFECDD3).withOpacity(0.45),
                    const Color(0xFFFECDD3).withOpacity(0.15),
                    const Color(0xFFFECDD3).withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                try {
                  final dashboardCubit = context.read<DashboardCubit>();
                  final bool hasActiveGym = dashboardCubit.state.activeMembershipData.fold(
                    () => false,
                    (either) => either.fold((_) => false, (activeMembership) => activeMembership?.id != null),
                  );
                  if (hasActiveGym) {
                    dashboardCubit.changeNav(index: 2);
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScoreCardScreen()),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScoreCardScreen()),
                  );
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF5B65),
                            Color(0xFFE11D48),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withOpacity(0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/svg/icons/selected_scorecard.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scorecard',
                            style: AppStyles.text14Px.poppins.w700.copyWith(
                              fontSize: 13.5,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Track rank, XP\nand total points',
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              fontSize: 9.5,
                              color: const Color(0xFF64748B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActiveGymSection(ActiveMembershipModel activeMembership) {
    final bool isPending = activeMembership.status?.toLowerCase() == 'pending';
    final now = DateTime.now();
    final localEndDate = activeMembership.endDate?.toLocal();
    final remainingDays =
        isPending
            ? 0
            : (localEndDate != null
                ? DateTime(
                  localEndDate.year,
                  localEndDate.month,
                  localEndDate.day,
                ).difference(DateTime(now.year, now.month, now.day)).inDays
                : 0);
    final bool isExpired =
        !isPending &&
        (activeMembership.status?.toLowerCase() == 'expired' ||
            remainingDays < 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Gym',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerMembershipDetailsScreen(
                  membership: activeMembership,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFEEEEEE),
                  Color(0xFFFFFFFF),
                  Color(0xFFEEEEEE),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isPending
                        ? const Color(0xFFFFB74D)
                        : (isExpired
                            ? const Color(0xFFD30C15)
                            : const Color(0xFFF5D6D8)),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Gym logo, name, plan pill, and trailing arrow
                Row(
                  children: [
                    // Gym Logo
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const ShapeDecoration(
                        shape: OvalBorder(
                          side: BorderSide(
                            color: Color(0xFFCF0B10),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: ClipOval(
                        child: ProfileImage(
                          isEdit: false,
                          radius: 52,
                          url: activeMembership.organization?.logo ?? '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Gym Name and Plan Pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeMembership.organization?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text15Px.poppins.w600.copyWith(
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: isPending
                                  ? null
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFEEEEEE),
                                        Color(0xFFFFFFFF),
                                        Color(0xFFEEEEEE),
                                        Color(0xFFFFFFFF),
                                      ],
                                    ),
                              color: isPending
                                  ? const Color(0xFFFFF3E0)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPending
                                    ? const Color(0xFFFFB74D)
                                    : const Color(0xFFE2E2E2),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isPending
                                  ? 'Pending Approval'
                                  : (activeMembership.planName ?? ''),
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: isPending
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Trailing Circular Chevron Button
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAEAEA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),

                // Divider Line
                const SizedBox(height: 14),
                const Divider(
                  color: Color(0xFFF5D6D8),
                  height: 1,
                  thickness: 0.8,
                ),
                const SizedBox(height: 14),

                // Bottom Row: Subscription Expires In
                Align(
                  alignment: Alignment.center,
                  child:
                      isPending
                          ? Text(
                            'Awaiting approval from gym administrator',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: const Color(0xFFE65100),
                            ),
                          )
                          : isExpired
                          ? Text(
                            'Subscription Expired',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: const Color(0xFFD30C15),
                            ),
                          )
                          : Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Subscription Expires in ',
                                  style: AppStyles.text13Px.poppins.w400.copyWith(
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                TextSpan(
                                  text: '$remainingDays Days',
                                  style: AppStyles.text13Px.poppins.w700.copyWith(
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerCard(AssignedTrainerModel trainer) {
    final experience = trainer.experienceYears ?? 0;
    final String rawName = (trainer.name != null && trainer.name!.trim().isNotEmpty)
        ? trainer.name!
        : (trainer.fullGymTrainer?.fullName != null && trainer.fullGymTrainer!.fullName!.trim().isNotEmpty
            ? trainer.fullGymTrainer!.fullName!
            : 'Trainer');

    final String displayName = rawName.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    final specialization = (trainer.specializations != null &&
            trainer.specializations!.isNotEmpty)
        ? trainer.specializations!.first
        : (trainer.userType != null && trainer.userType!.trim().isNotEmpty
            ? trainer.userType![0].toUpperCase() + trainer.userType!.substring(1).toLowerCase()
            : 'Trainer');
    final rawR = trainer.rating ?? trainer.fullGymTrainer?.averageRating;
    final double ratingVal = rawR is num
        ? rawR.toDouble()
        : (rawR is String ? (double.tryParse(rawR) ?? 4.8) : 4.8);
    final String ratingStr = ratingVal.toStringAsFixed(1);

    return GestureDetector(
      onTap: () {
        final gymTrainer = trainer.fullGymTrainer ??
            GymTrainer(
              id: trainer.id,
              fullName: displayName,
              userType: trainer.userType ?? 'Trainer',
              bio: trainer.bio,
              profileImage: trainer.profileImage,
              experienceYears: trainer.experienceYears,
              averageRating: ratingVal,
              reviewCount: 0,
              specializations: trainer.specializations,
              mobile: trainer.mobile,
              clientsCount: trainer.fullGymTrainer?.clientsCount,
              verifiedWorkoutsCount: trainer.fullGymTrainer?.verifiedWorkoutsCount,
              certifications: trainer.fullGymTrainer?.certifications,
              email: trainer.fullGymTrainer?.email,
              gender: trainer.fullGymTrainer?.gender,
            );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrainerDetailsScreen(trainer: gymTrainer),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          children: [
            // Circle Avatar with Outer Red Ring & Bottom Star Shield Badge
            SizedBox(
              width: 90,
              height: 94,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE53935),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: trainer.profileImage != null &&
                              trainer.profileImage!.isNotEmpty
                          ? ImageNetwork(
                              trainer.profileImage!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorWidget: ColoredBox(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            )
                          : ColoredBox(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                    ),
                  ),

                  // Overlapping bottom star icon badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: const Color(0xFF1E1E1E),
              ),
            ),

            const SizedBox(height: 2),

            // Specialization / Subtitle
            Text(
              specialization,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF8E8E93),
              ),
            ),

            const SizedBox(height: 6),

            // Ribbon Experience Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE53935),
                  size: 15,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '$experience+ Years Experience',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rating Pill Container
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE53935),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ratingStr,
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDidYouKnowSection() {
  return ColoredBox(
    color: const Color(0xffF7F7F7),
    child: SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            'Did you know?',
            style: AppStyles.text14Px.titanOne.w500.copyWith(
              color: const Color(0xff878787),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Strong Bodies',
            style: AppStyles.text26Px.titanOne.w400.copyWith(
              color: const Color(0xff878787),
            ),
          ),
          Text(
            'Are Built',
            style: AppStyles.text36Px.titanOne.w400.copyWith(
              color: const Color(0xff878787),
            ),
          ),
          Text(
            'Not Born. Start Today',
            style: AppStyles.text26Px.titanOne.w400.copyWith(
              color: const Color(0xff878787),
            ),
          ),
          // const SizedBox(height: 24),
          // Text(
          //   'Built by fitness lovers \u{1F9E1}',
          //   style: AppStyles.text14Px.poppins.w400.copyWith(
          //     color: const Color(0xff666666),
          //   ),
          // ),
          const SizedBox(height: 20),
        ],
      ).pxy(x: 20),
    ),
  );
}

Widget _membershipExpireCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/images/svg/vectors/Waving_Wolf.json',
            width: 130,
            height: 130,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'Ready To Level Up',
            style: AppStyles.text20Px.poppins.w600.dark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join a fitness center on Discipl and begin your fitness journey with confidence.',
            style: AppStyles.text14Px.poppins.w400.dark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Button.filled(
            title: 'Explore Fitness Centers',
            ontap: () {
              context.read<DashboardCubit>().changeNav(index: 2);
            },
            icon: SvgPicture.asset(
              'assets/images/svg/icons/search.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeBannerItem {
  HomeBannerItem({
    required this.imagePath,
    this.isAsset = false,
    this.title,
    this.contactNumber,
    this.websiteUrl,
    this.redirectType,
    this.whatsappNumber,
  });

  factory HomeBannerItem.fromModel(BannerModel model) {
    final rawWa = (model.whatsappNumber != null && model.whatsappNumber!.trim().isNotEmpty)
        ? model.whatsappNumber
        : (model.contactNumber != null && model.contactNumber!.trim().isNotEmpty)
            ? model.contactNumber
            : null;
    return HomeBannerItem(
      imagePath: model.bannerImage ?? '',
      isAsset: false,
      title: model.title,
      contactNumber: model.contactNumber,
      websiteUrl: model.websiteUrl,
      redirectType: model.redirectType,
      whatsappNumber: rawWa,
    );
  }

  factory HomeBannerItem.asset(String path, {String? whatsappNumber}) {
    return HomeBannerItem(
      imagePath: path,
      isAsset: true,
      whatsappNumber: whatsappNumber,
    );
  }

  final String imagePath;
  final bool isAsset;
  final String? title;
  final String? contactNumber;
  final String? websiteUrl;
  final String? redirectType;
  final String? whatsappNumber;
}

class BannersView extends StatefulWidget {
  const BannersView({this.organizationId, super.key});

  final int? organizationId;

  @override
  State<BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<BannersView> {
  late final PageController _pageController;
  int _currentPage = 0;
  List<HomeBannerItem> _banners = [];
  bool _isLoading = true;

  late final Duration _autoScrollDuration;
  late final Duration _animationDuration;
  Ticker? _ticker;



  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoScrollDuration = const Duration(seconds: 3);
    _animationDuration = const Duration(milliseconds: 400);
    _loadBanners();
  }

  @override
  void didUpdateWidget(covariant BannersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId) {
      _loadBanners();
    }
  }

  Future<void> _loadBanners() async {
    List<HomeBannerItem> combinedBanners = [];

    // 1st Banner: Gym-Specific Banners for assigned gym (passed via organizationId)
    if (widget.organizationId != null) {
      final gymBanners = await HomeRepository().fetchGymBanners(
        widget.organizationId!,
      );
      for (final b in gymBanners) {
        if (b.bannerImage != null && b.bannerImage!.isNotEmpty) {
          combinedBanners.add(HomeBannerItem.fromModel(b));
        }
      }
    }

    // 2nd Banner: Global Banners for all users
    final globalBanners = await HomeRepository().fetchGlobalBanners();
    for (final b in globalBanners) {
      if (b.bannerImage != null && b.bannerImage!.isNotEmpty) {
        combinedBanners.add(HomeBannerItem.fromModel(b));
      }
    }

    if (!mounted) return;

    setState(() {
      _banners = combinedBanners;
      _isLoading = false;
      _currentPage = 0;
    });

    _ticker?.dispose();
    _ticker = null;
    if (_banners.length > 1) {
      _ticker = Ticker(_autoScroll);
      _ticker!.start();
    }
  }

  void _autoScroll(Duration elapsed) {
    if (!mounted) return;
    if (_banners.length <= 1) return;
    if (elapsed.inMilliseconds % _autoScrollDuration.inMilliseconds < 50) {
      final nextPage = (_currentPage + 1) % _banners.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: _animationDuration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _onBannerTap(HomeBannerItem banner) async {
    if (banner.websiteUrl != null && banner.websiteUrl!.isNotEmpty) {
      String url = banner.websiteUrl!.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      final Uri uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Error launching website URL: $e');
      }
    }

    final phone = banner.whatsappNumber ?? banner.contactNumber;
    if (phone != null && phone.trim().isNotEmpty) {
      await _launchWhatsApp(phone, banner);
    }
  }

  Future<void> _launchWhatsApp(String target, [HomeBannerItem? banner]) async {
    final cleanStr = target.trim();
    if (cleanStr.isEmpty) return;

    final businessName = (banner?.title != null && banner!.title!.trim().isNotEmpty)
        ? ' ${banner.title!.trim()}'
        : '';
    final message = Uri.encodeComponent(
      'Hi$businessName,\n\n'
      'I saw your offer on the Discipl app and would like to place an order.\n\n'
      'Could you please share the menu and ordering details?\n\n'
      'Thank you!\n\n'
      '—\n'
      'Sent via Discipl App',
    );

    if (cleanStr.startsWith('http://') ||
        cleanStr.startsWith('https://') ||
        cleanStr.startsWith('whatsapp://')) {
      var uri = Uri.parse(cleanStr);
      if (!cleanStr.contains('text=')) {
        final separator = cleanStr.contains('?') ? '&' : '?';
        uri = Uri.parse('$cleanStr${separator}text=$message');
      }
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Error launching WhatsApp URL: $e');
      }
    }

    var phoneDigits = cleanStr.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneDigits.length == 10) {
      phoneDigits = '91$phoneDigits';
    }
    final phoneToUse = phoneDigits.isNotEmpty ? phoneDigits : cleanStr;

    final whatsappUri = Uri.parse('https://wa.me/$phoneToUse?text=$message');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final apiWhatsappUri =
        Uri.parse('https://api.whatsapp.com/send?phone=$phoneToUse&text=$message');
    try {
      if (await canLaunchUrl(apiWhatsappUri)) {
        await launchUrl(apiWhatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final phoneUri = Uri(scheme: 'tel', path: phoneToUse);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Error launching phone fallback: $e');
    }
  }

  Widget _buildWhatsAppButton(HomeBannerItem banner) {
    final whatsappNum = banner.whatsappNumber!;
    return Positioned(
      bottom: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchWhatsApp(whatsappNum, banner),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/svg/icons/whatsapp_logo.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Order Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AspectRatio(
        aspectRatio: 2.0 / 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_banners.length == 1) {
      final banner = _banners[0];
      final hasWa = banner.whatsappNumber != null &&
          banner.whatsappNumber!.trim().isNotEmpty;
      return AspectRatio(
        aspectRatio: 2.0 / 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _onBannerTap(banner),
                  child: banner.isAsset
                      ? Image.asset(
                          banner.imagePath,
                          fit: BoxFit.cover,
                          height: double.maxFinite,
                          width: double.maxFinite,
                        )
                      : ImageNetwork(
                          banner.imagePath,
                          height: double.maxFinite,
                          width: double.maxFinite,
                          errorWidget: ColoredBox(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.0 / 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = _banners[index];
                final hasWa = banner.whatsappNumber != null &&
                    banner.whatsappNumber!.trim().isNotEmpty;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _onBannerTap(banner),
                        child: banner.isAsset
                            ? Image.asset(
                                banner.imagePath,
                                fit: BoxFit.cover,
                                height: double.maxFinite,
                                width: double.maxFinite,
                              )
                            : ImageNetwork(
                                banner.imagePath,
                                height: double.maxFinite,
                                width: double.maxFinite,
                                errorWidget: ColoredBox(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 16,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              final isActive = index == _currentPage;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    height: isActive ? 16 : 9,
                    width: isActive ? 30 : 11,
                    padding: isActive
                        ? const EdgeInsets.symmetric(horizontal: 3.5, vertical: 2.5)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFF1F2) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(isActive ? 10 : 4.5),
                      border: Border.all(
                        color: isActive ? const Color(0xFFFECDD3) : Colors.transparent,
                        width: isActive ? 1.2 : 0,
                      ),
                    ),
                    child: isActive
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            }),
          ),
        ),
        ),
      ],
    );
  }
}

class _AssignedGymTrainersSection extends StatefulWidget {
  const _AssignedGymTrainersSection({
    required this.organizationId,
    this.gymName,
    required this.homeCubit,
    required this.onBuildTrainerCard,
  });

  final int organizationId;
  final String? gymName;
  final HomeCubit homeCubit;
  final Widget Function(AssignedTrainerModel trainer) onBuildTrainerCard;

  @override
  State<_AssignedGymTrainersSection> createState() =>
      __AssignedGymTrainersSectionState();
}

class __AssignedGymTrainersSectionState
    extends State<_AssignedGymTrainersSection> {
  bool _isLoading = true;
  List<AssignedTrainerModel> _trainers = [];
  List<Map<String, dynamic>> _transformations = [];
  int _currentTransformIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  @override
  void didUpdateWidget(covariant _AssignedGymTrainersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId) {
      _loadTrainers();
    }
  }

  Future<void> _loadTrainers() async {
    try {
      List<AssignedTrainerModel> trainers = [];
      List<Map<String, dynamic>> transformations = [];

      // 1. Fetch from assigned gym trainers API (/api/v1/customer/gym-trainers/)
      final apiTrainers = await HomeRepository().fetchAssignedGymTrainers();
      if (apiTrainers.isNotEmpty) {
        trainers = apiTrainers;
        for (final t in apiTrainers) {
          if (t.fullGymTrainer?.transformations != null) {
            for (final trans in t.fullGymTrainer!.transformations!) {
              if ((trans.beforeImage != null && trans.beforeImage!.trim().isNotEmpty) ||
                  (trans.afterImage != null && trans.afterImage!.trim().isNotEmpty)) {
                transformations.add({
                  'trainerName': t.name ?? t.fullGymTrainer?.fullName,
                  'transformation': trans,
                });
              }
            }
          }
        }
      }

      // 2. Fetch/check fitness center details API for complete trainers and transformations
      final repo = FitnesscenterRepository();
      var cached = repo.getCachedDetails(widget.organizationId);
      if (cached == null) {
        final res = await repo.fitnesscenterDetails(id: widget.organizationId);
        res.fold((_) {}, (details) {
          repo.cacheDetails(widget.organizationId, details);
          cached = details;
        });
      }

      if (cached != null && cached!.trainers != null) {
        if (trainers.isEmpty) {
          trainers = cached!.trainers!
              .map((t) => AssignedTrainerModel(
                    id: t.id,
                    name: t.fullName,
                    profileImage: t.profileImage,
                    mobile: t.mobile,
                    experienceYears: t.experienceYears,
                    bio: t.bio,
                    specializations: t.specializations,
                    fullGymTrainer: t,
                  ))
              .toList();
        }

        // Collect transformations from cached gym details if list is empty
        if (transformations.isEmpty) {
          for (final t in cached!.trainers!) {
            if (t.transformations != null) {
              for (final trans in t.transformations!) {
                if ((trans.beforeImage != null && trans.beforeImage!.trim().isNotEmpty) ||
                    (trans.afterImage != null && trans.afterImage!.trim().isNotEmpty)) {
                  transformations.add({
                    'trainerName': t.fullName,
                    'transformation': trans,
                  });
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _trainers = trainers;
          _transformations = transformations;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (context, homeState) {
        final List<AssignedTrainerModel> finalTrainers = List.from(_trainers);

        homeState.homeData.fold(
          () {},
          (either) => either.fold((_) {}, (homeModel) {
            if (homeModel.assignedTrainer != null) {
              final exists = finalTrainers.any((t) =>
                  (t.id != null && t.id == homeModel.assignedTrainer!.id) ||
                  (t.name != null && t.name == homeModel.assignedTrainer!.name));
              if (!exists) {
                finalTrainers.insert(0, homeModel.assignedTrainer!);
              }
            }
          }),
        );

        if (finalTrainers.isEmpty && _transformations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finalTrainers.isNotEmpty) ...[
              Text(
                widget.gymName != null && widget.gymName!.trim().isNotEmpty
                    ? '${widget.gymName!.trim()} Trainers'
                    : 'Gym Trainers',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 215,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: finalTrainers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final trainer = finalTrainers[index];
                    return widget.onBuildTrainerCard(trainer);
                  },
                ),
              ),
            ],
            if (_transformations.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildGymTransformationsWidget(_transformations),
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildGymTransformationsWidget(List<Map<String, dynamic>> transformations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transformations',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: PageView.builder(
            itemCount: transformations.length,
            onPageChanged: (index) {
              setState(() {
                _currentTransformIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = transformations[index];
              final trans = item['transformation'] as GymTransformation;
              final trainerName = item['trainerName'] as String?;

              return Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Before Image
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: trans.beforeImage != null && trans.beforeImage!.isNotEmpty
                                        ? ImageNetwork(
                                            trans.beforeImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: const Color(0xFFEAEAEA),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Before',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black87,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(
                              width: 1,
                              color: Colors.white,
                            ),
                            // After Image
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: trans.afterImage != null && trans.afterImage!.isNotEmpty
                                        ? ImageNetwork(
                                            trans.afterImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: const Color(0xFFEAEAEA),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'After',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black87,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((trans.description != null && trans.description!.isNotEmpty) ||
                          (trainerName != null && trainerName.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (trans.description != null && trans.description!.isNotEmpty)
                                      Text(
                                        trans.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if (trainerName != null && trainerName.isNotEmpty)
                                      Text(
                                        'Coach: $trainerName',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (transformations.length > 1) ...[
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                transformations.length,
                (idx) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentTransformIndex == idx
                        ? const Color(0xFFE53935)
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GiftBoxPainter extends CustomPainter {
  const _GiftBoxPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 26.0;
    canvas.save();
    canvas.scale(scale, scale);

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bow loops
    final leftLoop = Path()
      ..moveTo(13.0, 7.0)
      ..cubicTo(10.5, 2.5, 5.8, 2.5, 7.8, 6.0)
      ..cubicTo(8.8, 7.2, 11.2, 7.2, 13.0, 7.0);
    canvas.drawPath(leftLoop, whiteStroke);

    final rightLoop = Path()
      ..moveTo(13.0, 7.0)
      ..cubicTo(15.5, 2.5, 20.2, 2.5, 18.2, 6.0)
      ..cubicTo(17.2, 7.2, 14.8, 7.2, 13.0, 7.0);
    canvas.drawPath(rightLoop, whiteStroke);

    // Knot
    canvas.drawCircle(const Offset(13.0, 7.0), 1.1, whiteFill);

    // Lid pieces
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(3.5, 7.8, 11.8, 11.3),
        const Radius.circular(1.6),
      ),
      whiteFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(14.2, 7.8, 22.5, 11.3),
        const Radius.circular(1.6),
      ),
      whiteFill,
    );

    // Box body pieces
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(4.5, 12.8, 11.8, 22.3),
        bottomLeft: const Radius.circular(2.5),
        topLeft: const Radius.circular(1.0),
        topRight: const Radius.circular(1.0),
      ),
      whiteFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(14.2, 12.8, 21.5, 22.3),
        bottomRight: const Radius.circular(2.5),
        topRight: const Radius.circular(1.0),
        topLeft: const Radius.circular(1.0),
      ),
      whiteFill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




