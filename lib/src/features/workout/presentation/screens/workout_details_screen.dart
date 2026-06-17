import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({
    required this.sessionId,
    required this.fallbackTitle,
    super.key,
  });

  final int sessionId;
  final String fallbackTitle;

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  late Future<Either<ApiException, Map<String, dynamic>>> _detailsFuture;
  List<ExerciseLibraryModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadExercises();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = WorkoutRepository().getSessionDetails(
        sessionId: widget.sessionId,
      );
    });
  }

  void _loadExercises() async {
    final libRes = await WorkoutRepository().getExerciseLibrary();
    final custRes = await WorkoutRepository().getExerciseLibrary(queryParameters: {'custom_only': true});
    
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
      body: FutureBuilder<Either<ApiException, Map<String, dynamic>>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState('An unexpected error occurred.');
          }

          final result = snapshot.data;
          if (result == null) {
            return _buildErrorState('No details found for this session.');
          }

          return result.fold(
            (error) => _buildErrorState('Error loading details: ${error.msg}'),
            _buildContent,
          );
        },
      ),
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

    final duration = _formatDuration(startedAt, completedAt);
    final formattedDate = _formatDate(dateStr);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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
                      style: AppStyles.text22Px.poppins.w700.copyWith(
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
            return _buildExerciseCard(log, index);
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
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFF0B5B7), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: AppColors.dark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> log, int index) {
    final workoutName = log['workout_name']?.toString() ?? 'Exercise';
    final planExerciseId = log['plan_exercise'] ?? log['workout_id'] ?? log['id'];
    final muscle = log['muscle']?.toString() ?? '';
    final equipment = log['equipment']?.toString() ?? '';
    final videoUrl = log['effective_video_url']?.toString() ?? '';
    final setLogs = log['set_logs'] as List? ?? [];

    // Resolve type
    String? type;
    if (planExerciseId != null) {
      final match = _exercises.firstWhere(
        (e) => e.id?.toString() == planExerciseId.toString(),
        orElse: () => ExerciseLibraryModel(id: -1, name: '', type: '', muscleGroup: '', equipment: '', videoUrl: null),
      );
      if (match.id != -1 && match.type != null && match.type!.isNotEmpty) {
        type = match.type;
      }
    }
    if (type == null && workoutName.isNotEmpty) {
      final match = _exercises.firstWhere(
        (e) => e.name?.toLowerCase().trim() == workoutName.toLowerCase().trim(),
        orElse: () => ExerciseLibraryModel(id: -1, name: '', type: '', muscleGroup: '', equipment: '', videoUrl: null),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                Expanded(
                  flex: 3,
                  child: Text(
                    'Weight',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Reps',
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

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

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
              final set = setLogs[setIndex] as Map<String, dynamic>;
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
                            '$weight kg',
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
                      ],
                    ),
                  ),
                  if (setIndex < setLogs.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                ],
              );
            }),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
