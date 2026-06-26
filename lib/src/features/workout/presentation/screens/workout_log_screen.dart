import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/own_workout_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/presets_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/preset_model.dart';

import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_details_screen.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  DateTime _selectedDate = DateTime.now();

  late final ScrollController _scrollController;
  late final List<DateTime> _scrollableDays;
  bool _showWorkoutCard = false;
  bool _isLoadingDateLog = true;
  List<Map<String, dynamic>> _selectedDateWorkouts = [];
  List<PresetModel> _myPlans = [];
  ApiException? _activeError;

  Future<void> _retryLoading() async {
    await Future.wait([
      _loadMyPlans(),
      _loadActiveSessionTitle(),
      _loadWorkoutLogForSelectedDate(),
    ]);
  }

  Future<void> _loadMyPlans() async {
    final response = await WorkoutRepository().getPresets();
    response.fold((error) {
      debugPrint('Error loading my plans: $error');
      if (mounted) {
        setState(() {
          _activeError = error;
        });
      }
    }, (
      list,
    ) {
      if (mounted) {
        setState(() {
          _myPlans = list;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Generate 180 days before today, today itself, and 2 upcoming days (total 183 days)
    final today = DateTime.now();
    _scrollableDays = List.generate(183, (index) {
      return DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 180 - index));
    });

    // Center the selected date on layout finish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedDate(animate: false);
      _loadMyPlans();
      _loadActiveSessionTitle();
      _loadWorkoutLogForSelectedDate();
    });
  }

  Future<void> _loadWorkoutLogForSelectedDate() async {
    if (mounted) {
      setState(() {
        _isLoadingDateLog = true;
        _activeError = null;
      });
    }

    final String y = _selectedDate.year.toString();
    final String m = _selectedDate.month.toString().padLeft(2, '0');
    final String d = _selectedDate.day.toString().padLeft(2, '0');
    final String dateStr = '$y-$m-$d';

    final response = await WorkoutRepository().getWorkoutLogForDate(
      date: dateStr,
    );
    response.fold(
      (error) {
        debugPrint('Error loading workout log for date: $error');
        if (mounted) {
          setState(() {
            _selectedDateWorkouts = [];
            _isLoadingDateLog = false;
            _activeError = error;
          });
        }
      },
      (list) async {
        debugPrint('DEBUG WORKOUT LOG LIST: $list');
        final enrichedList = <Map<String, dynamic>>[];
        for (final item in list) {
          final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
          final sessionId = map['session_id'] ?? map['id'];
          if (sessionId != null) {
            try {
              final idInt = int.parse(sessionId.toString());
              final detailsRes = await WorkoutRepository().getSessionDetails(sessionId: idInt);
              detailsRes.fold(
                (_) => null,
                (details) {
                  if (details['started_at'] != null) map['started_at'] = details['started_at'];
                  if (details['completed_at'] != null) map['completed_at'] = details['completed_at'];
                  if (details['duration'] != null) map['duration'] = details['duration'];
                }
              );
            } catch (e) {
              debugPrint('Error fetching session details: $e');
            }
          }
          enrichedList.add(map);
        }
        if (mounted) {
          setState(() {
            _selectedDateWorkouts = enrichedList;
            _isLoadingDateLog = false;
            _activeError = null;
          });
        }
      },
    );
  }

  Future<void> _loadActiveSessionTitle() async {
    final response = await WorkoutRepository().getActiveSession();
    response.fold(
      (error) {
        debugPrint('Error loading active session title in log screen: $error');
        if (mounted) {
          setState(() {
            _showWorkoutCard = false;
          });
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            bool hasExercises = false;
            if (data is Map<String, dynamic>) {
              final exercisesData =
                  data['logs'] ??
                  data['exercises'] ??
                  data['session_exercises'] ??
                  data['results'];
              if (exercisesData is List && exercisesData.isNotEmpty) {
                hasExercises = true;
              }
            }
            _showWorkoutCard = hasExercises;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerSelectedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final index = _scrollableDays.indexWhere(
      (d) => _isSameDay(d, _selectedDate),
    );
    if (index == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final double slotWidth = (screenWidth - 32.0) / 5.0;

    // Calculate targeted offset to put the slot in the exact middle of the screen
    final double targetOffset =
        index * slotWidth + (slotWidth / 2) + 16.0 - (screenWidth / 2);

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double minScroll = _scrollController.position.minScrollExtent;
    final double clampedOffset = targetOffset.clamp(minScroll, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  void _changeMonth(int delta) {
    final today = DateTime.now();
    final targetDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + delta,
      1,
    );

    // Block transitioning if the target month is in the future relative to the current month/year
    if (targetDate.year > today.year ||
        (targetDate.year == today.year && targetDate.month > today.month)) {
      return;
    }

    setState(() {
      _selectedDate = targetDate;
    });
    _centerSelectedDate();
    _loadWorkoutLogForSelectedDate();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _centerSelectedDate();
    _loadWorkoutLogForSelectedDate();
  }

  List<Map<String, dynamic>> _parseWorkoutExercises(dynamic data) {
    final List<Map<String, dynamic>> result = [];

    void extractExercise(Map<String, dynamic> item) {
      String? title;
      String? subtitle;
      int? exerciseId;
      String? videoUrl;

      if (item['workout'] is Map<String, dynamic>) {
        final workout = item['workout'] as Map<String, dynamic>;
        title = workout['name'] as String?;
        exerciseId = workout['id'] as int?;
        final muscle =
            workout['primary_muscle_group_name'] as String? ??
            workout['muscle_group'] as String?;
        final equip =
            workout['equipment_name'] as String? ??
            workout['equipment'] as String?;
        final type = workout['type'] as String?;
        subtitle = '${muscle ?? ''} / ${equip ?? ''} / ${type ?? ''}';
        videoUrl = workout['video_url']?.toString();
      } else if (item['exercise'] is Map<String, dynamic>) {
        final exercise = item['exercise'] as Map<String, dynamic>;
        title = exercise['name'] as String?;
        exerciseId = exercise['id'] as int?;
        final muscle =
            exercise['primary_muscle_group_name'] as String? ??
            exercise['muscle_group'] as String?;
        final equip =
            exercise['equipment_name'] as String? ??
            exercise['equipment'] as String?;
        final type = exercise['type'] as String?;
        subtitle = '${muscle ?? ''} / ${equip ?? ''} / ${type ?? ''}';
        videoUrl = exercise['video_url']?.toString();
      } else {
        title =
            item['workout_name']?.toString() ??
            item['name']?.toString() ??
            item['title']?.toString();
        exerciseId =
            item['id'] as int? ??
            item['plan_exercise'] as int? ??
            item['workout_id'] as int?;
        final muscle =
            item['muscle']?.toString() ??
            item['primary_muscle_group_name']?.toString() ??
            item['muscle_group']?.toString();
        final equip =
            item['equipment_name']?.toString() ?? item['equipment']?.toString();
        final type = item['type']?.toString();
        videoUrl = item['video_url']?.toString();

        final List<String> parts = [];
        if (muscle != null && muscle.isNotEmpty) parts.add(muscle);
        if (equip != null && equip.isNotEmpty) parts.add(equip);
        if (type != null && type.isNotEmpty) parts.add(type);

        if (parts.isNotEmpty) {
          subtitle = parts.join(' / ');
        } else {
          subtitle = item['subtitle']?.toString();
        }
      }

      if (title == null || title.isEmpty) return;

      final List<Map<String, dynamic>> sets = [];
      final rawSets = item['set_logs'] ?? item['sets'];
      if (rawSets is List) {
        for (var i = 0; i < rawSets.length; i++) {
          final s = rawSets[i];
          if (s is Map<String, dynamic>) {
            final targetWeight = s['target_weight'] ?? s['targetWeight'];
            final targetReps = s['target_reps'] ?? s['targetReps'];
            final kgVal = s['weight_kg'] ?? s['weight'] ?? s['kg'] ?? targetWeight ?? '10';
            final repsVal = s['reps'] ?? targetReps ?? '15';
            final prevRaw = s['previous'];
            final prevWeightRaw = s['previous_weight_kg'];
            String prevStr;
            if (prevRaw != null && prevRaw.toString().isNotEmpty && prevRaw.toString() != 'no data') {
              prevStr = prevRaw.toString();
            } else if (prevWeightRaw != null) {
              final w = double.tryParse(prevWeightRaw.toString());
              if (w != null) {
                final wStr = w == w.truncateToDouble() ? w.toInt().toString() : w.toString();
                prevStr = '${wStr}kg';
              } else {
                prevStr = 'no data';
              }
            } else {
              prevStr = 'no data';
            }
            sets.add({
              'setNum':
                  s['set_number'] ?? s['set_num'] ?? s['setNum'] ?? (i + 1),
              'previous': prevStr,
              'kg': kgVal.toString(),
              'reps': repsVal.toString(),
              'checked': s['is_completed'] ?? s['checked'] ?? false,
            });
          }
        }
      }

      sets.sort((a, b) {
        final aNum = int.tryParse(a['setNum']?.toString() ?? '') ?? 0;
        final bNum = int.tryParse(b['setNum']?.toString() ?? '') ?? 0;
        return aNum.compareTo(bNum);
      });

      if (sets.isEmpty) {
        sets.add({
          'setNum': 1,
          'previous': 'no data',
          'kg': '10',
          'reps': '15',
          'checked': false,
        });
      }

      result.add({
        'id': exerciseId?.toString() ?? '',
        'title': title,
        'subtitle': subtitle ?? '',
        'video_url': videoUrl ?? '',
        'sets': sets,
      });
    }

    if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          extractExercise(item);
        }
      }
    } else if (data is Map<String, dynamic>) {
      final exercisesData =
          data['logs'] ??
          data['exercises'] ??
          data['session_exercises'] ??
          data['results'];
      if (exercisesData is List) {
        for (var item in exercisesData) {
          if (item is Map<String, dynamic>) {
            extractExercise(item);
          }
        }
      }
    }

    return result;
  }

  Widget _buildActiveWorkoutBanner() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const OwnWorkoutScreen(),
          ),
        );
        await _loadMyPlans();
        await _loadActiveSessionTitle();
        await _loadWorkoutLogForSelectedDate();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F2FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC2DBFF), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout in Progress',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to resume your draft',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(String? startedAtStr, String? completedAtStr) {
    if (startedAtStr == null || completedAtStr == null) return '--:--';
    try {
      final start = DateTime.parse(startedAtStr);
      final end = DateTime.parse(completedAtStr);
      final diff = end.difference(start);

      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      final seconds = diff.inSeconds.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    } catch (e) {
      return '--:--';
    }
  }

  Widget build(BuildContext context) {
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;
    debugPrint('DEBUG BUILD: isCustomer: $isCustomer, date: $_selectedDate');

    final List<Widget> logCards = [];

    int cardIndex = 1;

    if (_selectedDateWorkouts.isNotEmpty) {
      for (final workoutItem in _selectedDateWorkouts) {
        final exercisesData =
            workoutItem['logs'] ??
            workoutItem['exercises'] ??
            workoutItem['session_exercises'] ??
            workoutItem['results'];
        if (exercisesData is List && exercisesData.isEmpty) {
          continue; // Skip empty sessions
        }
        String? planNameFromMyPlans;
        final planVal = workoutItem['plan'] ?? workoutItem['plan_id'];
        if (planVal != null) {
          final planId = int.tryParse(planVal.toString());
          if (planId != null) {
            final match = _myPlans.firstWhere(
              (p) => p.id == planId,
              orElse: () => PresetModel(id: -1, title: '', exercises: []),
            );
            if (match.id != -1) {
              planNameFromMyPlans = match.title;
            }
          }
        }

        final rawTitle = workoutItem['title']?.toString() ?? '';
        final hasRawTitle = rawTitle.isNotEmpty && rawTitle != 'My Workout Plan';

        final backendPlanName = workoutItem['plan_name']?.toString() ?? '';
        final hasBackendPlanName =
            backendPlanName.isNotEmpty && backendPlanName != 'My Workout Plan';

        final title =
            (hasRawTitle ? rawTitle : null) ??
            (hasBackendPlanName ? backendPlanName : null) ??
            planNameFromMyPlans ??
            (rawTitle.isNotEmpty ? rawTitle : null) ??
            (backendPlanName.isNotEmpty ? backendPlanName : null) ??
            workoutItem['plan_day_title']?.toString() ??
            'Quick Workout';
        final badge =
            (hasRawTitle ? rawTitle : null) ??
            (hasBackendPlanName ? backendPlanName : null) ??
            planNameFromMyPlans ??
            (rawTitle.isNotEmpty ? rawTitle : null) ??
            (backendPlanName.isNotEmpty ? backendPlanName : null) ??
            'Workout';
        final isCompleted =
            ((workoutItem['is_completed'] as bool?) ?? false) ||
            (workoutItem['status']?.toString().toLowerCase() == 'completed');
        final startedAt = workoutItem['started_at']?.toString() ?? workoutItem['created_at']?.toString() ?? workoutItem['start_time']?.toString();
        final completedAt = workoutItem['completed_at']?.toString() ?? workoutItem['updated_at']?.toString() ?? workoutItem['end_time']?.toString();
        
        String durationStr = _formatDuration(startedAt, completedAt);
        if (durationStr == '--:--' && workoutItem['duration'] != null) {
          durationStr = workoutItem['duration'].toString();
        }
        logCards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkoutCard(
              index: cardIndex++,
              title: title,
              badge: badge,
              hasImage: true,
              isCompleted: isCompleted,
              duration: durationStr,
              trainerName: workoutItem['trainer_name']?.toString(),
              onTap: () async {
                final idVal = workoutItem['session_id'] ?? workoutItem['id'];
                final sessionId =
                    idVal != null ? int.tryParse(idVal.toString()) : null;
                debugPrint(
                  'DEBUG: Tapped completed workout log card. ID value: $idVal, parsed sessionId: $sessionId',
                );
                if (sessionId != null) {
                  final refresh = await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder:
                          (context) => WorkoutDetailsScreen(
                            sessionId: sessionId,
                            fallbackTitle: title,
                          ),
                    ),
                  );
                  if (refresh == true) {
                    _loadWorkoutLogForSelectedDate();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not find session ID for this workout log.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    }

    if (logCards.isEmpty) {
      logCards.add(const _RestDayCard());
    }

    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'Workout Log',
          style: AppStyles.text20Px.poppins.w500.copyWith(
            height: 1.0,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                context.push(const SettingsScreen());
              },
              child: SvgPicture.asset(
                'assets/images/svg/icons/settings _icon.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
        ],
      ),
      body:
          !isCustomer
              ? _GuestWorkoutView(
                onLoginTap: () {
                  context.push(const SentOtpScreen());
                },
              )
              : SafeArea(
                child: RefreshIndicator(
                  onRefresh: _retryLoading,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    clipBehavior: Clip.none,
                    child: Column(
                      children: [
                        if (_showWorkoutCard) ...[
                          const SizedBox(height: 8),
                          _buildActiveWorkoutBanner(),
                          const SizedBox(height: 12),
                        ] else ...[
                          const SizedBox(height: 21),
                        ],
                        _buildMonthNav(),
                        const SizedBox(height: 34),
                        _buildWeekStrip(),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              if (_isLoadingDateLog)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                              else if (_activeError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: _activeError!.maybeWhen(
                                    network: (e) => ErrorUi.network(onTap: _retryLoading),
                                    notFound: (e) => ErrorUi.notFound(onTap: _retryLoading),
                                    orElse: () => ErrorUi.server(onTap: _retryLoading),
                                  ),
                                )
                              else
                                ...logCards,
                            ],
                          ),
                        ),
                        // Add spacing so the bottom list items aren't hidden behind the floating buttons
                        const SizedBox(height: 130),
                      ],
                    ),
                  ),
                ),
              ),
      floatingActionButton: !isCustomer ? null : _buildStartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Month navigation ──────────────────────────────────────────────────────
  Widget _buildMonthNav() {
    final monthLabel =
        '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';

    final today = DateTime.now();
    final isCurrentOrFutureMonth =
        _selectedDate.year > today.year ||
        (_selectedDate.year == today.year &&
            _selectedDate.month >= today.month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: () => _changeMonth(-1)),
          const SizedBox(width: 12),
          Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              height: 1.0,
              color: const Color(0xFF434A5D),
            ),
          ),
          const SizedBox(width: 14),
          _NavArrow(
            icon: Icons.chevron_right,
            onTap: isCurrentOrFutureMonth ? null : () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  // ── Continuous swipable, auto-centering horizontal calendar strip ──────────
  Widget _buildWeekStrip() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double slotWidth = (screenWidth - 32.0) / 5.0;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _scrollableDays.length,
        itemBuilder: (context, index) {
          final d = _scrollableDays[index];
          final isFutureDay = d.isAfter(todayMidnight);
          return SizedBox(
            width: slotWidth,
            child: Center(
              child: _DayTile(
                date: d,
                selected: _isSameDay(d, _selectedDate),
                onTap: isFutureDay ? null : () => _selectDate(d),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button.filled(
            size: const Size(double.infinity, 45),
            title: 'Start Empty Workout',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: Colors.white,
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            raduis: 12,
            ontap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (context) => const OwnWorkoutScreen(isNewSession: true),
                ),
              );
              await _loadMyPlans();
              await _loadActiveSessionTitle();
              await _loadWorkoutLogForSelectedDate();
            },
          ),
          const SizedBox(height: 12),
          Button.filled(
            size: const Size(double.infinity, 45),
            title: 'Start a Preset',
            buttonColor: const Color(0xFFFFF4F4),
            side: const BorderSide(color: Color(0xFFF0B5B7)),
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: AppColors.primary,
            ),
            icon: SvgPicture.asset(
              'assets/images/svg/icons/presets.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            raduis: 12,
            ontap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const PresetsScreen(),
                ),
              );
              await _loadMyPlans();
              await _loadActiveSessionTitle();
              await _loadWorkoutLogForSelectedDate();
            },
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

