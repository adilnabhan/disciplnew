import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final WorkoutModel workoutModel;
  final List<Map<String, dynamic>> exercises;
  final bool isReadOnly;

  const WorkoutExecutionScreen({
    required this.workoutModel,
    required this.exercises,
    this.isReadOnly = false,
    super.key,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  late final List<Map<String, dynamic>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = List<Map<String, dynamic>>.from(
      widget.exercises.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final List<Map<String, dynamic>> sets = List<Map<String, dynamic>>.from(
        _exercises[exerciseIndex]['sets'] as List,
      );
      final lastSet = sets.isNotEmpty ? sets.last : null;
      final newSetNum = sets.length + 1;

      sets.add(<String, dynamic>{
        'setNum': newSetNum,
        'previous': 'no data',
        'kg': lastSet != null ? lastSet['kg'] : '-',
        'reps': lastSet != null ? lastSet['reps'] : '-',
        'checked': false,
      });
      _exercises[exerciseIndex]['sets'] = sets;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalExercises = _exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      GestureDetector(
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
                      const SizedBox(width: 11),
                      // Title
                      Expanded(
                        child: Text(
                          widget.isReadOnly
                              ? widget.workoutModel.title
                              : '${widget.workoutModel.title} Plan ${widget.workoutModel.day}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.0,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 51,
                    ),
                    child: Text(
                      '$totalExercises Exercises',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.0,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ],
              ),
            ),

             // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  // Exercise list
                  ...List.generate(_exercises.length, (exerciseIndex) {
                    final exercise = _exercises[exerciseIndex];
                    return _buildExerciseCard(exercise, exerciseIndex);
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (!widget.isReadOnly) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 12),
                child: PrimaryPillButton(
                  text: 'Finish Workout',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text(
                          'Finish Workout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to finish this workout session?',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Finish',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int exerciseIndex) {
    final sets = exercise['sets'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      debugPrint('DEBUG: Tapped exercise: ${exercise['title']} with ID: ${exercise['id']}');
                      _showExerciseDetailsBottomSheet(
                        context,
                        exercise['id']?.toString(),
                        exercise['title']?.toString(),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exerciseIndex + 1}. ${exercise['title']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          exercise['subtitle'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play button icon
                GestureDetector(
                  onTap: () async {
                    final videoUrlStr = exercise['video_url']?.toString() ?? '';
                    if (videoUrlStr.isNotEmpty) {
                      final uri = Uri.parse(videoUrlStr);
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No video link available for this exercise.'),
                        ),
                      );
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
              top: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Set',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'kg',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Rep',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Sets list rows
          ...List.generate(sets.length, (setIndex) {
            final set = sets[setIndex];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Set index
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${set['setNum']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                      ),
                      // Previous value
                      Expanded(
                        flex: 3,
                        child: Text(
                          set['previous'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                      ),
                      // kg Input Box
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: set['kg'] as String?,
                              readOnly: widget.isReadOnly,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF212121),
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) {
                                set['kg'] = val;
                              },
                            ),
                          ),
                        ),
                      ),
                      // Rep Input Box
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: set['reps'] as String?,
                              readOnly: widget.isReadOnly,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF212121),
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) {
                                set['reps'] = val;
                              },
                            ),
                          ),
                        ),
                      ),
                      // Check checkbox button
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: widget.isReadOnly
                                ? null
                                : () {
                                    setState(() {
                                      set['checked'] =
                                          !(set['checked'] as bool? ?? false);
                                    });
                                  },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color:
                                    (set['checked'] as bool? ?? false)
                                        ? AppColors.primary
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color:
                                      (set['checked'] as bool? ?? false)
                                          ? AppColors.primary
                                          : const Color(0xFFCCCCCC),
                                  width: 1.5,
                                ),
                              ),
                              child:
                                  (set['checked'] as bool? ?? false)
                                      ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F1F1)),
              ],
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showExerciseDetailsBottomSheet(
    BuildContext context,
    String? exerciseId,
    String? exerciseTitle,
  ) {
    debugPrint('DEBUG: _showExerciseDetailsBottomSheet called for $exerciseTitle (ID: $exerciseId)');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<Either<ApiException, Map<String, dynamic>>>(
                future: () async {
                  final parsedId = int.tryParse(exerciseId ?? '');
                  if (parsedId != null) {
                    debugPrint('DEBUG: Trying lookup by ID: $parsedId');
                    final res = await WorkoutRepository().getExerciseDetailsById(parsedId);
                    if (res.isRight()) {
                      debugPrint('DEBUG: ID lookup succeeded!');
                      return res;
                    }
                    debugPrint('DEBUG: ID lookup failed, falling back to title lookup');
                  }
                  if (exerciseTitle != null && exerciseTitle.isNotEmpty) {
                    debugPrint('DEBUG: Trying lookup by title: $exerciseTitle');
                    return WorkoutRepository().getExerciseDetails(title: exerciseTitle);
                  }
                  return left<ApiException, Map<String, dynamic>>(const ApiException.unknown());
                }(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(context, "An unexpected error occurred.");
                  }

                  final result = snapshot.data;
                  if (result == null) {
                    return _buildErrorState(context, "No data available.");
                  }

                  return result.fold(
                    (error) => _buildErrorState(context, "Error fetching details: $error"),
                    (data) => _buildExerciseDetailsContent(context, data, scrollController),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetailsContent(
    BuildContext context,
    Map<String, dynamic> data,
    ScrollController scrollController,
  ) {
    final String name = data['name']?.toString() ?? 'Exercise Details';
    final String description = data['description']?.toString() ?? 'No description available.';
    final String type = data['type']?.toString() ?? '';
    final String muscle = data['primary_muscle_group_name']?.toString() ?? '';
    final String equipment = data['equipment_name']?.toString() ?? '';
    final String instructions = data['instructions']?.toString() ?? '';
    final String? videoUrlStr = data['video_url']?.toString();

    final instructionSteps = instructions
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Column(
      children: [
        // Drag Handle Indicator
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(height: 16),

        // Title Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF666666)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 24, color: Color(0xFFEEEEEE)),

        // Scrollable Body
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (muscle.isNotEmpty)
                    _buildDetailTag(muscle, const Color(0xFFFFF0F1), const Color(0xFFD30C15)),
                  if (equipment.isNotEmpty)
                    _buildDetailTag(equipment, const Color(0xFFF1F3F9), const Color(0xFF4A5568)),
                  if (type.isNotEmpty)
                    _buildDetailTag(type.toUpperCase(), const Color(0xFFE6FFFA), const Color(0xFF00A389)),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              const Text(
                'About the Exercise',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Video Button if available
              if (videoUrlStr != null && videoUrlStr.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(videoUrlStr);
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
                  icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                  label: const Text('Watch Execution Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD30C15),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Instructions Section
              if (instructionSteps.isNotEmpty) ...[
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(instructionSteps.length, (idx) {
                  final stepText = instructionSteps[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0F1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD30C15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            stepText.replaceFirst(RegExp(r'^\d+\.\s*'), ''), // Strip duplicate numbering if present
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF444444),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
