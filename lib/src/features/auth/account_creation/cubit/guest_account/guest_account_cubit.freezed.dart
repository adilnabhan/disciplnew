// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_account_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GuestAccountState {
  Option<Either<ApiException, LoginSuccessModel?>>? get guestLogin =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of GuestAccountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuestAccountStateCopyWith<GuestAccountState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuestAccountStateCopyWith<$Res> {
  factory $GuestAccountStateCopyWith(
    GuestAccountState value,
    $Res Function(GuestAccountState) then,
  ) = _$GuestAccountStateCopyWithImpl<$Res, GuestAccountState>;
  @useResult
  $Res call({
    Option<Either<ApiException, LoginSuccessModel?>>? guestLogin,
    bool isLoading,
  });
}

/// @nodoc
class _$GuestAccountStateCopyWithImpl<$Res, $Val extends GuestAccountState>
    implements $GuestAccountStateCopyWith<$Res> {
  _$GuestAccountStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuestAccountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? guestLogin = freezed, Object? isLoading = null}) {
    return _then(
      _value.copyWith(
            guestLogin:
                freezed == guestLogin
                    ? _value.guestLogin
                    : guestLogin // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, LoginSuccessModel?>>?,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GuestAccountStateImplCopyWith<$Res>
    implements $GuestAccountStateCopyWith<$Res> {
  factory _$$GuestAccountStateImplCopyWith(
    _$GuestAccountStateImpl value,
    $Res Function(_$GuestAccountStateImpl) then,
  ) = __$$GuestAccountStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, LoginSuccessModel?>>? guestLogin,
    bool isLoading,
  });
}

/// @nodoc
class __$$GuestAccountStateImplCopyWithImpl<$Res>
    extends _$GuestAccountStateCopyWithImpl<$Res, _$GuestAccountStateImpl>
    implements _$$GuestAccountStateImplCopyWith<$Res> {
  __$$GuestAccountStateImplCopyWithImpl(
    _$GuestAccountStateImpl _value,
    $Res Function(_$GuestAccountStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuestAccountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? guestLogin = freezed, Object? isLoading = null}) {
    return _then(
      _$GuestAccountStateImpl(
        guestLogin:
            freezed == guestLogin
                ? _value.guestLogin
                : guestLogin // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, LoginSuccessModel?>>?,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$GuestAccountStateImpl implements _GuestAccountState {
  const _$GuestAccountStateImpl({this.guestLogin, this.isLoading = false});

  @override
  final Option<Either<ApiException, LoginSuccessModel?>>? guestLogin;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'GuestAccountState(guestLogin: $guestLogin, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuestAccountStateImpl &&
            (identical(other.guestLogin, guestLogin) ||
                other.guestLogin == guestLogin) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, guestLogin, isLoading);

  /// Create a copy of GuestAccountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuestAccountStateImplCopyWith<_$GuestAccountStateImpl> get copyWith =>
      __$$GuestAccountStateImplCopyWithImpl<_$GuestAccountStateImpl>(
        this,
        _$identity,
      );
}

abstract class _GuestAccountState implements GuestAccountState {
  const factory _GuestAccountState({
    final Option<Either<ApiException, LoginSuccessModel?>>? guestLogin,
    final bool isLoading,
  }) = _$GuestAccountStateImpl;

  @override
  Option<Either<ApiException, LoginSuccessModel?>>? get guestLogin;
  @override
  bool get isLoading;

  /// Create a copy of GuestAccountState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuestAccountStateImplCopyWith<_$GuestAccountStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
