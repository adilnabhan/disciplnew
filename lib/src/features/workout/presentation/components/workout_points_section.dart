import 'package:flutter/material.dart';
import 'package:customer_mobile_app/core/themes/app_colors.dart';
import 'package:customer_mobile_app/src/features/workout/domain/helpers/workout_points_helper.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/workout_points_arrow_animation.dart';

class WorkoutPointsSection extends StatefulWidget {
  final WorkoutPointsBreakdown breakdown;
  final VoidCallback? onReplayAnimation;

  const WorkoutPointsSection({
    super.key,
    required this.breakdown,
    this.onReplayAnimation,
  });

  @override
  State<WorkoutPointsSection> createState() => _WorkoutPointsSectionState();
}

class _WorkoutPointsSectionState extends State<WorkoutPointsSection> {
  bool _isExpanded = false;

  void _showHowPointsWorkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Discipl Workout Points Guide',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2022),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildGuideCategory(
                      title: '1. Workout Session Points (Max 40 XP / Day)',
                      items: [
                        '• Base Workout Completed: +30 points (requires ≥ 1 completed set)',
                        '• Exercise Count Bonus (≥ 3 exercises): +5 points',
                        '• Duration Bonus (≥ 45 minutes): +5 points',
                        'Note: Only 1 workout is scored per calendar day to prevent inflating.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideCategory(
                      title: '2. Streak & Consistency',
                      items: [
                        '• Daily Consecutive Workout: +10 points per active day',
                        '• Rest Day Grace: 1 rest day gap preserves your streak',
                        '• 7-Day Milestone: +25 points',
                        '• 14-Day Milestone: +50 points',
                        '• 30-Day Milestone: +150 points',
                        '• 50-Day Milestone: +250 points',
                        '• 100-Day Milestone: +600 points',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideCategory(
                      title: '3. Trainer Verification (+15 XP)',
                      items: [
                        '• When your mentor/trainer confirms your workout: +15 points',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideCategory(
                      title: '4. Health & Goal Milestones',
                      items: [
                        '• Daily Active Minutes Goal: +10 points',
                        '• Daily Calorie Burn Goal: +10 points',
                        '• Sharing Workout Completion Card: +15 points',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideCategory(
                      title: '5. Workout Challenges',
                      items: [
                        '• Join a Challenge: +50 points',
                        '• Complete a Challenge: +100 points',
                        '• Win a Challenge: +150 points',
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideCategory({
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2022),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no points earned, do NOT show the section
    if (!widget.breakdown.hasPoints || widget.breakdown.totalPoints <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Card
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Red Up Arrow Mini Icon
                  GestureDetector(
                    onTap: widget.onReplayAnimation,
                    child: Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Center(
                        child: WorkoutPointsArrowWidget(
                          points: 0,
                          arrowWidth: 18,
                          arrowHeight: 24,
                          arrowColor: AppColors.primary,
                          pointsTextStyle: TextStyle(fontSize: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Workout Points',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E2022),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _showHowPointsWorkSheet(context),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Max 40 session XP / day',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total Points Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFCF0B10),
                          Color(0xFFBA1A1A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '+${widget.breakdown.totalPoints} PTS',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Breakdown expansion
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: widget.breakdown.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          item.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E2022),
                                ),
                              ),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.isEarned
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isEarned
                                ? '+${item.points} pts'
                                : '- pts',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.isEarned
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
