import 'package:flutter/material.dart';
import 'plan_overview_screen.dart';

class WorkoutPlansScreen extends StatelessWidget {
  const WorkoutPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Workout Plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            radius: 20,
            child: const BackButton(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for plan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Muscle Gain",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("30 days", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Color(0xFFFF5252),
                  ),
                  label: const Text(
                    "Sort",
                    style: TextStyle(color: Color(0xFFFF5252)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _PlanDayItem(
                  day: "1",
                  title: "Chest Exercise",
                  exercises: "4",
                  isCompleted: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanOverviewScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _PlanDayItem(
                  day: "2",
                  title: "Triceps Exercise",
                  exercises: "4",
                  isCompleted: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanOverviewScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _PlanDayItem(
                  day: "3",
                  title: "Back Exercise",
                  exercises: "4",
                  isSelected: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanOverviewScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _PlanDayItem(
                  day: "10",
                  title: "Biceps Exercise",
                  exercises: "4",
                  isCompleted: false,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _PlanDayItem(
                  day: "30",
                  title: "Shoulder Exercise",
                  exercises: "4",
                  isCompleted: false,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDayItem extends StatelessWidget {
  final String day;
  final String title;
  final String exercises;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PlanDayItem({
    required this.day,
    required this.title,
    required this.exercises,
    this.isSelected = false,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 85,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFFFF5252)
                          : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(0xFFFF5252).withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : [],
              ),
              child: Row(
                children: [
                  // Day Box
                  SizedBox(
                    width: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Day",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isSelected
                                    ? const Color(0xFFC00000)
                                    : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? const Color(0xFFC00000)
                                    : Colors.black,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    color:
                        isSelected
                            ? const Color(0xFFFF5252)
                            : Colors.grey.shade300,
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "No of Exercises: $exercises",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menu Icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark Badge (Floating)
            if (isCompleted)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(2), // White border effect
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Color(0xFFFF5252),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
