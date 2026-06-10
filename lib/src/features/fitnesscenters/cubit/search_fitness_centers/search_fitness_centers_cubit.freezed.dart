// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_fitness_centers_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchFitnessCentersState {
  Option<Either<ApiException, ListFitnesscenterModel>> get fitnessCenters =>
      throw _privateConstructorUsedError;

  /// Create a copy of SearchFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFitnessCentersStateCopyWith<SearchFitnessCentersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFitnessCentersStateCopyWith<$Res> {
  factory $SearchFitnessCentersStateCopyWith(
    SearchFitnessCentersState value,
    $Res Function(SearchFitnessCentersState) then,
  ) = _$SearchFitnessCentersStateCopyWithImpl<$Res, SearchFitnessCentersState>;
  @useResult
  $Res call({
    Option<Either<ApiException, ListFitnesscenterModel>> fitnessCenters,
  });
}

/// @nodoc
class _$SearchFitnessCentersStateCopyWithImpl<
  $Res,
  $Val extends SearchFitnessCentersState
>
    implements $SearchFitnessCentersStateCopyWith<$Res> {
  _$SearchFitnessCentersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fitnessCenters = null}) {
    return _then(
      _value.copyWith(
            fitnessCenters:
                null == fitnessCenters
                    ? _value.fitnessCenters
                    : fitnessCenters // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, ListFitnesscenterModel>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchFitnessCentersStateImplCopyWith<$Res>
    implements $SearchFitnessCentersStateCopyWith<$Res> {
  factory _$$SearchFitnessCentersStateImplCopyWith(
    _$SearchFitnessCentersStateImpl value,
    $Res Function(_$SearchFitnessCentersStateImpl) then,
  ) = __$$SearchFitnessCentersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, ListFitnesscenterModel>> fitnessCenters,
  });
}

/// @nodoc
class __$$SearchFitnessCentersStateImplCopyWithImpl<$Res>
    extends
        _$SearchFitnessCentersStateCopyWithImpl<
          $Res,
          _$SearchFitnessCentersStateImpl
        >
    implements _$$SearchFitnessCentersStateImplCopyWith<$Res> {
  __$$SearchFitnessCentersStateImplCopyWithImpl(
    _$SearchFitnessCentersStateImpl _value,
    $Res Function(_$SearchFitnessCentersStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fitnessCenters = null}) {
    return _then(
      _$SearchFitnessCentersStateImpl(
        fitnessCenters:
            null == fitnessCenters
                ? _value.fitnessCenters
                : fitnessCenters // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, ListFitnesscenterModel>>,
      ),
    );
  }
}

/// @nodoc

class _$SearchFitnessCentersStateImpl implements _SearchFitnessCentersState {
  const _$SearchFitnessCentersStateImpl({this.fitnessCenters = const None()});

  @override
  @JsonKey()
  final Option<Either<ApiException, ListFitnesscenterModel>> fitnessCenters;

  @override
  String toString() {
    return 'SearchFitnessCentersState(fitnessCenters: $fitnessCenters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFitnessCentersStateImpl &&
            (identical(other.fitnessCenters, fitnessCenters) ||
                other.fitnessCenters == fitnessCenters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fitnessCenters);

  /// Create a copy of SearchFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFitnessCentersStateImplCopyWith<_$SearchFitnessCentersStateImpl>
  get copyWith => __$$SearchFitnessCentersStateImplCopyWithImpl<
    _$SearchFitnessCentersStateImpl
  >(this, _$identity);
}

abstract class _SearchFitnessCentersState implements SearchFitnessCentersState {
  const factory _SearchFitnessCentersState({
    final Option<Either<ApiException, ListFitnesscenterModel>> fitnessCenters,
  }) = _$SearchFitnessCentersStateImpl;

  @override
  Option<Either<ApiException, ListFitnesscenterModel>> get fitnessCenters;

  /// Create a copy of SearchFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFitnessCentersStateImplCopyWith<_$SearchFitnessCentersStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
