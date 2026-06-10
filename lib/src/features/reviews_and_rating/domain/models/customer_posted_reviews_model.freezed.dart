// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_posted_reviews_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerPostedReviewsModel _$CustomerPostedReviewsModelFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerPostedReviewsModel.fromJson(json);
}

/// @nodoc
mixin _$CustomerPostedReviewsModel {
  @JsonKey(name: 'count')
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'next')
  String? get next => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous')
  String? get previous => throw _privateConstructorUsedError;
  @JsonKey(name: 'results')
  List<SingleReviewModel>? get results => throw _privateConstructorUsedError;

  /// Serializes this CustomerPostedReviewsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerPostedReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerPostedReviewsModelCopyWith<CustomerPostedReviewsModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerPostedReviewsModelCopyWith<$Res> {
  factory $CustomerPostedReviewsModelCopyWith(
    CustomerPostedReviewsModel value,
    $Res Function(CustomerPostedReviewsModel) then,
  ) =
      _$CustomerPostedReviewsModelCopyWithImpl<
        $Res,
        CustomerPostedReviewsModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SingleReviewModel>? results,
  });
}

/// @nodoc
class _$CustomerPostedReviewsModelCopyWithImpl<
  $Res,
  $Val extends CustomerPostedReviewsModel
>
    implements $CustomerPostedReviewsModelCopyWith<$Res> {
  _$CustomerPostedReviewsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerPostedReviewsModel
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
                        as String?,
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<SingleReviewModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerPostedReviewsModelImplCopyWith<$Res>
    implements $CustomerPostedReviewsModelCopyWith<$Res> {
  factory _$$CustomerPostedReviewsModelImplCopyWith(
    _$CustomerPostedReviewsModelImpl value,
    $Res Function(_$CustomerPostedReviewsModelImpl) then,
  ) = __$$CustomerPostedReviewsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<SingleReviewModel>? results,
  });
}

/// @nodoc
class __$$CustomerPostedReviewsModelImplCopyWithImpl<$Res>
    extends
        _$CustomerPostedReviewsModelCopyWithImpl<
          $Res,
          _$CustomerPostedReviewsModelImpl
        >
    implements _$$CustomerPostedReviewsModelImplCopyWith<$Res> {
  __$$CustomerPostedReviewsModelImplCopyWithImpl(
    _$CustomerPostedReviewsModelImpl _value,
    $Res Function(_$CustomerPostedReviewsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerPostedReviewsModel
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
      _$CustomerPostedReviewsModelImpl(
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
                    as String?,
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<SingleReviewModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerPostedReviewsModelImpl implements _CustomerPostedReviewsModel {
  const _$CustomerPostedReviewsModelImpl({
    @JsonKey(name: 'count') this.count,
    @JsonKey(name: 'next') this.next,
    @JsonKey(name: 'previous') this.previous,
    @JsonKey(name: 'results') final List<SingleReviewModel>? results,
  }) : _results = results;

  factory _$CustomerPostedReviewsModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CustomerPostedReviewsModelImplFromJson(json);

  @override
  @JsonKey(name: 'count')
  final int? count;
  @override
  @JsonKey(name: 'next')
  final String? next;
  @override
  @JsonKey(name: 'previous')
  final String? previous;
  final List<SingleReviewModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<SingleReviewModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CustomerPostedReviewsModel(count: $count, next: $next, previous: $previous, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerPostedReviewsModelImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.next, next) || other.next == next) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    next,
    previous,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of CustomerPostedReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerPostedReviewsModelImplCopyWith<_$CustomerPostedReviewsModelImpl>
  get copyWith => __$$CustomerPostedReviewsModelImplCopyWithImpl<
    _$CustomerPostedReviewsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerPostedReviewsModelImplToJson(this);
  }
}

abstract class _CustomerPostedReviewsModel
    implements CustomerPostedReviewsModel {
  const factory _CustomerPostedReviewsModel({
    @JsonKey(name: 'count') final int? count,
    @JsonKey(name: 'next') final String? next,
    @JsonKey(name: 'previous') final String? previous,
    @JsonKey(name: 'results') final List<SingleReviewModel>? results,
  }) = _$CustomerPostedReviewsModelImpl;

  factory _CustomerPostedReviewsModel.fromJson(Map<String, dynamic> json) =
      _$CustomerPostedReviewsModelImpl.fromJson;

  @override
  @JsonKey(name: 'count')
  int? get count;
  @override
  @JsonKey(name: 'next')
  String? get next;
  @override
  @JsonKey(name: 'previous')
  String? get previous;
  @override
  @JsonKey(name: 'results')
  List<SingleReviewModel>? get results;

  /// Create a copy of CustomerPostedReviewsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerPostedReviewsModelImplCopyWith<_$CustomerPostedReviewsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SingleReviewModel _$SingleReviewModelFromJson(Map<String, dynamic> json) {
  return _SingleReviewModel.fromJson(json);
}

/// @nodoc
mixin _$SingleReviewModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  int? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_name')
  String? get organizationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_logo')
  String? get organizationLogo => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_category')
  List<String>? get organizationCategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer')
  int? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating')
  int? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment')
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created')
  DateTime? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified')
  DateTime? get modified => throw _privateConstructorUsedError;

  /// Serializes this SingleReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleReviewModelCopyWith<SingleReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleReviewModelCopyWith<$Res> {
  factory $SingleReviewModelCopyWith(
    SingleReviewModel value,
    $Res Function(SingleReviewModel) then,
  ) = _$SingleReviewModelCopyWithImpl<$Res, SingleReviewModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'organization_category') List<String>? organizationCategory,
    @JsonKey(name: 'customer') int? customer,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
  });
}

