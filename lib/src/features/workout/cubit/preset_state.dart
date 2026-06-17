import 'package:customer_mobile_app/src/features/workout/domain/models/preset_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset_state.freezed.dart';

@freezed
class PresetState with _$PresetState {
  const factory PresetState({
    @Default([]) List<PresetModel> presets,
    @Default([]) List<int> favoritePresetIds,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default('') String searchQuery,
    @Default(false) bool showOnlyFavorites,
  }) = _PresetState;
}
