// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitnesscenter_categories_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FitnesscenterCategoriesModel _$FitnesscenterCategoriesModelFromJson(
  Map<String, dynamic> json,
) {
  return _FitnesscenterCategoriesModel.fromJson(json);
}

/// @nodoc
mixin _$FitnesscenterCategoriesModel {
  @JsonKey(name: 'results')
  List<SingleFitnesscenterCategoryModel>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this FitnesscenterCategoriesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FitnesscenterCategoriesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FitnesscenterCategoriesModelCopyWith<FitnesscenterCategoriesModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FitnesscenterCategoriesModelCopyWith<$Res> {
  factory $FitnesscenterCategoriesModelCopyWith(
    FitnesscenterCategoriesModel value,
    $Res Function(FitnesscenterCategoriesModel) then,
  ) =
      _$FitnesscenterCategoriesModelCopyWithImpl<
        $Res,
        FitnesscenterCategoriesModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'results') List<SingleFitnesscenterCategoryModel>? results,
  });
}

/// @nodoc
class _$FitnesscenterCategoriesModelCopyWithImpl<
  $Res,
  $Val extends FitnesscenterCategoriesModel
>
    implements $FitnesscenterCategoriesModelCopyWith<$Res> {
  _$FitnesscenterCategoriesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FitnesscenterCategoriesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _value.copyWith(
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<SingleFitnesscenterCategoryModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FitnesscenterCategoriesModelImplCopyWith<$Res>
    implements $FitnesscenterCategoriesModelCopyWith<$Res> {
  factory _$$FitnesscenterCategoriesModelImplCopyWith(
    _$FitnesscenterCategoriesModelImpl value,
    $Res Function(_$FitnesscenterCategoriesModelImpl) then,
  ) = __$$FitnesscenterCategoriesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'results') List<SingleFitnesscenterCategoryModel>? results,
  });
}

