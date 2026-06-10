import 'dart:ui';

import 'package:customer_mobile_app/src/features/workout_log/persentation/persentation.dart';
import 'package:flutter/scheduler.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart'
    show
        CalendarBuilders,
        CalendarFormat,
        CalendarStyle,
        DaysOfWeekStyle,
        HeaderStyle,
        TableCalendar,
        isSameDay;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _cubit;
  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
    _dashboardCubit = DashboardCubit();
    _fetch();
    _fetchActiveMembership();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _fetch() async {
    await _cubit.fetchHomeData();
  }

  Future<void> _fetchActiveMembership() async {
    await _dashboardCubit.fetchActiveMembership();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F7),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          bloc: _dashboardCubit,
          builder: (context, dashboardState) {
            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return state.homeData.fold(
                  () => const Center(child: CircularProgressIndicator()),
                  (either) => either.fold((error) {
                    return error
                        .maybeWhen(
                          network: (e) => ErrorUi.network(onTap: _fetch),
                          notFound: (e) => ErrorUi.notFound(onTap: _fetch),
                          orElse: () => ErrorUi.server(onTap: _fetch),
                        )
                        .center;
                  }, homeView),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget homeView(HomeModel homeData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
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
                  return _buildActiveGymSection(activeMembership).pxy(x: 16);
                }),
              );
            },
          ),

          // Ready To Level Up Card (always shown for all users)
          _membershipExpireCard(context),

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

  // Widget _buildWorkoutLogSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Workout Log', style: AppStyles.text18Px.poppins.w600),
  //       const SizedBox(height: 16),
  //       SizedBox(
  //         height: 240,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withValues(alpha: 0.05),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //             border: Border.all(color: Colors.grey.shade300, width: 0.8),
  //           ),
  //           child: Stack(
  //             children: [
  //               Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   // Placeholder workout entries
  //                   ...List.generate(4, (index) {
  //                     return Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 8),
  //                       child: Row(
  //                         children: [
  //                           Container(
  //                             width: 40,
  //                             height: 40,
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey.shade100,
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Expanded(
  //                             child: Column(
  //                               children: [
  //                                 Container(
  //                                   height: 12,
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.grey.shade200,
  //                                     borderRadius: BorderRadius.circular(6),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 8),
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                       flex: 2,
  //                                       child: Container(
  //                                         height: 8,
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.grey.shade100,
  //                                           borderRadius: BorderRadius.circular(
  //                                             4,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 8),
  //                                     Expanded(
  //                                       child: Container(
  //                                         height: 8,
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.grey.shade100,
  //                                           borderRadius: BorderRadius.circular(
  //                                             4,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }),
  //                 ],
  //               ).pxy(x: 16),
  //               // Only show the blur effect inside the card area, not over the whole section
  //               Positioned(
  //                 left: 0,
  //                 right: 0,
  //                 top: 0,
  //                 bottom: 0,
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(12),
  //                   child: BackdropFilter(
  //                     filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withValues(alpha: 0.18),
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: Colors.white.withValues(alpha: 0.25),
  //                           width: 1.5,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Center(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(16),
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         gradient: const LinearGradient(
  //                           colors: [Color(0xFF232323), Color(0xFF757575)],
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                         ),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.black.withValues(alpha: 0.18),
  //                             blurRadius: 12,
  //                             offset: const Offset(0, 4),
  //                           ),
  //                         ],
  //                       ),
  //                       child: const Icon(
  //                         Icons.lock_outline_rounded,
  //                         size: 44,
  //                         color: Color(0xFFE0E0E0),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 18),
  //                     ShaderMask(
  //                       shaderCallback: (Rect bounds) {
  //                         return const LinearGradient(
  //                           colors: [Color(0xFF757575), Color(0xFF232323)],
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                         ).createShader(bounds);
  //                       },
  //                       blendMode: BlendMode.srcIn,
  //                       child: Text(
  //                         'Coming Soon',
  //                         style: AppStyles.text22Px.poppins.w600.copyWith(
  //                           color: Colors.white,
  //                           fontStyle: FontStyle.italic,
  //                           letterSpacing: 1.2,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Text(
  //                       'Exciting features are on the way!',
  //                       style: AppStyles.text14Px.poppins.w400.copyWith(
  //                         color: Colors.grey.shade600,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   ).pxy(x: 16);
  // }

  Widget _buildWorkoutLogSection({ActiveMembershipModel? activeMembership}) {
    DateTime selectedDay = DateTime.now();
    List<int> completedDays = [
      1,
      4,
      5,
      6,
      7,
      8,
      9,
      11,
      12,
      13,
      15,
      16,
      18,
      19,
      20,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // context.push(WorkoutLogScreen(activeMembership: activeMembership));
            // context.push(WorkoutLogScreen());
          },

          child: Text(
            'Attendance (Coming Soon)',
            style: AppStyles.text18Px.poppins.w600.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // Calendar size
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar(

                  // rowHeight: 60.h,
                  daysOfWeekHeight: 30.h,
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),

                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },

                  onDaySelected: (selected, focused) {
                    selectedDay = selected;
                  },

                  // Styling
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppStyles.text16Px.poppins.w600.copyWith(
                      color: Colors.black87,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, size: 22),
                    rightChevronIcon: const Icon(Icons.chevron_right, size: 22),
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppStyles.text12Px.poppins.w500,
                    weekendStyle: AppStyles.text12Px.poppins.w500,
                  ),

                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: false,
                    defaultTextStyle: AppStyles.text13Px.poppins.w500,
                    weekendTextStyle: AppStyles.text13Px.poppins.w500,
                    outsideTextStyle: const TextStyle(color: Colors.grey),
                  ),

                  // THE IMPORTANT PART — FULLY CUSTOM DAY UI
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final bool isFuture = day.isAfter(DateTime.now());
                      final bool isCompleted = completedDays.contains(day.day);

                      if (isFuture) return _futureDay(day);
                      if (isCompleted) return _completedDay(day);
                      // if (isSpecialDay) return _specialDay(day);
                      // if (isSelected) return _selectedDay(day);

                      return _normalDay(day);
                    },
                  ),
                ),
              ),

              /// Summary Boxes
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 55.r,
                      lineWidth: 12,
                      percent: 0.76,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      center: const Text(
                        '76%\nTotal Done',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      progressColor: Colors.red,
                      backgroundColor: Colors.grey.shade200,
                    ),

                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 25.h),
                          _summaryItem(
                            'Completed Sessions',
                            '150 Days',
                            Colors.red.shade100,
                            Colors.red,
                          ),
                          const SizedBox(height: 10),
                          _summaryItem(
                            'Rest Days',
                            '4 Days',
                            Colors.blue.shade100,
                            Colors.blue,
                          ),
                          const SizedBox(height: 10),
                          _summaryItem(
                            'Missed Sessions',
                            '38 Days',
                            Colors.yellow.shade100,
                            Colors.orange,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).pxy(x: 5);
  }

  Widget _completedDay(DateTime day) {
    return Stack(
      clipBehavior: Clip.none, // IMPORTANT: allows the icon to go outside
      children: [
        // MAIN DAY CONTAINER
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.2),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: AppColors.dark,
            ),
          ),
        ),

        // FLOATING CHECK ICON (TOP CENTER)
        Positioned(
          top: -3, // pushes icon slightly OUTSIDE the container
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary, // red
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectedDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.red),
      ),
    );
  }

  Widget _specialDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DD),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.black87),
      ),
    );
  }

  Widget _futureDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.dark),
      ),
    );
  }

  Widget _normalDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.2),
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.dark),
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    Color bgColor,
    Color dotColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // CircleAvatar(radius: 6, backgroundColor: dotColor),
          // const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontSize: 10.sp))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dotColor,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// --- Helper for the bottom stats ---
