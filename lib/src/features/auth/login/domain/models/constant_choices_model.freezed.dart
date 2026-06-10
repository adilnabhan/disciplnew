// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'constant_choices_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConstantChoicesModel _$ConstantChoicesModelFromJson(Map<String, dynamic> json) {
  return _ConstantChoicesModel.fromJson(json);
}

/// @nodoc
mixin _$ConstantChoicesModel {
  bool get success => throw _privateConstructorUsedError;
  Data get data => throw _privateConstructorUsedError;

  /// Serializes this ConstantChoicesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConstantChoicesModelCopyWith<ConstantChoicesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConstantChoicesModelCopyWith<$Res> {
  factory $ConstantChoicesModelCopyWith(
    ConstantChoicesModel value,
    $Res Function(ConstantChoicesModel) then,
  ) = _$ConstantChoicesModelCopyWithImpl<$Res, ConstantChoicesModel>;
  @useResult
  $Res call({bool success, Data data});

  $DataCopyWith<$Res> get data;
}

/// @nodoc
class _$ConstantChoicesModelCopyWithImpl<
  $Res,
  $Val extends ConstantChoicesModel
>
    implements $ConstantChoicesModelCopyWith<$Res> {
  _$ConstantChoicesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? data = null}) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            data:
                null == data
                    ? _value.data
                    : data // ignore: cast_nullable_to_non_nullable
                        as Data,
          )
          as $Val,
    );
  }

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DataCopyWith<$Res> get data {
    return $DataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConstantChoicesModelImplCopyWith<$Res>
    implements $ConstantChoicesModelCopyWith<$Res> {
  factory _$$ConstantChoicesModelImplCopyWith(
    _$ConstantChoicesModelImpl value,
    $Res Function(_$ConstantChoicesModelImpl) then,
  ) = __$$ConstantChoicesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, Data data});

  @override
  $DataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ConstantChoicesModelImplCopyWithImpl<$Res>
    extends _$ConstantChoicesModelCopyWithImpl<$Res, _$ConstantChoicesModelImpl>
    implements _$$ConstantChoicesModelImplCopyWith<$Res> {
  __$$ConstantChoicesModelImplCopyWithImpl(
    _$ConstantChoicesModelImpl _value,
    $Res Function(_$ConstantChoicesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? data = null}) {
    return _then(
      _$ConstantChoicesModelImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        data:
            null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                    as Data,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConstantChoicesModelImpl implements _ConstantChoicesModel {
  const _$ConstantChoicesModelImpl({required this.success, required this.data});

  factory _$ConstantChoicesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConstantChoicesModelImplFromJson(json);

  @override
  final bool success;
  @override
  final Data data;

  @override
  String toString() {
    return 'ConstantChoicesModel(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConstantChoicesModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConstantChoicesModelImplCopyWith<_$ConstantChoicesModelImpl>
  get copyWith =>
      __$$ConstantChoicesModelImplCopyWithImpl<_$ConstantChoicesModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConstantChoicesModelImplToJson(this);
  }
}

abstract class _ConstantChoicesModel implements ConstantChoicesModel {
  const factory _ConstantChoicesModel({
    required final bool success,
    required final Data data,
  }) = _$ConstantChoicesModelImpl;

  factory _ConstantChoicesModel.fromJson(Map<String, dynamic> json) =
      _$ConstantChoicesModelImpl.fromJson;

  @override
  bool get success;
  @override
  Data get data;

  /// Create a copy of ConstantChoicesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConstantChoicesModelImplCopyWith<_$ConstantChoicesModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Data _$DataFromJson(Map<String, dynamic> json) {
  return _Data.fromJson(json);
}

/// @nodoc
mixin _$Data {
  List<Profession> get professions => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_satisfactions')
  List<JobSatisfaction> get jobSatisfactions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'working_hours')
  List<Profession> get workingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'sleep_hours')
  List<Profession> get sleepHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_goals')
  List<Profession> get targetGoals => throw _privateConstructorUsedError;
  @JsonKey(name: 'health_conditions')
  List<Profession> get healthConditions => throw _privateConstructorUsedError;

  /// Serializes this Data to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DataCopyWith<Data> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataCopyWith<$Res> {
  factory $DataCopyWith(Data value, $Res Function(Data) then) =
      _$DataCopyWithImpl<$Res, Data>;
  @useResult
  $Res call({
    List<Profession> professions,
    @JsonKey(name: 'job_satisfactions') List<JobSatisfaction> jobSatisfactions,
    @JsonKey(name: 'working_hours') List<Profession> workingHours,
    @JsonKey(name: 'sleep_hours') List<Profession> sleepHours,
    @JsonKey(name: 'target_goals') List<Profession> targetGoals,
    @JsonKey(name: 'health_conditions') List<Profession> healthConditions,
  });
}

/// @nodoc
class _$DataCopyWithImpl<$Res, $Val extends Data>
    implements $DataCopyWith<$Res> {
  _$DataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? professions = null,
    Object? jobSatisfactions = null,
    Object? workingHours = null,
    Object? sleepHours = null,
    Object? targetGoals = null,
    Object? healthConditions = null,
  }) {
    return _then(
      _value.copyWith(
            professions:
                null == professions
                    ? _value.professions
                    : professions // ignore: cast_nullable_to_non_nullable
                        as List<Profession>,
            jobSatisfactions:
                null == jobSatisfactions
                    ? _value.jobSatisfactions
                    : jobSatisfactions // ignore: cast_nullable_to_non_nullable
                        as List<JobSatisfaction>,
            workingHours:
                null == workingHours
                    ? _value.workingHours
                    : workingHours // ignore: cast_nullable_to_non_nullable
                        as List<Profession>,
            sleepHours:
                null == sleepHours
                    ? _value.sleepHours
                    : sleepHours // ignore: cast_nullable_to_non_nullable
                        as List<Profession>,
            targetGoals:
                null == targetGoals
                    ? _value.targetGoals
                    : targetGoals // ignore: cast_nullable_to_non_nullable
                        as List<Profession>,
            healthConditions:
                null == healthConditions
                    ? _value.healthConditions
                    : healthConditions // ignore: cast_nullable_to_non_nullable
                        as List<Profession>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DataImplCopyWith<$Res> implements $DataCopyWith<$Res> {
  factory _$$DataImplCopyWith(
    _$DataImpl value,
    $Res Function(_$DataImpl) then,
  ) = __$$DataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Profession> professions,
    @JsonKey(name: 'job_satisfactions') List<JobSatisfaction> jobSatisfactions,
    @JsonKey(name: 'working_hours') List<Profession> workingHours,
    @JsonKey(name: 'sleep_hours') List<Profession> sleepHours,
    @JsonKey(name: 'target_goals') List<Profession> targetGoals,
    @JsonKey(name: 'health_conditions') List<Profession> healthConditions,
  });
}

/// @nodoc
class __$$DataImplCopyWithImpl<$Res>
    extends _$DataCopyWithImpl<$Res, _$DataImpl>
    implements _$$DataImplCopyWith<$Res> {
  __$$DataImplCopyWithImpl(_$DataImpl _value, $Res Function(_$DataImpl) _then)
    : super(_value, _then);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? professions = null,
    Object? jobSatisfactions = null,
    Object? workingHours = null,
    Object? sleepHours = null,
    Object? targetGoals = null,
    Object? healthConditions = null,
  }) {
    return _then(
      _$DataImpl(
        professions:
            null == professions
                ? _value._professions
                : professions // ignore: cast_nullable_to_non_nullable
                    as List<Profession>,
        jobSatisfactions:
            null == jobSatisfactions
                ? _value._jobSatisfactions
                : jobSatisfactions // ignore: cast_nullable_to_non_nullable
                    as List<JobSatisfaction>,
        workingHours:
            null == workingHours
                ? _value._workingHours
                : workingHours // ignore: cast_nullable_to_non_nullable
                    as List<Profession>,
        sleepHours:
            null == sleepHours
                ? _value._sleepHours
                : sleepHours // ignore: cast_nullable_to_non_nullable
                    as List<Profession>,
        targetGoals:
            null == targetGoals
                ? _value._targetGoals
                : targetGoals // ignore: cast_nullable_to_non_nullable
                    as List<Profession>,
        healthConditions:
            null == healthConditions
                ? _value._healthConditions
                : healthConditions // ignore: cast_nullable_to_non_nullable
                    as List<Profession>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataImpl implements _Data {
  const _$DataImpl({
    required final List<Profession> professions,
    @JsonKey(name: 'job_satisfactions')
    required final List<JobSatisfaction> jobSatisfactions,
    @JsonKey(name: 'working_hours')
    required final List<Profession> workingHours,
    @JsonKey(name: 'sleep_hours') required final List<Profession> sleepHours,
    @JsonKey(name: 'target_goals') required final List<Profession> targetGoals,
    @JsonKey(name: 'health_conditions')
    required final List<Profession> healthConditions,
  }) : _professions = professions,
       _jobSatisfactions = jobSatisfactions,
       _workingHours = workingHours,
       _sleepHours = sleepHours,
       _targetGoals = targetGoals,
       _healthConditions = healthConditions;

  factory _$DataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataImplFromJson(json);

  final List<Profession> _professions;
  @override
  List<Profession> get professions {
    if (_professions is EqualUnmodifiableListView) return _professions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_professions);
  }

  final List<JobSatisfaction> _jobSatisfactions;
  @override
  @JsonKey(name: 'job_satisfactions')
  List<JobSatisfaction> get jobSatisfactions {
    if (_jobSatisfactions is EqualUnmodifiableListView)
      return _jobSatisfactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobSatisfactions);
  }

  final List<Profession> _workingHours;
  @override
  @JsonKey(name: 'working_hours')
  List<Profession> get workingHours {
    if (_workingHours is EqualUnmodifiableListView) return _workingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workingHours);
  }

  final List<Profession> _sleepHours;
  @override
  @JsonKey(name: 'sleep_hours')
  List<Profession> get sleepHours {
    if (_sleepHours is EqualUnmodifiableListView) return _sleepHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sleepHours);
  }

  final List<Profession> _targetGoals;
  @override
  @JsonKey(name: 'target_goals')
  List<Profession> get targetGoals {
    if (_targetGoals is EqualUnmodifiableListView) return _targetGoals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetGoals);
  }

  final List<Profession> _healthConditions;
  @override
  @JsonKey(name: 'health_conditions')
  List<Profession> get healthConditions {
    if (_healthConditions is EqualUnmodifiableListView)
      return _healthConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_healthConditions);
  }

  @override
  String toString() {
    return 'Data(professions: $professions, jobSatisfactions: $jobSatisfactions, workingHours: $workingHours, sleepHours: $sleepHours, targetGoals: $targetGoals, healthConditions: $healthConditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataImpl &&
            const DeepCollectionEquality().equals(
              other._professions,
              _professions,
            ) &&
            const DeepCollectionEquality().equals(
              other._jobSatisfactions,
              _jobSatisfactions,
            ) &&
            const DeepCollectionEquality().equals(
              other._workingHours,
              _workingHours,
            ) &&
            const DeepCollectionEquality().equals(
              other._sleepHours,
              _sleepHours,
            ) &&
            const DeepCollectionEquality().equals(
              other._targetGoals,
              _targetGoals,
            ) &&
            const DeepCollectionEquality().equals(
              other._healthConditions,
              _healthConditions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_professions),
    const DeepCollectionEquality().hash(_jobSatisfactions),
    const DeepCollectionEquality().hash(_workingHours),
    const DeepCollectionEquality().hash(_sleepHours),
    const DeepCollectionEquality().hash(_targetGoals),
    const DeepCollectionEquality().hash(_healthConditions),
  );

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      __$$DataImplCopyWithImpl<_$DataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataImplToJson(this);
  }
}