/// @nodoc
class __$$FitnesscenterCategoriesModelImplCopyWithImpl<$Res>
    extends
        _$FitnesscenterCategoriesModelCopyWithImpl<
          $Res,
          _$FitnesscenterCategoriesModelImpl
        >
    implements _$$FitnesscenterCategoriesModelImplCopyWith<$Res> {
  __$$FitnesscenterCategoriesModelImplCopyWithImpl(
    _$FitnesscenterCategoriesModelImpl _value,
    $Res Function(_$FitnesscenterCategoriesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FitnesscenterCategoriesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _$FitnesscenterCategoriesModelImpl(
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<SingleFitnesscenterCategoryModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FitnesscenterCategoriesModelImpl
    implements _FitnesscenterCategoriesModel {
  const _$FitnesscenterCategoriesModelImpl({
    @JsonKey(name: 'results')
    final List<SingleFitnesscenterCategoryModel>? results,
  }) : _results = results;

  factory _$FitnesscenterCategoriesModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$FitnesscenterCategoriesModelImplFromJson(json);

  final List<SingleFitnesscenterCategoryModel>? _results;
  @override
  @JsonKey(name: 'results')
  List<SingleFitnesscenterCategoryModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FitnesscenterCategoriesModel(results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FitnesscenterCategoriesModelImpl &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  /// Create a copy of FitnesscenterCategoriesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FitnesscenterCategoriesModelImplCopyWith<
    _$FitnesscenterCategoriesModelImpl
  >
  get copyWith => __$$FitnesscenterCategoriesModelImplCopyWithImpl<
    _$FitnesscenterCategoriesModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FitnesscenterCategoriesModelImplToJson(this);
  }
}

abstract class _FitnesscenterCategoriesModel
    implements FitnesscenterCategoriesModel {
  const factory _FitnesscenterCategoriesModel({
    @JsonKey(name: 'results')
    final List<SingleFitnesscenterCategoryModel>? results,
  }) = _$FitnesscenterCategoriesModelImpl;

  factory _FitnesscenterCategoriesModel.fromJson(Map<String, dynamic> json) =
      _$FitnesscenterCategoriesModelImpl.fromJson;

  @override
  @JsonKey(name: 'results')
  List<SingleFitnesscenterCategoryModel>? get results;

  /// Create a copy of FitnesscenterCategoriesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FitnesscenterCategoriesModelImplCopyWith<
    _$FitnesscenterCategoriesModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

SingleFitnesscenterCategoryModel _$SingleFitnesscenterCategoryModelFromJson(
  Map<String, dynamic> json,
) {
  return _SingleFitnesscenterCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$SingleFitnesscenterCategoryModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;

  /// Serializes this SingleFitnesscenterCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleFitnesscenterCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleFitnesscenterCategoryModelCopyWith<SingleFitnesscenterCategoryModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleFitnesscenterCategoryModelCopyWith<$Res> {
  factory $SingleFitnesscenterCategoryModelCopyWith(
    SingleFitnesscenterCategoryModel value,
    $Res Function(SingleFitnesscenterCategoryModel) then,
  ) =
      _$SingleFitnesscenterCategoryModelCopyWithImpl<
        $Res,
        SingleFitnesscenterCategoryModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
  });
}

/// @nodoc
class _$SingleFitnesscenterCategoryModelCopyWithImpl<
  $Res,
  $Val extends SingleFitnesscenterCategoryModel
>
    implements $SingleFitnesscenterCategoryModelCopyWith<$Res> {
  _$SingleFitnesscenterCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleFitnesscenterCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SingleFitnesscenterCategoryModelImplCopyWith<$Res>
    implements $SingleFitnesscenterCategoryModelCopyWith<$Res> {
  factory _$$SingleFitnesscenterCategoryModelImplCopyWith(
    _$SingleFitnesscenterCategoryModelImpl value,
    $Res Function(_$SingleFitnesscenterCategoryModelImpl) then,
  ) = __$$SingleFitnesscenterCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
  });
}

/// @nodoc
class __$$SingleFitnesscenterCategoryModelImplCopyWithImpl<$Res>
    extends
        _$SingleFitnesscenterCategoryModelCopyWithImpl<
          $Res,
          _$SingleFitnesscenterCategoryModelImpl
        >
    implements _$$SingleFitnesscenterCategoryModelImplCopyWith<$Res> {
  __$$SingleFitnesscenterCategoryModelImplCopyWithImpl(
    _$SingleFitnesscenterCategoryModelImpl _value,
    $Res Function(_$SingleFitnesscenterCategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleFitnesscenterCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
  }) {
    return _then(
      _$SingleFitnesscenterCategoryModelImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleFitnesscenterCategoryModelImpl
    implements _SingleFitnesscenterCategoryModel {
  const _$SingleFitnesscenterCategoryModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'logo') this.logo,
  });

  factory _$SingleFitnesscenterCategoryModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SingleFitnesscenterCategoryModelImplFromJson(json);

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
  String toString() {
    return 'SingleFitnesscenterCategoryModel(id: $id, name: $name, logo: $logo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleFitnesscenterCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, logo);

  /// Create a copy of SingleFitnesscenterCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleFitnesscenterCategoryModelImplCopyWith<
    _$SingleFitnesscenterCategoryModelImpl
  >
  get copyWith => __$$SingleFitnesscenterCategoryModelImplCopyWithImpl<
    _$SingleFitnesscenterCategoryModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleFitnesscenterCategoryModelImplToJson(this);
  }
}

abstract class _SingleFitnesscenterCategoryModel
    implements SingleFitnesscenterCategoryModel {
  const factory _SingleFitnesscenterCategoryModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'logo') final String? logo,
  }) = _$SingleFitnesscenterCategoryModelImpl;

  factory _SingleFitnesscenterCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) = _$SingleFitnesscenterCategoryModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'logo')
  String? get logo;

  /// Create a copy of SingleFitnesscenterCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleFitnesscenterCategoryModelImplCopyWith<
    _$SingleFitnesscenterCategoryModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
