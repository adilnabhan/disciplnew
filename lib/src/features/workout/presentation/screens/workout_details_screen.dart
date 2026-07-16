import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_achievement_screen.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({
    required this.sessionId,
    required this.fallbackTitle,
    this.startTimer = false,
    this.trainerName,
    this.isVerified,
    this.onRefresh,
    super.key,
  });

  final int sessionId;
  final String fallbackTitle;
  final bool startTimer;
  final String? trainerName;
  final bool? isVerified;
  final VoidCallback? onRefresh;

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  late Future<Either<ApiException, Map<String, dynamic>>> _detailsFuture;
  List<ExerciseLibraryModel> _exercises = [];
  bool _isFinishing = false;
  Map<String, dynamic>? _sessionData;
  final Map<int, Timer> _debounceTimers = {};
  final Set<int> _addingSetLogIds = {};
  final Set<int> _completingSetIds = {};
  Timer? _detailsTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadExercises();
  }

  @override
  void dispose() {
    _detailsTimer?.cancel();
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    if (_detailsTimer != null) return;
    _detailsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _syncTimer(Map<String, dynamic> data) {
    if (_detailsTimer != null) return;
    final startedAtStr = data['started_at']?.toString();
    if (startedAtStr != null) {
      final start = DateTime.tryParse(startedAtStr);
      if (start != null) {
        final now = DateTime.now();
        final startLocal = start.isUtc ? start.toLocal() : start;
        final diff = now.difference(startLocal);
        final elapsed = diff.inSeconds;
        if (elapsed >= 0) {
          setState(() {
            _elapsedSeconds = elapsed;
          });
          _startTimer();
          return;
        }
      }
    }
    _startTimer();
  }

  String _formatTimer(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  void _loadDetails() {
    setState(() {
      _sessionData = null;
      _detailsFuture = WorkoutRepository()
          .getSessionDetails(sessionId: widget.sessionId)
          .then((res) {
            res.fold((_) => null, (data) {
              if (mounted) {
                setState(() {
                  _sessionData = data;
                });
              }
            });
            return res;
          });
    });
  }

  void _debounceUpdateSet(int setLogId, {int? reps, double? weightKg}) {
    _debounceTimers[setLogId]?.cancel();
    _debounceTimers[setLogId] = Timer(
      const Duration(milliseconds: 600),
      () async {
        final res = await WorkoutRepository().updateSetLog(
          setLogId: setLogId,
          reps: reps,
          weightKg: weightKg,
        );
        res.fold((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update set: ${error.msg}')),
            );
          }
        }, (_) => null);
      },
    );
  }

  void _addSet(Map<String, dynamic> log) async {
    final exerciseLogId = log['id'] as int?;
    if (exerciseLogId == null) return;
    if (_addingSetLogIds.contains(exerciseLogId)) return;

    setState(() {
      _addingSetLogIds.add(exerciseLogId);
    });

    final setLogs = List<Map<String, dynamic>>.from(
      log['set_logs'] as List? ?? [],
    );
    final lastSet = setLogs.isNotEmpty ? setLogs.last : null;

    final int defaultReps =
        lastSet != null
            ? (int.tryParse(lastSet['reps']?.toString() ?? '') ?? 10)
            : (int.tryParse(log['target_reps']?.toString() ?? '') ?? 10);

    final double defaultWeight =
        lastSet != null
            ? (double.tryParse(lastSet['weight_kg']?.toString() ?? '') ?? 0.0)
            : (double.tryParse(log['target_weight']?.toString() ?? '') ?? 0.0);

    try {
      final res = await WorkoutRepository().addSetToExerciseLog(
        logId: exerciseLogId,
        reps: defaultReps,
        weightKg: defaultWeight,
        isCompleted: false,
      );

      res.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add set: ${error.msg}')),
            );
          }
        },
        (newLogData) {
          if (mounted && _sessionData != null) {
            setState(() {
              final logsList = _sessionData!['logs'] as List;
              final targetLogIndex = logsList.indexWhere(
                (l) => l['id'] == exerciseLogId,
              );
              if (targetLogIndex != -1) {
                logsList[targetLogIndex] = Map<String, dynamic>.from(
                  newLogData as Map,
                );
              }
            });
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingSetLogIds.remove(exerciseLogId);
        });
      }
    }
  }

  void _deleteSet(int exerciseLogId, int setLogId) async {
    final res = await WorkoutRepository().deleteSetLog(setLogId: setLogId);
    res.fold(
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete set: ${error.msg}')),
          );
        }
      },
      (_) {
        if (mounted && _sessionData != null) {
          setState(() {
            final logsList = _sessionData!['logs'] as List;
            final targetLogIndex = logsList.indexWhere(
              (l) => l['id'] == exerciseLogId,
            );
            if (targetLogIndex != -1) {
              final targetLog = Map<String, dynamic>.from(
                logsList[targetLogIndex] as Map,
              );
              final targetSets = List<Map<String, dynamic>>.from(
                targetLog['set_logs'] as Iterable? ?? [],
              );
              targetSets.removeWhere((s) => s['id'] == setLogId);
              for (var i = 0; i < targetSets.length; i++) {
                targetSets[i]['set_number'] = i + 1;
              }
              targetLog['set_logs'] = targetSets;
              logsList[targetLogIndex] = targetLog;
            }
          });
        }
      },
    );
  }

  Widget _buildOutlineRedButton({
    required String text,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0B5B7), width: 1.0),
        ),
        child: Center(
          child:
              isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                  : Text(
                    text,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
        ),
      ),
    );
  }

  void _loadExercises() async {
    final libRes = await WorkoutRepository().getExerciseLibrary();
    final custRes = await WorkoutRepository().getExerciseLibrary(
      queryParameters: {'custom_only': true},
    );

    final List<ExerciseLibraryModel> allEx = [];
    libRes.fold((_) => null, (list) => allEx.addAll(list));
    custRes.fold((_) => null, (list) => allEx.addAll(list));

    if (mounted) {
      setState(() {
        _exercises = allEx;
      });
    }
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMM d, y').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<ApiException, Map<String, dynamic>>>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _sessionData == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Workout Details',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (snapshot.hasError && _sessionData == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Workout Details',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            body: _buildErrorState('An unexpected error occurred.'),
          );
        }

        final result = snapshot.data;
        if (result == null && _sessionData == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Workout Details',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            body: _buildErrorState('No details found for this session.'),
          );
        }

        if (_sessionData != null) {
          if (widget.startTimer) {
            _syncTimer(_sessionData!);
          }
          final status = _sessionData!['status']?.toString().toUpperCase() ?? 'COMPLETED';
          final showBack = !(widget.startTimer && status != 'COMPLETED');
          final scaffold = Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              automaticallyImplyLeading: showBack,
              leadingWidth: showBack ? 56 : 0,
              leading: showBack ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ) : null,
              title: Text(
                'Workout Details',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            body: _buildContent(_sessionData!),
            bottomNavigationBar: status != 'COMPLETED' ? _buildFinishButton() : null,
          );

          if (!showBack) {
            return PopScope(
              canPop: false,
              child: scaffold,
            );
          }
          return scaffold;
        }

        return result!.fold(
          (error) => Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF444444),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Workout Details',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            body: _buildErrorState('Error loading details: ${error.msg}'),
          ),
          (data) {
            _sessionData = data;
            if (widget.startTimer) {
              _syncTimer(data);
            }
            final status = data['status']?.toString().toUpperCase() ?? 'COMPLETED';
            final showBack = !(widget.startTimer && status != 'COMPLETED');
            final scaffold = Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                automaticallyImplyLeading: showBack,
                leadingWidth: showBack ? 56 : 0,
                leading: showBack ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF444444),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ) : null,
                title: Text(
                  'Workout Details',
                  style: AppStyles.text18Px.poppins.w600.copyWith(
                    color: const Color(0xFF212121),
                  ),
                ),
              ),
              body: _buildContent(data),
              bottomNavigationBar: status != 'COMPLETED' ? _buildFinishButton() : null,
            );

            if (!showBack) {
              return PopScope(
                canPop: false,
                child: scaffold,
              );
            }
            return scaffold;
          },
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.text16Px.poppins.w500.copyWith(
                color: const Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Retry',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? widget.fallbackTitle;
    final dateStr =
        data['session_date']?.toString() ?? data['started_at']?.toString();
    final startedAt = data['started_at']?.toString();
    final completedAt = data['completed_at']?.toString();
    final logs = data['logs'] as List? ?? [];
    final status = data['status']?.toString().toUpperCase() ?? 'COMPLETED';

    final bool isVerified = widget.isVerified ?? (data['is_verified'] as bool?) ?? false;

    bool isEditable = status != 'COMPLETED';
    if (!isEditable && completedAt != null && !isVerified) {
      try {
        final completedTime = DateTime.parse(completedAt).toLocal();
        final difference = DateTime.now().difference(completedTime);
        if (difference.inMinutes.abs() < 60) {
          isEditable = true;
        }
      } catch (_) {}
    }

    final duration = widget.startTimer ? _formatTimer(_elapsedSeconds) : _formatDuration(startedAt, completedAt);
    final formattedDate = _formatDate(dateStr);

    final trainerName = widget.trainerName ?? data['trainer_name']?.toString();
    final isMentor = trainerName != null && trainerName.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (status == 'COMPLETED' && !isVerified && isEditable) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFE65100),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMentor ? 'Trainer Assigned Workout' : 'Completed Workout',
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This workout has been successfully completed. Editing is available for 1 hour after completion.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Premium Summary Header Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFffffff), Color(0xFFffffff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffF0B5B7), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.text20Px.poppins.w600.copyWith(
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (formattedDate.isNotEmpty)
                Text(
                  formattedDate,
                  style: AppStyles.text14Px.poppins.w400.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryInfo(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: duration,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFF334155),
                  ),
                  _buildSummaryInfo(
                    icon: Icons.fitness_center_outlined,
                    label: 'Exercises',
                    value: '${logs.length}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Exercises Section Title
        Text(
          'Exercises Logged',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),

        if (logs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No exercises were logged in this session.',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          )
        else
          ...List.generate(logs.length, (index) {
            final log = logs[index] as Map<String, dynamic>;
            return _buildExerciseCard(log, index, isEditable);
          }),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSummaryInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isTimerActive = label == 'Duration' && widget.startTimer;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isTimerActive ? AppColors.primary : const Color(0xFFF0B5B7),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: isTimerActive ? AppColors.primary : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: isTimerActive ? AppColors.primary : AppColors.dark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    Map<String, dynamic> log,
    int index,
    bool isEditable,
  ) {
    final workoutName = log['workout_name']?.toString() ?? 'Exercise';
    final workoutId =
        log['workout_id'] ?? log['plan_exercise'] ?? log['id'];
    final muscle = log['muscle']?.toString() ?? '';
    final equipment = log['equipment']?.toString() ?? '';
    final videoUrl = log['effective_video_url']?.toString() ?? '';
    final setLogs = List<Map<String, dynamic>>.from(
      log['set_logs'] as List? ?? [],
    );
    setLogs.sort((a, b) {
      final aNum = int.tryParse(a['set_number']?.toString() ?? '') ?? 0;
      final bNum = int.tryParse(b['set_number']?.toString() ?? '') ?? 0;
      return aNum.compareTo(bNum);
    });

    // Resolve type
    String? type;
    if (workoutId != null) {
      final match = _exercises.firstWhere(
        (e) => e.id?.toString() == workoutId.toString(),
        orElse:
            () => ExerciseLibraryModel(
              id: -1,
              name: '',
              type: '',
              muscleGroup: '',
              equipment: '',
              videoUrl: null,
            ),
      );
      if (match.id != -1 && match.type != null && match.type!.isNotEmpty) {
        type = match.type;
      }
    }
    if (type == null && workoutName.isNotEmpty) {
      final match = _exercises.firstWhere(
        (e) => e.name?.toLowerCase().trim() == workoutName.toLowerCase().trim(),
        orElse:
            () => ExerciseLibraryModel(
              id: -1,
              name: '',
              type: '',
              muscleGroup: '',
              equipment: '',
              videoUrl: null,
            ),
      );
      if (match.id != -1 && match.type != null && match.type!.isNotEmpty) {
        type = match.type;
      }
    }

    final tags = <String>[];
    if (muscle.isNotEmpty) tags.add(muscle);
    if (equipment.isNotEmpty) tags.add(equipment);
    if (type != null && type.isNotEmpty) tags.add(type);
    final subtitle = tags.join(' / ');

    String? trackBy = log['track_by']?.toString();
    if (trackBy == null || trackBy.isEmpty) {
      if (workoutId != null) {
        final match = _exercises.firstWhere(
          (e) => e.id?.toString() == workoutId.toString(),
          orElse: () => ExerciseLibraryModel(id: -1, name: '', type: '', muscleGroup: '', equipment: '', videoUrl: null),
        );
        if (match.id != -1) {
          trackBy = match.trackBy;
        }
      }
    }
    if (trackBy == null || trackBy.isEmpty) {
      final match = _exercises.firstWhere(
        (e) => e.name?.toLowerCase().trim() == workoutName.toLowerCase().trim(),
        orElse: () => ExerciseLibraryModel(id: -1, name: '', type: '', muscleGroup: '', equipment: '', videoUrl: null),
      );
      if (match.id != -1) {
        trackBy = match.trackBy;
      }
    }

    final isTimeBased = trackBy?.toLowerCase() == 'time' ||
        subtitle.toLowerCase().contains('cardio') ||
        subtitle.toLowerCase().contains('flexibility') ||
        subtitle.toLowerCase().contains('hiit') ||
        setLogs.any((s) => s['input_type']?.toString().toLowerCase() == 'seconds');
    final isDistanceBased = trackBy?.toLowerCase() == 'distance';

    final String repsHeader = isTimeBased
        ? 'Secs'
        : (isDistanceBased ? 'Km' : 'Reps');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row of the card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. $workoutName',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xFF212121),
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (videoUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(videoUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch video URL.'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 18,
                          height: 13,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD30C15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Table header row
          // Table header row
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Set',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                if (isEditable)
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Previous',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: isEditable
                      ? Center(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: () {
                                final val = log['weight_type']?.toString();
                                if (val == null) return 'kg';
                                if (val.toLowerCase() == 'bw') return 'BW';
                                if (val.toLowerCase() == 'kg+bw') return 'kg+BW';
                                return val;
                              }(),
                              isDense: true,
                              isExpanded: true,
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF212121),
                              ),
                              icon: const Icon(Icons.arrow_drop_down, size: 14),
                              items: const [
                                DropdownMenuItem(value: 'kg', child: Text('kg')),
                                DropdownMenuItem(value: 'BW', child: Text('BW')),
                                DropdownMenuItem(value: 'kg+BW', child: Text('kg+BW')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  final logId = int.tryParse(log['id']?.toString() ?? '');
                                  if (logId != null) {
                                    setState(() {
                                      log['weight_type'] = val;
                                    });
                                    WorkoutRepository().updateWorkoutLogWeightType(
                                      logId: logId,
                                      weightType: val,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        )
                      : Text(
                          'Weight (${() {
                            final val = log['weight_type']?.toString();
                            if (val == null) return 'kg';
                            if (val.toLowerCase() == 'bw') return 'BW';
                            if (val.toLowerCase() == 'kg+bw') return 'kg+BW';
                            return val;
                          }()})',
                          textAlign: TextAlign.left,
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: const Color(0xFF212121),
                          ),
                        ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    repsHeader,
                    textAlign: TextAlign.center,
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Done',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sets list rows
          if (setLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No sets logged',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            )
          else
            ...List.generate(setLogs.length, (setIndex) {
              final set = setLogs[setIndex];
              final setNum = set['set_number'] ?? (setIndex + 1);
              final weight = set['weight_kg']?.toString() ?? '0.00';
              final reps = set['reps']?.toString() ?? '0';
              final isCompleted = set['is_completed'] == true;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        if (!isEditable) ...[
                          Expanded(
                            flex: 2,
                            child: Text(
                              '$setNum',
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color: const Color(0xFF212121),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (log['weight_type']?.toString().toUpperCase() == 'BW') ? 'BW' : '$weight kg',
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color: const Color(0xFF212121),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              reps,
                              textAlign: TextAlign.center,
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color: const Color(0xFF212121),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color:
                                    isCompleted
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFCCCCCC),
                                size: 20,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Editable pending set row
                          // Set number & Delete button
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final setLogId = set['id'] as int?;
                                    if (setLogId != null) {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text('Delete Set'),
                                              content: Text(
                                                'Are you sure you want to delete set $setNum?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm == true) {
                                        _deleteSet(log['id'] as int, setLogId);
                                      }
                                    }
                                  },
                                  child: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$setNum',
                                  style: AppStyles.text14Px.poppins.w400
                                      .copyWith(color: const Color(0xFF212121)),
                                ),
                              ],
                            ),
                          ),
                          // Previous
                          Expanded(
                            flex: 3,
                            child: Text(
                              (set['previous'] == 'no data' ||
                                      set['previous'] == null)
                                  ? '-'
                                  : set['previous'].toString(),
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                          // Weight input field
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.center,
                              child: (log['weight_type']?.toString().toUpperCase() == 'BW')
                                  ? Container(
                                      width: 65,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'BW',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 65,
                                      child: TextFormField(
                                        key: ValueKey('weight_${set['id']}'),
                                        initialValue:
                                            set['weight_kg'] != null &&
                                                    set['weight_kg'].toString() !=
                                                        'null'
                                                ? set['weight_kg'].toString()
                                                : '',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        textAlign: TextAlign.center,
                                        style: AppStyles.text14Px.poppins.w400
                                            .copyWith(color: const Color(0xFF212121)),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 4,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF1F3F9),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText:
                                              set['target_weight'] != null
                                                  ? '${set['target_weight']}'
                                                  : '-',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          final double? parsedWeight =
                                              double.tryParse(val);
                                          set['weight_kg'] = parsedWeight;
                                          _debounceUpdateSet(
                                            set['id'] as int,
                                            reps:
                                                set['reps'] != null
                                                    ? int.tryParse(
                                                      set['reps'].toString(),
                                                    )
                                                    : null,
                                            weightKg: parsedWeight,
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
                          // Reps input field
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 60,
                                child: TextFormField(
                                  key: ValueKey('reps_${set['id']}'),
                                  initialValue:
                                      set['reps'] != null &&
                                              set['reps'].toString() != 'null'
                                          ? set['reps'].toString()
                                          : '',
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.text14Px.poppins.w400
                                      .copyWith(color: const Color(0xFF212121)),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 4,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF1F3F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText:
                                        set['target_reps'] != null
                                            ? '${set['target_reps']}'
                                            : '-',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final int? parsedReps = double.tryParse(val)?.round();
                                    set['reps'] = parsedReps;
                                    _debounceUpdateSet(
                                      set['id'] as int,
                                      reps: parsedReps,
                                      weightKg:
                                          set['weight_kg'] != null
                                              ? double.tryParse(
                                                set['weight_kg'].toString(),
                                              )
                                              : null,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Done checkmark
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  final setLogId = set['id'] as int?;
                                  if (setLogId != null) {
                                    if (_completingSetIds.contains(setLogId)) return;
                                    setState(() {
                                      _completingSetIds.add(setLogId);
                                      set['is_completed'] = !isCompleted;
                                    });
                                    final res = await WorkoutRepository()
                                        .updateSetLog(
                                          setLogId: setLogId,
                                          isCompleted: !isCompleted,
                                        );
                                    res.fold((error) {
                                      setState(() {
                                        set['is_completed'] = isCompleted;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to update set: ${error.msg}',
                                          ),
                                        ),
                                      );
                                    }, (_) => null);
                                    if (mounted) {
                                      setState(() {
                                        _completingSetIds.remove(setLogId);
                                      });
                                    }
                                  }
                                },
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color:
                                      isCompleted
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFCCCCCC),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (setIndex < setLogs.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                ],
              );
            }),

          if (isEditable) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildOutlineRedButton(
                text: '+ Add Set',
                onTap: () => _addSet(log),
                isLoading: _addingSetLogIds.contains(log['id']),
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
      child: SafeArea(
        top: false,
        child: Button.filled(
          isLoading: _isFinishing,
          size: const Size(double.infinity, 48),
          title: 'Finish Workout',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
          icon: const Icon(Icons.check, color: Colors.white, size: 20),
          raduis: 12,
          ontap: () async {
            if (_isFinishing) return;
            setState(() {
              _isFinishing = true;
            });
            final res = await WorkoutRepository().finishSession(
              sessionId: widget.sessionId,
              title: widget.fallbackTitle,
            );
            res.fold(
              (error) {
                setState(() {
                  _isFinishing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to finish workout: ${error.msg}'),
                  ),
                );
              },
              (data) {
                final dateStr = _sessionData?['session_date']?.toString() ??
                    _sessionData?['started_at']?.toString();
                if (dateStr != null) {
                  try {
                    final date = DateTime.parse(dateStr);
                    WorkoutRepository().invalidateCalendarMonth(date.year, date.month);
                  } catch (_) {
                    final now = DateTime.now();
                    WorkoutRepository().invalidateCalendarMonth(now.year, now.month);
                  }
                } else {
                  final now = DateTime.now();
                  WorkoutRepository().invalidateCalendarMonth(now.year, now.month);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout finished successfully!')),
                );
                final Map<String, dynamic> sessionMap = data is Map<String, dynamic>
                    ? Map<String, dynamic>.from(data)
                    : <String, dynamic>{};
                sessionMap['id'] ??= widget.sessionId;
                sessionMap['session_id'] ??= widget.sessionId;
                widget.onRefresh?.call();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (context) => WorkoutAchievementScreen(
                      sessionData: sessionMap,
                      fallbackTitle: widget.fallbackTitle,
                    ),
                  ),
                );
              },
            );
          },
        ),

      ),
    );
  }
}
