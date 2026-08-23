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
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'slug')
  String? get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'active')
  bool? get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool? get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'registration_status')
  String? get registrationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<Category>? get categories => throw _privateConstructorUsedError;
  @JsonKey(name: 'category')
  List<Category>? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  Location? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'mentor_name')
  String? get mentorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'distance_km')
  double? get distanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  dynamic get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  dynamic get longitude => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'registration_status') String? registrationStatus,
    @JsonKey(name: 'categories') List<Category>? categories,
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'mentor_name') String? mentorName,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
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
    Object? description = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? logo = freezed,
    Object? slug = freezed,
    Object? active = freezed,
    Object? isPublic = freezed,
    Object? registrationStatus = freezed,
    Object? categories = freezed,
    Object? category = freezed,
    Object? location = freezed,
    Object? mentorName = freezed,
    Object? reviewCount = freezed,
    Object? averageRating = freezed,
    Object? createdAt = freezed,
    Object? distanceKm = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
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
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            slug:
                freezed == slug
                    ? _value.slug
                    : slug // ignore: cast_nullable_to_non_nullable
                        as String?,
            active:
                freezed == active
                    ? _value.active
                    : active // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isPublic:
                freezed == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
                        as bool?,
            registrationStatus:
                freezed == registrationStatus
                    ? _value.registrationStatus
                    : registrationStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            categories:
                freezed == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<Category>?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as List<Category>?,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as Location?,
            mentorName:
                freezed == mentorName
                    ? _value.mentorName
                    : mentorName // ignore: cast_nullable_to_non_nullable
                        as String?,
            reviewCount:
                freezed == reviewCount
                    ? _value.reviewCount
                    : reviewCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            averageRating:
                freezed == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as double?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            distanceKm:
                freezed == distanceKm
                    ? _value.distanceKm
                    : distanceKm // ignore: cast_nullable_to_non_nullable
                        as double?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
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
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'registration_status') String? registrationStatus,
    @JsonKey(name: 'categories') List<Category>? categories,
    @JsonKey(name: 'category') List<Category>? category,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'mentor_name') String? mentorName,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
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
    Object? description = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? logo = freezed,
    Object? slug = freezed,
    Object? active = freezed,
    Object? isPublic = freezed,
    Object? registrationStatus = freezed,
    Object? categories = freezed,
    Object? category = freezed,
    Object? location = freezed,
    Object? mentorName = freezed,
    Object? reviewCount = freezed,
    Object? averageRating = freezed,
    Object? createdAt = freezed,
    Object? distanceKm = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
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
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        slug:
            freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                    as String?,
        active:
            freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isPublic:
            freezed == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                    as bool?,
        registrationStatus:
            freezed == registrationStatus
                ? _value.registrationStatus
                : registrationStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        categories:
            freezed == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<Category>?,
        category:
            freezed == category
                ? _value._category
                : category // ignore: cast_nullable_to_non_nullable
                    as List<Category>?,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as Location?,
        mentorName:
            freezed == mentorName
                ? _value.mentorName
                : mentorName // ignore: cast_nullable_to_non_nullable
                    as String?,
        reviewCount:
            freezed == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        averageRating:
            freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as double?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        distanceKm:
            freezed == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                    as double?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleFItnessCenterModelImpl extends _SingleFItnessCenterModel {
  const _$SingleFItnessCenterModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'phone_number') this.phoneNumber,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'slug') this.slug,
    @JsonKey(name: 'active') this.active,
    @JsonKey(name: 'is_public') this.isPublic,
    @JsonKey(name: 'registration_status') this.registrationStatus,
    @JsonKey(name: 'categories') final List<Category>? categories,
    @JsonKey(name: 'category') final List<Category>? category,
    @JsonKey(name: 'location') this.location,
    @JsonKey(name: 'mentor_name') this.mentorName,
    @JsonKey(name: 'review_count') this.reviewCount,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'distance_km') this.distanceKm,
    @JsonKey(name: 'latitude') this.latitude,
    @JsonKey(name: 'longitude') this.longitude,
  }) : _categories = categories,
       _category = category,
       super._();

  factory _$SingleFItnessCenterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleFItnessCenterModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'slug')
  final String? slug;
  @override
  @JsonKey(name: 'active')
  final bool? active;
  @override
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  @override
  @JsonKey(name: 'registration_status')
  final String? registrationStatus;
  final List<Category>? _categories;
  @override
  @JsonKey(name: 'categories')
  List<Category>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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

  @override
  @JsonKey(name: 'location')
  final Location? location;
  @override
  @JsonKey(name: 'mentor_name')
  final String? mentorName;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  @override
  @JsonKey(name: 'latitude')
  final dynamic latitude;
  @override
  @JsonKey(name: 'longitude')
  final dynamic longitude;

  @override
  String toString() {
    return 'SingleFItnessCenterModel(id: $id, name: $name, description: $description, email: $email, phoneNumber: $phoneNumber, logo: $logo, slug: $slug, active: $active, isPublic: $isPublic, registrationStatus: $registrationStatus, categories: $categories, category: $category, location: $location, mentorName: $mentorName, reviewCount: $reviewCount, averageRating: $averageRating, createdAt: $createdAt, distanceKm: $distanceKm, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleFItnessCenterModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.registrationStatus, registrationStatus) ||
                other.registrationStatus == registrationStatus) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._category, _category) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.mentorName, mentorName) ||
                other.mentorName == mentorName) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            const DeepCollectionEquality().equals(other.latitude, latitude) &&
            const DeepCollectionEquality().equals(other.longitude, longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    email,
    phoneNumber,
    logo,
    slug,
    active,
    isPublic,
    registrationStatus,
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_category),
    location,
    mentorName,
    reviewCount,
    averageRating,
    createdAt,
    distanceKm,
    const DeepCollectionEquality().hash(latitude),
    const DeepCollectionEquality().hash(longitude),
  ]);

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

