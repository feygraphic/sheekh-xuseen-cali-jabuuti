import 'package:flutter/material.dart';

class AdhkarCategoryModel {
  final String id;
  final String arabicTitle;
  final String somaliTitle;
  final String englishTitle;
  final String description;
  final String icon;
  final int duaCount;
  final String jsonFile;
  final String? timeRange;
  final List<String> gradient;

  const AdhkarCategoryModel({
    required this.id,
    required this.arabicTitle,
    required this.somaliTitle,
    required this.englishTitle,
    required this.description,
    required this.icon,
    required this.duaCount,
    required this.jsonFile,
    this.timeRange,
    this.gradient = const ['#7A3E9D', '#4A2882'],
  });

  factory AdhkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdhkarCategoryModel(
      id: json['id'] as String,
      arabicTitle: json['arabicTitle'] as String,
      somaliTitle: json['somaliTitle'] as String,
      englishTitle: json['englishTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'wb_sunny_rounded',
      duaCount: json['duaCount'] as int? ?? 0,
      jsonFile: json['jsonFile'] as String? ?? '',
      timeRange: json['timeRange'] as String?,
      gradient: (json['gradient'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['#7A3E9D', '#4A2882'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicTitle': arabicTitle,
      'somaliTitle': somaliTitle,
      'englishTitle': englishTitle,
      'description': description,
      'icon': icon,
      'duaCount': duaCount,
      'jsonFile': jsonFile,
      'timeRange': timeRange,
      'gradient': gradient,
    };
  }

  IconData get iconData {
    switch (icon) {
      case 'wb_sunny_rounded':
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'wb_twilight_rounded':
      case 'wb_twilight':
        return Icons.wb_twilight_rounded;
      case 'mosque_rounded':
      case 'mosque':
        return Icons.mosque_rounded;
      case 'storefront_rounded':
      case 'storefront':
        return Icons.storefront_rounded;
      case 'bedtime_rounded':
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'health_and_safety_rounded':
      case 'healing':
        return Icons.health_and_safety_rounded;
      case 'shield_rounded':
      case 'shield':
        return Icons.shield_rounded;
      case 'favorite_rounded':
      case 'favorite':
        return Icons.favorite_rounded;
      case 'directions_car_rounded':
      case 'directions_bus':
        return Icons.directions_car_rounded;
      case 'restaurant_rounded':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'home_rounded':
      case 'home':
        return Icons.home_rounded;
      case 'account_balance_rounded':
      case 'location_city':
        return Icons.account_balance_rounded;
      case 'auto_stories_rounded':
      case 'auto_stories':
      default:
        return Icons.auto_stories_rounded;
    }
  }
}
