import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/exercise_technique_sheet.dart';

class RoutineAnatomyScreen extends StatefulWidget {
  const RoutineAnatomyScreen({
    super.key,
    this.routineTitle = "Full-Body Day 1",
    this.planName = "HALE",
    this.difficulty = "ADVANCED",
    this.category = "Gym",
    this.exerciseCount = 10,
    this.focusDescription = "Horizontal Push/Pull + Quad dominant legs",
  });

  final String routineTitle;
  final String planName;
  final String difficulty;
  final String category;
  final int exerciseCount;
  final String focusDescription;

  @override
  State<RoutineAnatomyScreen> createState() => _RoutineAnatomyScreenState();
}

class _RoutineAnatomyScreenState extends State<RoutineAnatomyScreen> {
  bool _warmupExpanded = false;
  final Map<int, bool> _setsExpanded = {};

  final List<Map<String, dynamic>> _exercises = [
    {
      "name": "Barbell Bench Press",
      "target": "Pectorals",
      "primaryMuscles": [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders],
      "secondaryMuscles": [MuscleGroupTarget.triceps],
      "defaultSets": [
        {"set": 1, "reps": "12", "weight": "60 kg", "rest": "90s"},
        {"set": 2, "reps": "10", "weight": "70 kg", "rest": "90s"},
        {"set": 3, "reps": "8", "weight": "80 kg", "rest": "120s"},
      ],
      "instructions": [
        "Lie back on the flat bench with eyes directly under the racked bar.",
        "Grip the bar slightly wider than shoulder-width with thumbs wrapped securely.",
        "Unrack the bar and stabilize over chest with arms straight.",
        "Inhale and lower slowly to mid-chest while tucking elbows at 45 degrees.",
        "Drive forcefully upward through chest and triceps to lockout while exhaling."
      ],
      "formTips": [
        "Keep 5 points of contact: head, upper back, glutes, left foot, right foot.",
        "Do NOT flare elbows out 90 degrees to protect the rotator cuff.",
        "Maintain a tight shoulder retraction (pinch shoulder blades together)."
      ],
    },
    {
      "name": "Barbell Bent Over Row",
      "target": "Upper Back",
      "primaryMuscles": [MuscleGroupTarget.upperBack, MuscleGroupTarget.lats],
      "secondaryMuscles": [MuscleGroupTarget.biceps, MuscleGroupTarget.abs],
      "defaultSets": [
        {"set": 1, "reps": "10", "weight": "50 kg", "rest": "90s"},
        {"set": 2, "reps": "10", "weight": "60 kg", "rest": "90s"},
        {"set": 3, "reps": "8", "weight": "65 kg", "rest": "90s"},
      ],
      "instructions": [
        "Hinge at the hips with knees slightly bent and spine flat at a 45-degree angle.",
        "Grip the barbell with an overhand grip slightly outside knees.",
        "Pull the bar toward your belly button, driving elbows back.",
        "Squeeze the shoulder blades firmly at the top for 1 full second.",
        "Lower under control back to full arm extension."
      ],
      "formTips": [
        "Avoid jerking the torso up to heave the weight.",
        "Keep neck in neutral alignment with your spine throughout the set."
      ],
    },
    {
      "name": "Barbell Full Squat",
      "target": "Quadriceps",
      "primaryMuscles": [MuscleGroupTarget.quadriceps],
      "secondaryMuscles": [MuscleGroupTarget.calves, MuscleGroupTarget.abs],
      "defaultSets": [
        {"set": 1, "reps": "12", "weight": "70 kg", "rest": "120s"},
        {"set": 2, "reps": "10", "weight": "85 kg", "rest": "120s"},
        {"set": 3, "reps": "8", "weight": "100 kg", "rest": "120s"},
      ],
      "instructions": [
        "Position the barbell across upper traps and step out with feet shoulder-width.",
        "Brace core tightly and initiate movement by sending hips back and down.",
        "Descend until thighs break parallel with knees tracking over toes.",
        "Drive forcefully through whole foot to stand tall."
      ],
      "formTips": [
        "Do not allow knees to cave inward during the ascent.",
        "Maintain upright torso posture and keep heels pinned to the floor."
      ],
    },
    {
      "name": "Standing Overhead Barbell Press",
      "target": "Deltoids",
      "primaryMuscles": [MuscleGroupTarget.shoulders],
      "secondaryMuscles": [MuscleGroupTarget.triceps, MuscleGroupTarget.abs],
      "defaultSets": [
        {"set": 1, "reps": "10", "weight": "40 kg", "rest": "90s"},
        {"set": 2, "reps": "8", "weight": "45 kg", "rest": "90s"},
        {"set": 3, "reps": "8", "weight": "50 kg", "rest": "90s"},
      ],
      "instructions": [
        "Hold barbell at upper collarbone with forearms vertical.",
        "Squeeze glutes and abs, press bar straight up past face until overhead lockout."
      ],
      "formTips": ["Do not arch the lower back excessively."],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: SafeArea(
        child: Column(
          children: [
            // Top Yellow Header Banner
            _buildTopYellowBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row (ROUTINE HALE, ADVANCED, Gym)
                    _buildTagsRow(),
                    const SizedBox(height: 16),

                    // Hero Anatomy & Routine Title Card
                    _buildHeroAnatomyCard(),
                    const SizedBox(height: 16),

                    // Warmup Accordion Card
                    _buildWarmupCard(),
                    const SizedBox(height: 24),

                    // Section Header: EXERCISES
                    _buildSectionHeader("EXERCISES"),
                    const SizedBox(height: 12),

                    // Exercise Cards List
                    ...List.generate(_exercises.length, (index) {
                      return _buildExerciseCard(index, _exercises[index]);
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopYellowBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: CyberWorkoutTheme.goldPrimary,
        boxShadow: [
          BoxShadow(
            color: Color(0x33FFDE03),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
                SizedBox(width: 4),
                Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "View Routine",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit Routine mode activated")),
              );
            },
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow() {
    return Row(
      children: [
        // ROUTINE HALE Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF142433),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF236EAA)),
          ),
          child: Row(
            children: [
              const Text(
                "ROUTINE ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                widget.planName,
                style: const TextStyle(
                  color: Color(0xFF5BC0EB),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ADVANCED Tag (Orange/Red)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1616),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE55934)),
          ),
          child: Text(
            widget.difficulty,
            style: const TextStyle(
              color: Color(0xFFE55934),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Gym Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: CyberWorkoutTheme.bgSurfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CyberWorkoutTheme.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text(
                widget.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAnatomyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CyberWorkoutTheme.glassCard(
        borderColor: CyberWorkoutTheme.borderGold,
        glow: true,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing Anatomy Visualizer Widget
          Container(
            width: 90,
            height: 115,
            decoration: BoxDecoration(
              color: const Color(0xFF101017),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberWorkoutTheme.borderGold.withOpacity(0.5)),
            ),
            child: const MuscleAnatomyVisualizer(
              primaryMuscles: [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders, MuscleGroupTarget.quadriceps],
              secondaryMuscles: [MuscleGroupTarget.triceps, MuscleGroupTarget.abs],
              width: 80,
              height: 105,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.routineTitle,
                  style: const TextStyle(
                    color: CyberWorkoutTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.exerciseCount} exercises",
                  style: const TextStyle(
                    color: CyberWorkoutTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.focusDescription,
                  style: const TextStyle(
                    color: CyberWorkoutTheme.textGold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarmupCard() {
    return Container(
      decoration: CyberWorkoutTheme.glassCard(
        borderColor: CyberWorkoutTheme.borderSubtle,
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _warmupExpanded = !_warmupExpanded),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CyberWorkoutTheme.goldPrimary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_run, color: CyberWorkoutTheme.goldPrimary, size: 20),
            ),
            title: const Text(
              "Warmup",
              style: TextStyle(
                color: CyberWorkoutTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text(
              "Warm up set included",
              style: TextStyle(
                color: CyberWorkoutTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              _warmupExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: CyberWorkoutTheme.textSecondary,
            ),
          ),
          if (_warmupExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberWorkoutTheme.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "• 8 min rowing machine moderate pace.\n• Band pull-aparts 3×20 reps.\n• Shoulder CARs 8 reps each direction.\n• Bodyweight squats 2×15 with 3s eccentric.",
                  style: TextStyle(
                    color: CyberWorkoutTheme.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Text(
          "☵ ",
          style: TextStyle(color: CyberWorkoutTheme.goldPrimary, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(
          title,
          style: const TextStyle(
            color: CyberWorkoutTheme.goldPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(color: CyberWorkoutTheme.borderSubtle, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(int index, Map<String, dynamic> exercise) {
    final bool isExpanded = _setsExpanded[index] ?? false;
    final List<Map<String, dynamic>> defaultSets = exercise['defaultSets'] as List<Map<String, dynamic>>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: CyberWorkoutTheme.glassCard(
        borderColor: isExpanded ? CyberWorkoutTheme.borderGold : CyberWorkoutTheme.borderSubtle,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Exercise Anatomical Icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF13131A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                  ),
                  child: Center(
                    child: MuscleAnatomyVisualizer(
                      primaryMuscles: exercise['primaryMuscles'] as List<MuscleGroupTarget>,
                      secondaryMuscles: exercise['secondaryMuscles'] as List<MuscleGroupTarget>? ?? [],
                      width: 44,
                      height: 48,
                      isAnimated: false,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'] as String,
                        style: const TextStyle(
                          color: CyberWorkoutTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.4)),
                            ),
                            child: Text(
                              exercise['target'] as String,
                              style: const TextStyle(
                                color: CyberWorkoutTheme.crimsonRed,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "How to do" Button
                          GestureDetector(
                            onTap: () {
                              ExerciseTechniqueSheet.show(
                                context,
                                exerciseName: exercise['name'] as String,
                                targetMuscle: exercise['target'] as String,
                                primaryMuscles: exercise['primaryMuscles'] as List<MuscleGroupTarget>,
                                secondaryMuscles: exercise['secondaryMuscles'] as List<MuscleGroupTarget>? ?? [],
                                instructions: (exercise['instructions'] as List?)?.cast<String>() ?? ["Execute with strict form."],
                                formTips: (exercise['formTips'] as List?)?.cast<String>() ?? ["Keep core tight."],
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: CyberWorkoutTheme.goldPrimary, size: 14),
                                SizedBox(width: 3),
                                Text(
                                  "How to do",
                                  style: TextStyle(
                                    color: CyberWorkoutTheme.goldPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
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

          // View Default Sets Button
          GestureDetector(
            onTap: () => setState(() => _setsExpanded[index] = !isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF14141B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? "Hide default sets" : "View default sets",
                    style: const TextStyle(
                      color: CyberWorkoutTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: CyberWorkoutTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Default Sets Table
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              color: CyberWorkoutTheme.bgSurface,
              child: Column(
                children: defaultSets.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Set ${s['set']}",
                          style: const TextStyle(color: CyberWorkoutTheme.goldPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          "${s['reps']} Reps",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          "${s['weight']}",
                          style: const TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 13),
                        ),
                        Text(
                          "Rest: ${s['rest']}",
                          style: const TextStyle(color: CyberWorkoutTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
