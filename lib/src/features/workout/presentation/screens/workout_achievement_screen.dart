import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

class WorkoutAchievementScreen extends StatefulWidget {
  const WorkoutAchievementScreen({
    required this.sessionData,
    this.fallbackTitle,
    super.key,
  });

  final Map<String, dynamic> sessionData;
  final String? fallbackTitle;

  @override
  State<WorkoutAchievementScreen> createState() => _WorkoutAchievementScreenState();
}

class _WorkoutAchievementScreenState extends State<WorkoutAchievementScreen> {
  int _workoutCount = 1;
  bool _isLoadingCount = true;
  bool _isLoadingDetails = true;
  Map<String, dynamic>? _fullSessionData;

  @override
  void initState() {
    super.initState();
    _loadWorkoutCount();
    _loadFullSessionDetails();
  }

  Future<void> _loadWorkoutCount() async {
    try {
      final now = DateTime.now();
      final res = await WorkoutRepository().getWorkoutCalendarForMonth(
        year: now.year,
        month: now.month,
        forceRefresh: true,
      );
      res.fold(
        (_) => null,
        (dataMap) {
          final data = dataMap;
          int count = 0;
          
          // Try to get a direct workout count field if returned
          final directCount = data['workout_count'] ?? 
              data['completed_count'] ?? 
              data['count'] ?? 
              data['total_workouts'] ??
              data['total_completed_workouts'];
          if (directCount != null) {
            final parsedCount = int.tryParse(directCount.toString());
            if (parsedCount != null) {
              count = parsedCount;
            }
          }
          
          if (count == 0) {
            // Try to extract days list
            final List<dynamic> days = (data['days'] as List<dynamic>?) ?? 
                (data['calendar'] as List<dynamic>?) ?? 
                (data['results'] as List<dynamic>?) ?? 
                [];
            if (days.isNotEmpty) {
              for (final dayItem in days) {
                if (dayItem is Map) {
                  final isCompleted = dayItem['is_completed'] == true || 
                      dayItem['completed'] == true || 
                      dayItem['checked'] == true;
                  if (isCompleted) {
                    count++;
                  }
                }
              }
            } else {
              // Try checking if it's a map containing date keys
              data.forEach((key, value) {
                if (value is Map) {
                  final isCompleted = value['is_completed'] == true || 
                      value['completed'] == true || 
                      value['checked'] == true;
                  if (isCompleted) {
                    count++;
                  }
                } else if (value is bool) {
                  if (value == true) {
                    count++;
                  }
                }
              });
            }
          }
          
          if (count > 0 && mounted) {
            setState(() {
              _workoutCount = count;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error fetching workout count: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCount = false;
        });
      }
    }
  }

  Future<void> _loadFullSessionDetails() async {
    try {
      final sessionMap = widget.sessionData['session'] is Map
          ? widget.sessionData['session'] as Map
          : null;
      final sessionDetailsMap = widget.sessionData['session_details'] is Map
          ? widget.sessionData['session_details'] as Map
          : null;
      final rawId = widget.sessionData['id'] ?? 
          widget.sessionData['session_id'] ?? 
          sessionMap?['id'] ??
          sessionMap?['session_id'] ??
          sessionDetailsMap?['id'];
      final sessionId = int.tryParse(rawId?.toString() ?? '');
      if (sessionId != null) {
        final res = await WorkoutRepository().getSessionDetails(sessionId: sessionId);
        res.fold(
          (_) {
            if (mounted) {
              setState(() {
                _fullSessionData = widget.sessionData;
                _isLoadingDetails = false;
              });
            }
          },
          (data) {
            if (mounted) {
              setState(() {
                _fullSessionData = data;
                _isLoadingDetails = false;
              });
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _fullSessionData = widget.sessionData;
            _isLoadingDetails = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading full session details: $e');
      if (mounted) {
        setState(() {
          _fullSessionData = widget.sessionData;
          _isLoadingDetails = false;
        });
      }
    }
  }

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  double _calculateVolume(List<dynamic> logs) {
    double total = 0;
    bool hasCompleted = false;
    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        for (final set in setLogs) {
          if (set is Map) {
            final isCompleted = (set['is_completed'] == true) || (set['checked'] == true);
            if (isCompleted) {
              hasCompleted = true;
              final reps = double.tryParse(set['reps']?.toString() ?? '') ?? 0;
              final weight = double.tryParse(
                set['weight_kg']?.toString() ??
                set['kg']?.toString() ??
                set['weight']?.toString() ??
                '',
              ) ?? 0;
              total += reps * weight;
            }
          }
        }
      }
    }
    if (!hasCompleted) {
      for (final log in logs) {
        if (log is Map) {
          final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
          for (final set in setLogs) {
            if (set is Map) {
              final reps = double.tryParse(set['reps']?.toString() ?? '') ?? 0;
              final weight = double.tryParse(
                set['weight_kg']?.toString() ??
                set['kg']?.toString() ??
                set['weight']?.toString() ??
                '',
              ) ?? 0;
              total += reps * weight;
            }
          }
        }
      }
    }
    return total;
  }

  int _countSets(List<dynamic> logs) {
    int total = 0;
    int completed = 0;
    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        total += setLogs.length;
        for (final set in setLogs) {
          if (set is Map) {
            final isCompleted = (set['is_completed'] == true) || (set['checked'] == true);
            if (isCompleted) {
              completed++;
            }
          }
        }
      }
    }
    return completed > 0 ? completed : total;
  }

  int _getDurationInMinutes(Map<String, dynamic> data) {
    if (data['duration'] != null) {
      final rawDuration = double.tryParse(data['duration'].toString()) ?? 0;
      if (rawDuration > 0) {
        if (rawDuration > 1000) {
          return (rawDuration / 60).round();
        }
        return rawDuration.round();
      }
    }
    final startedAtStr = data['started_at']?.toString() ??
        data['created_at']?.toString() ??
        data['start_time']?.toString();
    final completedAtStr = data['completed_at']?.toString() ??
        data['updated_at']?.toString() ??
        data['end_time']?.toString();
    if (startedAtStr == null || completedAtStr == null) return 1;
    try {
      final start = DateTime.parse(startedAtStr);
      final end = DateTime.parse(completedAtStr);
      final diff = end.difference(start);
      final mins = diff.inMinutes;
      return mins <= 0 ? 1 : mins;
    } catch (_) {
      return 1;
    }
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}min';
    } else {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h ${mins}m';
    }
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppStyles.text24Px.poppins.w700.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w600.copyWith(
            color: const Color(0xFF6E5D5D),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    bool useRawIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useRawIcon)
            icon
          else
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F9),
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: const Color(0xFF6E5D5D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetails) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = _fullSessionData ?? widget.sessionData;
    final title = data['title']?.toString() ?? data['plan_name']?.toString() ?? widget.fallbackTitle ?? 'Workout';
    final logs = data['logs'] as List? ?? data['exercises'] as List? ?? data['session_exercises'] as List? ?? [];
    final durationMins = _getDurationInMinutes(data);
    final durationStr = _formatDuration(durationMins);
    final volume = _calculateVolume(logs);
    final volumeStr = volume > 0 ? '${volume.toStringAsFixed(0)} kg' : '0 kg';
    final exerciseCount = logs.length;
    final setsCount = _countSets(logs);

