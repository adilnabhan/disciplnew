import 'dart:async';
import 'package:flutter/services.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/workout.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_achievement_screen.dart';

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
  final Map<String, FocusNode> _setKgFocusNodes = {};
  final Set<String> _addingExerciseIds = {};
  final Set<String> _removingExerciseIds = {};
  final Set<int> _addingSetExerciseIndices = {};
  final Set<int> _completingSetIds = {};

  @override
  void initState() {
    super.initState();
    _cubit = WorkoutCubit(
      startFresh: widget.isPresetCreation ? false : widget.isNewSession,
      presetToStart: widget.presetToStart,
      isPresetCreation: widget.isPresetCreation,
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
    for (final node in _setKgFocusNodes.values) {
      node.dispose();
    }
    _setKgFocusNodes.clear();
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

  Future<void> _addSet(int exerciseIndex) async {
    if (_addingSetExerciseIndices.contains(exerciseIndex)) return;
    setState(() {
      _addingSetExerciseIndices.add(exerciseIndex);
    });
    try {
      await _cubit.addSet(exerciseIndex);
    } finally {
      if (mounted) {
        setState(() {
          _addingSetExerciseIndices.remove(exerciseIndex);
        });
      }
    }
  }

  void _addExercise() {
    _showSelectWorkoutBottomSheet();
  }

  void _showSelectWorkoutBottomSheet() {
    final searchController = TextEditingController();
    String searchQuery = '';
    String? selectedMajorMuscle;
    dynamic selectedSubMuscle;
    int currentTab = 0; // 0 = Library, 1 = You created

    _cubit.loadMuscleClassification();
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
                      height: MediaQuery.of(sheetContext).size.height * 0.75,
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
                                if (currentTab == 0) {
                                  _cubit.loadLibraryExercises(
                                    search: searchQuery,
                                    majorMuscle: selectedMajorMuscle,
                                    subMuscle: selectedSubMuscle,
                                  );
                                } else {
                                  _cubit.loadCustomExercises(
                                    search: searchQuery,
                                    majorMuscle: selectedMajorMuscle,
                                    subMuscle: selectedSubMuscle,
                                  );
                                }
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
                                            if (currentTab == 0) {
                                              _cubit.loadLibraryExercises(
                                                search: '',
                                                majorMuscle:
                                                    selectedMajorMuscle,
                                                subMuscle: selectedSubMuscle,
                                              );
                                            } else {
                                              _cubit.loadCustomExercises(
                                                search: '',
                                                majorMuscle:
                                                    selectedMajorMuscle,
                                                subMuscle: selectedSubMuscle,
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
                                          search: searchQuery,
                                          majorMuscle: selectedMajorMuscle,
                                          subMuscle: selectedSubMuscle,
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
                                          search: searchQuery,
                                          majorMuscle: selectedMajorMuscle,
                                          subMuscle: selectedSubMuscle,
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
                          _buildMuscleGroupFilter(
                            state: state,
                            setSheetState: setSheetState,
                            selectedMajorMuscle: selectedMajorMuscle,
                            selectedSubMuscle: selectedSubMuscle,
                            onFilterChanged: (major, sub) {
                              setSheetState(() {
                                selectedMajorMuscle = major;
                                selectedSubMuscle = sub;
                              });
                              if (major != null) {
                                _cubit.loadMuscleClassification(
                                  majorMuscle: major,
                                );
                              }
                              if (currentTab == 0) {
                                _cubit.loadLibraryExercises(
                                  search: searchQuery,
                                  majorMuscle: selectedMajorMuscle,
                                  subMuscle: selectedSubMuscle,
                                );
                              } else {
                                _cubit.loadCustomExercises(
                                  search: searchQuery,
                                  majorMuscle: selectedMajorMuscle,
                                  subMuscle: selectedSubMuscle,
                                );
                              }
                            },
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

  Widget _buildMuscleGroupFilter({
    required WorkoutState state,
    required StateSetter setSheetState,
    required String? selectedMajorMuscle,
    required dynamic selectedSubMuscle,
    required Function(String? major, dynamic sub) onFilterChanged,
  }) {
    final List<String> defaultMajorMuscles = [
      'All',
      'Abs',
      'Back',
      'Biceps',
      'Chest',
      'Forearms',
      'Legs',
      'Neck',
      'Shoulders',
      'Triceps',
      'Others',
    ];

    List<String> majorListToUse = state.majorMuscleCategories;
    if (majorListToUse.length <= 1) {
      majorListToUse = defaultMajorMuscles;
    } else if (!majorListToUse.contains('All')) {
      majorListToUse = ['All', ...majorListToUse];
    }

    final List<String> majorNames = majorListToUse;

    final List<SubMuscleModel> subMusclesForSelected = [];
    if (selectedMajorMuscle != null &&
        selectedMajorMuscle.isNotEmpty &&
        selectedMajorMuscle != 'All') {
      subMusclesForSelected.addAll(
        state.subMuscles.where((sub) {
          if (sub.majorMuscle == null || sub.majorMuscle!.isEmpty) return true;
          return sub.majorMuscle!.toLowerCase() ==
              selectedMajorMuscle.toLowerCase();
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: majorNames.length,
            itemBuilder: (context, index) {
              final name = majorNames[index];
              final isAll = name == 'All';
              final isSelected =
                  isAll
                      ? (selectedMajorMuscle == null ||
                          selectedMajorMuscle.isEmpty ||
                          selectedMajorMuscle == 'All')
                      : (selectedMajorMuscle == name);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    final newMajor = isAll ? null : name;
                    onFilterChanged(newMajor, null);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : const Color(0xFFEFEFEF),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF444444),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (subMusclesForSelected.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: subMusclesForSelected.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAllSub =
                      selectedSubMuscle == null ||
                      selectedSubMuscle.toString().isEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: GestureDetector(
                      onTap: () => onFilterChanged(selectedMajorMuscle, null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isAllSub
                                  ? AppColors.primary.withOpacity(0.15)
                                  : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isAllSub
                                    ? AppColors.primary
                                    : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Text(
                          'All $selectedMajorMuscle',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight:
                                isAllSub ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isAllSub
                                    ? AppColors.primary
                                    : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final sub = subMusclesForSelected[index - 1];
                final isSelectedSub =
                    (selectedSubMuscle == sub.name ||
                        selectedSubMuscle == sub.id);

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: GestureDetector(
                    onTap: () => onFilterChanged(selectedMajorMuscle, sub.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelectedSub
                                ? AppColors.primary.withOpacity(0.15)
                                : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelectedSub
                                  ? AppColors.primary
                                  : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        sub.count > 0 ? '${sub.name} (${sub.count})' : sub.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight:
                              isSelectedSub ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelectedSub
                                  ? AppColors.primary
                                  : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
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
    final lowercaseQuery = searchQuery.toLowerCase().trim();
    final filteredList =
        exercises.where((item) {
          if (lowercaseQuery.isEmpty) return true;
          final title = (item['title'] ?? '').toLowerCase();
          final subtitle = (item['subtitle'] ?? '').toLowerCase();
          return title.contains(lowercaseQuery) ||
              subtitle.contains(lowercaseQuery);
        }).toList();

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
        final exerciseKey =
            (item['id'] != null && item['id']!.isNotEmpty)
                ? item['id']!
                : (item['title'] ?? '$index');
        final exerciseId = int.tryParse(item['id'] ?? '') ?? 0;

        final addedIndex = _cubit.state.exercises.indexWhere(
          (e) =>
              (item['id'] != null &&
                  item['id']!.isNotEmpty &&
                  e['id'] != null &&
                  e['id'].toString() == item['id'].toString()) ||
              e['title'].toString().toLowerCase() ==
                  (item['title'] ?? '').toLowerCase(),
        );
        final isAdded = addedIndex != -1;
        final canRemove = _cubit.state.exercises.length > 1;
        final isAdding = _addingExerciseIds.contains(exerciseKey);
        final isRemoving = _removingExerciseIds.contains(exerciseKey);
        final isLoading = isAdding || isRemoving;

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
                      isRemoving
                          ? const Color(0xFFFFF4F4)
                          : (isAdded
                              ? (canRemove
                                  ? const Color(0xFFFFF4F4)
                                  : const Color(0xFFEBEBEB))
                              : AppColors.primary),
                  foregroundColor:
                      isRemoving
                          ? AppColors.primary
                          : (isAdded
                              ? (canRemove
                                  ? AppColors.primary
                                  : const Color(0xFF888888))
                              : Colors.white),
                  disabledBackgroundColor:
                      isRemoving
                          ? const Color(0xFFFFF4F4)
                          : (isAdding
                              ? AppColors.primary
                              : const Color(0xFFEBEBEB)),
                  disabledForegroundColor:
                      isRemoving
                          ? AppColors.primary
                          : (isAdding ? Colors.white : const Color(0xFF888888)),
                  elevation: 0,
                  side:
                      (isRemoving || (isAdded && canRemove))
                          ? const BorderSide(color: Color(0xFFF0B5B7))
                          : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(76, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed:
                    isLoading
                        ? null
                        : isAdded
                        ? (canRemove
                            ? () async {
                              FocusScope.of(context).unfocus();
                              setSheetState(() {
                                _removingExerciseIds.add(exerciseKey);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removing exercise...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              try {
                                final removeIndex = _cubit.state.exercises
                                    .indexWhere(
                                      (e) =>
                                          (item['id'] != null &&
                                              item['id']!.isNotEmpty &&
                                              e['id'] != null &&
                                              e['id'].toString() ==
                                                  item['id'].toString()) ||
                                          e['title'].toString().toLowerCase() ==
                                              (item['title'] ?? '')
                                                  .toLowerCase(),
                                    );
                                if (removeIndex != -1) {
                                  await Future.wait([
                                    _cubit.deleteExercise(removeIndex),
                                    Future.delayed(
                                      const Duration(milliseconds: 350),
                                    ),
                                  ]);
                                }
                              } finally {
                                if (mounted) {
                                  setSheetState(() {
                                    _removingExerciseIds.remove(exerciseKey);
                                  });
                                }
                              }
                            }
                            : null)
                        : () async {
                          // Dismiss keyboard so it doesn't pop back up on Add tap
                          FocusScope.of(context).unfocus();
                          setSheetState(() {
                            _addingExerciseIds.add(exerciseKey);
                          });
                          if (!widget.isPresetCreation) {
                            _startTimer();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Adding exercise...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          try {
                            await _cubit.addExercise(
                              id: exerciseId,
                              title: item['title']!,
                              subtitle: item['subtitle']!,
                              videoUrl: item['video_url'],
                              trackBy: item['track_by'],
                            );
                          } finally {
                            if (mounted) {
                              setSheetState(() {
                                _addingExerciseIds.remove(exerciseKey);
                              });
                            }
                          }
                        },
                child:
                    isLoading
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isAdding ? Colors.white : AppColors.primary,
                            ),
                          ),
                        )
                        : Text(
                          isAdded ? (canRemove ? 'Remove' : 'Added') : 'Add',
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLabelWithAddNew(
    String label,
    bool hasSelected,
    String? selectedName,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.0,
            letterSpacing: -0.3,
            color: AppColors.button,
          ),
        ),
        if (hasSelected && selectedName != null)
          Text(
            selectedName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  void _showAddNewDialog({
    required BuildContext context,
    required String title,
    required String hintText,
    String? initialText,
    required void Function(String name) onSave,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    if (initialText != null && initialText.isNotEmpty) {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: initialText.length,
      );
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  onSave(name);
                }
              },
              child: const Text('Save'),
            ),
          ],
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
    List<int> selectedSecondaryMuscleIds = [];
    String? selectedTypeCode;
    int? selectedEquipmentId;
    String selectedTrackBy = 'rep';
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
                  builder: (context, blocState) {
                    final state = _cubit.state;
                    if (state.isLoadingLookups && state.muscleGroups.isEmpty) {
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
                              _buildLabelWithAddNew(
                                'Muscle',
                                selectedMuscleId != null,
                                selectedMuscleId != null
                                    ? state.muscleGroups
                                        .firstWhere(
                                          (m) => m.id == selectedMuscleId,
                                          orElse:
                                              () => MuscleGroupModel(
                                                id: 0,
                                                name: 'Custom',
                                              ),
                                        )
                                        .name
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              SearchableSingleSelectDropdown<int>(
                                value: selectedMuscleId,
                                hintText: 'Select the muscle',
                                searchHintText: 'Search muscle...',
                                decoration: _dropdownDecoration(),
                                validator: (val) {
                                  if (val == null) {
                                    return 'Required this field';
                                  }
                                  return null;
                                },
                                items: state.muscleGroups
                                    .map(
                                      (m) => SearchableDropdownItem<int>(
                                        value: m.id,
                                        label: m.name,
                                      ),
                                    )
                                    .toList(),
                                addNewText: 'Add New Muscle',
                                onAddNew: (query) {
                                  _showAddNewDialog(
                                    context: sheetContext,
                                    title: 'Add New Muscle',
                                    hintText: 'Enter muscle name',
                                    initialText: query,
                                    onSave: (name) async {
                                      final result = await WorkoutRepository()
                                          .createMuscleGroup(name: name);
                                      result.fold(
                                        (error) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to create: ${error.msg}',
                                              ),
                                            ),
                                          );
                                        },
                                        (newMuscle) {
                                          _cubit.addMuscleGroup(newMuscle);
                                          _cubit.loadLookups();
                                          setDialogState(() {
                                            selectedMuscleId = newMuscle.id;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '"${newMuscle.name}" added!',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedMuscleId = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Secondary Muscle Groups
                              const Text(
                                'Secondary Muscle Groups (Optional)',
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
                              SecondaryMuscleDropdown(
                                allMuscleGroups: state.muscleGroups,
                                selectedPrimaryMuscleId: selectedMuscleId,
                                selectedIds: selectedSecondaryMuscleIds,
                                decoration: _dropdownDecoration(),
                                onChanged: (newIds) {
                                  setDialogState(() {
                                    selectedSecondaryMuscleIds = List<int>.from(
                                      newIds,
                                    );
                                  });
                                },
                              ),
                              if (selectedSecondaryMuscleIds.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children:
                                      selectedSecondaryMuscleIds.map<Widget>((
                                        id,
                                      ) {
                                        final m = state.muscleGroups.firstWhere(
                                          (element) => element.id == id,
                                          orElse:
                                              () => MuscleGroupModel(
                                                id: id,
                                                name: 'Muscle $id',
                                              ),
                                        );
                                        return InputChip(
                                          label: Text(
                                            m.name,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: AppColors.primary,
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          onDeleted: () {
                                            setDialogState(() {
                                              selectedSecondaryMuscleIds.remove(
                                                id,
                                              );
                                            });
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          side: BorderSide.none,
                                        );
                                      }).toList(),
                                ),
                              ],
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
                                isExpanded: true,
                                value: selectedTypeCode,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Required this field';
                                  }
                                  return null;
                                },
                                decoration: _dropdownDecoration(),
                                hint: const Text(
                                  'Select the type of exercise',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
                                items: [
                                  ...state.exerciseTypes
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t.id,
                                          child: Text(
                                            t.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
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
                                  DropdownMenuItem(
                                    value: '__add_new__',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Add New Type',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val == '__add_new__') {
                                    _showAddNewDialog(
                                      context: sheetContext,
                                      title: 'Add New Type',
                                      hintText: 'Enter exercise type name',
                                      onSave: (name) {
                                        final newType = ExerciseTypeModel(
                                          id: name.toLowerCase().replaceAll(
                                            ' ',
                                            '_',
                                          ),
                                          name: name,
                                        );
                                        _cubit.addExerciseType(newType);
                                        setDialogState(() {
                                          selectedTypeCode = newType.id;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '"$name" type added!',
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    return;
                                  }
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
                              SearchableSingleSelectDropdown<int>(
                                value: selectedEquipmentId,
                                hintText: 'Select the equipment used',
                                searchHintText: 'Search equipment...',
                                decoration: _dropdownDecoration(),
                                validator: (val) {
                                  if (val == null) {
                                    return 'Required this field';
                                  }
                                  return null;
                                },
                                items: state.equipment
                                    .map(
                                      (e) => SearchableDropdownItem<int>(
                                        value: e.id,
                                        label: e.name,
                                      ),
                                    )
                                    .toList(),
                                addNewText: 'Add New Equipment',
                                onAddNew: (query) {
                                  _showAddNewDialog(
                                    context: sheetContext,
                                    title: 'Add New Equipment',
                                    hintText: 'Enter equipment name',
                                    initialText: query,
                                    onSave: (name) async {
                                      final result = await WorkoutRepository()
                                          .createEquipment(name: name);
                                      result.fold(
                                        (error) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to create: ${error.msg}',
                                              ),
                                            ),
                                          );
                                        },
                                        (newEquip) {
                                          _cubit.addEquipment(newEquip);
                                          _cubit.loadLookups();
                                          setDialogState(() {
                                            selectedEquipmentId = newEquip.id;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '"${newEquip.name}" added!',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedEquipmentId = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Track by
                              const Text(
                                'Track by',
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
                                isExpanded: true,
                                value: selectedTrackBy,
                                decoration: _dropdownDecoration(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'rep',
                                    child: Text(
                                      'Reps',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'time',
                                    child: Text(
                                      'Time',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'distance',
                                    child: Text(
                                      'Distance',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: AppColors.button,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedTrackBy = val;
                                    });
                                  }
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
                                              trackBy: selectedTrackBy,
                                              secondaryMuscleGroupIds:
                                                  selectedSecondaryMuscleIds,
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
                                      child: const Text(
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
                    final res = await _cubit.saveDraftSession(
                      _titleController.text.trim(),
                    );
                    res.fold(
                      (error) {
                        setState(() {
                          _isFinishing = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to save draft: ${error.msg ?? "Unknown error"}',
                              ),
                            ),
                          );
                        }
                      },
                      (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved as draft!')),
                          );
                          Navigator.of(context).pop(true);
                        }
                      },
                    );
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
        if (_cubit.reorderError != null) {
          final errStr = _cubit.reorderError!;
          _cubit.reorderError = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errStr),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (_titleController.text != state.sessionTitle &&
            !_titleFocusNode.hasFocus) {
          if ((widget.isNewSession &&
                  (state.sessionTitle == 'My Execise' ||
                      state.sessionTitle == 'My Session') &&
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
                                child: TextFormField(
                                  controller: _titleController,
                                  focusNode: _titleFocusNode,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Color(0xFF212121),
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        widget.isPresetCreation
                                            ? 'Enter preset name'
                                            : 'Enter session name',
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
                                if (_cubit.showReorderLoadingIndicator) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Saving...',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 20.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title: Create Your Workout
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    height: 1.2,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Create Your ',
                                      style: TextStyle(
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Workout',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Subtle Accent Line below title
                              Container(
                                width: 44,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0B5B7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Subtitle
                              const Text(
                                'Add exercises from the library or your custom list to customize your workout session.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Custom Styled + Add Workout Button
                              GestureDetector(
                                onTap: _addExercise,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF5F6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFFD1D6),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Add Workout',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Scrollable Content with Drag-to-Reorder
                    Expanded(
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        onReorderStart: (index) {
                          HapticFeedback.lightImpact();
                        },
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              final double animValue = Curves.easeInOut
                                  .transform(animation.value);
                              final double scale = 1.0 + (0.02 * animValue);
                              return Transform.scale(
                                scale: scale,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 4 * animValue,
                                  shadowColor: Colors.black.withOpacity(
                                    0.12 * animValue,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: child,
                                ),
                              );
                            },
                            child: child,
                          );
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: state.exercises.length,
                        onReorder: (oldIndex, newIndex) {
                          if (_cubit.isReorderingExercises) return;
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          if (oldIndex == newIndex) return;
                          _cubit.reorderExercises(oldIndex, newIndex);
                        },
                        footer: Column(
                          key: const ValueKey('add_workout_footer'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 18),
                            _buildOutlineRedButton(
                              text: '+ Add Workout',
                              onTap: _addExercise,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                        itemBuilder: (context, index) {
                          final exercise = state.exercises[index];
                          final exId =
                              exercise['id'] ??
                              exercise['workout_log_id'] ??
                              exercise['plan_exercise_id'] ??
                              exercise['exercise_id'];
                          final exerciseKey = ValueKey('ex_card_$exId');

                          return ReorderableDelayedDragStartListener(
                            key: exerciseKey,
                            index: index,
                            enabled: !_cubit.isReorderingExercises,
                            child: _buildExerciseCard(exercise, index),
                          );
                        },
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
                        onTap: () {
                          if (_isFinishing) return;
                          _showFinishDialog(context, state);
                        },
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
    bool isSubmitting = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return PopScope(
              canPop: !isSubmitting,
              child: AlertDialog(
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
                        enabled: !isSubmitting,
                        autofocus: true,
                        onChanged: (val) {
                          if (errorMessage != null) {
                            setDialogState(() {
                              errorMessage = null;
                            });
                          }
                        },
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
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
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
                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
                actions: [
                  TextButton(
                    onPressed:
                        isSubmitting
                            ? null
                            : () => Navigator.pop(dialogContext),
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
                      disabledBackgroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed:
                        isSubmitting
                            ? null
                            : () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              final enteredTitle =
                                  dialogTitleController.text.trim();

                              setDialogState(() {
                                isSubmitting = true;
                              });

                              try {
                                if (widget.isPresetCreation) {
                                  // Format exercises for Preset API
                                  final exercisesList =
                                      <Map<String, dynamic>>[];
                                  for (
                                    var i = 0;
                                    i < state.exercises.length;
                                    i++
                                  ) {
                                    final ex = state.exercises[i];
                                    final setsList = <Map<String, dynamic>>[];
                                    final rawSets = ex['sets'] as List? ?? [];
                                    for (var j = 0; j < rawSets.length; j++) {
                                      final s =
                                          rawSets[j] as Map<String, dynamic>;
                                      setsList.add({
                                        'set_number': s['setNum'] ?? (j + 1),
                                        'reps':
                                            double.tryParse(
                                              s['reps']?.toString() ?? '',
                                            )?.round() ??
                                            15,
                                        'weight':
                                            double.tryParse(
                                              s['kg']?.toString() ?? '',
                                            ) ??
                                            10.0,
                                      });
                                    }
                                    exercisesList.add({
                                      'workout_id':
                                          int.tryParse(
                                            ex['id']?.toString() ?? '',
                                          ) ??
                                          0,
                                      'name': ex['title']?.toString() ?? '',
                                      'muscle_group':
                                          ex['subtitle']
                                              ?.toString()
                                              .split('/')
                                              .first
                                              .trim() ??
                                          '',
                                      'order_index': i,
                                      'sets': setsList,
                                    });
                                  }

                                  final cubit =
                                      widget.presetCubit ??
                                      context.read<PresetCubit>();
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
                                    Navigator.pop(
                                      dialogContext,
                                    ); // close dialog
                                    Navigator.pop(context); // close screen
                                  } else if (!success && context.mounted) {
                                    setDialogState(() {
                                      isSubmitting = false;
                                      errorMessage =
                                          cubit.state.errorMessage ??
                                          'Failed to save preset. Please try again.';
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _isFinishing = true;
                                  });
                                  final res = await _cubit.finishSession(
                                    title: enteredTitle,
                                  );
                                  res.fold(
                                    (error) {
                                      if (context.mounted) {
                                        setDialogState(() {
                                          isSubmitting = false;
                                          errorMessage = error.msg;
                                        });
                                        setState(() {
                                          _isFinishing = false;
                                        });
                                      }
                                    },
                                    (success) {
                                      if (context.mounted) {
                                        Navigator.pop(
                                          dialogContext,
                                        ); // close dialog
                                        final Map<String, dynamic> sessionMap =
                                            success is Map<String, dynamic>
                                                ? Map<String, dynamic>.from(
                                                  success,
                                                )
                                                : <String, dynamic>{};
                                        if (_elapsedSeconds > 0) {
                                          sessionMap['elapsed_seconds'] =
                                              _elapsedSeconds;
                                        }
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<bool>(
                                            builder:
                                                (context) =>
                                                    WorkoutAchievementScreen(
                                                      sessionData: sessionMap,
                                                      fallbackTitle:
                                                          enteredTitle,
                                                    ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setDialogState(() {
                                    isSubmitting = false;
                                  });
                                  setState(() {
                                    _isFinishing = false;
                                  });
                                }
                              }
                            },
                    child:
                        isSubmitting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              widget.isPresetCreation ? 'Save' : 'Finish',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSwapDialog(int currentIndex, Map<String, dynamic> currentExercise) {
    final allExercises = _cubit.state.exercises;
    if (allExercises.length < 2) return;

    final isAtTop = currentIndex == 0;
    final isAtBottom = currentIndex == allExercises.length - 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle indicator bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reorder Exercise',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currentExercise['title']} (Position ${currentIndex + 1} of ${allExercises.length})',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Quick Action Buttons
                Column(
                  children: [
                    ListTile(
                      enabled: !isAtTop,
                      leading: Icon(
                        Icons.vertical_align_top_rounded,
                        color: isAtTop ? Colors.grey : AppColors.primary,
                      ),
                      title: const Text(
                        'Move to Top',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Place this exercise first in order',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _cubit.moveExerciseToTop(currentIndex);
                      },
                    ),
                    ListTile(
                      enabled: !isAtTop,
                      leading: Icon(
                        Icons.arrow_upward_rounded,
                        color: isAtTop ? Colors.grey : const Color(0xFF212121),
                      ),
                      title: const Text(
                        'Move Up',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        isAtTop
                            ? 'Already at top'
                            : 'Move up to position ${currentIndex}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _cubit.moveExerciseUp(currentIndex);
                      },
                    ),
                    ListTile(
                      enabled: !isAtBottom,
                      leading: Icon(
                        Icons.arrow_downward_rounded,
                        color:
                            isAtBottom ? Colors.grey : const Color(0xFF212121),
                      ),
                      title: const Text(
                        'Move Down',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        isAtBottom
                            ? 'Already at bottom'
                            : 'Move down to position ${currentIndex + 2}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _cubit.moveExerciseDown(currentIndex);
                      },
                    ),
                    ListTile(
                      enabled: !isAtBottom,
                      leading: Icon(
                        Icons.vertical_align_bottom_rounded,
                        color: isAtBottom ? Colors.grey : AppColors.primary,
                      ),
                      title: const Text(
                        'Move to Bottom',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Place this exercise last in order',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _cubit.moveExerciseToBottom(currentIndex);
                      },
                    ),
                  ],
                ),

                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Text(
                    'Or move directly to position:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allExercises.length,
                    itemBuilder: (context, index) {
                      final isCurrent = index == currentIndex;
                      final exercise = allExercises[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        selected: isCurrent,
                        selectedTileColor: AppColors.primary.withOpacity(0.05),
                        title: Text(
                          'Position ${index + 1}: ${exercise['title']}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                            color:
                                isCurrent
                                    ? AppColors.primary
                                    : const Color(0xFF212121),
                          ),
                        ),
                        trailing:
                            isCurrent
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.swap_vert,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                        onTap:
                            isCurrent
                                ? null
                                : () {
                                  Navigator.pop(bottomSheetContext);
                                  _cubit.reorderExercise(currentIndex, index);
                                },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int exerciseIndex) {
    final sets = exercise['sets'] as List<Map<String, dynamic>>;
    final subtitle = (exercise['subtitle']?.toString() ?? '').toLowerCase();
    final trackBy = (exercise['track_by']?.toString() ?? 'rep').toLowerCase();
    final isTimeBased =
        trackBy == 'time' ||
        subtitle.contains('cardio') ||
        subtitle.contains('flexibility') ||
        subtitle.contains('hiit') ||
        sets.any((s) => s['input_type']?.toString().toLowerCase() == 'seconds');
    final isDistanceBased = trackBy == 'distance';
    final repsHeader = isTimeBased ? 'Sec' : (isDistanceBased ? 'Km' : 'Rep');

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${exerciseIndex + 1}. ${exercise['title']}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Play button icon (custom miniature YouTube icon)
                          GestureDetector(
                            onTap: () async {
                              final videoUrlStr =
                                  exercise['video_url']?.toString() ?? '';
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
                                        content: Text(
                                          'Could not launch video URL.',
                                        ),
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
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0F1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 12,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD30C15),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                if (_cubit.state.exercises.length > 1) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Delete Exercise'),
                                content: Text(
                                  'Are you sure you want to delete ${exercise['title']} from this workout session?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      _cubit.deleteExercise(exerciseIndex);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFD30C15),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Table header row
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
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
                Expanded(
                  flex: 3,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: () {
                        final val = exercise['weight_type']?.toString();
                        if (val == null) return 'KG';
                        final lower = val.toLowerCase().replaceAll(' ', '');
                        if (lower == 'bw') return 'BW';
                        if (lower == 'fw' ||
                            lower == 'freeweight' ||
                            lower == 'baronly' ||
                            lower == 'bo' ||
                            lower == 'bar')
                          return 'FW';
                        if (lower == 'kg+bw' || lower == 'kgbw') return 'KG';
                        return 'KG';
                      }(),
                      isDense: true,
                      isExpanded: true,
                      alignment: Alignment.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      selectedItemBuilder: (BuildContext context) {
                        return const <Widget>[
                          Center(child: Text('KG')),
                          Center(child: Text('BW')),
                          Center(child: Text('FW')),
                        ];
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'KG',
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Kilograms', maxLines: 1),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'BW',
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Body Weight', maxLines: 1),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'FW',
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Free Weight', maxLines: 1),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _cubit.updateWorkoutLogWeightType(exerciseIndex, val);
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: () {
                        final val =
                            exercise['track_by']?.toString().toLowerCase();
                        if (val == 'time' ||
                            val == 'sec' ||
                            val == 'secs' ||
                            val == 'seconds')
                          return 'time';
                        if (val == 'distance' ||
                            val == 'dist' ||
                            val == 'km' ||
                            val == 'm')
                          return 'distance';
                        return 'rep';
                      }(),
                      isDense: true,
                      isExpanded: true,
                      alignment: Alignment.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      items: const [
                        DropdownMenuItem(
                          value: 'rep',
                          child: Center(child: Text('Rep')),
                        ),
                        DropdownMenuItem(
                          value: 'time',
                          child: Center(child: Text('Sec')),
                        ),
                        DropdownMenuItem(
                          value: 'distance',
                          child: Center(child: Text('Distance')),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _cubit.updateWorkoutLogTrackBy(exerciseIndex, val);
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!widget.isPresetCreation) ...[
                        Container(
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
                        const SizedBox(width: 28),
                      ] else ...[
                        const SizedBox(width: 20),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Sets list rows
          ...List.generate(sets.length, (setIndex) {
            final set = sets[setIndex];
            final focusKey = '${exerciseIndex}_${setIndex}_kg';
            final focusNode = _setKgFocusNodes.putIfAbsent(
              focusKey,
              () => FocusNode(),
            );

            // Compute hint values from preceding set or exercise target
            String kgHintStr = '-';
            String repsHintStr = '-';
            if (setIndex > 0) {
              final prevSet = sets[setIndex - 1];
              final pKg = prevSet['kg']?.toString();
              final pReps = prevSet['reps']?.toString();
              if (pKg != null && pKg.isNotEmpty && pKg != '-') {
                kgHintStr = pKg;
              }
              if (pReps != null && pReps.isNotEmpty && pReps != '-') {
                repsHintStr = pReps;
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
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
                          () {
                            final prev = set['previous']?.toString();
                            if (prev != null &&
                                prev != 'no data' &&
                                prev.isNotEmpty) {
                              return prev;
                            }
                            return 'no data';
                          }(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF212121),
                            height: 1.0,
                          ),
                        ),
                      ),
                      // kg Input Box
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.center,
                          child: () {
                            final weightType = exercise['weight_type']
                                ?.toString()
                                .toUpperCase()
                                .replaceAll(' ', '');
                            if (weightType == 'BW') {
                              return Container(
                                width: 58,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEEEEE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1.0,
                                  ),
                                ),
                                child: const Text(
                                  'BW',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              width: 58,
                              child: TextFormField(
                                key: ValueKey(
                                  '${exerciseIndex}_${setIndex}_kg_${set['checked']}',
                                ),
                                initialValue: set['kg'] as String?,
                                focusNode: focusNode,
                                autofocus: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF212121),
                                  height: 1.0,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 2,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFAFAFA),
                                  hintText: kgHintStr,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                onChanged: (val) {
                                  _cubit.updateSetKg(
                                    exerciseIndex,
                                    setIndex,
                                    val,
                                  );
                                  if (val.length == 8) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }(),
                        ),
                      ),
                      // Rep / Sec / Distance Input Box
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.center,
                          child: () {
                            return SizedBox(
                              width: 58,
                              child: TextFormField(
                                key: ValueKey(
                                  '${exerciseIndex}_${setIndex}_reps_${exercise['track_by']}_${set['checked']}',
                                ),
                                initialValue: set['reps'] as String?,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                keyboardType: () {
                                  final trackBy =
                                      exercise['track_by']
                                          ?.toString()
                                          .toLowerCase();
                                  if (trackBy == 'distance' ||
                                      trackBy == 'dist' ||
                                      trackBy == 'km' ||
                                      trackBy == 'm') {
                                    return const TextInputType.numberWithOptions(
                                      decimal: true,
                                    );
                                  }
                                  return TextInputType.number;
                                }(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF212121),
                                  height: 1.0,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 2,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFAFAFA),
                                  hintText: repsHintStr,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                onChanged: (val) {
                                  _cubit.updateSetReps(
                                    exerciseIndex,
                                    setIndex,
                                    val,
                                  );
                                },
                              ),
                            );
                          }(),
                        ),
                      ),
                      // Check checkbox button
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!widget.isPresetCreation) ...[
                              GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  focusNode.unfocus();
                                  final isCurrentlyChecked =
                                      set['checked'] as bool? ?? false;
                                  if (!isCurrentlyChecked) {
                                    var kgVal =
                                        set['kg']?.toString().trim() ?? '';
                                    var repsVal =
                                        set['reps']?.toString().trim() ?? '';
                                    final weightType =
                                        exercise['weight_type']
                                            ?.toString()
                                            .toUpperCase()
                                            .replaceAll(' ', '') ??
                                        '';
                                    final isBodyweight = weightType == 'BW';

                                    // Fallback to ghost/hint text if unedited
                                    if (kgVal.isEmpty &&
                                        !isBodyweight &&
                                        kgHintStr != '-') {
                                      kgVal = kgHintStr;
                                      _cubit.updateSetKg(
                                        exerciseIndex,
                                        setIndex,
                                        kgHintStr,
                                      );
                                    }
                                    if (repsVal.isEmpty && repsHintStr != '-') {
                                      repsVal = repsHintStr;
                                      _cubit.updateSetReps(
                                        exerciseIndex,
                                        setIndex,
                                        repsHintStr,
                                      );
                                    }

                                    if (repsVal.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter reps/seconds/distance first',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (!isBodyweight && kgVal.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter weight first',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                  }

                                  final setLogId = set['id'] as int?;
                                  if (setLogId != null) {
                                    if (_completingSetIds.contains(setLogId)) {
                                      return;
                                    }
                                    setState(() {
                                      _completingSetIds.add(setLogId);
                                    });
                                  }
                                  await _cubit.toggleSetChecked(
                                    exerciseIndex,
                                    setIndex,
                                    onError: (errorMsg) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(errorMsg),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                  if (setLogId != null && mounted) {
                                    setState(() {
                                      _completingSetIds.remove(setLogId);
                                    });
                                  }
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
                              const SizedBox(width: 8),
                            ],
                            if (setIndex > 0)
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Delete Set'),
                                        content: Text(
                                          'Are you sure you want to delete Set ${set['setNum']}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              _cubit.deleteSet(
                                                exerciseIndex,
                                                setIndex,
                                              );
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: Color(0xFFD30C15),
                                  size: 20,
                                ),
                              )
                            else if (!widget.isPresetCreation)
                              const SizedBox(
                                width: 20,
                              ), // Placeholder to keep checkbox aligned!
                          ],
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
              isLoading: _addingSetExerciseIndices.contains(exerciseIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineRedButton({
    required String text,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
          child:
              isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                  : Text(
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

class SecondaryMuscleDropdown extends StatefulWidget {
  final List<MuscleGroupModel> allMuscleGroups;
  final int? selectedPrimaryMuscleId;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final InputDecoration decoration;

  const SecondaryMuscleDropdown({
    super.key,
    required this.allMuscleGroups,
    required this.selectedPrimaryMuscleId,
    required this.selectedIds,
    required this.onChanged,
    required this.decoration,
  });

  @override
  State<SecondaryMuscleDropdown> createState() =>
      _SecondaryMuscleDropdownState();
}

class _SecondaryMuscleDropdownState extends State<SecondaryMuscleDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final GlobalKey<_DropdownOverlayContentState> _overlayKey =
      GlobalKey<_DropdownOverlayContentState>();

  void _toggleDropdown() {
    if (_isOpen) {
      _overlayKey.currentState?._handleClose();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final overlay = Overlay.of(context);
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _overlayKey.currentState?._handleClose();
              },
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                color: Colors.transparent,
                child: _DropdownOverlayContent(
                  key: _overlayKey,
                  allMuscleGroups: widget.allMuscleGroups,
                  selectedPrimaryMuscleId: widget.selectedPrimaryMuscleId,
                  initialSelectedIds: widget.selectedIds,
                  width: size.width,
                  onDone: (newIds) {
                    widget.onChanged(newIds);
                  },
                  onClose: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    setState(() {
                      _isOpen = false;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: InputDecorator(
          decoration: widget.decoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.selectedIds.isNotEmpty
                      ? '${widget.selectedIds.length} secondary muscle${widget.selectedIds.length > 1 ? 's' : ''} selected'
                      : 'Select secondary muscle groups',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 1.0,
                    letterSpacing: -0.3,
                    color: widget.selectedIds.isNotEmpty
                        ? AppColors.button
                        : const Color(0xFF888888),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF9E9E9E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownOverlayContent extends StatefulWidget {
  final List<MuscleGroupModel> allMuscleGroups;
  final int? selectedPrimaryMuscleId;
  final List<int> initialSelectedIds;
  final ValueChanged<List<int>> onDone;
  final VoidCallback onClose;
  final double width;

  const _DropdownOverlayContent({
    super.key,
    required this.allMuscleGroups,
    required this.selectedPrimaryMuscleId,
    required this.initialSelectedIds,
    required this.onDone,
    required this.onClose,
    required this.width,
  });

  @override
  State<_DropdownOverlayContent> createState() =>
      _DropdownOverlayContentState();
}

class _DropdownOverlayContentState extends State<_DropdownOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  late List<int> _tempSelectedIds;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List<int>.from(widget.initialSelectedIds);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose() {
    if (_animationController.isAnimating &&
        _animationController.status == AnimationStatus.reverse) {
      return;
    }
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase().trim();
    final filteredMuscles =
        widget.allMuscleGroups
            .where((m) => m.id != widget.selectedPrimaryMuscleId)
            .where((m) => query.isEmpty || m.name.toLowerCase().contains(query))
            .toList();

    return SizeTransition(
      sizeFactor: _expandAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {}, // Absorb taps
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search secondary muscle...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 18,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF9E9E9E),
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),

                // Muscle groups list
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: filteredMuscles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No matching muscle groups found'
                                : 'No muscle groups found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filteredMuscles.length,
                          itemBuilder: (context, index) {
                            final m = filteredMuscles[index];
                            final isSelected = _tempSelectedIds.contains(
                              m.id,
                            );
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              title: Text(
                                m.name,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF212121),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                      size: 18,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _tempSelectedIds.remove(m.id);
                                  } else {
                                    _tempSelectedIds.add(m.id);
                                  }
                                });
                                widget.onDone(_tempSelectedIds);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchableDropdownItem<T> {
  final T value;
  final String label;

  const SearchableDropdownItem({
    required this.value,
    required this.label,
  });
}

class SearchableSingleSelectDropdown<T> extends FormField<T> {
  SearchableSingleSelectDropdown({
    super.key,
    required T? value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    required this.decoration,
    this.searchHintText = 'Search...',
    super.validator,
    this.addNewText,
    this.onAddNew,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> field) {
            final state = field as _SearchableSingleSelectDropdownState<T>;

            SearchableDropdownItem<T>? selectedItem;
            for (final item in state.widget.items) {
              if (item.value == field.value) {
                selectedItem = item;
                break;
              }
            }

            final hasError = field.hasError;

            return CompositedTransformTarget(
              link: state._layerLink,
              child: GestureDetector(
                onTap: state._toggleDropdown,
                child: InputDecorator(
                  isFocused: state._isOpen,
                  decoration: state.widget.decoration.copyWith(
                    errorText: hasError ? field.errorText : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem != null
                              ? selectedItem.label
                              : state.widget.hintText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1,
                            letterSpacing: -0.3,
                            color: selectedItem != null
                                ? AppColors.button
                                : const Color(0xFF888888),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Icon(
                        state._isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

  final String hintText;
  final String searchHintText;
  final List<SearchableDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final InputDecoration decoration;
  final String? addNewText;
  final void Function(String? query)? onAddNew;

  @override
  FormFieldState<T> createState() => _SearchableSingleSelectDropdownState<T>();
}

class _SearchableSingleSelectDropdownState<T> extends FormFieldState<T> {
  @override
  SearchableSingleSelectDropdown<T> get widget =>
      super.widget as SearchableSingleSelectDropdown<T>;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final GlobalKey<_SearchableSingleSelectOverlayContentState<T>> _overlayKey =
      GlobalKey<_SearchableSingleSelectOverlayContentState<T>>();

  @override
  void didUpdateWidget(covariant SearchableSingleSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _overlayKey.currentState?._handleClose();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _overlayKey.currentState?._handleClose();
              },
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                color: Colors.transparent,
                child: _SearchableSingleSelectOverlayContent<T>(
                  key: _overlayKey,
                  items: widget.items,
                  selectedValue: value,
                  searchHintText: widget.searchHintText,
                  addNewText: widget.addNewText,
                  onAddNew: widget.onAddNew != null
                      ? (query) {
                          _closeDropdown();
                          widget.onAddNew?.call(query);
                        }
                      : null,
                  width: size.width,
                  onSelected: (val) {
                    didChange(val);
                    widget.onChanged(val);
                    _closeDropdown();
                  },
                  onClose: _closeDropdown,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }
}

class _SearchableSingleSelectOverlayContent<T> extends StatefulWidget {
  final List<SearchableDropdownItem<T>> items;
  final T? selectedValue;
  final String searchHintText;
  final String? addNewText;
  final void Function(String? query)? onAddNew;
  final ValueChanged<T> onSelected;
  final VoidCallback onClose;
  final double width;

  const _SearchableSingleSelectOverlayContent({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.searchHintText,
    required this.onSelected,
    required this.onClose,
    required this.width,
    this.addNewText,
    this.onAddNew,
  });

  @override
  State<_SearchableSingleSelectOverlayContent<T>> createState() =>
      _SearchableSingleSelectOverlayContentState<T>();
}

class _SearchableSingleSelectOverlayContentState<T>
    extends State<_SearchableSingleSelectOverlayContent<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose([VoidCallback? onComplete]) {
    if (_animationController.isAnimating &&
        _animationController.status == AnimationStatus.reverse) {
      return;
    }
    _animationController.reverse().then((_) {
      widget.onClose();
      onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase().trim();
    final filteredItems = query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => item.label.toLowerCase().contains(query))
            .toList();

    return SizeTransition(
      sizeFactor: _expandAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {}, // Absorb taps
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: widget.searchHintText,
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 18,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF9E9E9E),
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),

                // Items list
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: filteredItems.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No matching items found'
                                : 'No items found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isSelected =
                                item.value == widget.selectedValue;
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF212121),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                      size: 18,
                                    )
                                  : null,
                              onTap: () {
                                _handleClose(() {
                                  widget.onSelected(item.value);
                                });
                              },
                            );
                          },
                        ),
                ),

                // Add New option
                if (widget.addNewText != null && widget.onAddNew != null) ...[
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  InkWell(
                    onTap: () {
                      _handleClose(() {
                        widget.onAddNew?.call(
                          _searchQuery.trim().isNotEmpty
                              ? _searchQuery.trim()
                              : null,
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.addNewText!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
