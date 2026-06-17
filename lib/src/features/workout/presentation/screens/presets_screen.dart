import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/cubit/preset_cubit.dart';
import 'package:customer_mobile_app/src/features/workout/cubit/preset_state.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/preset_model.dart';
import 'package:customer_mobile_app/src/features/workout/cubit/workout_cubit.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/own_workout_screen.dart';

class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  late final PresetCubit _presetCubit;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _presetCubit = PresetCubit();
  }

  @override
  void dispose() {
    _presetCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PresetCubit>.value(
      value: _presetCubit,
      child: BlocBuilder<PresetCubit, PresetState>(
        builder: (context, state) {
          final displayedPresets = _presetCubit.filteredPresets;

          return Scaffold(
            backgroundColor: AppColors.bgcolorgrey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
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
                ),
              ),
              title: Text(
                'Presets',
                style: AppStyles.text20Px.poppins.w500.copyWith(color: AppColors.textDark),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Filter Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = _selectedFilterIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                              _presetCubit.emit(_presetCubit.state.copyWith(
                                showOnlyFavorites: index == 1,
                              ));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _filters[index],
                                style: AppStyles.text14Px.poppins.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: TextField(
                            onChanged: (val) => _presetCubit.setSearchQuery(val),
                            style: AppStyles.text14Px.poppins.copyWith(color: AppColors.textDark),
                            decoration: const InputDecoration(
                              hintText: 'Search Workout',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF9E9E9E),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.transparent,
                              prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 20,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preset List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (displayedPresets.isEmpty) {
                            return Center(
                              child: Text(
                                _selectedFilterIndex == 0
                                    ? 'No presets yet.'
                                    : 'No favorite presets yet.',
                                style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                            itemCount: displayedPresets.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _buildPresetCard(displayedPresets[index], state);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Bottom Create Button
                Positioned(
                  bottom: 30,
                  left: 100,
                  right: 100,
                  child: Center(
                    child: PrimaryPillButton(
                      text: 'Create New Preset',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => OwnWorkoutScreen(
                              isPresetCreation: true,
                              presetCubit: _presetCubit,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetCard(PresetModel preset, PresetState state) {
    final isFavorite = state.favoritePresetIds.contains(preset.id);
    final exercisesText = preset.exercises.isEmpty
        ? 'No exercises'
        : preset.exercises.map((e) => e.name).join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        preset.title,
                        style: AppStyles.text16Px.poppins.w500.copyWith(color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(Exercises: ${preset.exercises.length})',
                      style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 4,
                offset: const Offset(0, 40),
                onSelected: (value) async {
                  if (value == 'favorite') {
                    _presetCubit.toggleFavorite(preset.id);
                  } else if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => OwnWorkoutScreen(
                          isPresetCreation: true,
                          presetToEdit: preset,
                          presetCubit: _presetCubit,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Preset'),
                        content: const Text('Are you sure you want to delete this preset?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _presetCubit.deletePreset(preset.id);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    height: 22,
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.black, size: 20),
                        const SizedBox(width: 12),
                        Text('Edit Preset', style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'favorite',
                    height: 22,
                    child: Row(
                      children: [
                        Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.primary : Colors.black, size: 20),
                        const SizedBox(width: 12),
                        Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                            style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    height: 22,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Text('Delete Preset', style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, size: 20, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exercisesText,
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Button.filled(
            title: 'Start Workout',
            buttonColor: const Color(0xffFFF4F4),
            side: const BorderSide(color: Color(0xffF0B5B7)),
            style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.primary),
            size: const Size(double.infinity, 35),
            raduis: 12,
            ontap: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => OwnWorkoutScreen(
                    isNewSession: false,
                    presetToStart: preset,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}