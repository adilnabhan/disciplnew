import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';

class ExerciseTechniqueSheet extends StatefulWidget {
  const ExerciseTechniqueSheet({
    super.key,
    required this.exerciseName,
    required this.targetMuscle,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.formTips,
    this.videoUrl,
  });

  final String exerciseName;
  final String targetMuscle;
  final List<MuscleGroupTarget> primaryMuscles;
  final List<MuscleGroupTarget> secondaryMuscles;
  final List<String> instructions;
  final List<String> formTips;
  final String? videoUrl;

  static void show(
    BuildContext context, {
    required String exerciseName,
    required String targetMuscle,
    required List<MuscleGroupTarget> primaryMuscles,
    required List<MuscleGroupTarget> secondaryMuscles,
    required List<String> instructions,
    required List<String> formTips,
    String? videoUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseTechniqueSheet(
        exerciseName: exerciseName,
        targetMuscle: targetMuscle,
        primaryMuscles: primaryMuscles,
        secondaryMuscles: secondaryMuscles,
        instructions: instructions,
        formTips: formTips,
        videoUrl: videoUrl,
      ),
    );
  }

  @override
  State<ExerciseTechniqueSheet> createState() => _ExerciseTechniqueSheetState();
}

class _ExerciseTechniqueSheetState extends State<ExerciseTechniqueSheet> {
  int _selectedTab = 0; // 0: How to do, 1: Muscles Targeted, 2: Form Cues

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: CyberWorkoutTheme.bgVoid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: CyberWorkoutTheme.borderGold, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3E3E50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseName,
                        style: const TextStyle(
                          color: CyberWorkoutTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5)),
                            ),
                            child: Text(
                              widget.targetMuscle.toUpperCase(),
                              style: const TextStyle(
                                color: CyberWorkoutTheme.crimsonRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "• Pro Execution Guide",
                            style: TextStyle(
                              color: CyberWorkoutTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: CyberWorkoutTheme.bgSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Custom Tabs (How to do / Muscles / Form Cues)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CyberWorkoutTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberWorkoutTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, "How to do", Icons.play_circle_outline),
                  _buildTabItem(1, "Muscle Map", Icons.accessibility_new),
                  _buildTabItem(2, "Form Cues", Icons.lightbulb_outline),
                ],
              ),
            ),
          ),

          const Divider(color: CyberWorkoutTheme.borderSubtle, height: 16),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _selectedTab == 0
                  ? _buildExecutionGuide()
                  : _selectedTab == 1
                      ? _buildMuscleMap()
                      : _buildFormCues(),
            ),
          ),

          // Bottom Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberWorkoutTheme.goldPrimary,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "GOT IT, READY TO LIFT",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CyberWorkoutTheme.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : CyberWorkoutTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : CyberWorkoutTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animation Demo Box / Posture illustration
        Container(
          height: 170,
          width: double.infinity,
          decoration: CyberWorkoutTheme.glassCard(
            borderColor: CyberWorkoutTheme.borderGold,
            glow: true,
            glowColor: CyberWorkoutTheme.goldPrimary,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MuscleAnatomyVisualizer(
                    primaryMuscles: widget.primaryMuscles,
                    secondaryMuscles: widget.secondaryMuscles,
                    width: 100,
                    height: 140,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tempo Cadence",
                        style: TextStyle(
                          color: CyberWorkoutTheme.textGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "3-1-1-0",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "3s Eccentric · 1s Hold\n1s Explosive Push",
                        style: TextStyle(
                          color: CyberWorkoutTheme.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          "STEP-BY-STEP TECHNIQUE",
          style: TextStyle(
            color: CyberWorkoutTheme.textGold,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(widget.instructions.length, (idx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: CyberWorkoutTheme.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${idx + 1}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.instructions[idx],
                    style: const TextStyle(
                      color: CyberWorkoutTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMuscleMap() {
    return Column(
      children: [
        Center(
          child: MuscleAnatomyVisualizer(
            primaryMuscles: widget.primaryMuscles,
            secondaryMuscles: widget.secondaryMuscles,
            width: 180,
            height: 220,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(CyberWorkoutTheme.crimsonRed, "Primary Target (Max Strain)"),
            const SizedBox(width: 16),
            _buildLegendItem(CyberWorkoutTheme.goldPrimary, "Secondary Stabilizers"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFormCues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "COACHING CUES & COMMON MISTAKES",
          style: TextStyle(
            color: CyberWorkoutTheme.crimsonRed,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        ...widget.formTips.map((tip) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: CyberWorkoutTheme.glassCard(
              borderColor: CyberWorkoutTheme.crimsonRed.withOpacity(0.3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: CyberWorkoutTheme.goldPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: CyberWorkoutTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
