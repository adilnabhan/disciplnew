import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/workout_history_calendar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    if (!isGuest) {
      _fetchActiveMembership();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchActiveMembership() async {
    await _dashboardCubit.fetchActiveMembership();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: homeView(),
    );
  }

  Widget homeView() {
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel Banners (using local assets)
          BannersView(banners: const [
            'assets/images/carousel_images/discipl_carousel .png',
            'assets/images/carousel_images/carousel_discipl.jpg',
          ]).pxy(x: 16),

          // Active Gym Section (only if user has active membership data)
          BlocBuilder<DashboardCubit, DashboardState>(
            bloc: _dashboardCubit,
            builder: (context, dashboardState) {
              return dashboardState.activeMembershipData.fold(
                () => const SizedBox.shrink(),
                (either) => either.fold((_) => const SizedBox.shrink(), (
                  activeMembership,
                ) {
                  if (activeMembership == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildActiveGymSection(activeMembership).pxy(x: 16),
                    ],
                  );
                }),
              );
            },
          ),

          // Reduced gap before calendar/card
          const SizedBox(height: 8),

          // Ready To Level Up Card for guests, Workout History Calendar for logged-in users
          if (isGuest)
            _membershipExpireCard(context)
          else
            const WorkoutHistoryCalendar().pxy(x: 8),

          const SizedBox(height: 24),

          // Did You Know Section (always shown)
          _buildDidYouKnowSection(),
        ],
      ),
    );
  }

  Widget _buildActiveGymSection(ActiveMembershipModel activeMembership) {
    final remainingDays =
        activeMembership.endDate?.toLocal().difference(DateTime.now()).inDays ??
        0;
    return InkWell(
      onTap: () {
        final gymId = activeMembership.organization?.id;
        if (gymId != null) {
          context.push(
            FitnessCenterDetailsScreen(
              fitnessCenterId: gymId,
              activeMembership: activeMembership,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1D1D2), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1E888888),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Gym logo, name, plan, and trailing icon
            Row(
              children: [
                // Gym Logo
                Container(
                  decoration: const ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(color: Color(0xFFCF0B10)),
                    ),
                  ),
                  child: AbsorbPointer(
                    child: ProfileImage(
                      isEdit: false,
                      radius: 48,
                      url: activeMembership.organization?.logo ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Gym Name and Plan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeMembership.organization?.name ?? '',
                        style: AppStyles.text13Px.poppins.w500.copyWith(
                          color: const Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0, 0.50),
                            end: Alignment(1, 0.50),
                            colors: [
                              Color(0xFFF7F7F7),
                              Color(0xFFDDDDDD),
                              Color(0xFFF7F7F7),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 0.50,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              color: Color(0xFFDDDDDD),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          activeMembership.planName ?? '',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing Icon
                const SizedBox(width: 14),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDDDDD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
            // Divider
            const Divider(color: Color(0xFFF1D1D2), height: 1).pxy(y: 16),
            // Subscription Expires In
            Align(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Subscription Expires in',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF222222),
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: const Color(0xFF222222),
                      ),
                    ),
                    TextSpan(
                      text: '$remainingDays Days',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
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
          //   'Built by fitness lovers 🧡',
          //   style: AppStyles.text14Px.poppins.w400.copyWith(
          //     color: const Color(0xff666666),
          //   ),
          // ),
          const SizedBox(height: 120),
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
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 24,
      ),
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



class BannersView extends StatefulWidget {
  const BannersView({required this.banners, super.key});

  final List<String> banners;

  @override
  State<BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<BannersView> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final int _bannerCount;
  late final Duration _autoScrollDuration;
  late final Duration _animationDuration;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _bannerCount = widget.banners.length;
    _pageController = PageController();
    _autoScrollDuration = const Duration(seconds: 3);
    _animationDuration = const Duration(milliseconds: 400);

    // Only start ticker if more than one banner
    if (_bannerCount > 1) {
      _ticker = Ticker(_autoScroll);
      _ticker!.start();
    }
  }

  void _autoScroll(Duration elapsed) {
    if (!mounted) return;
    if (_bannerCount <= 1) return;
    if (elapsed.inMilliseconds % _autoScrollDuration.inMilliseconds < 50) {
      final nextPage = (_currentPage + 1) % _bannerCount;
      _pageController.animateToPage(
        nextPage,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle single banner item state
    if (_bannerCount == 1) {
      final banner = widget.banners[0];
      final isAsset = banner.startsWith('assets/');
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: isAsset
              ? Image.asset(
                  banner,
                  fit: BoxFit.cover,
                  height: double.maxFinite,
                  width: double.maxFinite,
                )
              : ImageNetwork(
                  banner,
                  height: double.maxFinite,
                  width: double.maxFinite,
                  errorWidget: ColoredBox(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
        ),
      );
    }

    // Multiple banners
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _bannerCount,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                final isAsset = banner.startsWith('assets/');
                return isAsset
                    ? Image.asset(
                        banner,
                        fit: BoxFit.cover,
                        height: double.maxFinite,
                        width: double.maxFinite,
                      )
                    : ImageNetwork(
                        banner,
                        height: double.maxFinite,
                        width: double.maxFinite,
                        errorWidget: ColoredBox(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                      );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_bannerCount, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color:
                      index == _currentPage
                          ? Colors.red
                          : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}