/// @nodoc
class _$SingleReviewModelCopyWithImpl<$Res, $Val extends SingleReviewModel>
    implements $SingleReviewModelCopyWith<$Res> {
  _$SingleReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? organizationName = freezed,
    Object? organizationLogo = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? organizationCategory = freezed,
    Object? customer = freezed,
    Object? rating = freezed,
    Object? comment = freezed,
    Object? customerName = freezed,
    Object? created = freezed,
    Object? modified = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            organization:
                freezed == organization
                    ? _value.organization
                    : organization // ignore: cast_nullable_to_non_nullable
                        as int?,
            organizationName:
                freezed == organizationName
                    ? _value.organizationName
                    : organizationName // ignore: cast_nullable_to_non_nullable
                        as String?,
            organizationLogo:
                freezed == organizationLogo
                    ? _value.organizationLogo
                    : organizationLogo // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            organizationCategory:
                freezed == organizationCategory
                    ? _value.organizationCategory
                    : organizationCategory // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            customer:
                freezed == customer
                    ? _value.customer
                    : customer // ignore: cast_nullable_to_non_nullable
                        as int?,
            rating:
                freezed == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int?,
            comment:
                freezed == comment
                    ? _value.comment
                    : comment // ignore: cast_nullable_to_non_nullable
                        as String?,
            customerName:
                freezed == customerName
                    ? _value.customerName
                    : customerName // ignore: cast_nullable_to_non_nullable
                        as String?,
            created:
                freezed == created
                    ? _value.created
                    : created // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            modified:
                freezed == modified
                    ? _value.modified
                    : modified // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SingleReviewModelImplCopyWith<$Res>
    implements $SingleReviewModelCopyWith<$Res> {
  factory _$$SingleReviewModelImplCopyWith(
    _$SingleReviewModelImpl value,
    $Res Function(_$SingleReviewModelImpl) then,
  ) = __$$SingleReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'organization_name') String? organizationName,
    @JsonKey(name: 'organization_logo') String? organizationLogo,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'organization_category') List<String>? organizationCategory,
    @JsonKey(name: 'customer') int? customer,
    @JsonKey(name: 'rating') int? rating,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
  });
}

