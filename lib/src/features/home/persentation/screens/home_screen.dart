import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/workout_history_calendar.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/customer_membership_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_cubit.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_model.dart';
import 'package:customer_mobile_app/src/features/home/persentation/widgets/health_dashboard_widgets.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _homeCubit = HomeCubit();
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    if (!isGuest) {
      _fetchActiveMembership();
      _homeCubit.fetchHomeData();
    }
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  Future<void> _fetchActiveMembership() async {
    await _dashboardCubit.fetchActiveMembership();
    if (Feggy.read<AppCubit>()?.state.currentUser != null) {
      await _homeCubit.fetchHomeData();
    }
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
    return RefreshIndicator(
      onRefresh: _fetchActiveMembership,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                    if (activeMembership == null) return const SizedBox.shrink();
                    final bool isPending = activeMembership.status?.toLowerCase() == 'pending';
                    final now = DateTime.now();
                    final localEndDate = activeMembership.endDate?.toLocal();
                    final remainingDays = isPending
                        ? 0
                        : (localEndDate != null
                            ? DateTime(localEndDate.year, localEndDate.month, localEndDate.day)
                                .difference(DateTime(now.year, now.month, now.day))
                                .inDays
                            : 0);
                    final bool isExpired = !isPending && (activeMembership.status?.toLowerCase() == 'expired' || remainingDays < 0);
                    if (!isExpired) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD1D1), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠ ',
                            style: TextStyle(fontSize: 16, color: Color(0xFFD30C15)),
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
                        _buildActiveGymSection(activeMembership).pxy(x: 16),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                );
              },
            ),

            // Carousel Banners (using local assets)
            BannersView(banners: const [
              'assets/images/carousel_images/discipl_carousel .png',
              'assets/images/carousel_images/carousel_discipl.jpg',
            ]).pxy(x: 16),
  
            // Trainer Card under Banners View
            if (!isGuest)
              BlocBuilder<HomeCubit, HomeState>(
                bloc: _homeCubit,
                builder: (context, homeState) {
                  return homeState.homeData.fold(
                    () => const SizedBox.shrink(),
                    (either) => either.fold(
                      (_) => const SizedBox.shrink(),
                      (homeModel) {
                        final trainer = homeModel.assignedTrainer;
                        if (trainer == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Assigned Trainer',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xFF222222),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildTrainerCard(trainer).pxy(x: 16),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),

            // Reduced gap before calendar/card
            const SizedBox(height: 8),
   
            if (!isGuest)
              const HealthDashboardSection(),

            if (isGuest)
              _membershipExpireCard(context)
            else
              BlocBuilder<DashboardCubit, DashboardState>(
                bloc: _dashboardCubit,
                builder: (context, state) {
                  final activeMembership = state.activeMembershipData.fold(
                    () => null,
                    (either) => either.fold((_) => null, (m) => m),
                  );
                  return WorkoutHistoryCalendar(
                    startDate: activeMembership?.startDate,
                  ).pxy(x: 8);
                },
              ),
  
            const SizedBox(height: 24),
  
            // Did You Know Section (always shown)
            _buildDidYouKnowSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGymSection(ActiveMembershipModel activeMembership) {
    final bool isPending = activeMembership.status?.toLowerCase() == 'pending';
    final now = DateTime.now();
    final localEndDate = activeMembership.endDate?.toLocal();
    final remainingDays = isPending
        ? 0
        : (localEndDate != null
            ? DateTime(localEndDate.year, localEndDate.month, localEndDate.day)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays
            : 0);
    final bool isExpired = !isPending && (activeMembership.status?.toLowerCase() == 'expired' || remainingDays < 0);

    return InkWell(
      onTap: () {
        context.push(
          CustomerMembershipDetailsScreen(
            membership: activeMembership,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPending 
                ? const Color(0xFFFFB74D) 
                : (isExpired ? const Color(0xFFD30C15) : const Color(0xFFF1D1D2)),
            width: 0.8,
          ),
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
                          gradient: LinearGradient(
                            begin: const Alignment(0, 0.50),
                            end: const Alignment(1, 0.50),
                            colors: isPending
                                ? [
                                    const Color(0xFFFFF3E0),
                                    const Color(0xFFFFE0B2),
                                    const Color(0xFFFFF3E0),
                                  ]
                                : [
                                    const Color(0xFFF7F7F7),
                                    const Color(0xFFDDDDDD),
                                    const Color(0xFFF7F7F7),
                                  ],
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 0.50,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              color: isPending ? const Color(0xFFFFB74D) : const Color(0xFFDDDDDD),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          isPending ? 'Pending Approval' : (activeMembership.planName ?? ''),
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: isPending ? const Color(0xFFE65100) : Colors.black,
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
              child: isPending
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

  Widget _buildTrainerCard(AssignedTrainerModel trainer) {
    final experience = trainer.experienceYears ?? 0;
    final specializations = trainer.specializations ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: trainer.profileImage != null && trainer.profileImage!.isNotEmpty
                      ? ImageNetwork(
                          trainer.profileImage!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorWidget: const Icon(Icons.person, color: Colors.grey, size: 30),
                        )
                      : const Icon(Icons.person, color: Colors.grey, size: 30),
                ),
              ),
              const SizedBox(width: 14),

              // Trainer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.name ?? '',
                      style: AppStyles.text15Px.poppins.w600.copyWith(
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Experience Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$experience yrs experience',
                            style: AppStyles.text10Px.poppins.w500.copyWith(
                              color: const Color(0xFF666666),
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

          if (specializations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: specializations.map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    spec,
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (trainer.bio != null && trainer.bio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              trainer.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF666666),
                height: 1.3,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // "Chat Now" WhatsApp launch button
          Button.filled(
            size: const Size(double.infinity, 40),
            title: 'Chat Now',
            buttonColor: const Color(0xFF25D366),
            style: AppStyles.text13Px.poppins.w600.copyWith(
              color: Colors.white,
            ),
            icon: SvgPicture.asset(
              'assets/images/svg/icons/whatsapp_logo.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            raduis: 10,
            ontap: () async {
              final phone = trainer.mobile?.replaceAll(RegExp('[^0-9+]'), '') ?? '';
              if (phone.isNotEmpty) {
                final message = Uri.encodeComponent(
                  'Hi ${trainer.name},\n\n'
                  'I would like to connect with you regarding my workouts and training plans.\n\n'
                  'Thank you.',
                );
                final waUrl = Uri.parse('https://wa.me/$phone?text=$message');
                if (await canLaunchUrl(waUrl)) {
                  await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                } else {
                  await Dialogs.showSnack(msg: 'Invalid WhatsApp number');
                }
              } else {
                await Dialogs.showSnack(msg: 'WhatsApp number not available');
              }
            },
          ),
        ],
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
