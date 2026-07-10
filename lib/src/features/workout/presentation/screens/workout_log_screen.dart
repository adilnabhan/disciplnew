import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/own_workout_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/presets_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/preset_model.dart';
import 'package:customer_mobile_app/core/widgets/image_network.dart';

import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_details_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_preview_screen.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  static DateTime? selectedDateOverride;
  static int? autoOpenSessionId;

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  DateTime _selectedDate = DateTime.now();

  late final ScrollController _scrollController;
  late final List<DateTime> _scrollableDays;
  bool _showWorkoutCard = false;
  Map<String, dynamic>? _activeSessionData;
  bool _isLoadingDateLog = true;
  List<Map<String, dynamic>> _selectedDateWorkouts = [];
  List<PresetModel> _myPlans = [];
  ApiException? _activeError;
  CustomerDetailsModel? _customerDetails;

  Future<void> _retryLoading() async {
    await Future.wait([
      _loadMyPlans(),
      _loadActiveSessionTitle(),
      _loadWorkoutLogForSelectedDate(),
    ]);
  }

  Future<void> _loadMyPlans() async {
    final response = await WorkoutRepository().getPresets();
    response.fold(
      (error) {
        debugPrint('Error loading my plans: $error');
        if (mounted) {
          setState(() {
            _activeError = error;
          });
        }
      },
      (list) {
        if (mounted) {
          setState(() {
            _myPlans = list;
          });
        }
      },
    );
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

    final customerId = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (customerId != null && _customerDetails == null) {
      CustomerDetailsRepository().customerDetails(id: customerId).then((res) {
        res.fold((error) => null, (details) {
          if (mounted) {
            setState(() {
              _customerDetails = details;
            });
          }
        });
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
          
          final isCompleted =
              ((map['is_completed'] as bool?) ?? false) ||
              (map['status']?.toString().toLowerCase() == 'completed');
          final trainerName = map['trainer_name']?.toString() ?? '';
          final isMentorGiven = trainerName.isNotEmpty;
          
          // Skip user's own/preset workouts that are not completed (drafts / in-progress)
          if (!isMentorGiven && !isCompleted) {
            continue;
          }

          final sessionId = map['session_id'] ?? map['id'];
          if (sessionId != null) {
            try {
              final idInt = int.parse(sessionId.toString());
              final detailsRes = await WorkoutRepository().getSessionDetails(
                sessionId: idInt,
              );
              detailsRes.fold((_) => null, (details) {
                if (details['started_at'] != null)
                  map['started_at'] = details['started_at'];
                if (details['completed_at'] != null)
                  map['completed_at'] = details['completed_at'];
                if (details['duration'] != null)
                  map['duration'] = details['duration'];
              });
            } catch (e) {
              debugPrint('Error fetching session details: $e');
            }
          }
          enrichedList.add(map);
        }
        // Sort: trainer-assigned first, within trainer → not-completed before completed
        enrichedList.sort((a, b) {
          final aTrainer = a['trainer_name']?.toString() ?? '';
          final bTrainer = b['trainer_name']?.toString() ?? '';
          final aIsTrainer = aTrainer.isNotEmpty;
          final bIsTrainer = bTrainer.isNotEmpty;

          // Trainer vs non-trainer
          if (aIsTrainer && !bIsTrainer) return -1;
          if (!aIsTrainer && bIsTrainer) return 1;

          // Both trainer-assigned: not-completed before completed
          if (aIsTrainer && bIsTrainer) {
            final aCompleted =
                ((a['is_completed'] as bool?) ?? false) ||
                (a['status']?.toString().toLowerCase() == 'completed');
            final bCompleted =
                ((b['is_completed'] as bool?) ?? false) ||
                (b['status']?.toString().toLowerCase() == 'completed');
            if (!aCompleted && bCompleted) return -1;
            if (aCompleted && !bCompleted) return 1;
          }

          // Both user-created: last created on top
          if (!aIsTrainer && !bIsTrainer) {
            final aStart = DateTime.tryParse(a['started_at']?.toString() ?? '');
            final bStart = DateTime.tryParse(b['started_at']?.toString() ?? '');
            if (aStart != null && bStart != null) {
              final cmp = bStart.compareTo(aStart);
              if (cmp != 0) return cmp;
            }
            final aId = int.tryParse((a['session_id'] ?? a['id'] ?? '').toString()) ?? 0;
            final bId = int.tryParse((b['session_id'] ?? b['id'] ?? '').toString()) ?? 0;
            return bId.compareTo(aId);
          }

          return 0;
        });
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
            _activeSessionData = null;
          });
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            bool hasActiveSession = false;
            if (data is Map<String, dynamic>) {
              if (data['id'] != null) {
                hasActiveSession = true;
                _activeSessionData = data;
              } else {
                _activeSessionData = null;
              }
            } else {
              _activeSessionData = null;
            }
            _showWorkoutCard = hasActiveSession;
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
            final kgVal =
                s['weight_kg'] ??
                s['weight'] ??
                s['kg'] ??
                targetWeight ??
                '10';
            final repsVal = s['reps'] ?? targetReps ?? '15';
            final prevRaw = s['previous'];
            final prevWeightRaw = s['previous_weight_kg'];
            String prevStr;
            if (prevRaw != null &&
                prevRaw.toString().isNotEmpty &&
                prevRaw.toString() != 'no data') {
              prevStr = prevRaw.toString();
            } else if (prevWeightRaw != null) {
              final w = double.tryParse(prevWeightRaw.toString());
              if (w != null) {
                final wStr =
                    w == w.truncateToDouble()
                        ? w.toInt().toString()
                        : w.toString();
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
        final finished = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const OwnWorkoutScreen(),
          ),
        );
        await _loadMyPlans();
        await _loadActiveSessionTitle();
        await _loadWorkoutLogForSelectedDate();
        if (finished == true && context.mounted) {
          // Stay on Workout Log screen
        }
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

  @override
  Widget build(BuildContext context) {
    if (WorkoutLogScreen.selectedDateOverride != null) {
      final date = WorkoutLogScreen.selectedDateOverride!;
      final autoSessionId = WorkoutLogScreen.autoOpenSessionId;
      WorkoutLogScreen.selectedDateOverride = null;
      WorkoutLogScreen.autoOpenSessionId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectDate(date);
        if (autoSessionId != null) {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder:
                  (context) => WorkoutDetailsScreen(
                    sessionId: autoSessionId,
                    fallbackTitle: 'Workout',
                  ),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadWorkoutLogForSelectedDate();
            }
          });
        }
      });
    }

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
        final hasRawTitle =
            rawTitle.isNotEmpty && rawTitle != 'My Workout Plan';

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
        final isVerified = (workoutItem['is_verified'] as bool?) ?? false;
        final startedAt =
            workoutItem['started_at']?.toString() ??
            workoutItem['created_at']?.toString() ??
            workoutItem['start_time']?.toString();
        final completedAt =
            workoutItem['completed_at']?.toString() ??
            workoutItem['updated_at']?.toString() ??
            workoutItem['end_time']?.toString();

        String durationStr = _formatDuration(startedAt, completedAt);
        if (durationStr == '--:--' && workoutItem['duration'] != null) {
          durationStr = workoutItem['duration'].toString();
        }
        final bool isExpired =
            workoutItem['membership_status']?.toString().toLowerCase() ==
            'expired';
        logCards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkoutCard(
              index: cardIndex++,
              title: title,
              badge: badge,
              hasImage: true,
              isCompleted: isCompleted,
              isVerified: isVerified,
              duration: durationStr,
              trainerName: workoutItem['trainer_name']?.toString(),
              isMembershipExpired: isExpired,
              gymLogo:
                  _customerDetails?.assignedFitnessCenter?['logo']?.toString(),
              isLoadingGymLogo: _customerDetails == null,
              trainerProfileImage:
                  _customerDetails?.assignedTrainer?['profile_image']
                      ?.toString(),
              verificationStatus:
                  workoutItem['verification_status']?.toString() ??
                  workoutItem['verification']?.toString(),
              onTap: () async {
                final idVal = workoutItem['session_id'] ?? workoutItem['id'];
                final sessionId =
                    idVal != null ? int.tryParse(idVal.toString()) : null;
                debugPrint(
                  'DEBUG: Tapped completed workout log card. ID value: $idVal, parsed sessionId: $sessionId',
                );
                if (sessionId != null) {
                  final isMentor = workoutItem['trainer_name']?.toString().isNotEmpty ?? false;
                  final refresh = await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (context) {
                        if (isMentor && !isCompleted) {
                          return WorkoutPreviewScreen(
                            sessionId: sessionId,
                            fallbackTitle: title,
                            trainerName: workoutItem['trainer_name']?.toString(),
                          );
                        } else {
                          return WorkoutDetailsScreen(
                            sessionId: sessionId,
                            fallbackTitle: title,
                          );
                        }
                      },
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
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                        const SizedBox(height: 20),
                        _buildWeekStrip(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    _isLoadingDateLog
                                        ? _buildShimmerWorkoutLogs(
                                          key: const ValueKey('shimmer'),
                                        )
                                        : _activeError != null
                                        ? Padding(
                                          key: const ValueKey('error'),
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: _activeError!.maybeWhen(
                                            network:
                                                (e) => ErrorUi.network(
                                                  onTap: _retryLoading,
                                                ),
                                            notFound:
                                                (e) => ErrorUi.notFound(
                                                  onTap: _retryLoading,
                                                ),
                                            orElse:
                                                () => ErrorUi.server(
                                                  onTap: _retryLoading,
                                                ),
                                          ),
                                        )
                                        : Column(
                                          key: const ValueKey('content'),
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: logCards,
                                        ),
                              ),
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

  Widget _buildShimmerWorkoutLogs({Key? key}) {
    return Column(
      key: key,
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(width: 80, height: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
              if (_activeSessionData != null) {
                _showResumeOrNewDialog(context, isPreset: false);
                return;
              }
              final finished = await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (context) => const OwnWorkoutScreen(isNewSession: true),
                ),
              );
              await _loadMyPlans();
              await _loadActiveSessionTitle();
              await _loadWorkoutLogForSelectedDate();
              if (finished == true && context.mounted) {
                // Stay on Workout Log screen
              }
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
              if (_activeSessionData != null) {
                _showResumeOrNewDialog(context, isPreset: true);
                return;
              }
              final finished = await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const PresetsScreen(),
                ),
              );
              await _loadMyPlans();
              await _loadActiveSessionTitle();
              await _loadWorkoutLogForSelectedDate();
              if (finished == true && context.mounted) {
                // Stay on Workout Log screen
              }
            },
          ),
        ],
      ),
    );
  }

  void _showResumeOrNewDialog(BuildContext context, {required bool isPreset}) {
    final data = _activeSessionData;
    if (data == null) return;

    // Parse active draft title
    final title = data['plan_name']?.toString() ??
        data['plan_day_title']?.toString() ??
        data['title']?.toString() ??
        data['name']?.toString() ??
        'Active Workout';

    // Parse elapsed time
    String elapsedText = '';
    final startedAtStr = data['started_at'] ?? data['created_at'];
    if (startedAtStr != null) {
      final startedAt = DateTime.tryParse(startedAtStr.toString());
      if (startedAt != null) {
        final diff = DateTime.now().difference(startedAt.toLocal());
        if (diff.inMinutes < 60) {
          elapsedText = 'Started ${diff.inMinutes} minutes ago';
        } else if (diff.inHours < 24) {
          elapsedText = 'Started ${diff.inHours} hours ago';
        } else {
          elapsedText = 'Started ${diff.inDays} days ago';
        }
      }
    }
    if (elapsedText.isEmpty) {
      elapsedText = 'Active draft session';
    }

    // Parse completion status (exercise logs)
    int completedSets = 0;
    int totalSets = 0;
    final rawLogs = data['logs'] ?? data['exercises'] ?? data['session_exercises'] ?? data['results'];
    if (rawLogs is List) {
      for (final log in rawLogs) {
        if (log is Map<String, dynamic>) {
          final sets = log['set_logs'] ?? log['sets'];
          if (sets is List) {
            for (final s in sets) {
              if (s is Map<String, dynamic>) {
                totalSets++;
                final isCompleted = s['is_completed'] ?? s['checked'] ?? false;
                if (isCompleted == true) {
                  completedSets++;
                }
              }
            }
          }
        }
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Blue circle 🏋️ icon
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🏋️',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'Continue Existing Workout?',
                textAlign: TextAlign.center,
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'You already have an unfinished workout.',
                textAlign: TextAlign.center,
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Starting a new workout won\'t delete your current draft. You can resume it anytime from Workout Log.',
                textAlign: TextAlign.center,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Current Draft card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Draft',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          '💪',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text15Px.poppins.w600.copyWith(
                              color: const Color(0xFF222222),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      elapsedText,
                      style: AppStyles.text13Px.poppins.w500.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedSets/$totalSets sets completed',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Resume Draft Button
              GestureDetector(
                onTap: () async {
                  Navigator.pop(dialogContext);
                  final finished = await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const OwnWorkoutScreen(isNewSession: false),
                    ),
                  );
                  await _loadMyPlans();
                  await _loadActiveSessionTitle();
                  await _loadWorkoutLogForSelectedDate();
                  if (finished == true && context.mounted) {
                    // Stay on Workout Log screen
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Resume Draft',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Start New Workout Button
              GestureDetector(
                onTap: () async {
                  Navigator.pop(dialogContext);
                  final finished = await Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => isPreset
                          ? const PresetsScreen()
                          : const OwnWorkoutScreen(isNewSession: true),
                    ),
                  );
                  await _loadMyPlans();
                  await _loadActiveSessionTitle();
                  await _loadWorkoutLogForSelectedDate();
                  if (finished == true && context.mounted) {
                    // Stay on Workout Log screen
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isPreset ? '+ Start a Preset' : '+ Start New Workout',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(100, 36),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Cancel',
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    this.isVerified = false,
    this.duration,
    this.onTap,
    this.trainerName,
    this.isMembershipExpired = false,
    this.gymLogo,
    this.isLoadingGymLogo = false,
    this.trainerProfileImage,
    this.verificationStatus,
  });

  final int index;
  final String title;
  final String? badge;
  final bool hasImage;
  final bool isCompleted;
  final bool isVerified;
  final String? duration;
  final VoidCallback? onTap;
  final String? trainerName;
  final bool isMembershipExpired;
  final String? gymLogo;
  final bool isLoadingGymLogo;
  final String? trainerProfileImage;
  final String? verificationStatus;

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

    final bool isMentorGiven = trainerName != null && trainerName!.isNotEmpty;

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
            height: isCompleted ? 140 : 100,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient:
                  isMentorGiven
                      ? const LinearGradient(
                        colors: [Color(0xffFFD5D5), Color(0xffFFD5D5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                      : cardGradient,
              borderRadius: BorderRadius.circular(20),
              image:
                  (hasImage && !isMentorGiven)
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
            child:
                isMentorGiven
                    ? Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 68,
                            top: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isCompleted
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Gym Profile Logo
                                  isLoadingGymLogo
                                      ? const KShimmer(
                                        width: 68,
                                        height: 68,
                                        radius: 12,
                                      )
                                      : Container(
                                        width: 68,
                                        height: 68,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: ImageNetwork(
                                            gymLogo,
                                            fit: BoxFit.cover,
                                            errorWidget: const Center(
                                              child: Icon(
                                                Icons.fitness_center,
                                                color: Colors.grey,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  const SizedBox(width: 16),
                                  // Middle: Workout title and Trainer Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            if (trainerProfileImage != null &&
                                                trainerProfileImage!.isNotEmpty) ...[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: ImageNetwork(
                                                  trainerProfileImage,
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                  errorWidget: const Icon(
                                                    Icons.account_circle,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Expanded(
                                              child: Text(
                                                trainerName!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF222222),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isCompleted) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Duration: ${duration ?? '--'}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isVerified ? '• Verified' : '• Pending',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isVerified
                                                ? const Color(0xFF019C37)
                                                : const Color(0xFFA9AF00),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Right: Chevron Button (always show, vertically centered)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC84A4A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Stack(
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
                              if (trainerName != null &&
                                  trainerName!.isNotEmpty) ...[
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
                                  const Icon(
                                    Icons.timer_outlined,
                                    color: Color(0xFFF0B5B7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Duration',
                                    style: TextStyle(
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
                        // Bottom right: Circular white/red button
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
                                  color: Colors.black.withValues(alpha: 0.06),
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
          Positioned(
            top: -7.0,
            right: -5.35,
            child: (trainerName == null || trainerName!.isEmpty)
                ? SvgPicture.asset(
                    'assets/images/svg/icons/user_completed_tick.svg',
                    width: 28,
                    height: 27,
                  )
                : isVerified
                    ? SvgPicture.asset(
                        'assets/images/svg/icons/trainer_verified_tick.svg',
                        width: 28,
                        height: 27,
                      )
                    : SvgPicture.asset(
                        'assets/images/svg/icons/not_verified_tick.svg',
                        width: 28,
                        height: 27,
                      ),
          ),
        if (isMembershipExpired)
          Positioned(
            top: -7.0,
            right: isCompleted ? 32.0 : -5.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD30C15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                'Expired',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