// ── Day tile ─────────────────────────────────────────────────────────────────
class _DayTile extends StatelessWidget {
  const _DayTile({required this.date, required this.selected, this.onTap});

  final DateTime date;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[date.weekday - 1];

    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selected ? 65 : 55,
        height: selected ? 85 : 70,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding:
                selected
                    ? const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    )
                    : const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  textAlign: TextAlign.center,
                  style:
                      selected
                          ? AppStyles.text16Px.poppins.w700.copyWith(
                            height: 1.3,
                            color: Colors.white,
                          )
                          : isEnabled
                          ? AppStyles.text16Px.poppins.w600.copyWith(
                            height: 1.3,
                            color: AppColors.button,
                          )
                          : AppStyles.text16Px.poppins.w600.copyWith(
                            height: 1.3,
                            color: const Color(0xFF888888),
                          ),
                ),
                SizedBox(height: selected ? 12 : 4),
                Text(
                  dayName,
                  textAlign: TextAlign.center,
                  style:
                      selected
                          ? AppStyles.text12Px.poppins.w500.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            color: Colors.white,
                          )
                          : isEnabled
                          ? AppStyles.text12Px.poppins.w400.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            color: AppColors.button,
                          )
                          : AppStyles.text12Px.poppins.w400.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            color: const Color(0xFF888888),
                          ),
                ),
                if (selected) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav arrow button ──────────────────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 16,
        color:
            onTap != null ? const Color(0xFF434A5D) : const Color(0xFFD1D3D9),
      ),
    );
  }
}

