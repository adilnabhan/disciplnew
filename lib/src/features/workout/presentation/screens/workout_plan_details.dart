import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_execution_screen.dart';
class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({
    required this.workoutModel,
    super.key, 
    });
  final WorkoutModel workoutModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          '${workoutModel.title} Plan ${workoutModel.day}',
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
                    ), // button width (40) + gap (11)
                    child: Text(
                      '${workoutModel.exerciseCount} Exercises',
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

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: workoutModel.exerciseCount,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return Exercisecard(index: index + 1);
                },
              ),
            ),

            // Start Workout Button Container
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 24,
                top: 12,
              ),
              child: PrimaryPillButton(
                text: 'Start Workout',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutExecutionScreen(
                        workoutModel: workoutModel,
                      ),
                    ),
                  );
                },
              ),
            ),
            ],
          ),
        ),
      );
    }
  }

class Exercisecard extends StatelessWidget {
  const Exercisecard({
    required this.index,
    super.key, 
    });
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              border: Border(
                left: BorderSide(color: Color(0xFF8E8E93),),
                top: BorderSide(color: Color(0xFF8E8E93)),
                right: BorderSide(color: Color(0xFF8E8E93),),
                bottom: BorderSide(color: Color(0xFF8E8E93),),
              ),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 35,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          const Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incline bench Press',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0,
                letterSpacing: 0.0,
                color: Color(0xFF1C1C1E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'chest / Barbell / Volume*Reps',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
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
