import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  const WorkoutHistoryCalendar({super.key});

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

enum CalendarDayState { completed, missed, rest, future }

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, CalendarDayState> _dayStates = {};
  bool _isLoading = false;
  int _completedRequestsCount = 0;
  Timer? _loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _prepopulateDefaultStates();
    _loadMonthData();
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  void _prepopulateDefaultStates() {
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      _dayStates[DateTime(date.year, date.month, date.day)] = date.isAfter(todayOnly)
          ? CalendarDayState.future
          : CalendarDayState.rest;
    }
  }

  Future<void> _loadMonthData() async {
    if (!mounted) return;
    
    _loadingTimeoutTimer?.cancel();
    setState(() {
      _isLoading = true;
      _completedRequestsCount = 0;
    });

    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Timeout safety net to make sure loading indicator doesn't get stuck
    _loadingTimeoutTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      WorkoutRepository().getWorkoutLogForDate(date: dateStr).then((result) {
        if (!mounted) return;
        
        result.fold(
          (error) {
            _updateDayState(date, date.isAfter(todayOnly)
                ? CalendarDayState.future
                : CalendarDayState.rest, daysInMonth);
          },
          (logs) {
            final dateOnly = DateTime(date.year, date.month, date.day);
            final isFuture = dateOnly.isAfter(todayOnly);

            bool hasCompleted = logs.any((item) => item['is_completed'] == true);

            if (hasCompleted) {
              _updateDayState(date, CalendarDayState.completed, daysInMonth);
            } else if (!isFuture && dateOnly.isBefore(todayOnly)) {
              if (logs.isNotEmpty) {
                _updateDayState(date, CalendarDayState.missed, daysInMonth);
              } else {
                _updateDayState(date, CalendarDayState.rest, daysInMonth);
              }
            } else {
              _updateDayState(date, CalendarDayState.future, daysInMonth);
            }
          },
        );
      }).catchError((e) {
        if (!mounted) return;
        _updateDayState(date, date.isAfter(todayOnly)
            ? CalendarDayState.future
            : CalendarDayState.rest, daysInMonth);
      });
    }
  }

  void _updateDayState(DateTime date, CalendarDayState state, int totalDays) {
    if (!mounted) return;
    setState(() {
      _dayStates[DateTime(date.year, date.month, date.day)] = state;
      _completedRequestsCount++;
      if (_completedRequestsCount >= totalDays) {
        _isLoading = false;
        _loadingTimeoutTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    int missedCount = 0;
    int restCount = 0;

    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final state = _dayStates[DateTime(date.year, date.month, date.day)] ?? CalendarDayState.future;
      if (state == CalendarDayState.completed) {
        completedCount++;
      } else if (state == CalendarDayState.missed) {
        missedCount++;
      } else if (state == CalendarDayState.rest) {
        restCount++;
      }
    }

    final totalScheduled = completedCount + missedCount;
    final double percent = totalScheduled > 0 ? (completedCount / totalScheduled) : 0.0;
    final int percentInt = (percent * 100).round();

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
                          _prepopulateDefaultStates();
                          _loadMonthData();
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
                          _prepopulateDefaultStates();
                          _loadMonthData();
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
              if (_isLoading)
                const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                const SizedBox(height: 2),

              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 60,
                headerVisible: false, // Hidden default header
                availableGestures: AvailableGestures.none, // Fixes the scroll issue!
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
                  defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
                  todayBuilder: (context, day, focusedDay) => _buildDayCell(day),
                  outsideBuilder: (context, day, focusedDay) => const SizedBox.shrink(), // Hide outside days
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
                      percent: percent,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      center: Text(
                        '$percentInt%\nTotal Done',
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
                            '$completedCount Days',
                            Colors.red.shade100,
                            Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Rest Days',
                            '$restCount Days',
                            Colors.blue.shade100,
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Missed Sessions',
                            '$missedCount Days',
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

    final state = _dayStates[dateOnly] ?? CalendarDayState.future;

    if (state == CalendarDayState.completed) {
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
    if (state == CalendarDayState.missed) {
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

    // Default / Future / Rest Day
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
          color: state == CalendarDayState.rest ? Colors.black87 : Colors.grey.shade400,
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
