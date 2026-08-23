import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/routine_anatomy_screen.dart';

class MultiDayPlanScreen extends StatefulWidget {
  const MultiDayPlanScreen({
    super.key,
    this.planTitle = "Full Body",
    this.planDescription = "A weekly workout plan that schedules your routines day by day with progressive overload.",
    this.cycleDaysCount = 6,
  });

  final String planTitle;
  final String planDescription;
  final int cycleDaysCount;

  @override
  State<MultiDayPlanScreen> createState() => _MultiDayPlanScreenState();
}

class _MultiDayPlanScreenState extends State<MultiDayPlanScreen> {
  int _expandedDay = 1; // Day 1 expanded by default

  final List<Map<String, dynamic>> _planDays = [
    {
      "day": 1,
      "title": "Full-Body Day 1",
      "subtitle": "Full Body Day 1",
      "isRest": false,
      "isToday": true,
      "tag": "Full-B",
      "primaryMuscles": [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders, MuscleGroupTarget.quadriceps],
    },
    {
      "day": 2,
      "title": "Rest day",
      "subtitle": "Active Recovery",
      "isRest": true,
      "isToday": false,
      "tag": "Rest",
      "primaryMuscles": <MuscleGroupTarget>[],
    },
    {
      "day": 3,
      "title": "Full-Body Day 2",
      "subtitle": "Full Body Day 2",
      "isRest": false,
      "isToday": false,
      "tag": "Full-B",
      "primaryMuscles": [MuscleGroupTarget.upperBack, MuscleGroupTarget.lats, MuscleGroupTarget.hamstrings],
    },
    {
      "day": 4,
      "title": "Rest day",
      "subtitle": "Active Recovery",
      "isRest": true,
      "isToday": false,
      "tag": "Rest",
      "primaryMuscles": <MuscleGroupTarget>[],
    },
    {
      "day": 5,
      "title": "Full-Body Day 3",
      "subtitle": "Full Body Day 3",
      "isRest": false,
      "isToday": false,
      "tag": "Full-B",
      "primaryMuscles": [MuscleGroupTarget.chest, MuscleGroupTarget.biceps, MuscleGroupTarget.abs],
    },
    {
      "day": 6,
      "title": "Rest day",
      "subtitle": "Active Recovery",
      "isRest": true,
      "isToday": false,
      "tag": "Rest",
      "primaryMuscles": <MuscleGroupTarget>[],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Pills (Explore Plans > | Check Routines >)
                    _buildPillActions(),
                    const SizedBox(height: 16),

                    // Plan Overview Hero Card
                    _buildHeroPlanCard(),
                    const SizedBox(height: 16),

                    // Cycle Header & Reorder Button
                    _buildCycleHeader(),
                    const SizedBox(height: 16),

                    // This Week & Edit Banner
                    _buildThisWeekHeader(),
                    const SizedBox(height: 12),

                    // List of Days
                    ...List.generate(_planDays.length, (index) {
                      return _buildDayCard(_planDays[index]);
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: CyberWorkoutTheme.goldPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          ),
          const Text(
            "Workout Plan",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const Row(
            children: [
              Text(
                "Help",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(width: 2),
              Icon(Icons.help_outline, color: Colors.black, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: CyberWorkoutTheme.bgSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CyberWorkoutTheme.borderSubtle),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Explore Plans",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: CyberWorkoutTheme.bgSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CyberWorkoutTheme.borderSubtle),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Check Routines",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPlanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CyberWorkoutTheme.glassCard(
        borderColor: CyberWorkoutTheme.borderGold,
        glow: true,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Box
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.5)),
            ),
            child: const Center(
              child: MuscleAnatomyVisualizer(
                primaryMuscles: [MuscleGroupTarget.fullBody],
                width: 60,
                height: 75,
                isAnimated: false,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.planTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.planDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CyberWorkoutTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Show more",
                  style: TextStyle(
                    color: CyberWorkoutTheme.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: CyberWorkoutTheme.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildCycleHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.loop, color: CyberWorkoutTheme.goldPrimary, size: 16),
                const SizedBox(width: 8),
                Text(
                  "YOUR CYCLE · ${widget.cycleDaysCount} DAYS",
                  style: const TextStyle(
                    color: CyberWorkoutTheme.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C323B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pan_tool_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  "Reorder Days",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: CyberWorkoutTheme.goldPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "This Week",
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Row(
          children: [
            Text(
              "EDIT",
              style: TextStyle(
                color: CyberWorkoutTheme.goldPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.edit_outlined, color: CyberWorkoutTheme.goldPrimary, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayData) {
    final int dayNum = dayData['day'] as int;
    final bool isExpanded = _expandedDay == dayNum;
    final bool isRest = dayData['isRest'] as bool;
    final bool isToday = dayData['isToday'] as bool;
    final String tag = dayData['tag'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CyberWorkoutTheme.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? CyberWorkoutTheme.goldPrimary
              : CyberWorkoutTheme.borderSubtle,
          width: isToday ? 1.5 : 1.0,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Day Header
          ListTile(
            onTap: () {
              setState(() {
                _expandedDay = isExpanded ? -1 : dayNum;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DAY",
                  style: TextStyle(color: CyberWorkoutTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  "$dayNum",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  dayData['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: CyberWorkoutTheme.goldPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "TODAY",
                      style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              dayData['subtitle'] as String,
              style: const TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRest ? const Color(0xFF1E2D42) : const Color(0xFF332014),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRest ? const Color(0xFF3B7BBF) : const Color(0xFFCC5A1E),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isRest ? const Color(0xFF64B5F6) : const Color(0xFFFF8A65),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: CyberWorkoutTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),

          // Expanded Day Actions (for workout day)
          if (isExpanded && !isRest)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  // Routine Preview Banner (clickable -> opens RoutineAnatomyScreen)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RoutineAnatomyScreen(
                            routineTitle: dayData['title'] as String,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CyberWorkoutTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF13131A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MuscleAnatomyVisualizer(
                              primaryMuscles: dayData['primaryMuscles'] as List<MuscleGroupTarget>,
                              width: 36,
                              height: 40,
                              isAnimated: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dayData['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: CyberWorkoutTheme.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          const Icon(Icons.delete_outline, color: CyberWorkoutTheme.crimsonRed, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons (Change & Make Rest)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.styleFrom(
                          backgroundColor: CyberWorkoutTheme.goldPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ).buildChild(
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Change workout routine selected")),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_vert, color: Colors.black, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "Change",
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222834),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Make Rest",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
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
    );
  }
}

extension on ButtonStyle {
  Widget buildChild(Widget child) {
    return child;
  }
}
