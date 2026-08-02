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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;
  late final HomeCubit _homeCubit;
  final ProfileCompletionCubit _profileCompletionCubit =
      ProfileCompletionCubit();
  int _calendarRefreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _homeCubit = HomeCubit();
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    if (!isGuest) {
      _profileCompletionCubit.fetchProfileCompletion();
      _fetchActiveMembership();
    }
  }

  @override
  void dispose() {
    _profileCompletionCubit.close();
    _homeCubit.close();
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
      if (Feggy.read<AppCubit>()?.state.currentUser != null) ...[
        _homeCubit.fetchHomeData(),
        _profileCompletionCubit.fetchProfileCompletion(),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    return BlocProvider.value(
      value: _profileCompletionCubit,
      child:
          isGuest
              ? Scaffold(
                backgroundColor: const Color(0xffF7F7F7),
                body: homeView(),
              )
              : BlocListener<DashboardCubit, DashboardState>(
                listenWhen:
                    (previous, current) =>
                        previous.navIndex != current.navIndex &&
                        current.navIndex == 0,
                listener: (context, state) {
                  _profileCompletionCubit.fetchProfileCompletion();
                },
                child: Scaffold(
                  backgroundColor: const Color(0xffF7F7F7),
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

            // Active Gym Section (only if user has active membership data)
            BlocBuilder<DashboardCubit, DashboardState>(
              bloc: _dashboardCubit,
              builder: (context, dashboardState) {
                return dashboardState.activeMembershipData.fold(
                  () => const SizedBox.shrink(),
                  (either) => either.fold((_) => const SizedBox.shrink(), (
                    activeMembership,
                  ) {
                    if (activeMembership == null) {
                      return const SizedBox.shrink();
                    }
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
    final specialization = (trainer.specializations != null &&
            trainer.specializations!.isNotEmpty)
        ? trainer.specializations!.first
        : (trainer.userType ?? 'Trainer');
    final double ratingVal = trainer.rating ?? 4.8;
    final String ratingStr = ratingVal.toStringAsFixed(1);

    return GestureDetector(
      onTap: () {
        final gymTrainer = GymTrainer(
          id: trainer.id,
          fullName: trainer.name,
          userType: trainer.userType ?? 'Trainer',
          bio: trainer.bio,
          profileImage: trainer.profileImage,
          experienceYears: trainer.experienceYears,
          averageRating: trainer.rating ?? 4.8,
          reviewCount: 0,
          specializations: trainer.specializations,
          mobile: trainer.mobile,
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
              trainer.name ?? '',
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
  });

  factory HomeBannerItem.fromModel(BannerModel model) {
    return HomeBannerItem(
      imagePath: model.bannerImage ?? '',
      isAsset: false,
      title: model.title,
      contactNumber: model.contactNumber,
      websiteUrl: model.websiteUrl,
      redirectType: model.redirectType,
    );
  }

  factory HomeBannerItem.asset(String path) {
    return HomeBannerItem(imagePath: path, isAsset: true);
  }

  final String imagePath;
  final bool isAsset;
  final String? title;
  final String? contactNumber;
  final String? websiteUrl;
  final String? redirectType;
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

  static const List<String> _defaultLocalBanners = [
    'assets/images/carousel_images/discipl_carousel .png',
    'assets/images/carousel_images/carousel_discipl.jpg',
    'assets/images/carousel_images/GYM (Banner (Landscape)).png',
  ];

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

    // Fallback: If both APIs return no banners, use default local asset banners
    if (combinedBanners.isEmpty) {
      combinedBanners =
          _defaultLocalBanners
              .map((path) => HomeBannerItem.asset(path))
              .toList();
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

    if (banner.contactNumber != null && banner.contactNumber!.isNotEmpty) {
      final String phone = banner.contactNumber!.trim();
      final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
      try {
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}

      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
      } catch (e) {
        debugPrint('Error launching call: $e');
      }
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
    if (_isLoading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
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

    if (_banners.length == 1) {
      final banner = _banners[0];
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: GestureDetector(
            onTap: () => _onBannerTap(banner),
            child:
                banner.isAsset
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
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
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
                return GestureDetector(
                  onTap: () => _onBannerTap(banner),
                  child:
                      banner.isAsset
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
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_banners.length, (index) {
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
      // 1. Fetch from assigned gym trainers API (/api/v1/customer/gym-trainers/)
      final apiTrainers = await HomeRepository().fetchAssignedGymTrainers();
      if (apiTrainers.isNotEmpty) {
        if (mounted) {
          setState(() {
            _trainers = apiTrainers;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Fallback to fitness center details API
      final repo = FitnesscenterRepository();
      final cached = repo.getCachedDetails(widget.organizationId);
      if (cached != null &&
          cached.trainers != null &&
          cached.trainers!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _trainers = cached.trainers!
                .map((t) => AssignedTrainerModel(
                      id: t.id,
                      name: t.fullName,
                      profileImage: t.profileImage,
                      mobile: t.mobile,
                      experienceYears: t.experienceYears,
                      bio: t.bio,
                      specializations: t.specializations,
                    ))
                .toList();
            _isLoading = false;
          });
        }
        return;
      }

      final res = await repo.fitnesscenterDetails(id: widget.organizationId);
      res.fold((_) {
        if (mounted) setState(() => _isLoading = false);
      }, (details) {
        repo.cacheDetails(widget.organizationId, details);
        if (mounted) {
          setState(() {
            _trainers = (details.trainers ?? [])
                .map((t) => AssignedTrainerModel(
                      id: t.id,
                      name: t.fullName,
                      profileImage: t.profileImage,
                      mobile: t.mobile,
                      experienceYears: t.experienceYears,
                      bio: t.bio,
                      specializations: t.specializations,
                    ))
                .toList();
            _isLoading = false;
          });
        }
      });
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

        if (finalTrainers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