abstract class _Data implements Data {
  const factory _Data({
    required final List<Profession> professions,
    @JsonKey(name: 'job_satisfactions')
    required final List<JobSatisfaction> jobSatisfactions,
    @JsonKey(name: 'working_hours')
    required final List<Profession> workingHours,
    @JsonKey(name: 'sleep_hours') required final List<Profession> sleepHours,
    @JsonKey(name: 'target_goals') required final List<Profession> targetGoals,
    @JsonKey(name: 'health_conditions')
    required final List<Profession> healthConditions,
  }) = _$DataImpl;

  factory _Data.fromJson(Map<String, dynamic> json) = _$DataImpl.fromJson;

  @override
  List<Profession> get professions;
  @override
  @JsonKey(name: 'job_satisfactions')
  List<JobSatisfaction> get jobSatisfactions;
  @override
  @JsonKey(name: 'working_hours')
  List<Profession> get workingHours;
  @override
  @JsonKey(name: 'sleep_hours')
  List<Profession> get sleepHours;
  @override
  @JsonKey(name: 'target_goals')
  List<Profession> get targetGoals;
  @override
  @JsonKey(name: 'health_conditions')
  List<Profession> get healthConditions;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobSatisfaction _$JobSatisfactionFromJson(Map<String, dynamic> json) {
  return _JobSatisfaction.fromJson(json);
}

/// @nodoc
mixin _$JobSatisfaction {
  int get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this JobSatisfaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobSatisfaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobSatisfactionCopyWith<JobSatisfaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobSatisfactionCopyWith<$Res> {
  factory $JobSatisfactionCopyWith(
    JobSatisfaction value,
    $Res Function(JobSatisfaction) then,
  ) = _$JobSatisfactionCopyWithImpl<$Res, JobSatisfaction>;
  @useResult
  $Res call({int value, String label});
}

/// @nodoc
class _$JobSatisfactionCopyWithImpl<$Res, $Val extends JobSatisfaction>
    implements $JobSatisfactionCopyWith<$Res> {
  _$JobSatisfactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobSatisfaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            value:
                null == value
                    ? _value.value
                    : value // ignore: cast_nullable_to_non_nullable
                        as int,
            label:
                null == label
                    ? _value.label
                    : label // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobSatisfactionImplCopyWith<$Res>
    implements $JobSatisfactionCopyWith<$Res> {
  factory _$$JobSatisfactionImplCopyWith(
    _$JobSatisfactionImpl value,
    $Res Function(_$JobSatisfactionImpl) then,
  ) = __$$JobSatisfactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int value, String label});
}

/// @nodoc
class __$$JobSatisfactionImplCopyWithImpl<$Res>
    extends _$JobSatisfactionCopyWithImpl<$Res, _$JobSatisfactionImpl>
    implements _$$JobSatisfactionImplCopyWith<$Res> {
  __$$JobSatisfactionImplCopyWithImpl(
    _$JobSatisfactionImpl _value,
    $Res Function(_$JobSatisfactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobSatisfaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _$JobSatisfactionImpl(
        value:
            null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                    as int,
        label:
            null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobSatisfactionImpl implements _JobSatisfaction {
  const _$JobSatisfactionImpl({required this.value, required this.label});

  factory _$JobSatisfactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobSatisfactionImplFromJson(json);

  @override
  final int value;
  @override
  final String label;

  @override
  String toString() {
    return 'JobSatisfaction(value: $value, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobSatisfactionImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label);

  /// Create a copy of JobSatisfaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobSatisfactionImplCopyWith<_$JobSatisfactionImpl> get copyWith =>
      __$$JobSatisfactionImplCopyWithImpl<_$JobSatisfactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JobSatisfactionImplToJson(this);
  }
}

abstract class _JobSatisfaction implements JobSatisfaction {
  const factory _JobSatisfaction({
    required final int value,
    required final String label,
  }) = _$JobSatisfactionImpl;

  factory _JobSatisfaction.fromJson(Map<String, dynamic> json) =
      _$JobSatisfactionImpl.fromJson;

  @override
  int get value;
  @override
  String get label;

  /// Create a copy of JobSatisfaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobSatisfactionImplCopyWith<_$JobSatisfactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Profession _$ProfessionFromJson(Map<String, dynamic> json) {
  return _Profession.fromJson(json);
}

/// @nodoc
mixin _$Profession {
  String get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this Profession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfessionCopyWith<Profession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfessionCopyWith<$Res> {
  factory $ProfessionCopyWith(
    Profession value,
    $Res Function(Profession) then,
  ) = _$ProfessionCopyWithImpl<$Res, Profession>;
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class _$ProfessionCopyWithImpl<$Res, $Val extends Profession>
    implements $ProfessionCopyWith<$Res> {
  _$ProfessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            value:
                null == value
                    ? _value.value
                    : value // ignore: cast_nullable_to_non_nullable
                        as String,
            label:
                null == label
                    ? _value.label
                    : label // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfessionImplCopyWith<$Res>
    implements $ProfessionCopyWith<$Res> {
  factory _$$ProfessionImplCopyWith(
    _$ProfessionImpl value,
    $Res Function(_$ProfessionImpl) then,
  ) = __$$ProfessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class __$$ProfessionImplCopyWithImpl<$Res>
    extends _$ProfessionCopyWithImpl<$Res, _$ProfessionImpl>
    implements _$$ProfessionImplCopyWith<$Res> {
  __$$ProfessionImplCopyWithImpl(
    _$ProfessionImpl _value,
    $Res Function(_$ProfessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Profession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _$ProfessionImpl(
        value:
            null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                    as String,
        label:
            null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfessionImpl implements _Profession {
  const _$ProfessionImpl({required this.value, required this.label});

  factory _$ProfessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfessionImplFromJson(json);

  @override
  final String value;
  @override
  final String label;

  @override
  String toString() {
    return 'Profession(value: $value, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfessionImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label);

  /// Create a copy of Profession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfessionImplCopyWith<_$ProfessionImpl> get copyWith =>
      __$$ProfessionImplCopyWithImpl<_$ProfessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfessionImplToJson(this);
  }
}

abstract class _Profession implements Profession {
  const factory _Profession({
    required final String value,
    required final String label,
  }) = _$ProfessionImpl;

  factory _Profession.fromJson(Map<String, dynamic> json) =
      _$ProfessionImpl.fromJson;

  @override
  String get value;
  @override
  String get label;

  /// Create a copy of Profession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfessionImplCopyWith<_$ProfessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
