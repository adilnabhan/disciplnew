import 'dart:async';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/workout.dart';

class OwnWorkoutScreen extends StatefulWidget {
  final bool isNewSession;
  final bool isPresetCreation;
  final PresetModel? presetToEdit;
  final PresetCubit? presetCubit;
  final PresetModel? presetToStart;

  const OwnWorkoutScreen({
    super.key,
    this.isNewSession = false,
    this.isPresetCreation = false,
    this.presetToEdit,
    this.presetCubit,
    this.presetToStart,
  });

  @override
  State<OwnWorkoutScreen> createState() => _OwnWorkoutScreenState();
}

class _OwnWorkoutScreenState extends State<OwnWorkoutScreen> {
  late final WorkoutCubit _cubit;
  late final TextEditingController _titleController;
  late final FocusNode _titleFocusNode;
  bool _isFinishing = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _cubit = WorkoutCubit(
      startFresh: widget.isPresetCreation ? false : widget.isNewSession,
      presetToStart: widget.presetToStart,
    );
    _titleController = TextEditingController();
    _titleFocusNode = FocusNode();

    if (widget.isPresetCreation) {
      if (widget.presetToEdit != null) {
        _titleController.text = widget.presetToEdit!.title;
        _cubit.loadPreset(widget.presetToEdit!);
      } else {
        _titleController.text = '';
        // Post frame callback or inline is fine, but we can update state title
        _cubit.emit(_cubit.state.copyWith(exercises: [], sessionTitle: ''));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _timer?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _syncTimer() {
    // If timer is already running (started locally for a new session), don't overwrite
    if (_timer != null) return;

    final startedAtStr = _cubit.startedAt;
    if (startedAtStr != null) {
      final start = DateTime.tryParse(startedAtStr);
      if (start != null) {
        final now = DateTime.now();
        final startLocal = start.isUtc ? start.toLocal() : start;
        final diff = now.difference(startLocal);
        final elapsed = diff.inSeconds;
        if (elapsed >= 0) {
          setState(() {
            _elapsedSeconds = elapsed;
          });
          _startTimer();
        }
      }
    } else if (_cubit.state.exercises.isNotEmpty) {
      _startTimer();
    }
  }

  String _formatTimer(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
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
                                suffixIcon:
                                    searchQuery.isNotEmpty
                                        ? IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Color(0xFF9E9E9E),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            setSheetState(() {
                                              searchQuery = '';
                                            });
                                            EasyDebounce.cancel(
                                              'workout_search_debouncer',
                                            );
                                            if (currentTab == 0) {
                                              _cubit.loadLibraryExercises(
                                                search: '',
                                              );
                                            } else {
                                              _cubit.loadCustomExercises(
                                                search: '',
                                              );
                                            }
                                          },
                                        )
                                        : null,
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
                                        _cubit.loadLibraryExercises(
                                          search: searchController.text,
                                        );
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
                                        _cubit.loadCustomExercises(
                                          search: searchController.text,
                                        );
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
                          final exerciseId =
                              int.tryParse(item['id'] ?? '') ?? 0;
                          _cubit.addExercise(
                            id: exerciseId,
                            title: item['title']!,
                            subtitle: item['subtitle']!,
                            videoUrl: item['video_url'],
                          );
                          if (!widget.isPresetCreation) {
                            _startTimer();
                          }
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
                        child: const Center(child: CircularProgressIndicator()),
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
                                items:
                                    state.muscleGroups
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
                                items:
                                    state.exerciseTypes
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
                                items:
                                    state.equipment
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
                                        youtubeLinkController.text =
                                            data!.text!;
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
                                  onTap:
                                      state.isCreatingExercise
                                          ? null
                                          : () {
                                            if (!formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            final name =
                                                nameController.text.trim();
                                            _cubit.createCustomExercise(
                                              name: name,
                                              muscleGroupId: selectedMuscleId!,
                                              equipmentId: selectedEquipmentId!,
                                              type: selectedTypeCode!,
                                              videoUrl:
                                                  youtubeLinkController.text
                                                      .trim(),
                                              onComplete: (success, message) {
                                                if (success) {
                                                  sheetNavigator.pop();
                                                  onCreated?.call();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(message),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(message),
                                                    ),
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
                                      child:
                                          state.isCreatingExercise
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
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
                              const SizedBox(height: 32),
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

  Future<bool> _onWillPop() async {
    if (_isFinishing || widget.isPresetCreation) {
      return true;
    }

    if (_cubit.state.exercises.isEmpty) {
      setState(() {
        _isFinishing = true;
      });
      await _cubit.discardSession();
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Exit Workout?',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'You have a workout in progress. What would you like to do?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Discarding workout...')),
                    );
                    setState(() {
                      _isFinishing = true;
                    });
                    await _cubit.discardSession();
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'Discard',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isFinishing = true;
                    });
                    await _cubit.saveDraftSession(_titleController.text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved as draft!')),
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text(
                    'Save as Draft',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      bloc: _cubit,
      listener: (context, state) {
        if (!widget.isPresetCreation && state.exercises.isNotEmpty) {
          _syncTimer();
        }
        if (_titleController.text != state.sessionTitle &&
            !_titleFocusNode.hasFocus) {
          if ((widget.isNewSession &&
                  state.sessionTitle == 'My Execise' &&
                  _titleController.text.isEmpty) ||
              (widget.isPresetCreation &&
                  state.sessionTitle == 'New Preset' &&
                  _titleController.text.isEmpty)) {
            // Keep empty initially to force user input
          } else {
            _titleController.text = state.sessionTitle;
          }
        }
      },
      builder: (context, state) {
        int totalExercises = state.exercises.length;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
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
                              onTap: () async {
                                final shouldPop = await _onWillPop();
                                if (shouldPop && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
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
                                child:
                                    widget.isPresetCreation
                                        ? TextFormField(
                                          controller: _titleController,
                                          focusNode: _titleFocusNode,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Color(0xFF212121),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter preset name',
                                            hintStyle: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: Color(0xFFCCCCCC),
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onChanged: (v) {
                                            EasyDebounce.debounce(
                                              'workout_title_debouncer',
                                              const Duration(milliseconds: 600),
                                              () {
                                                _cubit.updateSessionTitle(v);
                                              },
                                            );
                                          },
                                        )
                                        : Text(
                                          state.sessionTitle.isNotEmpty
                                              ? state.sessionTitle
                                              : 'My Session',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
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
                            child: Row(
                              children: [
                                Text(
                                  '$totalExercises Exercises',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.0,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                                if (!widget.isPresetCreation) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 15,
                                    color: Color(0xFF888888),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTimer(_elapsedSeconds),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Scrollable Content or Empty State
                  if (state.isLoadingActiveSession)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (totalExercises == 0)
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
                        text:
                            widget.isPresetCreation ? 'Save Preset' : 'Finish',
                        onTap: () => _showFinishDialog(context, state),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFinishDialog(
    BuildContext context,
    WorkoutState state,
  ) async {
    final dialogTitleController = TextEditingController(
      text:
          _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : (widget.isPresetCreation ? '' : state.sessionTitle),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            widget.isPresetCreation ? 'Save Preset' : 'Finish Workout',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF212121),
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isPresetCreation
                      ? 'Enter a name for this preset:'
                      : 'Enter a name for this workout session:',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dialogTitleController,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Color(0xFF212121),
                  ),
                  decoration: InputDecoration(
                    hintText:
                        widget.isPresetCreation
                            ? 'e.g., Leg Day'
                            : 'e.g., Chest Day',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Color(0xFFCCCCCC),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final enteredTitle = dialogTitleController.text.trim();

                // Close dialog
                Navigator.pop(dialogContext);

                if (widget.isPresetCreation) {
                  // Format exercises for Preset API
                  final exercisesList = <Map<String, dynamic>>[];
                  for (var i = 0; i < state.exercises.length; i++) {
                    final ex = state.exercises[i];
                    final setsList = <Map<String, dynamic>>[];
                    final rawSets = ex['sets'] as List? ?? [];
                    for (var j = 0; j < rawSets.length; j++) {
                      final s = rawSets[j] as Map<String, dynamic>;
                      setsList.add({
                        'set_number': s['setNum'] ?? (j + 1),
                        'reps': int.tryParse(s['reps']?.toString() ?? '') ?? 15,
                        'weight':
                            double.tryParse(s['kg']?.toString() ?? '') ?? 10.0,
                      });
                    }
                    exercisesList.add({
                      'workout_id':
                          int.tryParse(ex['id']?.toString() ?? '') ?? 0,
                      'name': ex['title']?.toString() ?? '',
                      'muscle_group':
                          ex['subtitle']?.toString().split('/').first.trim() ??
                          '',
                      'order_index': i,
                      'sets': setsList,
                    });
                  }

                  final cubit =
                      widget.presetCubit ?? context.read<PresetCubit>();
                  bool success = false;
                  if (widget.presetToEdit != null) {
                    success = await cubit.updatePreset(
                      presetId: widget.presetToEdit!.id,
                      title: enteredTitle,
                      exercises: exercisesList,
                    );
                  } else {
                    success = await cubit.createPreset(
                      title: enteredTitle,
                      exercises: exercisesList,
                    );
                  }

                  if (success && context.mounted) {
                    setState(() {
                      _isFinishing = true;
                    });
                    Navigator.pop(context);
                  }
                } else {
                  setState(() {
                    _isFinishing = true;
                  });
                  await _cubit.finishSession(title: enteredTitle);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(
                widget.isPresetCreation ? 'Save' : 'Finish',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
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
                  onTap: () async {
                    final videoUrlStr = exercise['video_url']?.toString() ?? '';
                    if (videoUrlStr.isNotEmpty) {
                      final uri = Uri.parse(videoUrlStr);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch video URL.'),
                            ),
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No video link available for this exercise.',
                            ),
                          ),
                        );
                      }
                    }
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
