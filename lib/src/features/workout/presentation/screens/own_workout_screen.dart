import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';

class OwnWorkoutScreen extends StatefulWidget {
  const OwnWorkoutScreen({super.key});

  @override
  State<OwnWorkoutScreen> createState() => _OwnWorkoutScreenState();
}

class _OwnWorkoutScreenState extends State<OwnWorkoutScreen> {
  final List<Map<String, dynamic>> _exercises = <Map<String, dynamic>>[
    <String, dynamic>{
      'title': 'Incline Bench Press',
      'subtitle': 'Chest / Barbell / Volume×Reps',
      'sets': <Map<String, dynamic>>[
        <String, dynamic>{
          'setNum': 1,
          'previous': '10kg×15',
          'kg': '10',
          'reps': '15',
          'checked': true,
        },
        <String, dynamic>{
          'setNum': 2,
          'previous': '10kg×15',
          'kg': '10',
          'reps': '15',
          'checked': true,
        },
        <String, dynamic>{
          'setNum': 3,
          'previous': '10kg×15',
          'kg': '12.5',
          'reps': '15',
          'checked': true,
        },
      ],
    },
  ];

  final List<Map<String, String>> _libraryExercises = [
    {
      'title': 'Flat Bench Dumbbell Press',
      'subtitle': 'Chest / Dumbbell / Volume×Reps',
    },
    {
      'title': 'Incline Dumbbell Press',
      'subtitle': 'Chest / Dumbbell / Volume×Reps',
    },
    {'title': 'Chest Fly', 'subtitle': 'Chest / Dumbbell / Volume×Reps'},
    {
      'title': 'Barbell Bench Press',
      'subtitle': 'Chest / Barbell / Volume×Reps',
    },
    {'title': 'Cable Crossover', 'subtitle': 'Chest / Cable / Volume×Reps'},
  ];

  final List<Map<String, String>> _customExercises = [];

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

  void _addExercise() {
    _showSelectWorkoutBottomSheet();
  }

