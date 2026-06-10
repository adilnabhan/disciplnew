import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout_log/cubit/cubit.dart';
import 'package:customer_mobile_app/src/features/workout_log/persentation/screens/workout_plans_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  DateTime _selectedDate = DateTime.now();
  late final WorkoutLogCubit _cubit;
  final ScrollController _scrollController = ScrollController();


  List<bool> expandedList = [];

  @override
  void initState() {
    super.initState();
    _cubit = WorkoutLogCubit();
    _fetch();
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    // await _cubit.fetchPaymentHistory();
    // await _cubit.fetchPaymentHistoryDetails();
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Workout Log'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Date Strip
            _DateStrip(selectedDate: _selectedDate, onDateChange: _changeDate),
            const SizedBox(height: 30),

            // Card 1: Back Exercise (Complex layout with image/inner card)
            _ComplexWorkoutCard(
              number: "1",
              title: "Back\nExercise",
              subtitle: "Day 3/30",
              isCompleted: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPlansScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Card 2: Abs Workout (Simple layout)
            _SimpleWorkoutCard(
              number: "2",
              title: "Abs\nWorkout",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;

  const _DateStrip({required this.selectedDate, required this.onDateChange});

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(5, (index) {
      return selectedDate.add(Duration(days: index - 2));
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.grey),
              onPressed:
                  () => onDateChange(
                    selectedDate.subtract(const Duration(days: 1)),
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('d MMM yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.grey),
              onPressed:
                  () => onDateChange(selectedDate.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
              dates.map((date) {
                final isSelected = DateUtils.isSameDay(date, selectedDate);
                return GestureDetector(
                  onTap: () => onDateChange(date),
                  child: _DateItem(
                    day: DateFormat('d').format(date),
                    weekday: DateFormat('E').format(date),
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  final String day;
  final String weekday;
  final bool isSelected;

  const _DateItem({
    required this.day,
    required this.weekday,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: isSelected ? 86 : 64, // Active is visibly taller
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFC00000) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFFC00000).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            weekday,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComplexWorkoutCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ComplexWorkoutCard({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 160,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Layer (Image + Color)
            Container(
              decoration: BoxDecoration(
                // Simulating the beige/brown background from the image
                color: const Color(0xFFDCC8BC),
                borderRadius: BorderRadius.circular(24),
                // In a real app, you would add the wolf image here:
                // image: DecorationImage(image: AssetImage('...'), fit: BoxFit.cover),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                // Placeholder for the wolf image positioned right
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Inner White Card
            Positioned(
              left: 12,
              top: 12,
              bottom: 12,
              width:
                  MediaQuery.of(context).size.width *
                  0.42, // Approx width from image
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Floating elements on the right side
            Positioned(
              right: 16,
              bottom: 24,
              child: Row(
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark Badge
            if (isCompleted)
              Positioned(
                top: -6,
                right: 12,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2), // White border
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

class _SimpleWorkoutCard extends StatelessWidget {
  final String number;
  final String title;
  final VoidCallback onTap;

  const _SimpleWorkoutCard({
    required this.number,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // Grey background
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.chevron_right, size: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
