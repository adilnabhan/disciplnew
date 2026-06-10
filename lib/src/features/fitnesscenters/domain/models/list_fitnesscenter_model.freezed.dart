// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_fitnesscenter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ListFitnesscenterModel _$ListFitnesscenterModelFromJson(
  Map<String, dynamic> json,
) {
  return _ListFitnesscenterModel.fromJson(json);
}

/// @nodoc
mixin _$ListFitnesscenterModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  dynamic get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<SingleFItnessCenterModel>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this ListFitnesscenterModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListFitnesscenterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListFitnesscenterModelCopyWith<ListFitnesscenterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListFitnesscenterModelCopyWith<$Res> {
  factory $ListFitnesscenterModelCopyWith(
    ListFitnesscenterModel value,
    $Res Function(ListFitnesscenterModel) then,
  ) = _$ListFitnesscenterModelCopyWithImpl<$Res, ListFitnesscenterModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<SingleFItnessCenterModel>? results,
  });
}

/// @nodoc
class _$ListFitnesscenterModelCopyWithImpl<
  $Res,
  $Val extends ListFitnesscenterModel
>
    implements $ListFitnesscenterModelCopyWith<$Res> {
  _$ListFitnesscenterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListFitnesscenterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _value.copyWith(
            count:
                freezed == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int?,
            next:
                freezed == next
                    ? _value.next
                    : next // ignore: cast_nullable_to_non_nullable
                        as String?,
            previous:
                freezed == previous
                    ? _value.previous
                    : previous // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<SingleFItnessCenterModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListFitnesscenterModelImplCopyWith<$Res>
    implements $ListFitnesscenterModelCopyWith<$Res> {
  factory _$$ListFitnesscenterModelImplCopyWith(
    _$ListFitnesscenterModelImpl value,
    $Res Function(_$ListFitnesscenterModelImpl) then,
  ) = __$$ListFitnesscenterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<SingleFItnessCenterModel>? results,
  });
}

/// @nodoc
class __$$ListFitnesscenterModelImplCopyWithImpl<$Res>
    extends
        _$ListFitnesscenterModelCopyWithImpl<$Res, _$ListFitnesscenterModelImpl>
    implements _$$ListFitnesscenterModelImplCopyWith<$Res> {
  __$$ListFitnesscenterModelImplCopyWithImpl(
    _$ListFitnesscenterModelImpl _value,
    $Res Function(_$ListFitnesscenterModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListFitnesscenterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? next = freezed,
    Object? previous = freezed,
    Object? results = freezed,
  }) {
    return _then(
      _$ListFitnesscenterModelImpl(
        count:
            freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int?,
        next:
            freezed == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                    as String?,
        previous:
            freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<SingleFItnessCenterModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ListFitnesscenterModelImpl implements _ListFitnesscenterModel {
  const _$ListFitnesscenterModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') final List<SingleFItnessCenterModel>? results,
  }) : _results = results;

  factory _$ListFitnesscenterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListFitnesscenterModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final dynamic previous;
  final List<SingleFItnessCenterModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<SingleFItnessCenterModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ListFitnesscenterModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListFitnesscenterModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            const DeepCollectionEquality().equals(other.previous, previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    next,
    const DeepCollectionEquality().hash(previous),
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of ListFitnesscenterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListFitnesscenterModelImplCopyWith<_$ListFitnesscenterModelImpl>
  get copyWith =>
      __$$ListFitnesscenterModelImplCopyWithImpl<_$ListFitnesscenterModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ListFitnesscenterModelImplToJson(this);
  }
}

abstract class _ListFitnesscenterModel implements ListFitnesscenterModel {
  const factory _ListFitnesscenterModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final dynamic previous,
    @JsonKey(name: 'results') final List<SingleFItnessCenterModel>? results,
  }) = _$ListFitnesscenterModelImpl;

  factory _ListFitnesscenterModel.fromJson(Map<String, dynamic> json) =
      _$ListFitnesscenterModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  dynamic get previous;
  @override
  @JsonKey(name: 'results')
  List<SingleFItnessCenterModel>? get results;

  /// Create a copy of ListFitnesscenterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListFitnesscenterModelImplCopyWith<_$ListFitnesscenterModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SingleFItnessCenterModel _$SingleFItnessCenterModelFromJson(
  Map<String, dynamic> json,
) {
  return _SingleFItnessCenterModel.fromJson(json);
}