    final user = Feggy.read<AppCubit>()?.state.currentUser;
    final fName = user?.firstName ?? '';
    final lName = user?.lastName ?? '';
    String username = '@user';
    if (fName.isNotEmpty || lName.isNotEmpty) {
      username = '@${(fName + lName).toLowerCase().replaceAll(' ', '')}';
    } else if (user?.email != null && user!.email!.contains('@')) {
      username = '@${user.email!.split('@').first.toLowerCase()}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            // Top Back button
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
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

            // Wolf Mascot Lottie
            Center(
              child: Lottie.asset(
                'assets/images/svg/vectors/thumbsUp_achievement.json',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),

            // Headers
            Center(
              child: Text(
                'Good Job!',
                style: AppStyles.text24Px.poppins.w700.copyWith(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _isLoadingCount
                    ? 'Processing achievements...'
                    : 'This is your $_workoutCount${_getOrdinal(_workoutCount)} Workout',
                style: AppStyles.text16Px.poppins.w500.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Achievement Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xffF0B5B7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Title and Dumbbell Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppStyles.text20Px.poppins.w700.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Metrics Grid (2x2 Column/Row structure)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetric(durationStr, 'DURATION'),
                            const SizedBox(height: 20),
                            _buildMetric('$exerciseCount', 'EXERCISES'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetric(volumeStr, 'VOLUME'),
                            const SizedBox(height: 20),
                            _buildMetric('$setsCount', 'SETS'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Divider
                  const Divider(
                    color: Color(0xFFF1D1D2),
                    height: 32,
                    thickness: 1,
                  ),

                  // Bottom Row: Logo & Username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/png/vectors/discipl_spell.png',
                        height: 20,
                      ),
                      Text(
                        username,
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share Section
            Center(
              child: Text(
                'Share workout – Tag @discipl',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: const Color(0xFF6E5D5D),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Share Options Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShareButton(
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
                  label: 'Background',
                  onTap: () {
                    Dialogs.showSnack(msg: 'Feature coming soon!');
                  },
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 16),
                _buildShareButton(
                  useRawIcon: true,
                  icon: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF833AB4),
                          Color(0xFFFD1D1D),
                          Color(0xFFF56040),
                          Color(0xFFFCAF45),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  label: 'Stories',
                  onTap: () {
                    Dialogs.showSnack(msg: 'Feature coming soon!');
                  },
                ),
                const SizedBox(width: 20),
                _buildShareButton(
                  icon: Icon(
                    Icons.ios_share,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  label: 'More',
                  onTap: () {
                    Dialogs.showSnack(msg: 'Feature coming soon!');
                  },
                ),
                const SizedBox(width: 20),
                _buildShareButton(
                  icon: Icon(
                    Icons.file_download_outlined,
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
                  label: 'Download',
                  onTap: () {
                    Dialogs.showSnack(msg: 'Feature coming soon!');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Done Button
            Button.filled(
              title: 'Done',
              ontap: () => Navigator.pop(context, true),
              buttonColor: AppColors.primary,
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
