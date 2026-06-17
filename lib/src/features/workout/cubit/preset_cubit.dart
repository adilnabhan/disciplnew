import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/workout/domain/domain.dart';
import 'preset_state.dart';

class PresetCubit extends Cubit<PresetState> {
  PresetCubit() : super(const PresetState()) {
    loadPresets();
  }

  Future<void> loadPresets() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await WorkoutRepository().getPresets();
    result.fold(
      (error) => emit(state.copyWith(
        isLoading: false,
        errorMessage: error.msg ?? 'Failed to load presets',
      )),
      (list) => emit(state.copyWith(
        isLoading: false,
        presets: list,
      )),
    );
  }

  Future<bool> createPreset({
    required String title,
    required List<Map<String, dynamic>> exercises,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await WorkoutRepository().createPreset(
      title: title,
      exercises: exercises,
    );
    return result.fold(
      (error) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: error.msg ?? 'Failed to create preset',
        ));
        return false;
      },
      (newPreset) {
        emit(state.copyWith(isSaving: false));
        loadPresets();
        return true;
      },
    );
  }

  Future<bool> updatePreset({
    required int presetId,
    required String title,
    required List<Map<String, dynamic>> exercises,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await WorkoutRepository().updatePreset(
      presetId: presetId,
      title: title,
      exercises: exercises,
    );
    return result.fold(
      (error) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: error.msg ?? 'Failed to update preset',
        ));
        return false;
      },
      (updatedPreset) {
        emit(state.copyWith(isSaving: false));
        loadPresets();
        return true;
      },
    );
  }

  Future<bool> deletePreset(int presetId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await WorkoutRepository().deletePreset(presetId: presetId);
    return result.fold(
      (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.msg ?? 'Failed to delete preset',
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(isLoading: false));
        loadPresets();
        return true;
      },
    );
  }

  void toggleFavorite(int presetId) {
    final updatedFavorites = List<int>.from(state.favoritePresetIds);
    if (updatedFavorites.contains(presetId)) {
      updatedFavorites.remove(presetId);
    } else {
      updatedFavorites.add(presetId);
    }
    emit(state.copyWith(favoritePresetIds: updatedFavorites));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleShowOnlyFavorites() {
    emit(state.copyWith(showOnlyFavorites: !state.showOnlyFavorites));
  }

  List<PresetModel> get filteredPresets {
    var list = state.presets;
    if (state.showOnlyFavorites) {
      list = list.where((p) => state.favoritePresetIds.contains(p.id)).toList();
    }
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(query)).toList();
    }
    return list;
  }
}
