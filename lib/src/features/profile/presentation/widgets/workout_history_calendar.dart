import 'dart:async';
import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_log_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  const WorkoutHistoryCalendar({this.startDate, super.key});

  final DateTime? startDate;

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

enum CalendarDayState { completed, verified, missed, rest, future }

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  final GlobalKey _calendarCardKey = GlobalKey();
  OverlayEntry? _onboardingOverlayEntry;

  DateTime _focusedDay = DateTime.now();
  final Map<String, CalendarDayState> _dayStates = {};
  bool _isLoading = false;
  int _completedRequestsCount = 0;
  Timer? _loadingTimeoutTimer;

  bool _isEditing = false;
  final Set<String> _selectedRestDays = {};

  final Map<String, int> _dayPlanDayIds = {};
  final Map<String, int> _dayCustomerWorkoutPlanIds = {};
  final Map<String, int> _dayWorkoutIds = {};
  int? _fallbackPlanId;
  int? _fallbackPlanDayId;

  bool _hasLoadedData = false;
  Timer? _visibilityDebounceTimer;
  DateTime? _lastVisibilityLoadTime;

  T? _firstNonNull<T>(Iterable<T?> values) {
    for (final v in values) {
      if (v != null) return v;
    }
    return null;
  }

  DateTime get _firstWorkoutDate {
    return widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));
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

            if (activePreset.planDayId != null) {
              _fallbackPlanDayId = activePreset.planDayId;
            } else {
              final detailRes = await WorkoutRepository().getPresetDetail(activePreset.id);
              detailRes.fold(
                (error) => null,
                (detail) {
                  final planDayId = detail['plan_day_id'];
                  if (planDayId != null) {
                    _fallbackPlanDayId = int.tryParse(planDayId.toString());
                  }
                },
              );
            }
          }
        },
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
          final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
          final oldState = _dayStates[dateKey] ?? CalendarDayState.future;
          final isCurrentlyRest = oldState == CalendarDayState.rest;
          final shouldBeRest = _selectedRestDays.contains(dateKey);

          if (isCurrentlyRest != shouldBeRest) {
            final planDayId = _dayPlanDayIds[dateKey] ??
                _firstNonNull(_dayPlanDayIds.values) ??
                _fallbackPlanDayId;

            final customerWorkoutPlanId = _dayCustomerWorkoutPlanIds[dateKey] ??
                _firstNonNull(_dayCustomerWorkoutPlanIds.values) ??
                _fallbackPlanId;

            if (customerWorkoutPlanId != null) {
              finalPlanId = customerWorkoutPlanId;
            }
            restDaysToUpdate.add({
              'plan_day_id': planDayId ?? -1,
              'date': dateKey,
              'is_rest_day': shouldBeRest,
            });
          }
        }

        if (restDaysToUpdate.isNotEmpty) {
          finalPlanId ??= _fallbackPlanId ?? -1;
          setState(() {
            _isLoading = true;
          });
          WorkoutRepository()
              .updateRestDaysBulk(
                customerWorkoutPlanId: finalPlanId,
                restDays: restDaysToUpdate,
              )
              .then((res) {
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
    // Data loading is deferred to VisibilityDetector
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.05) {
      // Debounce: skip if loaded less than 3 seconds ago
      final now = DateTime.now();
      if (_lastVisibilityLoadTime != null &&
          now.difference(_lastVisibilityLoadTime!).inSeconds < 3) {
        return;
      }

      _visibilityDebounceTimer?.cancel();
      _visibilityDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final bool wasLoaded = _hasLoadedData;
        _lastVisibilityLoadTime = DateTime.now();
        setState(() {
          _hasLoadedData = true;
        });
        _loadFallbackPlanInfo().then((_) {
          _prepopulateDefaultStates();
          _loadMonthData();
          if (!wasLoaded) {
            _checkAndShowOnboardingHint();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _onboardingOverlayEntry?.remove();
    _onboardingOverlayEntry = null;
    _loadingTimeoutTimer?.cancel();
    _visibilityDebounceTimer?.cancel();
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
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

      if (dateOnly.isBefore(startDateOnly) ||
          dateOnly.isAfter(todayOnly) ||
          dateOnly.isAtSameMomentAs(todayOnly)) {
        _dayStates[dateKey] = CalendarDayState.future;
      } else {
        if (_dayStates[dateKey] != CalendarDayState.rest) {
          _dayStates[dateKey] = CalendarDayState.future;
        }
      }
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

    _loadingTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    WorkoutRepository().getWorkoutCalendarForMonth(year: year, month: month).then((result) {
      if (!mounted) return;

      result.fold(
        (error) {
          setState(() {
            _isLoading = false;
          });
        },
        (data) {
          final List<dynamic> days = data['days'] as List<dynamic>? ?? [];
          final today = DateTime.now();
          final todayOnly = DateTime(today.year, today.month, today.day);
          final startDate = _firstWorkoutDate;
          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

          setState(() {
            _dayStates.clear();
            _dayPlanDayIds.clear();
            _dayCustomerWorkoutPlanIds.clear();
            _dayWorkoutIds.clear();

            for (final dayItem in days) {
              if (dayItem is Map<String, dynamic>) {
                final dateStr = dayItem['date'] as String;
                final date = DateTime.parse(dateStr);
                final dateOnly = DateTime(date.year, date.month, date.day);
                final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

                final bool isCompleted = dayItem['is_completed'] == true;
                final bool isVerified = dayItem['is_verified'] == true;
                final bool isRestDay = dayItem['is_rest_day'] == true;
                final int? planDayId = dayItem['plan_day_id'] != null ? int.tryParse(dayItem['plan_day_id'].toString()) : null;
                final int? customerWorkoutPlanId = dayItem['customer_workout_plan_id'] != null ? int.tryParse(dayItem['customer_workout_plan_id'].toString()) : null;
                final int? workoutId = dayItem['workout_id'] != null ? int.tryParse(dayItem['workout_id'].toString()) : null;

                if (planDayId != null) _dayPlanDayIds[dateKey] = planDayId;
                if (customerWorkoutPlanId != null) {
                  _dayCustomerWorkoutPlanIds[dateKey] = customerWorkoutPlanId;
                }
                if (workoutId != null) {
                  _dayWorkoutIds[dateKey] = workoutId;
                }

                CalendarDayState state;
                if (isCompleted) {
                  state = isVerified ? CalendarDayState.verified : CalendarDayState.completed;
                } else if (isRestDay) {
                  state = CalendarDayState.rest;
                } else if (dateOnly.isBefore(startDateOnly) ||
                    dateOnly.isAfter(todayOnly) ||
                    dateOnly.isAtSameMomentAs(todayOnly)) {
                  state = CalendarDayState.future;
                } else {
                  state = CalendarDayState.missed;
                }

                _dayStates[dateKey] = state;
              }
            }
            _isLoading = false;
            _loadingTimeoutTimer?.cancel();
          });
        },
      );
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _updateDayState(DateTime date, CalendarDayState state, int totalDays) {
    if (!mounted) return;
    setState(() {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      _dayStates[dateKey] = state;
      _completedRequestsCount++;
      if (_completedRequestsCount >= totalDays) {
        _isLoading = false;
        _loadingTimeoutTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final joinDate = _firstWorkoutDate;
    final joinMonth = DateTime(joinDate.year, joinDate.month, 1);
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final canGoPrev = currentMonth.isAfter(joinMonth);

    final today = DateTime.now();
    final todayMonth = DateTime(today.year, today.month, 1);
    final canGoNext = currentMonth.isBefore(todayMonth);

    int completedCount = 0;
    int missedCount = 0;
    int restCount = 0;

    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final state =
          _dayStates[dateKey] ?? CalendarDayState.future;
      if (state == CalendarDayState.completed || state == CalendarDayState.verified) {
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

    return VisibilityDetector(
      key: const Key('workout_history_calendar_visibility'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workout Journey', style: AppStyles.text18Px.poppins.w600),
              ],
            ),
            const SizedBox(height: 12),

            // Calendar Card
            Container(
              key: _calendarCardKey,
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
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: canGoPrev ? AppColors.primary : Colors.grey.shade400,
                            ),
                            onPressed: canGoPrev
                                ? () {
                                    setState(() {
                                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                                    });
                                    _prepopulateDefaultStates();
                                    _loadMonthData();
                                  }
                                : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy').format(_focusedDay),
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  fontSize: 11,
                                  color: AppColors.primary.withValues(alpha: .7),
                                ),
                              ),
                              Text(
                                DateFormat('MMMM').format(_focusedDay),
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: canGoNext ? AppColors.primary : Colors.grey.shade400,
                            ),
                            onPressed: canGoNext
                                ? () {
                                    setState(() {
                                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                                    });
                                    _prepopulateDefaultStates();
                                    _loadMonthData();
                                  }
                                : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _toggleEditMode,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? const Color(0xFFC60000)
                                : const Color.fromARGB(255, 238, 240, 245),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              if (!_isEditing)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isEditing ? Icons.save : Icons.edit,
                                size: 14,
                                color:
                                    _isEditing ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isEditing ? 'Save' : 'Edit Rest day',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: _isEditing
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Loading indicator
                  const SizedBox(height: 2),

                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    rowHeight: 60,
                    headerVisible: false,
                    availableGestures: AvailableGestures.none,
                    daysOfWeekHeight: 46,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      _prepopulateDefaultStates();
                      _loadMonthData();
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (_isEditing) return;

                      final today = DateTime.now();
                      final todayMidnight = DateTime(today.year, today.month, today.day);
                      final selectedMidnight = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      if (selectedMidnight.isAfter(todayMidnight)) {
                        return;
                      }

                      WorkoutLogScreen.selectedDateOverride = selectedDay;
                      try {
                        context.read<DashboardCubit>().changeNav(index: 1);
                      } catch (e) {
                        debugPrint('Error navigating to workouts tab: $e');
                      }
                    },
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        final text =
                            DateFormat.E().format(day).substring(0, 3);
                        return Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            text,
                            style: AppStyles.text14Px.poppins.w500
                                .copyWith(color: Colors.grey),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        return GestureDetector(
                          onDoubleTap: () => _handleDayDoubleTap(day),
                          child: _buildDayCell(day),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return GestureDetector(
                          onDoubleTap: () => _handleDayDoubleTap(day),
                          child: _buildDayCell(day),
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) =>
                          const SizedBox.shrink(),
                    ),
                  ),

                  if (_isEditing)
                    Container(
                      margin:
                          const EdgeInsets.only(top: 16, left: 8, right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                              _summaryItem('Completed Days',
                                  '$completedCount Days', Colors.green.shade100, AppColors.dark),
                              const SizedBox(height: 8),
                              _summaryItem('Rest Days', '$restCount Days',
                                  Colors.blue.shade100, AppColors.dark),
                              const SizedBox(height: 8),
                              _summaryItem('Missed Days', '$missedCount Days',
                                  Colors.red.shade100, AppColors.dark),
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
      ),
    );
  }

  Widget _summaryItem(
      String title, String value, Color bgColor, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppStyles.text12Px.poppins.w500)),
          Text(value,
              style:
                  AppStyles.text12Px.poppins.w700.copyWith(color: dotColor)),
        ],
      ),
    );
  }

  void _handleDayDoubleTap(DateTime day) {
    if (_isEditing) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final workoutId = _dayWorkoutIds[dateKey];

    WorkoutLogScreen.selectedDateOverride = day;
    if (workoutId != null) {
      WorkoutLogScreen.autoOpenSessionId = workoutId;
    }

    try {
      context.read<DashboardCubit>().changeNav(index: 1);
    } catch (e) {
      debugPrint('Error navigating to workouts tab: $e');
    }
  }

  Widget _buildDayCell(DateTime day) {
    final now = DateTime.now();
    final dateOnly = DateTime(day.year, day.month, day.day);
    final todayOnly = DateTime(now.year, now.month, now.day);

    final startDate = _firstWorkoutDate;
    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);

    final state = _dayStates[DateFormat('yyyy-MM-dd').format(dateOnly)] ?? CalendarDayState.future;

    if (_isEditing &&
        state != CalendarDayState.completed &&
        state != CalendarDayState.verified &&
        !dateOnly.isBefore(startDateOnly) &&
        !dateOnly.isBefore(todayOnly)) {
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
      final isSelected = _selectedRestDays.contains(dateKey);
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedRestDays.remove(dateKey);
            } else {
              _selectedRestDays.add(dateKey);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(95, 122, 197, 1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : const Color.fromRGBO(95, 122, 197, 1),
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

    if (state == CalendarDayState.verified) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFE3F2FD),
        borderColor: Colors.transparent,
        topIcon: const CompletedBadge(
          isVerified: true,
          width: 17,
          height: 17,
          coreSize: 8,
        ),
      );
    }

    if (state == CalendarDayState.completed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFE8F5E9),
        borderColor: Colors.transparent,
        topIcon: const CompletedBadge(
          isVerified: false,
          showDoubleTick: true,
          iconColor: Color(0xFF019C37),
          width: 17,
          height: 17,
          coreSize: 8,
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
    final isRest = state == CalendarDayState.rest;
    // Dates from startDate onwards (including today & future) → black text
    // Dates strictly before startDate (user never had the app) → grey text
    final isBeforeStart = dateOnly.isBefore(startDateOnly);
    final dayTextColor = isRest
        ? const Color.fromRGBO(95, 122, 197, 1)
        : isBeforeStart
            ? Colors.grey.shade400
            : const Color(0xFF212121);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: isRest
            ? const Color.fromRGBO(239, 243, 255, 1)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(
          color: dayTextColor,
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
            style: AppStyles.text14Px.poppins.w500
                .copyWith(color: Colors.black87),
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

  Future<void> _checkAndShowOnboardingHint() async {
    if (!mounted) return;
    
    final customerId = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (customerId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'has_seen_workout_journey_hint_$customerId';
    final hasSeen = prefs.getBool(key) ?? false;
    if (hasSeen) return;

    // Immediately mark as seen
    await prefs.setBool(key, true);

    // Schedule frame callback to measure layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = _calendarCardKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      final cutoutRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

      final overlayState = Overlay.of(context);
      _onboardingOverlayEntry = OverlayEntry(
        builder: (context) {
          return OnboardingOverlayContent(
            cutoutRect: cutoutRect,
            onDismiss: () {
              _onboardingOverlayEntry?.remove();
              _onboardingOverlayEntry = null;
            },
          );
        },
      );
      overlayState.insert(_onboardingOverlayEntry!);
    });
  }
}

class InvertedRectClipper extends CustomClipper<Path> {
  InvertedRectClipper({required this.rect});
  final Rect rect;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(InvertedRectClipper oldClipper) => oldClipper.rect != rect;
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}

class OnboardingTooltip extends StatelessWidget {
  const OnboardingTooltip({required this.onGotIt, super.key});
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            'Track Your Workout Journey',
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: Colors.black54,
                ),
                children: [
                  const TextSpan(
                    text: 'Track your completed workouts, planned rest days, and overall progress. Tap ',
                  ),
                  TextSpan(
                    text: '"Edit Rest Day"',
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: const Color(0xFFC60000),
                    ),
                  ),
                  const TextSpan(
                    text: ' to schedule your recovery days.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
          InkWell(
            onTap: onGotIt,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                'Got it',
                style: AppStyles.text16Px.poppins.w700.copyWith(
                  color: const Color(0xFFC60000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingOverlayContent extends StatefulWidget {
  const OnboardingOverlayContent({
    required this.cutoutRect,
    required this.onDismiss,
    super.key,
  });

  final Rect cutoutRect;
  final VoidCallback onDismiss;

  @override
  State<OnboardingOverlayContent> createState() => _OnboardingOverlayContentState();
}

class _OnboardingOverlayContentState extends State<OnboardingOverlayContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final tooltipWidth = screenWidth * 0.85;
    
    // Bottom offset from screen height
    final bottomOffset = screenHeight - widget.cutoutRect.top + 8;

    return Stack(
      children: [
        // 1. Full-screen GestureDetector to capture all gestures and block background scrolling
        GestureDetector(
          onTap: _handleDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),

        // 2. Semi-transparent black background with blur, excluding the calendar card visually
        IgnorePointer(
          child: ClipPath(
            clipper: InvertedRectClipper(rect: widget.cutoutRect),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ),
          ),
        ),

        // 2. Tooltip Card positioned above calendar
        Positioned(
          left: (screenWidth - tooltipWidth) / 2,
          bottom: bottomOffset,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingTooltip(
                      onGotIt: _handleDismiss,
                    ),
                    CustomPaint(
                      size: const Size(16, 8),
                      painter: TrianglePainter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
