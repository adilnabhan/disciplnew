import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipmentAnatomyGuideModal extends StatefulWidget {
  final String exerciseName;
  final String targetMuscle;
  final String equipment;
  final String? videoUrl;
  final List<String> instructions;
  final List<String> formTips;

  const EquipmentAnatomyGuideModal({
    super.key,
    required this.exerciseName,
    required this.targetMuscle,
    required this.equipment,
    this.videoUrl,
    this.instructions = const [],
    this.formTips = const [],
  });

  static void show(
    BuildContext context, {
    required String exerciseName,
    required String targetMuscle,
    required String equipment,
    String? videoUrl,
    List<String> instructions = const [],
    List<String> formTips = const [],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EquipmentAnatomyGuideModal(
        exerciseName: exerciseName,
        targetMuscle: targetMuscle,
        equipment: equipment,
        videoUrl: videoUrl,
        instructions: instructions,
        formTips: formTips,
      ),
    );
  }

  @override
  State<EquipmentAnatomyGuideModal> createState() => _EquipmentAnatomyGuideModalState();
}

class _EquipmentAnatomyGuideModalState extends State<EquipmentAnatomyGuideModal>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: 3D Equipment & Muscles, 1: Step-by-Step, 2: Cadence / Tempo
  late AnimationController _cadenceController;
  int _cadencePhase = 0; // 0: Eccentric (3s), 1: Isometric (1s), 2: Concentric (1s)

  final List<String> _cadenceLabels = [
    "1. LOWER WEIGHT (ECCENTRIC - 3s)",
    "2. HOLD & SQUEEZE (ISOMETRIC - 1s)",
    "3. DRIVE UPWARD (CONCENTRIC - 1s)",
  ];

  @override
  void initState() {
    super.initState();
    _cadenceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _cadenceController.addListener(() {
      final val = _cadenceController.value;
      int phase;
      if (val < 0.6) {
        phase = 0; // 3 seconds
      } else if (val < 0.8) {
        phase = 1; // 1 second
      } else {
        phase = 2; // 1 second
      }
      if (phase != _cadencePhase && mounted) {
        setState(() => _cadencePhase = phase);
      }
    });
  }

  @override
  void dispose() {
    _cadenceController.dispose();
    super.dispose();
  }

  List<MuscleGroupTarget> _getMuscleTargets() {
    final m = widget.targetMuscle.toLowerCase();
    if (m.contains("chest") || m.contains("pec")) return [MuscleGroupTarget.chest];
    if (m.contains("back") || m.contains("lat")) return [MuscleGroupTarget.upperBack, MuscleGroupTarget.lats];
    if (m.contains("shoulder") || m.contains("delt")) return [MuscleGroupTarget.shoulders];
    if (m.contains("bicep") || m.contains("arm")) return [MuscleGroupTarget.biceps];
    if (m.contains("tricep")) return [MuscleGroupTarget.triceps];
    if (m.contains("leg") || m.contains("quad") || m.contains("squat")) return [MuscleGroupTarget.quadriceps];
    if (m.contains("hamstring") || m.contains("glute")) return [MuscleGroupTarget.hamstrings];
    if (m.contains("abs") || m.contains("core")) return [MuscleGroupTarget.abs];
    return [MuscleGroupTarget.fullBody];
  }

  IconData _getEquipmentIcon() {
    final eq = widget.equipment.toLowerCase();
    if (eq.contains("barbell")) return Icons.fitness_center;
    if (eq.contains("dumbbell")) return Icons.sports_gymnastics;
    if (eq.contains("cable")) return Icons.cable;
    if (eq.contains("machine")) return Icons.settings_suggest;
    return Icons.accessibility_new;
  }

  @override
  Widget build(BuildContext context) {
    final primaryMuscles = _getMuscleTargets();
    final List<String> defaultInstructions = widget.instructions.isNotEmpty
        ? widget.instructions
        : [
            "Assume stable starting stance with core braced.",
            "Grip the ${widget.equipment.isEmpty ? 'weights' : widget.equipment} firmly and establish proper alignment.",
            "Lower with control over 3 seconds to feel maximum muscle stretch.",
            "Powerfully contract the ${widget.targetMuscle} to return to starting position.",
          ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: CyberWorkoutTheme.bgVoid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: CyberWorkoutTheme.goldPrimary, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: CyberWorkoutTheme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: CyberWorkoutTheme.crimsonRed.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.6)),
                            ),
                            child: Text(
                              widget.targetMuscle.toUpperCase(),
                              style: const TextStyle(
                                color: CyberWorkoutTheme.crimsonRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(_getEquipmentIcon(), color: CyberWorkoutTheme.goldPrimary, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  widget.equipment.toUpperCase(),
                                  style: const TextStyle(
                                    color: CyberWorkoutTheme.goldPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(widget.videoUrl!);
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0000),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "VIDEO",
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: CyberWorkoutTheme.bgCardGlass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CyberWorkoutTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  _buildTab(0, "3D Anatomy & Gear"),
                  _buildTab(1, "Step-by-Step"),
                  _buildTab(2, "Cadence & Tempo"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _activeTab == 0
                  ? _buildAnatomyAndGearTab(primaryMuscles)
                  : _activeTab == 1
                      ? _buildStepByStepTab(defaultInstructions)
                      : _buildCadenceTab(),
            ),
          ),

          // Bottom Close CTA
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberWorkoutTheme.goldPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "GOT IT — LET'S WORKOUT",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? CyberWorkoutTheme.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : CyberWorkoutTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnatomyAndGearTab(List<MuscleGroupTarget> primaryMuscles) {
    return Column(
      children: [
        // 3D Equipment Graphic Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CyberWorkoutTheme.glassCard(),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22222E), Color(0xFF14141C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(_getEquipmentIcon(), color: CyberWorkoutTheme.goldPrimary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REQUIRED EQUIPMENT",
                      style: TextStyle(
                        color: CyberWorkoutTheme.goldPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.equipment.isEmpty ? "Standard Gym Setup" : widget.equipment,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Targeting ${widget.targetMuscle} activation with strict form.",
                      style: const TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Glowing Muscle Anatomy Visualizer Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CyberWorkoutTheme.glassCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TARGET MUSCLE HEATMAP",
                    style: TextStyle(
                      color: CyberWorkoutTheme.crimsonRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: CyberWorkoutTheme.crimsonRed, size: 8),
                      SizedBox(width: 4),
                      Text("Active Strain", style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: MuscleAnatomyVisualizer(
                  primaryMuscles: primaryMuscles,
                  width: 140,
                  height: 180,
                  isAnimated: true,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13131C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                  ),
                  child: Text(
                    "PRIMARY LOAD: ${widget.targetMuscle.toUpperCase()}",
                    style: const TextStyle(
                      color: CyberWorkoutTheme.goldPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepByStepTab(List<String> instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < instructions.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: CyberWorkoutTheme.glassCard(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: CyberWorkoutTheme.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${i + 1}",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    instructions[i],
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCadenceTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CyberWorkoutTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "REPETITION CADENCE / TEMPO (3 - 1 - 1)",
            style: TextStyle(
              color: CyberWorkoutTheme.goldPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Follow the animated cadence guide below to maximize muscle tension and hypertrophy.",
            style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Animated Cadence Display Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 10,
              color: const Color(0xFF1E1E2C),
              child: AnimatedBuilder(
                animation: _cadenceController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _cadenceController.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CyberWorkoutTheme.crimsonRed,
                            CyberWorkoutTheme.goldPrimary,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active Phase Callout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _cadencePhase == 0
                    ? CyberWorkoutTheme.crimsonRed
                    : CyberWorkoutTheme.goldPrimary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _cadencePhase == 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: _cadencePhase == 0 ? CyberWorkoutTheme.crimsonRed : CyberWorkoutTheme.goldPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _cadenceLabels[_cadencePhase],
                    style: TextStyle(
                      color: _cadencePhase == 0 ? CyberWorkoutTheme.crimsonRed : CyberWorkoutTheme.goldPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
