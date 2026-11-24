import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/islamic_wisdom_model.dart';

class WisdomCategoryInfo {
  final String id;
  final String name;
  final String arabicTitle;
  final String iconName;

  const WisdomCategoryInfo({
    required this.id,
    required this.name,
    required this.arabicTitle,
    required this.iconName,
  });
}

class WisdomService {
  static final WisdomService _instance = WisdomService._internal();
  factory WisdomService() => _instance;
  WisdomService._internal();

  List<IslamicWisdomModel> _cachedWisdom = [];
  bool _isLoaded = false;

  static const List<WisdomCategoryInfo> categories = [
    WisdomCategoryInfo(
      id: 'all',
      name: 'Dhammaan',
      arabicTitle: 'الكل',
      iconName: 'all_inclusive',
    ),
    WisdomCategoryInfo(
      id: 'diin',
      name: 'Hikmadda Diinta',
      arabicTitle: 'حكمة الدين والإيمان',
      iconName: 'menu_book',
    ),
    WisdomCategoryInfo(
      id: 'akhlaaq',
      name: 'Akhlaaqda & Dabeecadda',
      arabicTitle: 'الأخلاق والآداب',
      iconName: 'favorite',
    ),
    WisdomCategoryInfo(
      id: 'cilmi',
      name: 'Cilmiga & Aqoonta',
      arabicTitle: 'العلم والتعلم',
      iconName: 'school',
    ),
    WisdomCategoryInfo(
      id: 'nolol',
      name: 'Nolosha & Dunida',
      arabicTitle: 'حقيقة الدنيا',
      iconName: 'public',
    ),
    WisdomCategoryInfo(
      id: 'samir',
      name: 'Samirka & Tawakkulka',
      arabicTitle: 'الصبر والتوكل',
      iconName: 'shield',
    ),
    WisdomCategoryInfo(
      id: 'waqti',
      name: 'Waqtiga & Cimriga',
      arabicTitle: 'قيمة الوقت والعمر',
      iconName: 'hourglass_empty',
    ),
    WisdomCategoryInfo(
      id: 'qalbi',
      name: 'Qalbiga & Nafsiga',
      arabicTitle: 'صلاح القلوب والنفوس',
      iconName: 'spa',
    ),
    WisdomCategoryInfo(
      id: 'caddaalad',
      name: 'Caddaaladda & Hogaaminta',
      arabicTitle: 'العدل والقيادة',
      iconName: 'balance',
    ),
  ];

  Future<List<IslamicWisdomModel>> loadWisdom() async {
    if (_isLoaded && _cachedWisdom.isNotEmpty) {
      return _cachedWisdom;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/islamic_wisdom.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _cachedWisdom = decoded
            .map((item) => IslamicWisdomModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoaded = true;
      }
    } catch (_) {
      _cachedWisdom = [];
    }
    return _cachedWisdom;
  }

  List<IslamicWisdomModel> get cachedWisdom => _cachedWisdom;

  IslamicWisdomModel? getDailyWisdom() {
    if (_cachedWisdom.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _cachedWisdom[dayOfYear % _cachedWisdom.length];
  }

  List<String> getUniqueSpeakers() {
    final speakers = _cachedWisdom.map((w) => w.speaker).toSet().toList();
    // Sort logically: Prophet ﷺ first, then Sahabah, then others
    speakers.sort((a, b) {
      if (a.contains('ﷺ')) return -1;
      if (b.contains('ﷺ')) return 1;
      if (a.contains('(R.A)')) return -1;
      if (b.contains('(R.A)')) return 1;
      return a.compareTo(b);
    });
    return speakers;
  }
}