abstract class _SingleFItnessCenterModel extends SingleFItnessCenterModel {
  const factory _SingleFItnessCenterModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'phone_number') final String? phoneNumber,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'slug') final String? slug,
    @JsonKey(name: 'active') final bool? active,
    @JsonKey(name: 'is_public') final bool? isPublic,
    @JsonKey(name: 'registration_status') final String? registrationStatus,
    @JsonKey(name: 'categories') final List<Category>? categories,
    @JsonKey(name: 'category') final List<Category>? category,
    @JsonKey(name: 'location') final Location? location,
    @JsonKey(name: 'mentor_name') final String? mentorName,
    @JsonKey(name: 'review_count') final int? reviewCount,
    @JsonKey(name: 'average_rating') final double? averageRating,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'distance_km') final double? distanceKm,
    @JsonKey(name: 'latitude') final dynamic latitude,
    @JsonKey(name: 'longitude') final dynamic longitude,
  }) = _$SingleFItnessCenterModelImpl;
  const _SingleFItnessCenterModel._() : super._();

  factory _SingleFItnessCenterModel.fromJson(Map<String, dynamic> json) =
      _$SingleFItnessCenterModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'slug')
  String? get slug;
  @override
  @JsonKey(name: 'active')
  bool? get active;
  @override
  @JsonKey(name: 'is_public')
  bool? get isPublic;
  @override
  @JsonKey(name: 'registration_status')
  String? get registrationStatus;
  @override
  @JsonKey(name: 'categories')
  List<Category>? get categories;
  @override
  @JsonKey(name: 'category')
  List<Category>? get category;
  @override
  @JsonKey(name: 'location')
  Location? get location;
  @override
  @JsonKey(name: 'mentor_name')
  String? get mentorName;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'distance_km')
  double? get distanceKm;
  @override
  @JsonKey(name: 'latitude')
  dynamic get latitude;
  @override
  @JsonKey(name: 'longitude')
  dynamic get longitude;

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