/// @nodoc
mixin _$SingleFItnessCenterModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  Location? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'category')
  List<Category>? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'services')
  List<Service>? get services => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_slot_available')
  bool? get isSlotAvailable => throw _privateConstructorUsedError;

  /// Serializes this SingleFItnessCenterModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleFItnessCenterModelCopyWith<SingleFItnessCenterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleFItnessCenterModelCopyWith<$Res> {
  factory $SingleFItnessCenterModelCopyWith(
    SingleFItnessCenterModel value,
    $Res Function(SingleFItnessCenterModel) then,
  ) = _$SingleFItnessCenterModelCopyWithImpl<$Res, SingleFItnessCenterModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'services') List<Service>? services,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'is_slot_available') bool? isSlotAvailable,
  });

  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$SingleFItnessCenterModelCopyWithImpl<
  $Res,
  $Val extends SingleFItnessCenterModel
>
    implements $SingleFItnessCenterModelCopyWith<$Res> {
  _$SingleFItnessCenterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? description = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? location = freezed,
    Object? category = freezed,
    Object? services = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = freezed,
    Object? isSlotAvailable = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as Location?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as List<Category>?,
            services:
                freezed == services
                    ? _value.services
                    : services // ignore: cast_nullable_to_non_nullable
                        as List<Service>?,
            averageRating:
                freezed == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as double?,
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            isSlotAvailable:
                freezed == isSlotAvailable
                    ? _value.isSlotAvailable
                    : isSlotAvailable // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SingleFItnessCenterModelImplCopyWith<$Res>
    implements $SingleFItnessCenterModelCopyWith<$Res> {
  factory _$$SingleFItnessCenterModelImplCopyWith(
    _$SingleFItnessCenterModelImpl value,
    $Res Function(_$SingleFItnessCenterModelImpl) then,
  ) = __$$SingleFItnessCenterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'services') List<Service>? services,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'is_slot_available') bool? isSlotAvailable,
  });

  @override
  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$SingleFItnessCenterModelImplCopyWithImpl<$Res>
    extends
        _$SingleFItnessCenterModelCopyWithImpl<
          $Res,
          _$SingleFItnessCenterModelImpl
        >
    implements _$$SingleFItnessCenterModelImplCopyWith<$Res> {
  __$$SingleFItnessCenterModelImplCopyWithImpl(
    _$SingleFItnessCenterModelImpl _value,
    $Res Function(_$SingleFItnessCenterModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? description = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? location = freezed,
    Object? category = freezed,
    Object? services = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = freezed,
    Object? isSlotAvailable = freezed,
  }) {
    return _then(
      _$SingleFItnessCenterModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as Location?,
        category:
            freezed == category
                ? _value._category
                : category // ignore: cast_nullable_to_non_nullable
                    as List<Category>?,
        services:
            freezed == services
                ? _value._services
                : services // ignore: cast_nullable_to_non_nullable
                    as List<Service>?,
        averageRating:
            freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as double?,
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        isSlotAvailable:
            freezed == isSlotAvailable
                ? _value.isSlotAvailable
                : isSlotAvailable // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleFItnessCenterModelImpl implements _SingleFItnessCenterModel {
  const _$SingleFItnessCenterModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'phone_number') this.phoneNumber,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'location') this.location,
    @JsonKey(name: 'category') final List<Category>? category,
    @JsonKey(name: 'services') final List<Service>? services,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'is_slot_available') this.isSlotAvailable,
  }) : _category = category,
       _services = services;

  factory _$SingleFItnessCenterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleFItnessCenterModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'location')
  final Location? location;
  final List<Category>? _category;
  @override
  @JsonKey(name: 'category')
  List<Category>? get category {
    final value = _category;
    if (value == null) return null;
    if (_category is EqualUnmodifiableListView) return _category;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Service>? _services;
  @override
  @JsonKey(name: 'services')
  List<Service>? get services {
    final value = _services;
    if (value == null) return null;
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'is_slot_available')
  final bool? isSlotAvailable;

  @override
  String toString() {
    return 'SingleFItnessCenterModel(id: $id, name: $name, logo: $logo, description: $description, phoneNumber: $phoneNumber, email: $email, location: $location, category: $category, services: $services, averageRating: $averageRating, reviewCount: $reviewCount, isSlotAvailable: $isSlotAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleFItnessCenterModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._category, _category) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isSlotAvailable, isSlotAvailable) ||
                other.isSlotAvailable == isSlotAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    logo,
    description,
    phoneNumber,
    email,
    location,
    const DeepCollectionEquality().hash(_category),
    const DeepCollectionEquality().hash(_services),
    averageRating,
    reviewCount,
    isSlotAvailable,
  );

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleFItnessCenterModelImplCopyWith<_$SingleFItnessCenterModelImpl>
  get copyWith => __$$SingleFItnessCenterModelImplCopyWithImpl<
    _$SingleFItnessCenterModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleFItnessCenterModelImplToJson(this);
  }
}

