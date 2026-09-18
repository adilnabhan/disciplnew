import 'dart:async';
import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_log_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  const WorkoutHistoryCalendar({super.key});

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

enum CalendarDayState { completed, verified, missed, rest, future, inactive }

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  final GlobalKey _calendarCardKey = GlobalKey();
  OverlayEntry? _onboardingOverlayEntry;
  bool _showLoginHint = false;
  Timer? _hintTimer;

  DateTime _focusedDay = DateTime.now();
  final Map<String, CalendarDayState> _dayStates = {};
  final Map<String, bool> _isRestDayMap = {};
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

  // Subscription to repository invalidation events
  StreamSubscription<String>? _calendarInvalidationSub;

  T? _firstNonNull<T>(Iterable<T?> values) {
    for (final v in values) {
      if (v != null) return v;
    }
    return null;
  }

  DateTime? _calendarStartDate;

  DateTime get _firstWorkoutDate {
    return _calendarStartDate ?? DateTime.now();
  }

  Future<void> _loadFallbackPlanInfo() async {
    try {
      final presetsRes = await WorkoutRepository().getPresets();
      presetsRes.fold((error) => null, (presetsList) async {
        if (presetsList.isNotEmpty) {
          final activePreset = presetsList.first;
          _fallbackPlanId = activePreset.id;

          if (activePreset.planDayId != null) {
            _fallbackPlanDayId = activePreset.planDayId;
          } else {
            final detailRes = await WorkoutRepository().getPresetDetail(
              activePreset.id,
            );
            detailRes.fold((error) => null, (detail) {
              final planDayId = detail['plan_day_id'];
              if (planDayId != null) {
                _fallbackPlanDayId = int.tryParse(planDayId.toString());
              }
            });
          }
        }
      });
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

        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final startDate = _firstWorkoutDate;
        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );

        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(year, month, day);
          final dateOnly = DateTime(date.year, date.month, date.day);
          final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
          final oldState = _dayStates[dateKey] ?? CalendarDayState.future;
          final isCurrentlyRest = oldState == CalendarDayState.rest;
          final shouldBeRest = _selectedRestDays.contains(dateKey);

          if (isCurrentlyRest != shouldBeRest) {
            final planDayId =
                _dayPlanDayIds[dateKey] ??
                _firstNonNull(_dayPlanDayIds.values) ??
                _fallbackPlanDayId;

            final customerWorkoutPlanId =
                _dayCustomerWorkoutPlanIds[dateKey] ??
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

            // Optimistically update local day state immediately so UI updates instantly
            _isRestDayMap[dateKey] = shouldBeRest;
            if (shouldBeRest) {
              _dayStates[dateKey] = CalendarDayState.rest;
            } else {
              if (dateOnly.isBefore(startDateOnly)) {
                _dayStates[dateKey] = CalendarDayState.inactive;
              } else if (dateOnly.isAfter(todayOnly) ||
                  dateOnly.isAtSameMomentAs(todayOnly)) {
                _dayStates[dateKey] = CalendarDayState.future;
              } else {
                _dayStates[dateKey] = CalendarDayState.missed;
              }
            }
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
                    _loadMonthData(forceRefresh: true);
                  },
                  (data) {
                    debugPrint('Successfully updated rest days in bulk: $data');
                    // Parse response rest_days if available to synchronize local state
                    if (data['rest_days'] is List) {
                      for (final item in (data['rest_days'] as List)) {
                        if (item is Map<String, dynamic> &&
                            item['date'] != null) {
                          final dStr = item['date'].toString();
                          final isRest = item['is_rest_day'] == true;
                          _isRestDayMap[dStr] = isRest;
                          if (isRest) {
                            _dayStates[dStr] = CalendarDayState.rest;
                          } else {
                            final dObj = DateTime.tryParse(dStr);
                            if (dObj != null) {
                              final dOnly = DateTime(
                                dObj.year,
                                dObj.month,
                                dObj.day,
                              );
                              if (dOnly.isBefore(startDateOnly)) {
                                _dayStates[dStr] = CalendarDayState.inactive;
                              } else if (dOnly.isAfter(todayOnly) ||
                                  dOnly.isAtSameMomentAs(todayOnly)) {
                                _dayStates[dStr] = CalendarDayState.future;
                              } else {
                                _dayStates[dStr] = CalendarDayState.missed;
                              }
                            }
                          }
                        }
                      }
                    }
                    // Invalidate cache so the refreshed month reflects new rest days
                    WorkoutRepository().invalidateCalendarMonth(
                      _focusedDay.year,
                      _focusedDay.month,
                    );
                    _loadMonthData(forceRefresh: true);
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
    _checkAndShowLoginHint();
    // Load data once on first mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hasLoadedData = true;
      _loadFallbackPlanInfo().then((_) {
        _prepopulateDefaultStates();
        _loadMonthData();
      });
    });

    // Listen for external invalidation events (e.g. finish workout).
    // When the currently displayed month is invalidated, reload immediately.
    _calendarInvalidationSub = WorkoutRepository().calendarInvalidationStream
        .listen((invalidatedKey) {
          if (!mounted) return;
          final currentKey =
              '${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, '0')}';
          if (invalidatedKey == currentKey) {
            debugPrint(
              '[Calendar] Received invalidation for $invalidatedKey – reloading',
            );
            _loadMonthData(forceRefresh: true);
          }
        });
  }

  /// Called externally (e.g. after finishing a workout) to invalidate the
  /// current month and reload fresh data.
  void invalidateAndReload() {
    if (!mounted) return;
    WorkoutRepository().invalidateCalendarMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    _loadMonthData(forceRefresh: true);
  }

  Future<void> _onPullToRefresh() async {
    WorkoutRepository().invalidateCalendarMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    await _loadMonthData(forceRefresh: true);
  }

  @override
  void dispose() {
    _calendarInvalidationSub?.cancel();
    _onboardingOverlayEntry?.remove();
    _onboardingOverlayEntry = null;
    _loadingTimeoutTimer?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _prepopulateDefaultStates() {
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

      _isRestDayMap[dateKey] = false;

      if (dateOnly.isBefore(startDateOnly)) {
        _dayStates[dateKey] = CalendarDayState.inactive;
      } else if (dateOnly.isAfter(todayOnly) ||
          dateOnly.isAtSameMomentAs(todayOnly)) {
        _dayStates[dateKey] = CalendarDayState.future;
      } else {
        if (_dayStates[dateKey] != CalendarDayState.rest) {
          _dayStates[dateKey] = CalendarDayState.future;
        }
      }
    }
  }

  void _parseAndSetCalendarData(Map<String, dynamic> data) {
    final String? apiStartDateStr = data['calendar_start_date'] as String?;
    if (apiStartDateStr != null) {
      _calendarStartDate = DateTime.tryParse(apiStartDateStr);
    }

    final List<dynamic> days = data['days'] as List<dynamic>? ?? [];
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    setState(() {
      _dayStates.clear();
      _isRestDayMap.clear();
      _dayPlanDayIds.clear();
      _dayCustomerWorkoutPlanIds.clear();
      _dayWorkoutIds.clear();

      _prepopulateDefaultStates();

      for (final dayItem in days) {
        if (dayItem is Map<String, dynamic>) {
          final dateStr = dayItem['date'] as String;
          final date = DateTime.parse(dateStr);
          final dateOnly = DateTime(date.year, date.month, date.day);
          final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

          final bool isCompleted = dayItem['is_completed'] == true;
          final bool isVerified = dayItem['is_verified'] == true;
          final bool isRestDay = dayItem['is_rest_day'] == true;
          final int? planDayId =
              dayItem['plan_day_id'] != null
                  ? int.tryParse(dayItem['plan_day_id'].toString())
                  : null;
          final int? customerWorkoutPlanId =
              dayItem['customer_workout_plan_id'] != null
                  ? int.tryParse(dayItem['customer_workout_plan_id'].toString())
                  : null;
          final int? workoutId =
              dayItem['workout_id'] != null
                  ? int.tryParse(dayItem['workout_id'].toString())
                  : null;

          _isRestDayMap[dateKey] = isRestDay;

          if (planDayId != null) _dayPlanDayIds[dateKey] = planDayId;
          if (customerWorkoutPlanId != null) {
            _dayCustomerWorkoutPlanIds[dateKey] = customerWorkoutPlanId;
          }
          if (workoutId != null) {
            _dayWorkoutIds[dateKey] = workoutId;
          }

          CalendarDayState state;
          if (dateOnly.isBefore(startDateOnly)) {
            state = CalendarDayState.inactive;
          } else if (isCompleted) {
            state =
                isVerified
                    ? CalendarDayState.verified
                    : CalendarDayState.completed;
          } else if (isRestDay) {
            state = CalendarDayState.rest;
          } else if (dateOnly.isAfter(todayOnly) ||
              dateOnly.isAtSameMomentAs(todayOnly)) {
            state = CalendarDayState.future;
          } else {
            state = CalendarDayState.missed;
          }

          _dayStates[dateKey] = state;
        }
      }
    });
  }

  Future<void> _loadMonthData({bool forceRefresh = false}) async {
    if (!mounted) return;

    _loadingTimeoutTimer?.cancel();

    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final cacheKey = '$year-${month.toString().padLeft(2, '0')}';

    final hasCache = WorkoutRepository().hasCalendarCache(cacheKey);
    if (hasCache) {
      final cachedData = WorkoutRepository().getCalendarCache(cacheKey);
      if (cachedData != null) {
        _parseAndSetCalendarData(cachedData);
      }
    } else {
      setState(() {
        _isLoading = true;
        _completedRequestsCount = 0;
      });
      _loadingTimeoutTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    WorkoutRepository()
        .getWorkoutCalendarForMonth(
          year: year,
          month: month,
          forceRefresh:
              true, // Always fetch fresh data to update status (verified / completed)
        )
        .then((result) {
          if (!mounted) return;

          result.fold(
            (error) {
              setState(() {
                _isLoading = false;
              });
            },
            (data) {
              _parseAndSetCalendarData(data);
              setState(() {
                _isLoading = false;
                _loadingTimeoutTimer?.cancel();
              });
            },
          );
        })
        .catchError((e) {
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
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
      final state = _dayStates[dateKey] ?? CalendarDayState.future;

      if (state == CalendarDayState.completed ||
          state == CalendarDayState.verified) {
        completedCount++;
      } else if (state == CalendarDayState.missed) {
        missedCount++;
      } else if (state == CalendarDayState.rest) {
        restCount++;
      }
    }

    final double percent =
        daysInMonth > 0 ? (completedCount / daysInMonth).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (percent * 100).round();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'Consistency',
                style: AppStyles.text18Px.poppins.w700.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ),

            // Calendar Card
            Container(
              key: _calendarCardKey,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_showLoginHint)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Track your completed workouts, planned rest days, and overall progress.',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: AppColors.textDark,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Custom Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canGoPrev)
                            GestureDetector(
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
                              child: const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.chevron_left,
                                  size: 22,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: AppStyles.text18Px.poppins.w700.copyWith(
                              color: const Color(0xFFE53935),
                            ),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap:
                                canGoNext
                                    ? () {
                                      setState(() {
                                        _focusedDay = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                          1,
                                        );
                                      });
                                      _prepopulateDefaultStates();
                                      _loadMonthData();
                                    }
                                    : null,
                            child: Icon(
                              Icons.chevron_right,
                              size: 24,
                              color:
                                  canGoNext
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _toggleEditMode,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isEditing
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isEditing ? Icons.check : Icons.edit_outlined,
                                size: 15,
                                color:
                                    _isEditing
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isEditing ? 'Save' : 'Set Rest day',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color:
                                      _isEditing
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    rowHeight: 44,
                    headerVisible: false,
                    availableGestures: AvailableGestures.none,
                    daysOfWeekHeight: 42,
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
                      final todayMidnight = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      );
                      final selectedMidnight = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      if (selectedMidnight.isAfter(todayMidnight)) {
                        return;
                      }

                      final startDate = _firstWorkoutDate;
                      final startDateOnly = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                      );
                      if (selectedMidnight.isBefore(startDateOnly)) {
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
                        final text = DateFormat.E().format(day);
                        return Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            text,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
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
                        if (day.month != _focusedDay.month) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onDoubleTap: () => _handleDayDoubleTap(day),
                          child: _buildDayCell(day),
                        );
                      },
                      outsideBuilder:
                          (context, day, focusedDay) => const SizedBox.shrink(),
                    ),
                  ),

                  if (_isEditing)
                    Container(
                      margin: const EdgeInsets.only(top: 12, left: 4, right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Set your rest days by selecting on the dates and clicking the save button.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF1D4ED8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Status Info Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(
                            icon: SvgPicture.asset(
                              'assets/images/svg/icons/trainer_verified_tick.svg',
                              width: 9.5,
                              height: 9.5,
                            ),
                            label: 'Verified',
                            bgColor: const Color(0xFFEAF8F0),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChip(
                            icon: SvgPicture.asset(
                              'assets/images/svg/icons/not_verified_tick.svg',
                              width: 9.5,
                              height: 9.5,
                            ),
                            label: 'Completed',
                            bgColor: const Color(0xFFFEFCE8),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChip(
                            icon: Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5F7AC5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            label: 'Rest',
                            bgColor: const Color(0xFFEEF3FF),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChip(
                            icon: Container(
                              width: 9.5,
                              height: 9.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5252),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 7.5,
                              ),
                            ),
                            label: 'Missed',
                            bgColor: const Color(0xFFFEECEE),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey.shade200, thickness: 1),
                  ),

                  // Progress Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 42.r,
                        lineWidth: 10,
                        percent: percent,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$percentInt%',
                              style: AppStyles.text18Px.poppins.w700.copyWith(
                                color: const Color(0xFF111827),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total Done',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        progressColor: const Color(0xFFE53935),
                        backgroundColor: const Color(0xFFF3F4F6),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            _summaryPill(
                              label: 'Completed Sessions',
                              value: '$completedCount Days',
                              bgColor: const Color(0xFFE6F4EA),
                              valueColor: const Color(0xFF16A34A),
                            ),
                            const SizedBox(height: 8),
                            _summaryPill(
                              label: 'Rest Days',
                              value: '$restCount Days',
                              bgColor: const Color(0xFFE8F0FE),
                              valueColor: const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(height: 8),
                            _summaryPill(
                              label: 'Missed Sessions',
                              value: '$missedCount Days',
                              bgColor: const Color(0xFFFCE8E6),
                              valueColor: const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required Widget icon,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 3.5),
          Text(
            label,
            style: AppStyles.text10Px.poppins.w500.copyWith(
              color: const Color(0xFF374151),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill({
    required String label,
    required String value,
    required Color bgColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            value,
            style: AppStyles.text12Px.poppins.w700.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  void _handleDayDoubleTap(DateTime day) {
    if (_isEditing) return;

    final dateOnly = DateTime(day.year, day.month, day.day);
    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    if (dateOnly.isBefore(startDateOnly)) {
      return;
    }

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
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
    final state = _dayStates[dateKey] ?? CalendarDayState.future;

    if (_isEditing &&
        state != CalendarDayState.completed &&
        state != CalendarDayState.verified &&
        !dateOnly.isBefore(startDateOnly) &&
        !dateOnly.isBefore(todayOnly)) {
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
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromRGBO(95, 122, 197, 1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
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

    final isToday = (dateOnly == todayOnly);

    // 1. Green Double Tick (Verified Workout)
    if (state == CalendarDayState.verified) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFE8F5E9),
        borderColor: isToday ? const Color(0xFF019C37) : Colors.transparent,
        topIcon: SvgPicture.asset(
          'assets/images/svg/icons/trainer_verified_tick.svg',
          width: 17,
          height: 17,
        ),
      );
    }

    // 2. Yellow Single Tick (Completed Workout - Pending Verification)
    if (state == CalendarDayState.completed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFFFFDE7),
        borderColor: isToday ? const Color(0xFFA9AF00) : Colors.transparent,
        topIcon: SvgPicture.asset(
          'assets/images/svg/icons/not_verified_tick.svg',
          width: 17,
          height: 17,
        ),
      );
    }

    // 3. Red X Mark (Missed Session)
    if (state == CalendarDayState.missed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFFFEBEE),
        borderColor: isToday ? const Color(0xFFFF5252) : Colors.transparent,
        topIcon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 11),
        ),
      );
    }

    final isRest = state == CalendarDayState.rest;
    final isBeforeStart = state == CalendarDayState.inactive;
    final dayTextColor =
        isRest
            ? const Color.fromRGBO(95, 122, 197, 1)
            : isBeforeStart
            ? Colors.grey.shade400
            : const Color(0xFF212121);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color:
            isRest
                ? const Color.fromRGBO(239, 243, 255, 1)
                : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isToday
                  ? (isRest ? const Color(0xFF1D9BF0) : Colors.grey.shade600)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text14Px.poppins.w500.copyWith(color: dayTextColor),
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
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
          top: -3,
          left: 0,
          right: 0,
          child: Align(alignment: Alignment.topCenter, child: topIcon),
        ),
      ],
    );
  }

  Future<void> _checkAndShowOnboardingHint() async {}

  Future<void> _checkAndShowLoginHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_calendar_login_hint') ?? false;
    if (!hasSeen) {
      if (mounted) {
        setState(() {
          _showLoginHint = true;
        });
      }
      await prefs.setBool('has_seen_calendar_login_hint', true);
      _hintTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _showLoginHint = false;
          });
        }
      });
    }
  }
}

