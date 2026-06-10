// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileState {
  Option<Either<ApiException, CustomerDetailsModel>> get customerDetails =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get updateProfileDetails =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, ConstantChoicesModel>>? get constChoice =>
      throw _privateConstructorUsedError;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
    ProfileState value,
    $Res Function(ProfileState) then,
  ) = _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call({
    Option<Either<ApiException, CustomerDetailsModel>> customerDetails,
    Option<Either<ApiException, void>>? updateProfileDetails,
    Option<Either<ApiException, ConstantChoicesModel>>? constChoice,
  });
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerDetails = null,
    Object? updateProfileDetails = freezed,
    Object? constChoice = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerDetails:
                null == customerDetails
                    ? _value.customerDetails
                    : customerDetails // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, CustomerDetailsModel>>,
            updateProfileDetails:
                freezed == updateProfileDetails
                    ? _value.updateProfileDetails
                    : updateProfileDetails // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, void>>?,
            constChoice:
                freezed == constChoice
                    ? _value.constChoice
                    : constChoice // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, ConstantChoicesModel>>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
    _$ProfileStateImpl value,
    $Res Function(_$ProfileStateImpl) then,
  ) = __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, CustomerDetailsModel>> customerDetails,
    Option<Either<ApiException, void>>? updateProfileDetails,
    Option<Either<ApiException, ConstantChoicesModel>>? constChoice,
  });
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
    _$ProfileStateImpl _value,
    $Res Function(_$ProfileStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerDetails = null,
    Object? updateProfileDetails = freezed,
    Object? constChoice = freezed,
  }) {
    return _then(
      _$ProfileStateImpl(
        customerDetails:
            null == customerDetails
                ? _value.customerDetails
                : customerDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, CustomerDetailsModel>>,
        updateProfileDetails:
            freezed == updateProfileDetails
                ? _value.updateProfileDetails
                : updateProfileDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, void>>?,
        constChoice:
            freezed == constChoice
                ? _value.constChoice
                : constChoice // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, ConstantChoicesModel>>?,
      ),
    );
  }
}

/// @nodoc

class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl({
    this.customerDetails = const None(),
    this.updateProfileDetails,
    this.constChoice,
  });

  @override
  @JsonKey()
  final Option<Either<ApiException, CustomerDetailsModel>> customerDetails;
  @override
  final Option<Either<ApiException, void>>? updateProfileDetails;
  @override
  final Option<Either<ApiException, ConstantChoicesModel>>? constChoice;

  @override
  String toString() {
    return 'ProfileState(customerDetails: $customerDetails, updateProfileDetails: $updateProfileDetails, constChoice: $constChoice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.customerDetails, customerDetails) ||
                other.customerDetails == customerDetails) &&
            (identical(other.updateProfileDetails, updateProfileDetails) ||
                other.updateProfileDetails == updateProfileDetails) &&
            (identical(other.constChoice, constChoice) ||
                other.constChoice == constChoice));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerDetails,
    updateProfileDetails,
    constChoice,
  );

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState({
    final Option<Either<ApiException, CustomerDetailsModel>> customerDetails,
    final Option<Either<ApiException, void>>? updateProfileDetails,
    final Option<Either<ApiException, ConstantChoicesModel>>? constChoice,
  }) = _$ProfileStateImpl;

  @override
  Option<Either<ApiException, CustomerDetailsModel>> get customerDetails;
  @override
  Option<Either<ApiException, void>>? get updateProfileDetails;
  @override
  Option<Either<ApiException, ConstantChoicesModel>>? get constChoice;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