/// @nodoc
class __$$SingleReviewModelImplCopyWithImpl<$Res>
    extends _$SingleReviewModelCopyWithImpl<$Res, _$SingleReviewModelImpl>
    implements _$$SingleReviewModelImplCopyWith<$Res> {
  __$$SingleReviewModelImplCopyWithImpl(
    _$SingleReviewModelImpl _value,
    $Res Function(_$SingleReviewModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? organizationName = freezed,
    Object? organizationLogo = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? organizationCategory = freezed,
    Object? customer = freezed,
    Object? rating = freezed,
    Object? comment = freezed,
    Object? customerName = freezed,
    Object? created = freezed,
    Object? modified = freezed,
  }) {
    return _then(
      _$SingleReviewModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        organization:
            freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                    as int?,
        organizationName:
            freezed == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                    as String?,
        organizationLogo:
            freezed == organizationLogo
                ? _value.organizationLogo
                : organizationLogo // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        organizationCategory:
            freezed == organizationCategory
                ? _value._organizationCategory
                : organizationCategory // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        customer:
            freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                    as int?,
        rating:
            freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int?,
        comment:
            freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                    as String?,
        customerName:
            freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                    as String?,
        created:
            freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        modified:
            freezed == modified
                ? _value.modified
                : modified // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleReviewModelImpl implements _SingleReviewModel {
  const _$SingleReviewModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'organization') this.organization,
    @JsonKey(name: 'organization_name') this.organizationName,
    @JsonKey(name: 'organization_logo') this.organizationLogo,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'organization_category')
    final List<String>? organizationCategory,
    @JsonKey(name: 'customer') this.customer,
    @JsonKey(name: 'rating') this.rating,
    @JsonKey(name: 'comment') this.comment,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'created') this.created,
    @JsonKey(name: 'modified') this.modified,
  }) : _organizationCategory = organizationCategory;

  factory _$SingleReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleReviewModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'organization')
  final int? organization;
  @override
  @JsonKey(name: 'organization_name')
  final String? organizationName;
  @override
  @JsonKey(name: 'organization_logo')
  final String? organizationLogo;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final List<String>? _organizationCategory;
  @override
  @JsonKey(name: 'organization_category')
  List<String>? get organizationCategory {
    final value = _organizationCategory;
    if (value == null) return null;
    if (_organizationCategory is EqualUnmodifiableListView)
      return _organizationCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'customer')
  final int? customer;
  @override
  @JsonKey(name: 'rating')
  final int? rating;
  @override
  @JsonKey(name: 'comment')
  final String? comment;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'created')
  final DateTime? created;
  @override
  @JsonKey(name: 'modified')
  final DateTime? modified;

  @override
  String toString() {
    return 'SingleReviewModel(id: $id, organization: $organization, organizationName: $organizationName, organizationLogo: $organizationLogo, startDate: $startDate, endDate: $endDate, organizationCategory: $organizationCategory, customer: $customer, rating: $rating, comment: $comment, customerName: $customerName, created: $created, modified: $modified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.organizationLogo, organizationLogo) ||
                other.organizationLogo == organizationLogo) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._organizationCategory,
              _organizationCategory,
            ) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.modified, modified) ||
                other.modified == modified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organization,
    organizationName,
    organizationLogo,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_organizationCategory),
    customer,
    rating,
    comment,
    customerName,
    created,
    modified,
  );

  /// Create a copy of SingleReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleReviewModelImplCopyWith<_$SingleReviewModelImpl> get copyWith =>
      __$$SingleReviewModelImplCopyWithImpl<_$SingleReviewModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleReviewModelImplToJson(this);
  }
}

abstract class _SingleReviewModel implements SingleReviewModel {
  const factory _SingleReviewModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'organization') final int? organization,
    @JsonKey(name: 'organization_name') final String? organizationName,
    @JsonKey(name: 'organization_logo') final String? organizationLogo,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'organization_category')
    final List<String>? organizationCategory,
    @JsonKey(name: 'customer') final int? customer,
    @JsonKey(name: 'rating') final int? rating,
    @JsonKey(name: 'comment') final String? comment,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'created') final DateTime? created,
    @JsonKey(name: 'modified') final DateTime? modified,
  }) = _$SingleReviewModelImpl;

  factory _SingleReviewModel.fromJson(Map<String, dynamic> json) =
      _$SingleReviewModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'organization')
  int? get organization;
  @override
  @JsonKey(name: 'organization_name')
  String? get organizationName;
  @override
  @JsonKey(name: 'organization_logo')
  String? get organizationLogo;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'organization_category')
  List<String>? get organizationCategory;
  @override
  @JsonKey(name: 'customer')
  int? get customer;
  @override
  @JsonKey(name: 'rating')
  int? get rating;
  @override
  @JsonKey(name: 'comment')
  String? get comment;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'created')
  DateTime? get created;
  @override
  @JsonKey(name: 'modified')
  DateTime? get modified;

  /// Create a copy of SingleReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleReviewModelImplCopyWith<_$SingleReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