class InvertedRectClipper extends CustomClipper<Path> {
  InvertedRectClipper({required this.rect});
  final Rect rect;

  @override
  Path getClip(Size size) {
    final path =
        Path()
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
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path =
        Path()
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
                    text:
                        'Track your completed workouts, planned rest days, and overall progress. Tap ',
                  ),
                  TextSpan(
                    text: '"Edit Rest Day"',
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: const Color(0xFFC60000),
                    ),
                  ),
                  const TextSpan(text: ' to schedule your recovery days.'),
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
  State<OnboardingOverlayContent> createState() =>
      _OnboardingOverlayContentState();
}

class _OnboardingOverlayContentState extends State<OnboardingOverlayContent>
    with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
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

    // Limit cutout bottom so it does not cover or bleed into the bottom navigation bar
    final double maxBottom =
        screenHeight - 80 - MediaQuery.of(context).padding.bottom;
    Rect adjustedCutout = widget.cutoutRect;
    if (adjustedCutout.bottom > maxBottom) {
      adjustedCutout = Rect.fromLTWH(
        adjustedCutout.left,
        adjustedCutout.top,
        adjustedCutout.width,
        (maxBottom - adjustedCutout.top).clamp(0.0, adjustedCutout.height),
      );
    }

    // Bottom offset from screen height
    final bottomOffset = screenHeight - adjustedCutout.top + 8;

    return Stack(
      children: [
        // 1. Full-screen GestureDetector to capture all gestures and block background scrolling
        GestureDetector(
          onTap: _handleDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),

        // 2. Semi-transparent black background with blur, excluding the calendar card visually
        Positioned.fill(
          child: IgnorePointer(
            child: ClipPath(
              clipper: InvertedRectClipper(rect: adjustedCutout),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(color: Colors.black.withOpacity(0.55)),
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
                    OnboardingTooltip(onGotIt: _handleDismiss),
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
