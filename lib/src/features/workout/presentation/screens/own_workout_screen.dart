import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/workout.dart';

class OwnWorkoutScreen extends StatefulWidget {
  const OwnWorkoutScreen({super.key});

  @override
  State<OwnWorkoutScreen> createState() => _OwnWorkoutScreenState();
}

class _OwnWorkoutScreenState extends State<OwnWorkoutScreen> {
  late final WorkoutCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = WorkoutCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _addSet(int exerciseIndex) {
    _cubit.addSet(exerciseIndex);
  }

  void _addExercise() {
    _showSelectWorkoutBottomSheet();
  }

  void _showSelectWorkoutBottomSheet() {
    final searchController = TextEditingController();
    String searchQuery = '';
    int currentTab = 0; // 0 = Library, 1 = You created
    _cubit.loadLibraryExercises();

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
                return BlocBuilder<WorkoutCubit, WorkoutState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    return Container(
                      height: MediaQuery.of(sheetContext).size.height * 0.7,
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Select Workout',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: (v) {
                                setSheetState(() {
                                  searchQuery = v;
                                });
                                EasyDebounce.debounce(
                                  'workout_search_debouncer',
                                  const Duration(milliseconds: 500),
                                  () {
                                    if (currentTab == 0) {
                                      _cubit.loadLibraryExercises(search: v);
                                    } else {
                                      _cubit.loadCustomExercises(search: v);
                                    }
                                  },
                                );
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
                                  padding: EdgeInsets.only(
                                    left: 16.0,
                                    right: 12.0,
                                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
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
                                        _cubit.loadLibraryExercises(search: searchController.text);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              currentTab == 0
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow:
                                              currentTab == 0
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Library',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight:
                                                currentTab == 0
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            fontSize: 14,
                                            height: 1.5,
                                            letterSpacing: -0.41,
                                            color:
                                                currentTab == 0
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
                                        _cubit.loadCustomExercises(search: searchController.text);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              currentTab == 1
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow:
                                              currentTab == 1
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'You created',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight:
                                                currentTab == 1
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            fontSize: 14,
                                            height: 1.5,
                                            letterSpacing: -0.41,
                                            color:
                                                currentTab == 1
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
                                  child:
                                      currentTab == 0
                                          ? _buildExerciseTabList(
                                            context: sheetContext,
                                            exercises: state.libraryExercises,
                                            searchQuery: searchQuery,
                                            setSheetState: setSheetState,
                                            localFilter: false,
                                            showCreateButton: false,
                                          )
                                          : _buildExerciseTabList(
                                            context: sheetContext,
                                            exercises: state.customExercises,
                                            searchQuery: searchQuery,
                                            setSheetState: setSheetState,
                                            localFilter: true,
                                            showCreateButton: true,
                                          ),
                                ),
                                if (currentTab == 1)
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
                                          onCreated: () {
                                            setSheetState(() {
                                              currentTab = 1;
                                              searchController.clear();
                                              searchQuery = '';
                                            });
                                          },
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
    required bool localFilter,
    required bool showCreateButton,
  }) {
    final filteredList =
        localFilter
            ? exercises
                .where(
                  (item) => item['title']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                )
                .toList()
            : exercises;

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'No exercises found',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: showCreateButton ? 84 : 24,
      ),
      itemCount: filteredList.length,
      itemBuilder: (itemContext, index) {
        final item = filteredList[index];
        final isAdded = _cubit.state.exercises.any(
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
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAdded ? const Color(0xFFFFF4F4) : AppColors.primary,
                  foregroundColor: isAdded ? AppColors.primary : Colors.white,
                  elevation: 0,
                  side:
                      isAdded
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
                          _cubit.addExercise(item['title']!, item['subtitle']!);
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
    StateSetter setSheetState, {
    VoidCallback? onCreated,
  }) {
    final nameController = TextEditingController();
    final youtubeLinkController = TextEditingController();
    int? selectedMuscleId;
    String? selectedTypeCode;
    int? selectedEquipmentId;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return BlocBuilder<WorkoutCubit, WorkoutState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    if (state.isLoadingLookups) {
                      return Container(
                        height: MediaQuery.of(sheetContext).size.height * 0.4,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Form(
                      key: formKey,
                      child: Container(
                        height: MediaQuery.of(sheetContext).size.height * 0.7,
                      padding: const EdgeInsets.only(top: 24),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(sheetContext),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: AppColors.button,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                              ],
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
                            TextFormField(
                              controller: nameController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                height: 1.0,
                                letterSpacing: -0.3,
                                color: AppColors.button,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required this field';
                                }
                                return null;
                              },
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
                            DropdownButtonFormField<int>(
                              value: selectedMuscleId,
                              validator: (val) {
                                if (val == null) {
                                  return 'Required this field';
                                }
                                return null;
                              },
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
                              items: state.muscleGroups
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(
                                        m.name,
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
                                  selectedMuscleId = val;
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
                              value: selectedTypeCode,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required this field';
                                }
                                return null;
                              },
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
                              items: state.exerciseTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(
                                        t.name,
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
                                  selectedTypeCode = val;
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
                            DropdownButtonFormField<int>(
                              value: selectedEquipmentId,
                              validator: (val) {
                                if (val == null) {
                                  return 'Required this field';
                                }
                                return null;
                              },
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
                              items: state.equipment
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(
                                        e.name,
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
                                  selectedEquipmentId = val;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // Youtube Link
                            Text.rich(
                              const TextSpan(
                                text: 'Youtube Link ',
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
                                    text: '(Optional)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ],
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
                                hintText:
                                    'Paste the youtube link of exercise video',
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
                                onTap: state.isCreatingExercise
                                    ? null
                                    : () {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }
                                        final name = nameController.text.trim();
                                        _cubit.createCustomExercise(
                                          name: name,
                                          muscleGroupId: selectedMuscleId!,
                                          equipmentId: selectedEquipmentId!,
                                          type: selectedTypeCode!,
                                          videoUrl: youtubeLinkController.text.trim(),
                                          onComplete: (success, message) {
                                            if (success) {
                                              sheetNavigator.pop();
                                              onCreated?.call();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(message)),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(message)),
                                              );
                                            }
                                          },
                                        );
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
                                  child: Center(
                                    child: state.isCreatingExercise
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
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
                    ),
                  );
                  },
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
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      bloc: _cubit,
      builder: (context, state) {
        int totalExercises = state.exercises.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // Custom App Bar / Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                          if (totalExercises > 0)
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
                      if (totalExercises > 0) ...[
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
                    ],
                  ),
                ),

                // Scrollable Content or Empty State
                if (totalExercises == 0)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Start your First Workout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add exercises from the library or your custom list to customize your workout session.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildOutlineRedButton(
                              text: '+ Add Workout',
                              onTap: _addExercise,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      children: [
                        // Exercise list
                        ...List.generate(state.exercises.length, (
                          exerciseIndex,
                        ) {
                          final exercise = state.exercises[exerciseIndex];
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
              ],
            ),
          ),
        );
      },
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
                              key: ValueKey('${exerciseIndex}_${setIndex}_kg'),
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
                                _cubit.updateSetKg(
                                  exerciseIndex,
                                  setIndex,
                                  val,
                                );
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
                              key: ValueKey(
                                '${exerciseIndex}_${setIndex}_reps',
                              ),
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
                                _cubit.updateSetReps(
                                  exerciseIndex,
                                  setIndex,
                                  val,
                                );
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
                              _cubit.toggleSetChecked(exerciseIndex, setIndex);
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
