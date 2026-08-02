import 'package:flutter/foundation.dart';

@immutable
class BodyMatrixModel {
  const BodyMatrixModel({
    this.customerId,
    this.heightCm,
    this.weightKg,
    this.neckCm,
    this.waistCm,
    this.hipCm,
    this.gender,
    this.age,
    this.bmiValue,
    this.bmiCategory,
    this.bmiLabel,
    this.bmrValue,
    this.bmrUnit,
    this.bodyFatPercentage,
    this.bodyFatCategory,
    this.bodyFatNavyPercentage,
    this.whrRatio,
    this.whrCategory,
    this.whtrRatio,
    this.whtrCategory,
  });

  final int? customerId;
  final double? heightCm;
  final double? weightKg;
  final double? neckCm;
  final double? waistCm;
  final double? hipCm;
  final String? gender;
  final int? age;

  final double? bmiValue;
  final String? bmiCategory;
  final String? bmiLabel;

  final double? bmrValue;
  final String? bmrUnit;

  final double? bodyFatPercentage;
  final String? bodyFatCategory;
  final double? bodyFatNavyPercentage;

  final double? whrRatio;
  final String? whrCategory;

  final double? whtrRatio;
  final String? whtrCategory;

  factory BodyMatrixModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final inputs = data['inputs'] is Map<String, dynamic>
        ? data['inputs'] as Map<String, dynamic>
        : <String, dynamic>{};

    final metrics = data['metrics'] is Map<String, dynamic>
        ? data['metrics'] as Map<String, dynamic>
        : <String, dynamic>{};

    final bmi = metrics['bmi'] is Map<String, dynamic>
        ? metrics['bmi'] as Map<String, dynamic>
        : <String, dynamic>{};

    final bmr = metrics['bmr'] is Map<String, dynamic>
        ? metrics['bmr'] as Map<String, dynamic>
        : <String, dynamic>{};

    final bodyFat = metrics['body_fat'] is Map<String, dynamic>
        ? metrics['body_fat'] as Map<String, dynamic>
        : <String, dynamic>{};

    final whr = metrics['whr'] is Map<String, dynamic>
        ? metrics['whr'] as Map<String, dynamic>
        : <String, dynamic>{};

    final whtr = metrics['whtr'] is Map<String, dynamic>
        ? metrics['whtr'] as Map<String, dynamic>
        : <String, dynamic>{};

    double? _toDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? _toInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return BodyMatrixModel(
      customerId: _toInt(data['customer_id']),
      heightCm: _toDouble(inputs['height_cm']),
      weightKg: _toDouble(inputs['weight_kg']),
      neckCm: _toDouble(inputs['neck_cm']),
      waistCm: _toDouble(inputs['waist_cm']),
      hipCm: _toDouble(inputs['hip_cm']),
      gender: inputs['gender']?.toString(),
      age: _toInt(inputs['age']),
      bmiValue: _toDouble(bmi['value']),
      bmiCategory: bmi['category']?.toString(),
      bmiLabel: bmi['label']?.toString(),
      bmrValue: _toDouble(bmr['value']),
      bmrUnit: bmr['unit']?.toString(),
      bodyFatPercentage: _toDouble(bodyFat['percentage']),
      bodyFatCategory: bodyFat['category']?.toString(),
      bodyFatNavyPercentage: _toDouble(bodyFat['navy_method_percentage']),
      whrRatio: _toDouble(whr['ratio']),
      whrCategory: whr['category']?.toString(),
      whtrRatio: _toDouble(whtr['ratio']),
      whtrCategory: whtr['category']?.toString(),
    );
  }
}
