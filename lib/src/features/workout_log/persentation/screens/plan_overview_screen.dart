import 'package:flutter/material.dart';
import 'active_session_screen.dart';

class PlanOverviewScreen extends StatelessWidget {
  const PlanOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chest Exercise Plan 1'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("4 Exercises", style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ExerciseListItem(
                  index: "1",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                ),
                SizedBox(height: 12),
                _ExerciseListItem(
                  index: "2",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                ),
                SizedBox(height: 12),
                _ExerciseListItem(
                  index: "3",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                ),
                SizedBox(height: 12),
                _ExerciseListItem(
                  index: "4",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActiveSessionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC00000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Start Workout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;

  const _ExerciseListItem({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            index,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(width: 2, height: 40, color: Colors.grey.shade200),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
