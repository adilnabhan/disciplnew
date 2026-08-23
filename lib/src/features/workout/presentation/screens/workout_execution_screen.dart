import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/equipment_anatomy_guide_modal.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Timer? _sessionTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _exercises = List<Map<String, dynamic>>.from(
      widget.exercises.map((e) => Map<String, dynamic>.from(e)),
    );

    if (!widget.isReadOnly) {
      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  String _formatElapsedTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
        'kg': lastSet != null ? lastSet['kg'] : '10',
        'reps': lastSet != null ? lastSet['reps'] : '12',
        'checked': false,
      });
      _exercises[exerciseIndex]['sets'] = sets;
    });
  }

  void _addCustomWorkout() {
    setState(() {
      _exercises.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': 'Custom Exercise',
        'subtitle': 'Chest / Dumbbells / strength',
        'sets': [
          {
            'setNum': 1,
            'previous': 'no data',
            'kg': '10',
            'reps': '12',
            'checked': false,
          }
        ],
        'video_url': '',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalExercises = _exercises.length;

    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar / Header with Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: CyberWorkoutTheme.bgCardGlass,
                        shape: BoxShape.circle,
                        border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title & Live Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isReadOnly
                              ? widget.workoutModel.title
                              : (widget.workoutModel.title.isEmpty ? 'My Session' : widget.workoutModel.title),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '$totalExercises Exercises',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: CyberWorkoutTheme.textSecondary,
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(color: CyberWorkoutTheme.textSecondary),
                            ),
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: CyberWorkoutTheme.goldPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatElapsedTime(_elapsedSeconds),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: CyberWorkoutTheme.goldPrimary,
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

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Exercise list
                  ...List.generate(_exercises.length, (exerciseIndex) {
                    final exercise = _exercises[exerciseIndex];
                    return _buildCyberExerciseCard(exercise, exerciseIndex);
                  }),

                  // "+ Add Workout" button
                  if (!widget.isReadOnly) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _addCustomWorkout,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF151520),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: CyberWorkoutTheme.goldPrimary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "+ Add Workout",
                              style: TextStyle(
                                color: CyberWorkoutTheme.goldPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom Finish CTA
            if (!widget.isReadOnly) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberWorkoutTheme.goldPrimary,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: CyberWorkoutTheme.goldPrimary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: CyberWorkoutTheme.goldPrimary, width: 1.2),
                          ),
                          title: const Text(
                            'Finish Workout',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          content: Text(
                            'Great job! You worked out for ${_formatElapsedTime(_elapsedSeconds)}. Ready to save and record your stats?',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: CyberWorkoutTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Keep Going',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CyberWorkoutTheme.goldPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Save & Finish',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCyberExerciseCard(Map<String, dynamic> exercise, int exerciseIndex) {
    final sets = exercise['sets'] as List<Map<String, dynamic>>;
    final title = exercise['title']?.toString() ?? 'Exercise';
    final subtitle = exercise['subtitle']?.toString() ?? 'Full Body / General';
    final videoUrlStr = exercise['video_url']?.toString() ?? '';

    // Extract target muscle and equipment from subtitle
    final parts = subtitle.split('/');
    final targetMuscle = parts.isNotEmpty ? parts[0].trim() : 'Chest';
    final equipment = parts.length > 1 ? parts[1].trim() : 'Dumbbells';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151520),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CyberWorkoutTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row of the card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      EquipmentAnatomyGuideModal.show(
                        context,
                        exerciseName: title,
                        targetMuscle: targetMuscle,
                        equipment: equipment,
                        videoUrl: videoUrlStr,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${exerciseIndex + 1}. $title',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: CyberWorkoutTheme.goldPrimary, size: 11),
                                  SizedBox(width: 3),
                                  Text(
                                    "3D GUIDE",
                                    style: TextStyle(
                                      color: CyberWorkoutTheme.goldPrimary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberWorkoutTheme.crimsonRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                targetMuscle,
                                style: const TextStyle(
                                  color: CyberWorkoutTheme.crimsonRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF222233),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                equipment,
                                style: const TextStyle(
                                  color: CyberWorkoutTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Play button icon
                if (videoUrlStr.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(videoUrlStr);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCC0000),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF252535)),

          // Table header row
          Container(
            color: const Color(0xFF11111A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Set',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CyberWorkoutTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CyberWorkoutTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'kg',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CyberWorkoutTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Rep',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CyberWorkoutTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.check, size: 16, color: CyberWorkoutTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF252535)),

          // Sets table rows
          ...List.generate(sets.length, (setIndex) {
            final set = sets[setIndex];
            final bool isChecked = set['checked'] as bool? ?? false;

            return Container(
              color: isChecked ? const Color(0xFF1D261A) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Set Number
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set['setNum'] ?? (setIndex + 1)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isChecked ? CyberWorkoutTheme.goldPrimary : Colors.white,
                      ),
                    ),
                  ),
                  // Previous data
                  Expanded(
                    flex: 3,
                    child: Text(
                      set['previous']?.toString() ?? 'no data',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: CyberWorkoutTheme.textSecondary,
                      ),
                    ),
                  ),
                  // kg input
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isChecked ? CyberWorkoutTheme.goldPrimary : CyberWorkoutTheme.borderSubtle,
                          ),
                        ),
                        child: TextFormField(
                          initialValue: set['kg']?.toString(),
                          readOnly: widget.isReadOnly,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => set['kg'] = val,
                        ),
                      ),
                    ),
                  ),
                  // Reps input
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isChecked ? CyberWorkoutTheme.goldPrimary : CyberWorkoutTheme.borderSubtle,
                          ),
                        ),
                        child: TextFormField(
                          initialValue: set['reps']?.toString(),
                          readOnly: widget.isReadOnly,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => set['reps'] = val,
                        ),
                      ),
                    ),
                  ),
                  // Checkbox toggle
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: widget.isReadOnly
                            ? null
                            : () {
                                setState(() {
                                  set['checked'] = !isChecked;
                                });
                              },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isChecked ? CyberWorkoutTheme.goldPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isChecked ? CyberWorkoutTheme.goldPrimary : CyberWorkoutTheme.borderSubtle,
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(Icons.check, size: 18, color: Colors.black)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // "+ Add a Set" Button
          if (!widget.isReadOnly) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => _addSet(exerciseIndex),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CyberWorkoutTheme.goldPrimary.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: CyberWorkoutTheme.goldPrimary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "+ Add a Set",
                        style: TextStyle(
                          color: CyberWorkoutTheme.goldPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
