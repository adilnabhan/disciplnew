// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_fitness_centers_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ListFitnessCentersState {
  ({
    Option<Either<ApiException, ListFitnesscenterModel>> data,
    bool isPagination,
  })
  get listFitnessCenters => throw _privateConstructorUsedError;
  Option<Either<ApiException, FitnesscenterCategoriesModel>> get categories =>
      throw _privateConstructorUsedError;
  SingleFitnesscenterCategoryModel? get selectedCategory =>
      throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get showLocationBanner => throw _privateConstructorUsedError;

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListFitnessCentersStateCopyWith<ListFitnessCentersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListFitnessCentersStateCopyWith<$Res> {
  factory $ListFitnessCentersStateCopyWith(
    ListFitnessCentersState value,
    $Res Function(ListFitnessCentersState) then,
  ) = _$ListFitnessCentersStateCopyWithImpl<$Res, ListFitnessCentersState>;
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, ListFitnesscenterModel>> data,
      bool isPagination,
    })
    listFitnessCenters,
    Option<Either<ApiException, FitnesscenterCategoriesModel>> categories,
    SingleFitnesscenterCategoryModel? selectedCategory,
    String searchQuery,
    double? latitude,
    double? longitude,
    bool showLocationBanner,
  });

  $SingleFitnesscenterCategoryModelCopyWith<$Res>? get selectedCategory;
}

/// @nodoc
class _$ListFitnessCentersStateCopyWithImpl<
  $Res,
  $Val extends ListFitnessCentersState
