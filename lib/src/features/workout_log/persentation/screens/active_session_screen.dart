import 'package:flutter/material.dart';

class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({super.key});

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
              children: [
                _ActiveExerciseCard(
                  number: "1",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                  sets: const [
                    _SetData(
                      set: 1,
                      prev: "10kg×15",
                      kg: "10",
                      rep: "15",
                      isChecked: true,
                    ),
                    _SetData(
                      set: 2,
                      prev: "10kg×15",
                      kg: "10",
                      rep: "15",
                      isChecked: true,
                    ),
                    _SetData(
                      set: 3,
                      prev: "10kg×15",
                      kg: "12.5",
                      rep: "15",
                      isChecked: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ActiveExerciseCard(
                  number: "2",
                  title: "Incline Bench Press",
                  subtitle: "Chest / Barbell / Volume×Reps",
                  sets: const [
                    _SetData(
                      set: 1,
                      prev: "no previous",
                      kg: "10",
                      rep: "15",
                      isChecked: true,
                    ),
                    _SetData(
                      set: 2,
                      prev: "no previous",
                      kg: "10",
                      rep: "15",
                      isChecked: true,
                    ),
                    _SetData(
                      set: 3,
                      prev: "no previous",
                      kg: "0",
                      rep: "0",
                      isChecked: false,
                      isCurrent: true,
                    ), // Placeholder for active input
                  ],
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC00000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Finish",
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

class _SetData {
  final int set;
  final String prev;
  final String kg;
  final String rep;
  final bool isChecked;
  final bool isCurrent;

  const _SetData({
    required this.set,
    required this.prev,
    required this.kg,
    required this.rep,
    required this.isChecked,
    this.isCurrent = false,
  });
}

class _ActiveExerciseCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final List<_SetData> sets;

  const _ActiveExerciseCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.sets,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$number. $title",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Icon(
                Icons.video_library_outlined,
                color: Colors.red,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Table Headers
          Row(
            children: const [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "Set",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "Previous",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    "kg",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    "Rep",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(child: Icon(Icons.check, size: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sets
          ...sets.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "${s.set}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        s.prev,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          s.kg,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          s.rep,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child:
                          s.isChecked
                              ? Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC00000),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              )
                              : Icon(
                                Icons.check,
                                color: Colors.grey.withOpacity(0.3),
                                size: 18,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Add Set Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "+ Add a Set",
                style: TextStyle(
                  color: Color(0xFFC00000),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
