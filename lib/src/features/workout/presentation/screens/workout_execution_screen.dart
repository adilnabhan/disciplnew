import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final WorkoutModel workoutModel;

  const WorkoutExecutionScreen({
    required this.workoutModel,
    super.key,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  late final List<Map<String, dynamic>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = List.generate(widget.workoutModel.exerciseCount, (index) {
      final title = index == 0
          ? 'Incline Bench Press'
          : (index == 1 ? 'Flat Bench Press' : (index == 2 ? 'Chest Fly' : 'Cable Crossover'));
      final subtitle = index % 2 == 0
          ? 'Chest / Barbell / Volume×Reps'
          : 'Chest / Dumbbell / Volume×Reps';
      return <String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'sets': <Map<String, dynamic>>[
          <String, dynamic>{
            'setNum': 1,
            'previous': index == 0 ? '10kg×15' : 'no data',
            'kg': '10',
            'reps': '15',
            'checked': true,
          },
          <String, dynamic>{
            'setNum': 2,
            'previous': index == 0 ? '10kg×15' : 'no data',
            'kg': '10',
            'reps': '15',
            'checked': true,
          },
          <String, dynamic>{
            'setNum': 3,
            'previous': index == 0 ? '10kg×15' : 'no data',
            'kg': index == 0 ? '12.5' : '0',
            'reps': index == 0 ? '15' : '0',
            'checked': index == 0 ? true : false,
          },
        ],
      };
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final List<Map<String, dynamic>> sets = List<Map<String, dynamic>>.from(
        _exercises[exerciseIndex]['sets'] as List,
      );
      final lastSet = sets.isNotEmpty ? sets.last : null;
      final newSetNum = sets.length + 1;

      sets.add(<String, dynamic>{
        'setNum': newSetNum,
        'previous':
            lastSet != null
                ? '${lastSet['kg']}kg×${lastSet['reps']}'
                : '10kg×15',
        'kg': lastSet != null ? lastSet['kg'] : '10',
        'reps': lastSet != null ? lastSet['reps'] : '15',
        'checked': false,
      });
      _exercises[exerciseIndex]['sets'] = sets;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalExercises = _exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
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
                          '${widget.workoutModel.title} Plan ${widget.workoutModel.day}',
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
                    ),
                    child: Text(
                      '$totalExercises Exercises',
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

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  // Exercise list
                  ...List.generate(_exercises.length, (exerciseIndex) {
                    final exercise = _exercises[exerciseIndex];
                    return _buildExerciseCard(exercise, exerciseIndex);
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom Finish Button Container
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 24,
                top: 12,
              ),
              child: PrimaryPillButton(
                text: 'Finish',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int exerciseIndex) {
    final sets = exercise['sets'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row of the card
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${exerciseIndex + 1}. ${exercise['title']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exercise['subtitle'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play button icon
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Playing exercise demonstration video...',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD30C15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Table header row
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Set',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'kg',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Rep',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Sets list rows
          ...List.generate(sets.length, (setIndex) {
            final set = sets[setIndex];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Set index
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${set['setNum']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                      ),
                      // Previous value
                      Expanded(
                        flex: 3,
                        child: Text(
                          set['previous'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                      ),
                      // kg Input Box
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: set['kg'] as String?,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF212121),
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) {
                                set['kg'] = val;
                              },
                            ),
                          ),
                        ),
                      ),
                      // Rep Input Box
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: set['reps'] as String?,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF212121),
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) {
                                set['reps'] = val;
                              },
                            ),
                          ),
                        ),
                      ),
                      // Check checkbox button
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                set['checked'] =
                                    !(set['checked'] as bool? ?? false);
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color:
                                    (set['checked'] as bool? ?? false)
                                        ? AppColors.primary
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color:
                                      (set['checked'] as bool? ?? false)
                                          ? AppColors.primary
                                          : const Color(0xFFCCCCCC),
                                  width: 1.5,
                                ),
                              ),
                              child:
                                  (set['checked'] as bool? ?? false)
                                      ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F1F1)),
              ],
            );
          }),

          const SizedBox(height: 16),

          // Add a Set Button inside the card
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: _buildOutlineRedButton(
              text: '+ Add a Set',
              onTap: () => _addSet(exerciseIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineRedButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0B5B7), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              offset: Offset(0, 1),
              blurRadius: 5.3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
