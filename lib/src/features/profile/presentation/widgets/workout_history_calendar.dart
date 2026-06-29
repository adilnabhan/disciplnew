import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  const WorkoutHistoryCalendar({this.startDate, super.key});

  final DateTime? startDate;

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
  
  bool _isEditing = false;
  final Set<DateTime> _selectedRestDays = {};
  
  final Map<DateTime, int> _dayPlanDayIds = {};
  final Map<DateTime, int> _dayCustomerWorkoutPlanIds = {};
  int? _fallbackPlanId;
  int? _fallbackPlanDayId;

  T? _firstNonNull<T>(Iterable<T?> values) {
    for (final v in values) {
      if (v != null) return v;
    }
    return null;
  }

  DateTime get _firstWorkoutDate {
    return (widget.startDate ?? DateTime.now().subtract(const Duration(days: 30))).toLocal();
  }

  Future<void> _loadFallbackPlanInfo() async {
    try {
      final presetsRes = await WorkoutRepository().getPresets();
      presetsRes.fold(
        (error) => null,
        (presetsList) async {
          if (presetsList.isNotEmpty) {
            final activePreset = presetsList.first;
            _fallbackPlanId = activePreset.id;
            
            // Use planDayId directly from preset model (populated from API)
            if (activePreset.planDayId != null) {
              _fallbackPlanDayId = activePreset.planDayId;
            } else {
              // Fallback: call detail endpoint to get plan_day_id
              final detailRes = await WorkoutRepository().getPresetDetail(activePreset.id);
              detailRes.fold(
                (error) => null,
                (detail) {
                  final planDayId = detail['plan_day_id'];
                  if (planDayId != null) {
                    _fallbackPlanDayId = int.tryParse(planDayId.toString());
                  }
                }
              );
            }
          }
        }
      );
    } catch (e) {
      debugPrint('Error loading fallback plan info: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _selectedRestDays.clear();
        _dayStates.forEach((date, state) {
          if (state == CalendarDayState.rest) {
            _selectedRestDays.add(date);
          }
        });
      } else {
        final List<Map<String, dynamic>> restDaysToUpdate = [];
        int? finalPlanId;

        final year = _focusedDay.year;
        final month = _focusedDay.month;
        final daysInMonth = DateTime(year, month + 1, 0).day;

        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(year, month, day);
          final dateOnly = DateTime(date.year, date.month, date.day);
          final oldState = _dayStates[dateOnly] ?? CalendarDayState.future;
          final isCurrentlyRest = oldState == CalendarDayState.rest;
          final shouldBeRest = _selectedRestDays.contains(dateOnly);

          if (isCurrentlyRest != shouldBeRest) {
            final planDayId = _dayPlanDayIds[dateOnly] ?? 
                              _firstNonNull(_dayPlanDayIds.values) ?? 
                              _fallbackPlanDayId;
            
            final customerWorkoutPlanId = _dayCustomerWorkoutPlanIds[dateOnly] ?? 
                                           _firstNonNull(_dayCustomerWorkoutPlanIds.values) ?? 
                                           _fallbackPlanId;

            if (customerWorkoutPlanId != null) {
              finalPlanId = customerWorkoutPlanId;
            }
            restDaysToUpdate.add({
              'plan_day_id': planDayId ?? -1,
              'date': DateFormat('yyyy-MM-dd').format(dateOnly),
              'is_rest_day': shouldBeRest,
            });
          }
        }

        if (restDaysToUpdate.isNotEmpty) {
          finalPlanId ??= _fallbackPlanId ?? -1;
          setState(() {
            _isLoading = true;
          });
          WorkoutRepository().updateRestDaysBulk(
            customerWorkoutPlanId: finalPlanId,
            restDays: restDaysToUpdate,
          ).then((res) {
            if (!mounted) return;
            res.fold(
              (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err.msg ?? 'Failed to update rest days.'),
                    backgroundColor: const Color(0xFFC60000),
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
                _loadMonthData();
              },
              (data) {
                debugPrint('Successfully updated rest days in bulk: $data');
                _loadMonthData();
              },
            );
          });
        } else {
          _prepopulateDefaultStates();
          _loadMonthData();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFallbackPlanInfo().then((_) {
      _prepopulateDefaultStates();
      _loadMonthData();
    });
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

    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      if (dateOnly.isBefore(startDateOnly) || dateOnly.isAfter(todayOnly) || dateOnly.isAtSameMomentAs(todayOnly)) {
        _dayStates[dateOnly] = CalendarDayState.future;
      } else {
        if (_dayStates[dateOnly] != CalendarDayState.rest) {
          _dayStates[dateOnly] = CalendarDayState.future;
        }
      }
    }
  }

  Future<void> _loadMonthData() async {
    if (!mounted) return;
    
    _loadingTimeoutTimer?.cancel();
    setState(() {
      _isLoading = true;
    });

    final year = _focusedDay.year;
    final month = _focusedDay.month;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    _loadingTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    WorkoutRepository().getWorkoutCalendarForMonth(year: year, month: month).then((result) {
      if (!mounted) return;
      _loadingTimeoutTimer?.cancel();
      
      result.fold(
        (error) {
          setState(() {
            _isLoading = false;
          });
        },
        (data) {
          final List<dynamic> days = data['days'] as List<dynamic>? ?? [];
          setState(() {
            for (final dayItem in days) {
              if (dayItem is Map<String, dynamic>) {
                final dateStr = dayItem['date'] as String;
                final date = DateTime.parse(dateStr);
                final dateOnly = DateTime(date.year, date.month, date.day);
                
                final bool hasWorkout = dayItem['has_workout'] == true;
                final bool isCompleted = dayItem['is_completed'] == true;
                final bool isRestDay = dayItem['is_rest_day'] == true;
                final int? workoutId = dayItem['workout_id'] != null ? int.tryParse(dayItem['workout_id'].toString()) : null;
                
                if (workoutId != null) {
                  _dayCustomerWorkoutPlanIds[dateOnly] = workoutId;
                }
                
                CalendarDayState state;
                if (!hasWorkout && !isRestDay) {
                  state = CalendarDayState.future;
                } else if (isCompleted) {
                  state = CalendarDayState.completed;
                } else if (isRestDay) {
                  state = CalendarDayState.rest;
                } else if (dateOnly.isBefore(startDateOnly)) {
                  state = CalendarDayState.future;
                } else if (dateOnly.isAfter(todayOnly)) {
                  state = CalendarDayState.future;
                } else if (dateOnly.isAtSameMomentAs(todayOnly)) {
                  state = CalendarDayState.future;
                } else {
                  state = CalendarDayState.missed;
                }
                
                _dayStates[dateOnly] = state;
              }
            }
            _isLoading = false;
          });
        },
      );
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consistency',
              style: AppStyles.text18Px.poppins.w600,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                  InkWell(
                    onTap: _toggleEditMode,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isEditing ? const Color(0xFFC60000) : const Color.fromARGB(255, 238, 240, 245),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (!_isEditing)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            )
                        ]
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing ? Icons.save : Icons.edit,
                            size: 16,
                            color: _isEditing ? Colors.white : Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isEditing ? 'Save' : 'Edit Rest day',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: _isEditing ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
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

              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(top: 16, left: 8, right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(239, 243, 255, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Set your rest days by selecting on the dates and clicking the save button.',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color.fromRGBO(95, 122, 197, 1),
                    ),
                    textAlign: TextAlign.center,
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
                            'Completed Days',
                            '$completedCount Days',
                            Colors.green.shade100,
                            AppColors.dark,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Rest Days',
                            '$restCount Days',
                            Colors.blue.shade100,
                            AppColors.dark,
                          ),
                          const SizedBox(height: 8),
                          _summaryItem(
                            'Missed Days',
                            '$missedCount Days',
                            Colors.red.shade100,
                            AppColors.dark,
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

    final startDate = _firstWorkoutDate;
    final startDateOnly = startDate != null 
        ? DateTime(startDate.year, startDate.month, startDate.day) 
        : DateTime(todayOnly.year, todayOnly.month, 1);

    final state = _dayStates[dateOnly] ?? CalendarDayState.future;

    if (_isEditing && state != CalendarDayState.completed && !dateOnly.isBefore(startDateOnly) && !dateOnly.isBefore(todayOnly)) {
      final isSelected = _selectedRestDays.contains(dateOnly);
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedRestDays.remove(dateOnly);
            } else {
              _selectedRestDays.add(dateOnly);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromRGBO(95, 122, 197, 1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color.fromRGBO(95, 122, 197, 1),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

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
    final isRest = state == CalendarDayState.rest;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: isRest ? const Color.fromRGBO(239, 243, 255, 1) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(
          color: isRest ? const Color.fromRGBO(95, 122, 197, 1) : Colors.grey.shade400,
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