  void _showSelectWorkoutBottomSheet() {
    final searchController = TextEditingController();
    String searchQuery = '';
    int currentTab = 0; // 0 = Library, 1 = You created

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setSheetState) {
                return Container(
                  height: MediaQuery.of(sheetContext).size.height * 0.7,
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Workout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 20 / 14,
                                color: Color(0xFF212121),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(sheetContext),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF212121),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: (v) {
                            setSheetState(() {
                              searchQuery = v;
                            });
                          },
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 24 / 14,
                            color: Color(0xFF212121),
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hintText: 'Search Workout',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 24 / 14,
                              color: Color(0xFF888888),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 16.0, right: 12.0),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF9E9E9E),
                                size: 24,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 52,
                              minHeight: 24,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      currentTab = 0;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          currentTab == 0
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow:
                                          currentTab == 0
                                              ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Library',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: currentTab == 0
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.5,
                                        letterSpacing: -0.41,
                                        color: currentTab == 0
                                            ? AppColors.button
                                            : const Color(0xFF444444),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      currentTab = 1;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          currentTab == 1
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow:
                                          currentTab == 1
                                              ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'You created',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: currentTab == 1
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.5,
                                        letterSpacing: -0.41,
                                        color: currentTab == 1
                                            ? AppColors.button
                                            : const Color(0xFF444444),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: currentTab == 0
                                  ? _buildExerciseTabList(
                                      context: sheetContext,
                                      exercises: _libraryExercises,
                                      searchQuery: searchQuery,
                                      setSheetState: setSheetState,
                                    )
                                  : _buildExerciseTabList(
                                      context: sheetContext,
                                      exercises: _customExercises,
                                      searchQuery: searchQuery,
                                      setSheetState: setSheetState,
                                    ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 40,
                              child: PrimaryPillButton(
                                text: '+ Create new Exercise',
                                onTap: () {
                                  _showCreateCustomExerciseBottomSheet(
                                    context,
                                    setSheetState,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseTabList({
    required BuildContext context,
    required List<Map<String, String>> exercises,
    required String searchQuery,
    required StateSetter setSheetState,
  }) {
    final filteredList =
        exercises
            .where(
              (item) => item['title']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'No exercises found',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 84),
      itemCount: filteredList.length,
      itemBuilder: (itemContext, index) {
        final item = filteredList[index];
        final isAdded = _exercises.any(
          (e) =>
              e['title'].toString().toLowerCase() ==
              item['title']!.toLowerCase(),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAdded ? AppColors.primary : const Color(0xFFF0F0F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdded ? const Color(0xFFFFF4F4) : AppColors.primary,
                  foregroundColor: isAdded ? AppColors.primary : Colors.white,
                  elevation: 0,
                  side: isAdded
                      ? const BorderSide(color: Color(0xFFF0B5B7))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed:
                    isAdded
                        ? () {}
                        : () {
                          setState(() {
                            _exercises.add(<String, dynamic>{
                              'title': item['title']!,
                              'subtitle': item['subtitle']!,
                              'sets': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'setNum': 1,
                                  'previous': '10kg×15',
                                  'kg': '10',
                                  'reps': '15',
                                  'checked': false,
                                },
                              ],
                            });
                          });
                          setSheetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Adding exercise...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                child: Text(isAdded ? 'Added' : 'Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateCustomExerciseBottomSheet(
    BuildContext context,
    StateSetter setSheetState,
  ) {
    final nameController = TextEditingController();
    final youtubeLinkController = TextEditingController();
    String? selectedMuscle;
    String? selectedType;
    String? selectedEquipment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Container(
                  height: MediaQuery.of(sheetContext).size.height * 0.7,
                  padding: const EdgeInsets.only(top: 24),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        'Create new Workout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 20 / 14,
                          color: AppColors.button,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Workout Name
                      RichText(
                        text: const TextSpan(
                          text: 'Workout Name',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: AppColors.button,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: 'Enter workout name',
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: Color(0xFF888888),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Muscle
                      const Text(
                        'Muscle',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedMuscle,
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                        ),
                        hint: const Text(
                          'Select the muscle',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: Color(0xFF888888),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF9E9E9E),
                        ),
                        items:
                            [
                                  'Chest',
                                  'Back',
                                  'Legs',
                                  'Shoulders',
                                  'Arms',
                                  'Abs',
                                  'Cardio',
                                ]
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        height: 1.0,
                                        letterSpacing: -0.3,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedMuscle = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Type
                      const Text(
                        'Type',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                        ),
                        hint: const Text(
                          'Select the type of exercise',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: Color(0xFF888888),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF9E9E9E),
                        ),
                        items:
                            ['Volume×Reps', 'Reps Only', 'Time Only']
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        height: 1.0,
                                        letterSpacing: -0.3,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Equipment
                      const Text(
                        'Equipment',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedEquipment,
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                        ),
                        hint: const Text(
                          'Select the equipment used',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: Color(0xFF888888),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF9E9E9E),
                        ),
                        items:
                            [
                                  'Dumbbell',
                                  'Barbell',
                                  'Machine',
                                  'Cables',
                                  'Bodyweight',
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        height: 1.0,
                                        letterSpacing: -0.3,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedEquipment = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Youtube Link
                      const Text(
                        'Youtube Link',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: youtubeLinkController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.0,
                          letterSpacing: -0.3,
                          color: AppColors.button,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: 'Paste the youtube link of exercise video',
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.0,
                            letterSpacing: -0.3,
                            color: Color(0xFF888888),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              final data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              if (data?.text != null) {
                                youtubeLinkController.text = data!.text!;
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(
                                Icons.content_paste_outlined,
                                color: Color(0xFF212121),
                                size: 20,
                              ),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),

                      // Create Exercise Button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            final name = nameController.text.trim();
                            final muscle = selectedMuscle ?? 'Chest';
                            final equipment = selectedEquipment ?? 'Dumbbell';
                            final type = selectedType ?? 'Volume×Reps';

                            if (name.isNotEmpty) {
                              final newExercise = {
                                'title': name,
                                'subtitle': '$muscle / $equipment / $type',
                              };

                              setState(() {
                                _customExercises.add(newExercise);
                                _exercises.add(<String, dynamic>{
                                  'title': name,
                                  'subtitle': '$muscle / $equipment / $type',
                                  'sets': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'setNum': 1,
                                      'previous': '10kg×15',
                                      'kg': '10',
                                      'reps': '15',
                                      'checked': false,
                                    },
                                  ],
                                });
                              });
                              setSheetState(() {});
                              Navigator.pop(sheetContext);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a workout name'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 301,
                            height: 39,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 5.3,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Create Exercise',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  height: 1.0,
                                  letterSpacing: -0.3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                 ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total count of exercises across all cards
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
                          'Chest Exercise Plan 1',
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

                  const SizedBox(height: 18),

                  // + Add Workout Button
                  _buildOutlineRedButton(
                    text: '+ Add Workout',
                    onTap: _addExercise,
                  ),

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
                // Play button icon (custom miniature YouTube icon)
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
