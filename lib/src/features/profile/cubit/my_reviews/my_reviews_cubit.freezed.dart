// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_reviews_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MyReviewsState {
  ({
    Option<Either<ApiException, CustomerPostedReviewsModel>> data,
    bool isPagination,
  })
  get myReviews => throw _privateConstructorUsedError;
  Option<Either<ApiException, ActiveMembershipModel?>>
  get activeMembershipData => throw _privateConstructorUsedError;

  /// Create a copy of MyReviewsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyReviewsStateCopyWith<MyReviewsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyReviewsStateCopyWith<$Res> {
  factory $MyReviewsStateCopyWith(
    MyReviewsState value,
    $Res Function(MyReviewsState) then,
  ) = _$MyReviewsStateCopyWithImpl<$Res, MyReviewsState>;
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, CustomerPostedReviewsModel>> data,
      bool isPagination,
    })
    myReviews,
    Option<Either<ApiException, ActiveMembershipModel?>> activeMembershipData,
  });
}

/// @nodoc
class _$MyReviewsStateCopyWithImpl<$Res, $Val extends MyReviewsState>
    implements $MyReviewsStateCopyWith<$Res> {
  _$MyReviewsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyReviewsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? myReviews = null, Object? activeMembershipData = null}) {
    return _then(
      _value.copyWith(
            myReviews:
                null == myReviews
                    ? _value.myReviews
                    : myReviews // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<
                            Either<ApiException, CustomerPostedReviewsModel>
                          >
                          data,
                          bool isPagination,
                        }),
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
abstract class _$$MyReviewsStateImplCopyWith<$Res>
    implements $MyReviewsStateCopyWith<$Res> {
  factory _$$MyReviewsStateImplCopyWith(
    _$MyReviewsStateImpl value,
    $Res Function(_$MyReviewsStateImpl) then,
  ) = __$$MyReviewsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, CustomerPostedReviewsModel>> data,
      bool isPagination,
    })
    myReviews,
    Option<Either<ApiException, ActiveMembershipModel?>> activeMembershipData,
  });
}

/// @nodoc
class __$$MyReviewsStateImplCopyWithImpl<$Res>
    extends _$MyReviewsStateCopyWithImpl<$Res, _$MyReviewsStateImpl>
    implements _$$MyReviewsStateImplCopyWith<$Res> {
  __$$MyReviewsStateImplCopyWithImpl(
    _$MyReviewsStateImpl _value,
    $Res Function(_$MyReviewsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyReviewsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? myReviews = null, Object? activeMembershipData = null}) {
    return _then(
      _$MyReviewsStateImpl(
        myReviews:
            null == myReviews
                ? _value.myReviews
                : myReviews // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, CustomerPostedReviewsModel>>
                      data,
                      bool isPagination,
                    }),
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

class _$MyReviewsStateImpl implements _MyReviewsState {
  const _$MyReviewsStateImpl({
    this.myReviews = const (data: None(), isPagination: false),
    this.activeMembershipData = const None(),
  });

  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, CustomerPostedReviewsModel>> data,
    bool isPagination,
  })
  myReviews;
  @override
  @JsonKey()
  final Option<Either<ApiException, ActiveMembershipModel?>>
  activeMembershipData;

  @override
  String toString() {
    return 'MyReviewsState(myReviews: $myReviews, activeMembershipData: $activeMembershipData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyReviewsStateImpl &&
            (identical(other.myReviews, myReviews) ||
                other.myReviews == myReviews) &&
            (identical(other.activeMembershipData, activeMembershipData) ||
                other.activeMembershipData == activeMembershipData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, myReviews, activeMembershipData);

  /// Create a copy of MyReviewsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyReviewsStateImplCopyWith<_$MyReviewsStateImpl> get copyWith =>
      __$$MyReviewsStateImplCopyWithImpl<_$MyReviewsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MyReviewsState implements MyReviewsState {
  const factory _MyReviewsState({
    final ({
      Option<Either<ApiException, CustomerPostedReviewsModel>> data,
      bool isPagination,
    })
    myReviews,
    final Option<Either<ApiException, ActiveMembershipModel?>>
    activeMembershipData,
  }) = _$MyReviewsStateImpl;

  @override
  ({
    Option<Either<ApiException, CustomerPostedReviewsModel>> data,
    bool isPagination,
  })
  get myReviews;
  @override
  Option<Either<ApiException, ActiveMembershipModel?>> get activeMembershipData;

  /// Create a copy of MyReviewsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyReviewsStateImplCopyWith<_$MyReviewsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