abstract class _SingleFItnessCenterModel implements SingleFItnessCenterModel {
  const factory _SingleFItnessCenterModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'phone_number') final String? phoneNumber,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'location') final Location? location,
    @JsonKey(name: 'category') final List<Category>? category,
    @JsonKey(name: 'services') final List<Service>? services,
    @JsonKey(name: 'average_rating') final double? averageRating,
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'is_slot_available') final bool? isSlotAvailable,
  }) = _$SingleFItnessCenterModelImpl;

  factory _SingleFItnessCenterModel.fromJson(Map<String, dynamic> json) =
      _$SingleFItnessCenterModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'location')
  Location? get location;
  @override
  @JsonKey(name: 'category')
  List<Category>? get category;
  @override
  @JsonKey(name: 'services')
  List<Service>? get services;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'is_slot_available')
  bool? get isSlotAvailable;

  /// Create a copy of SingleFItnessCenterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleFItnessCenterModelImplCopyWith<_$SingleFItnessCenterModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return _Category.fromJson(json);
}

/// @nodoc
mixin _$Category {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
    _$CategoryImpl value,
    $Res Function(_$CategoryImpl) then,
  ) = __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
    _$CategoryImpl _value,
    $Res Function(_$CategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _$CategoryImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryImpl implements _Category {
  const _$CategoryImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
  });

  factory _$CategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryImplToJson(this);
  }
}

abstract class _Category implements Category {
  const factory _Category({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
  }) = _$CategoryImpl;

  factory _Category.fromJson(Map<String, dynamic> json) =
      _$CategoryImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Service _$ServiceFromJson(Map<String, dynamic> json) {
  return _Service.fromJson(json);
}

/// @nodoc
mixin _$Service {
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCopyWith<Service> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCopyWith<$Res> {
  factory $ServiceCopyWith(Service value, $Res Function(Service) then) =
      _$ServiceCopyWithImpl<$Res, Service>;
  @useResult
  $Res call({@JsonKey(name: 'name') String? name});
}

/// @nodoc
class _$ServiceCopyWithImpl<$Res, $Val extends Service>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed}) {
    return _then(
      _value.copyWith(
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceImplCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$$ServiceImplCopyWith(
    _$ServiceImpl value,
    $Res Function(_$ServiceImpl) then,
  ) = __$$ServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'name') String? name});
}

/// @nodoc
class __$$ServiceImplCopyWithImpl<$Res>
    extends _$ServiceCopyWithImpl<$Res, _$ServiceImpl>
    implements _$$ServiceImplCopyWith<$Res> {
  __$$ServiceImplCopyWithImpl(
    _$ServiceImpl _value,
    $Res Function(_$ServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed}) {
    return _then(
      _$ServiceImpl(
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceImpl implements _Service {
  const _$ServiceImpl({@JsonKey(name: 'name') this.name});

  factory _$ServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceImplFromJson(json);

  @override
  @JsonKey(name: 'name')
  final String? name;

  @override
  String toString() {
    return 'Service(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      __$$ServiceImplCopyWithImpl<_$ServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceImplToJson(this);
  }
}

abstract class _Service implements Service {
  const factory _Service({@JsonKey(name: 'name') final String? name}) =
      _$ServiceImpl;

  factory _Service.fromJson(Map<String, dynamic> json) = _$ServiceImpl.fromJson;

  @override
  @JsonKey(name: 'name')
  String? get name;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
