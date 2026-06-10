// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DashboardState {
  int get navIndex => throw _privateConstructorUsedError;
  Option<Either<ApiException, ActiveMembershipModel?>>
  get activeMembershipData => throw _privateConstructorUsedError;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
    DashboardState value,
    $Res Function(DashboardState) then,
  ) = _$DashboardStateCopyWithImpl<$Res, DashboardState>;
  @useResult
  $Res call({
    int navIndex,
    Option<Either<ApiException, ActiveMembershipModel?>> activeMembershipData,
  });
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res, $Val extends DashboardState>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? navIndex = null, Object? activeMembershipData = null}) {
    return _then(
      _value.copyWith(
            navIndex:
                null == navIndex
                    ? _value.navIndex
                    : navIndex // ignore: cast_nullable_to_non_nullable
                        as int,
            activeMembershipData:
                null == activeMembershipData
                    ? _value.activeMembershipData
                    : activeMembershipData // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, ActiveMembershipModel?>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardStateImplCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$$DashboardStateImplCopyWith(
    _$DashboardStateImpl value,
    $Res Function(_$DashboardStateImpl) then,
  ) = __$$DashboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int navIndex,
    Option<Either<ApiException, ActiveMembershipModel?>> activeMembershipData,
  });
}

/// @nodoc
class __$$DashboardStateImplCopyWithImpl<$Res>
    extends _$DashboardStateCopyWithImpl<$Res, _$DashboardStateImpl>
    implements _$$DashboardStateImplCopyWith<$Res> {
  __$$DashboardStateImplCopyWithImpl(
    _$DashboardStateImpl _value,
    $Res Function(_$DashboardStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? navIndex = null, Object? activeMembershipData = null}) {
    return _then(
      _$DashboardStateImpl(
        navIndex:
            null == navIndex
                ? _value.navIndex
                : navIndex // ignore: cast_nullable_to_non_nullable
                    as int,
        activeMembershipData:
            null == activeMembershipData
                ? _value.activeMembershipData
                : activeMembershipData // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, ActiveMembershipModel?>>,
      ),
    );
  }
}

/// @nodoc

class _$DashboardStateImpl implements _DashboardState {
  const _$DashboardStateImpl({
    this.navIndex = 0,
    this.activeMembershipData = const None(),
  });

  @override
  @JsonKey()
  final int navIndex;
  @override
  @JsonKey()
  final Option<Either<ApiException, ActiveMembershipModel?>>
  activeMembershipData;

  @override
  String toString() {
    return 'DashboardState(navIndex: $navIndex, activeMembershipData: $activeMembershipData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStateImpl &&
            (identical(other.navIndex, navIndex) ||
                other.navIndex == navIndex) &&
            (identical(other.activeMembershipData, activeMembershipData) ||
                other.activeMembershipData == activeMembershipData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, navIndex, activeMembershipData);

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      __$$DashboardStateImplCopyWithImpl<_$DashboardStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DashboardState implements DashboardState {
  const factory _DashboardState({
    final int navIndex,
    final Option<Either<ApiException, ActiveMembershipModel?>>
    activeMembershipData,
  }) = _$DashboardStateImpl;

  @override
  int get navIndex;
  @override
  Option<Either<ApiException, ActiveMembershipModel?>> get activeMembershipData;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
