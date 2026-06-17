// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PresetState {
  List<PresetModel> get presets => throw _privateConstructorUsedError;
  List<int> get favoritePresetIds => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  bool get showOnlyFavorites => throw _privateConstructorUsedError;

  /// Create a copy of PresetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresetStateCopyWith<PresetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetStateCopyWith<$Res> {
  factory $PresetStateCopyWith(
    PresetState value,
    $Res Function(PresetState) then,
  ) = _$PresetStateCopyWithImpl<$Res, PresetState>;
  @useResult
  $Res call({
    List<PresetModel> presets,
    List<int> favoritePresetIds,
    bool isLoading,
    bool isSaving,
    String? errorMessage,
    String searchQuery,
    bool showOnlyFavorites,
  });
}

/// @nodoc
class _$PresetStateCopyWithImpl<$Res, $Val extends PresetState>
    implements $PresetStateCopyWith<$Res> {
  _$PresetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? presets = null,
    Object? favoritePresetIds = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
    Object? searchQuery = null,
    Object? showOnlyFavorites = null,
  }) {
    return _then(
      _value.copyWith(
            presets:
                null == presets
                    ? _value.presets
                    : presets // ignore: cast_nullable_to_non_nullable
                        as List<PresetModel>,
            favoritePresetIds:
                null == favoritePresetIds
                    ? _value.favoritePresetIds
                    : favoritePresetIds // ignore: cast_nullable_to_non_nullable
                        as List<int>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            isSaving:
                null == isSaving
                    ? _value.isSaving
                    : isSaving // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            showOnlyFavorites:
                null == showOnlyFavorites
                    ? _value.showOnlyFavorites
                    : showOnlyFavorites // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PresetStateImplCopyWith<$Res>
    implements $PresetStateCopyWith<$Res> {
  factory _$$PresetStateImplCopyWith(
    _$PresetStateImpl value,
    $Res Function(_$PresetStateImpl) then,
  ) = __$$PresetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PresetModel> presets,
    List<int> favoritePresetIds,
    bool isLoading,
    bool isSaving,
    String? errorMessage,
    String searchQuery,
    bool showOnlyFavorites,
  });
}

/// @nodoc
class __$$PresetStateImplCopyWithImpl<$Res>
    extends _$PresetStateCopyWithImpl<$Res, _$PresetStateImpl>
    implements _$$PresetStateImplCopyWith<$Res> {
  __$$PresetStateImplCopyWithImpl(
    _$PresetStateImpl _value,
    $Res Function(_$PresetStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PresetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? presets = null,
    Object? favoritePresetIds = null,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
    Object? searchQuery = null,
    Object? showOnlyFavorites = null,
  }) {
    return _then(
      _$PresetStateImpl(
        presets:
            null == presets
                ? _value._presets
                : presets // ignore: cast_nullable_to_non_nullable
                    as List<PresetModel>,
        favoritePresetIds:
            null == favoritePresetIds
                ? _value._favoritePresetIds
                : favoritePresetIds // ignore: cast_nullable_to_non_nullable
                    as List<int>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        isSaving:
            null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        showOnlyFavorites:
            null == showOnlyFavorites
                ? _value.showOnlyFavorites
                : showOnlyFavorites // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$PresetStateImpl implements _PresetState {
  const _$PresetStateImpl({
    final List<PresetModel> presets = const [],
    final List<int> favoritePresetIds = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
    this.showOnlyFavorites = false,
  }) : _presets = presets,
       _favoritePresetIds = favoritePresetIds;

  final List<PresetModel> _presets;
  @override
  @JsonKey()
  List<PresetModel> get presets {
    if (_presets is EqualUnmodifiableListView) return _presets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_presets);
  }

  final List<int> _favoritePresetIds;
  @override
  @JsonKey()
  List<int> get favoritePresetIds {
    if (_favoritePresetIds is EqualUnmodifiableListView)
      return _favoritePresetIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoritePresetIds);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool showOnlyFavorites;

  @override
  String toString() {
    return 'PresetState(presets: $presets, favoritePresetIds: $favoritePresetIds, isLoading: $isLoading, isSaving: $isSaving, errorMessage: $errorMessage, searchQuery: $searchQuery, showOnlyFavorites: $showOnlyFavorites)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetStateImpl &&
            const DeepCollectionEquality().equals(other._presets, _presets) &&
            const DeepCollectionEquality().equals(
              other._favoritePresetIds,
              _favoritePresetIds,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.showOnlyFavorites, showOnlyFavorites) ||
                other.showOnlyFavorites == showOnlyFavorites));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_presets),
    const DeepCollectionEquality().hash(_favoritePresetIds),
    isLoading,
    isSaving,
    errorMessage,
    searchQuery,
    showOnlyFavorites,
  );

  /// Create a copy of PresetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresetStateImplCopyWith<_$PresetStateImpl> get copyWith =>
      __$$PresetStateImplCopyWithImpl<_$PresetStateImpl>(this, _$identity);
}

abstract class _PresetState implements PresetState {
  const factory _PresetState({
    final List<PresetModel> presets,
    final List<int> favoritePresetIds,
    final bool isLoading,
    final bool isSaving,
    final String? errorMessage,
    final String searchQuery,
    final bool showOnlyFavorites,
  }) = _$PresetStateImpl;

  @override
  List<PresetModel> get presets;
  @override
  List<int> get favoritePresetIds;
  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  String? get errorMessage;
  @override
  String get searchQuery;
  @override
  bool get showOnlyFavorites;

  /// Create a copy of PresetState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresetStateImplCopyWith<_$PresetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