>
    implements $ListFitnessCentersStateCopyWith<$Res> {
  _$ListFitnessCentersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listFitnessCenters = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? searchQuery = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? showLocationBanner = null,
  }) {
    return _then(
      _value.copyWith(
            listFitnessCenters:
                null == listFitnessCenters
                    ? _value.listFitnessCenters
                    : listFitnessCenters // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<Either<ApiException, ListFitnesscenterModel>>
                          data,
                          bool isPagination,
                        }),
            categories:
                null == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, FitnesscenterCategoriesModel>
                        >,
            selectedCategory:
                freezed == selectedCategory
                    ? _value.selectedCategory
                    : selectedCategory // ignore: cast_nullable_to_non_nullable
                        as SingleFitnesscenterCategoryModel?,
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            showLocationBanner:
                null == showLocationBanner
                    ? _value.showLocationBanner
                    : showLocationBanner // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SingleFitnesscenterCategoryModelCopyWith<$Res>? get selectedCategory {
    if (_value.selectedCategory == null) {
      return null;
    }

    return $SingleFitnesscenterCategoryModelCopyWith<$Res>(
      _value.selectedCategory!,
      (value) {
        return _then(_value.copyWith(selectedCategory: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$ListFitnessCentersStateImplCopyWith<$Res>
    implements $ListFitnessCentersStateCopyWith<$Res> {
  factory _$$ListFitnessCentersStateImplCopyWith(
    _$ListFitnessCentersStateImpl value,
    $Res Function(_$ListFitnessCentersStateImpl) then,
  ) = __$$ListFitnessCentersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ({
      Option<Either<ApiException, ListFitnesscenterModel>> data,
      bool isPagination,
    })
    listFitnessCenters,
    Option<Either<ApiException, FitnesscenterCategoriesModel>> categories,
    SingleFitnesscenterCategoryModel? selectedCategory,
    String searchQuery,
    double? latitude,
    double? longitude,
    bool showLocationBanner,
  });

  @override
  $SingleFitnesscenterCategoryModelCopyWith<$Res>? get selectedCategory;
}

/// @nodoc
class __$$ListFitnessCentersStateImplCopyWithImpl<$Res>
    extends
        _$ListFitnessCentersStateCopyWithImpl<
          $Res,
          _$ListFitnessCentersStateImpl
        >
    implements _$$ListFitnessCentersStateImplCopyWith<$Res> {
  __$$ListFitnessCentersStateImplCopyWithImpl(
    _$ListFitnessCentersStateImpl _value,
    $Res Function(_$ListFitnessCentersStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listFitnessCenters = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? searchQuery = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? showLocationBanner = null,
  }) {
    return _then(
      _$ListFitnessCentersStateImpl(
        listFitnessCenters:
            null == listFitnessCenters
                ? _value.listFitnessCenters
                : listFitnessCenters // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, ListFitnesscenterModel>> data,
                      bool isPagination,
                    }),
        categories:
            null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as Option<
                      Either<ApiException, FitnesscenterCategoriesModel>
                    >,
        selectedCategory:
            freezed == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                    as SingleFitnesscenterCategoryModel?,
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        showLocationBanner:
            null == showLocationBanner
                ? _value.showLocationBanner
                : showLocationBanner // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$ListFitnessCentersStateImpl implements _ListFitnessCentersState {
  const _$ListFitnessCentersStateImpl({
    this.listFitnessCenters = const (data: None(), isPagination: false),
    this.categories = const None(),
    this.selectedCategory,
    this.searchQuery = '',
    this.latitude = 11.2588,
    this.longitude = 75.7804,
    this.showLocationBanner = false,
  });

  @override
  @JsonKey()
  final ({
    Option<Either<ApiException, ListFitnesscenterModel>> data,
    bool isPagination,
  })
  listFitnessCenters;
  @override
  @JsonKey()
  final Option<Either<ApiException, FitnesscenterCategoriesModel>> categories;
  @override
  final SingleFitnesscenterCategoryModel? selectedCategory;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final double? latitude;
  @override
  @JsonKey()
  final double? longitude;
  @override
  @JsonKey()
  final bool showLocationBanner;

  @override
  String toString() {
    return 'ListFitnessCentersState(listFitnessCenters: $listFitnessCenters, categories: $categories, selectedCategory: $selectedCategory, searchQuery: $searchQuery, latitude: $latitude, longitude: $longitude, showLocationBanner: $showLocationBanner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListFitnessCentersStateImpl &&
            (identical(other.listFitnessCenters, listFitnessCenters) ||
                other.listFitnessCenters == listFitnessCenters) &&
            (identical(other.categories, categories) ||
                other.categories == categories) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.showLocationBanner, showLocationBanner) ||
                other.showLocationBanner == showLocationBanner));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    listFitnessCenters,
    categories,
    selectedCategory,
    searchQuery,
    latitude,
    longitude,
    showLocationBanner,
  );

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListFitnessCentersStateImplCopyWith<_$ListFitnessCentersStateImpl>
  get copyWith => __$$ListFitnessCentersStateImplCopyWithImpl<
    _$ListFitnessCentersStateImpl
  >(this, _$identity);
}

abstract class _ListFitnessCentersState implements ListFitnessCentersState {
  const factory _ListFitnessCentersState({
    final ({
      Option<Either<ApiException, ListFitnesscenterModel>> data,
      bool isPagination,
    })
    listFitnessCenters,
    final Option<Either<ApiException, FitnesscenterCategoriesModel>> categories,
    final SingleFitnesscenterCategoryModel? selectedCategory,
    final String searchQuery,
    final double? latitude,
    final double? longitude,
    final bool showLocationBanner,
  }) = _$ListFitnessCentersStateImpl;

  @override
  ({
    Option<Either<ApiException, ListFitnesscenterModel>> data,
    bool isPagination,
  })
  get listFitnessCenters;
  @override
  Option<Either<ApiException, FitnesscenterCategoriesModel>> get categories;
  @override
  SingleFitnesscenterCategoryModel? get selectedCategory;
  @override
  String get searchQuery;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get showLocationBanner;

  /// Create a copy of ListFitnessCentersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListFitnessCentersStateImplCopyWith<_$ListFitnessCentersStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
