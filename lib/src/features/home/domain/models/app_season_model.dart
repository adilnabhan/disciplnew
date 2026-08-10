import 'package:flutter/foundation.dart';

@immutable
class AppSeasonModel {
  final bool isActive;
  final int? id;
  final String? name;
  final String? code;

  const AppSeasonModel({
    required this.isActive,
    this.id,
    this.name,
    this.code,
  });

  factory AppSeasonModel.fromJson(Map<String, dynamic> json) {
    final rawActive = json['is_active'] ?? json['active'] ?? json['is_season_active'];
    final bool active = rawActive == true ||
        rawActive == 1 ||
        rawActive.toString().toLowerCase() == 'true' ||
        rawActive.toString() == '1';

    if (!active) {
      return const AppSeasonModel(isActive: false);
    }

    if (json['season'] is Map) {
      final s = json['season'] as Map<String, dynamic>;
      return AppSeasonModel(
        isActive: true,
        id: s['id'] is int ? s['id'] as int : int.tryParse(s['id']?.toString() ?? ''),
        name: s['name']?.toString(),
        code: s['code']?.toString(),
      );
    }

    return AppSeasonModel(
      isActive: true,
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['season_name']?.toString(),
      code: json['code']?.toString() ?? json['season_code']?.toString(),
    );
  }
}