Widget _stat(String title, String value, Color bg) {
  return Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppStyles.text14Px.poppins.w500),
        const SizedBox(width: 6),
        Text(value, style: AppStyles.text14Px.poppins.w600),
      ],
    ),
  );
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
          const SizedBox(height: 24),
          Text(
            'Built by fitness lovers 🧡',
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: const Color(0xff666666),
            ),
          ),
          const SizedBox(height: 132),
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

void _showMembershipExpiredPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(child: _membershipExpireView(context, dialogContext)),
  );
}

Widget _membershipExpireView(BuildContext parentContext, BuildContext dialogContext) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
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
                      // Container(
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         Colors.pink.shade100,
                      //         Colors.purple.shade200,
                      //       ],
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.purple.withValues(alpha: 0.3),
                      //         blurRadius: 24,
                      //         spreadRadius: 4,
                      //         offset: const Offset(0, 8),
                      //       ),
                      //     ],
                      //   ),
                      //   padding: const EdgeInsets.all(24),
                      //   child: Icon(
                      //     Icons.sentiment_dissatisfied,
                      //     size: 64,
                      //     color: Colors.purple.shade700,
                      //   ),
                      // ),
                      Lottie.asset(
                        'assets/images/svg/vectors/Waving_Wolf.json',
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                      ),
                      // const SizedBox(height: 24),
                      Text(
                        'Ready To Level Up',
                        style: AppStyles.text20Px.poppins.w600.dark,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        // 'You currently do not have an active subscription. Please subscribe to access all features.',
                        'Join a fitness center on Discipl and begin your fitness journey with confidence.',
                        style: AppStyles.text14Px.poppins.w400.dark,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Button.filled(
                        title: 'Explore Fitness Centers',
                        ontap: () {
                          Navigator.pop(dialogContext);
                          parentContext.read<DashboardCubit>().changeNav(index: 2);
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
              ),
            ).pOnly(bottom: 80),
          ],
        ),
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

class DynamicCalendar extends StatelessWidget {
  final int year;
  final int month;

  /// Pass dynamic data here
  final List<int> completedDays;
  final List<int> missedDays;
  final List<int> restDays;

  /// Selected day
  final int? selectedDay;

  const DynamicCalendar({
    super.key,
    required this.year,
    required this.month,
    this.completedDays = const [],
    this.missedDays = const [],
    this.restDays = const [],
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month);
    final totalDays = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1 = Monday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- WEEKDAYS ---
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mon'),
            Text('Tue'),
            Text('Wed'),
            Text('Thu'),
            Text('Fri'),
            Text('Sat'),
            Text('Sun'),
          ],
        ),
        const SizedBox(height: 14),

        // --- CALENDAR GRID ---
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            // Add empty placeholders until the first weekday
            ...List.generate(startWeekday - 1, (_) {
              return Container(width: 34, height: 34);
            }),

            // Now generate all days dynamically
            ...List.generate(totalDays, (index) {
              int day = index + 1;

              Color bgColor = Colors.grey.shade200;
              Color textColor = Colors.black87;

              if (completedDays.contains(day)) {
                bgColor = Colors.red;
                textColor = Colors.white;
              } else if (restDays.contains(day)) {
                bgColor = Colors.blue.shade300;
                textColor = Colors.white;
              } else if (missedDays.contains(day)) {
                bgColor = Colors.orange.shade400;
                textColor = Colors.white;
              }

              if (selectedDay == day) {
                bgColor = Colors.red.withOpacity(0.3);
                textColor = Colors.black;
              }

              return Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
