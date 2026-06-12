import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  const WorkoutHistoryCalendar({super.key});

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  DateTime _focusedDay = DateTime.now();

  // Dummy data mimicking the image
  final List<int> completedDays = [1, 2, 5, 6, 8];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consistency',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: const Color(0xFF222222),
              ),
            ),
            // InkWell(
            //   onTap: () {},
            //   child: Row(
            //     children: [
            //       Text(
            //         'Show all',
            //         style: AppStyles.text14Px.poppins.w600.copyWith(
            //           color: AppColors.textDark,
            //           decoration: TextDecoration.underline,
            //         ),
            //       ),
            //       const SizedBox(width: 4),
            //       const Icon(Icons.arrow_outward, size: 16),
            //     ],
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Custom Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy').format(_focusedDay), // "2025"
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: AppColors.primary.withValues(alpha: .7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM').format(_focusedDay), // "March"
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                              1,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                              1,
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Calendar Grid
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 60,
                headerVisible: false, // Hidden default header
                availableGestures:
                    AvailableGestures.none, //  Fixes the scroll issue!
                daysOfWeekHeight: 46, // Increased height to allow for a gap
                calendarBuilders: CalendarBuilders(
                  // Custom Day of Week builder to add bottom padding
                  dowBuilder: (context, day) {
                    final text = DateFormat.E()
                        .format(day)
                        .substring(0, 3); // "Mon", "Tue"
                    return Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        text,
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  defaultBuilder:
                      (context, day, focusedDay) => _buildDayCell(day),
                  todayBuilder:
                      (context, day, focusedDay) => _buildDayCell(day),
                  outsideBuilder:
                      (context, day, focusedDay) =>
                          const SizedBox.shrink(), // Hide outside days
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.grey.shade200, thickness: 1),
              ),

              // Progress Section
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
                      center: Text(
                        '76%\nTotal Done',
                        textAlign: TextAlign.center,
                        style: AppStyles.text13Px.poppins.w700,
                      ),
                      progressColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _summaryItem(
                            'Completed Sessions',
                            '150 Days',
                            Colors.red.shade100,
                            Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Rest Days',
                            '4 Days',
                            Colors.blue.shade100,
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Missed Sessions',
                            '38 Days',
                            Colors.yellow.shade100,
                            Colors.orange,
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
      ],
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    Color bgColor,
    Color dotColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppStyles.text12Px.poppins.w500)),
          Text(
            value,
            style: AppStyles.text12Px.poppins.w700.copyWith(color: dotColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    DateTime todayOnly = DateTime(now.year, now.month, now.day);

    // Any day after today is strictly future/upcoming
    bool isFuture = dateOnly.isAfter(todayOnly);

    // Only past or present days can be completed
    bool isCompleted = !isFuture && completedDays.contains(day.day);

    // Any past or present day that is not completed is automatically missed
    bool isMissed = !isFuture && !isCompleted;

    if (isCompleted) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFE8F5E9),
        borderColor: Colors.transparent,
        topIcon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipOval(
            child: SvgPicture.asset(
              'assets/images/svg/icons/green_success.svg',
              width: 17,
              height: 17,
            ),
          ),
        ),
      );
    }
    if (isMissed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFFFEBEE),
        borderColor: Colors.transparent,
        topIcon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
        ),
      );
    }

    // Default / Future Day
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _dayState({
    required DateTime day,
    required Color bgColor,
    required Color borderColor,
    required Widget topIcon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: Colors.black87,
            ),
          ),
        ),
        Positioned(
          top: -5,
          left: 0,
          right: 0,
          child: Align(alignment: Alignment.topCenter, child: topIcon),
        ),
      ],
    );
  }
}