// ── Workout card ──────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.index,
    required this.title,
    required this.badge,
    required this.hasImage,
    required this.isCompleted,
    this.duration,
    this.onTap,
    this.trainerName,
  });

  final int index;
  final String title;
  final String? badge;
  final bool hasImage;
  final bool isCompleted;
  final String? duration;
  final VoidCallback? onTap;
  final String? trainerName;

  @override
  Widget build(BuildContext context) {
    String formattedTitle = title;
    if (!formattedTitle.contains('\n')) {
      final parts = formattedTitle.split(' ');
      if (parts.length > 1) {
        final middle = (parts.length / 2).ceil();
        formattedTitle =
            '${parts.sublist(0, middle).join(' ')}\n${parts.sublist(middle).join(' ')}';
      }
    }

    final Gradient cardGradient =
        isCompleted
            ? const LinearGradient(
              colors: [Color(0xFFD1CBC6), Color(0xFFB0A9A3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : const LinearGradient(
              colors: [Color(0xFFE5E5E5), Color(0xFFD1D3D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            debugPrint(
              'DEBUG: Tapped _WorkoutCard with index: $index, title: $title',
            );
            if (onTap != null) onTap!();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 140,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(20),
              image:
                  hasImage
                      ? const DecorationImage(
                        image: AssetImage(
                          'assets/images/png/vectors/workout_plan_creation_image.png',
                        ),
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      )
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top left: Title
                Positioned(
                  left: 24,
                  top: 20,
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                          height: 1.15,
                        ),
                      ),
                      if (trainerName != null && trainerName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trainerName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Bottom left: Duration
                Positioned(
                  left: 24,
                  bottom: 20,
                  width: 135,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFFF0B5B7), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Duration',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        duration ?? '--:--',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom right: Circular white button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: Color(0xFF020202),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // CompletedBadge overlay at top right of the card
        if (isCompleted)
          const Positioned(top: -7.0, right: -5.35, child: CompletedBadge()),
      ],
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Text(
          'No workout created on this day .',
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _GuestWorkoutView extends StatelessWidget {
  const _GuestWorkoutView({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Guest Account',
              style: AppStyles.text16Px.poppins.w500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to see workout details.',
              style: AppStyles.text12Px.poppins.w400,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLoginTap,
                child: const Text('Log In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
