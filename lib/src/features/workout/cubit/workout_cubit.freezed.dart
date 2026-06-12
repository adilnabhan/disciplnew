// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WorkoutState {
  List<Map<String, dynamic>> get exercises =>
      throw _privateConstructorUsedError;
  List<Map<String, String>> get libraryExercises =>
      throw _privateConstructorUsedError;
  List<Map<String, String>> get customExercises =>
      throw _privateConstructorUsedError;

  /// Create a copy of WorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutStateCopyWith<WorkoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutStateCopyWith<$Res> {
  factory $WorkoutStateCopyWith(
    WorkoutState value,
    $Res Function(WorkoutState) then,
  ) = _$WorkoutStateCopyWithImpl<$Res, WorkoutState>;
  @useResult
  $Res call({
    List<Map<String, dynamic>> exercises,
    List<Map<String, String>> libraryExercises,
    List<Map<String, String>> customExercises,
  });
}

/// @nodoc
class _$WorkoutStateCopyWithImpl<$Res, $Val extends WorkoutState>
    implements $WorkoutStateCopyWith<$Res> {
  _$WorkoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exercises = null,
    Object? libraryExercises = null,
    Object? customExercises = null,
  }) {
    return _then(
      _value.copyWith(
            exercises:
                null == exercises
                    ? _value.exercises
                    : exercises // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            libraryExercises:
                null == libraryExercises
                    ? _value.libraryExercises
                    : libraryExercises // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, String>>,
            customExercises:
                null == customExercises
                    ? _value.customExercises
                    : customExercises // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, String>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutStateImplCopyWith<$Res>
    implements $WorkoutStateCopyWith<$Res> {
  factory _$$WorkoutStateImplCopyWith(
    _$WorkoutStateImpl value,
    $Res Function(_$WorkoutStateImpl) then,
  ) = __$$WorkoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Map<String, dynamic>> exercises,
    List<Map<String, String>> libraryExercises,
    List<Map<String, String>> customExercises,
  });
}

/// @nodoc
class __$$WorkoutStateImplCopyWithImpl<$Res>
    extends _$WorkoutStateCopyWithImpl<$Res, _$WorkoutStateImpl>
    implements _$$WorkoutStateImplCopyWith<$Res> {
  __$$WorkoutStateImplCopyWithImpl(
    _$WorkoutStateImpl _value,
    $Res Function(_$WorkoutStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exercises = null,
    Object? libraryExercises = null,
    Object? customExercises = null,
  }) {
    return _then(
      _$WorkoutStateImpl(
        exercises:
            null == exercises
                ? _value._exercises
                : exercises // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        libraryExercises:
            null == libraryExercises
                ? _value._libraryExercises
                : libraryExercises // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, String>>,
        customExercises:
            null == customExercises
                ? _value._customExercises
                : customExercises // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, String>>,
      ),
    );
  }
}

/// @nodoc

class _$WorkoutStateImpl implements _WorkoutState {
  const _$WorkoutStateImpl({
    required final List<Map<String, dynamic>> exercises,
    required final List<Map<String, String>> libraryExercises,
    required final List<Map<String, String>> customExercises,
  }) : _exercises = exercises,
       _libraryExercises = libraryExercises,
       _customExercises = customExercises;

  final List<Map<String, dynamic>> _exercises;
  @override
  List<Map<String, dynamic>> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  final List<Map<String, String>> _libraryExercises;
  @override
  List<Map<String, String>> get libraryExercises {
    if (_libraryExercises is EqualUnmodifiableListView)
      return _libraryExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_libraryExercises);
  }

  final List<Map<String, String>> _customExercises;
  @override
  List<Map<String, String>> get customExercises {
    if (_customExercises is EqualUnmodifiableListView) return _customExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customExercises);
  }

  @override
  String toString() {
    return 'WorkoutState(exercises: $exercises, libraryExercises: $libraryExercises, customExercises: $customExercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStateImpl &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ) &&
            const DeepCollectionEquality().equals(
              other._libraryExercises,
              _libraryExercises,
            ) &&
            const DeepCollectionEquality().equals(
              other._customExercises,
              _customExercises,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_exercises),
    const DeepCollectionEquality().hash(_libraryExercises),
    const DeepCollectionEquality().hash(_customExercises),
  );

  /// Create a copy of WorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStateImplCopyWith<_$WorkoutStateImpl> get copyWith =>
      __$$WorkoutStateImplCopyWithImpl<_$WorkoutStateImpl>(this, _$identity);
}

abstract class _WorkoutState implements WorkoutState {
  const factory _WorkoutState({
    required final List<Map<String, dynamic>> exercises,
    required final List<Map<String, String>> libraryExercises,
    required final List<Map<String, String>> customExercises,
  }) = _$WorkoutStateImpl;

  @override
  List<Map<String, dynamic>> get exercises;
  @override
  List<Map<String, String>> get libraryExercises;
  @override
  List<Map<String, String>> get customExercises;

  /// Create a copy of WorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutStateImplCopyWith<_$WorkoutStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
