import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/adkhar_model.dart';
import '../models/adhkar_category_model.dart';
import '../services/storage_service.dart';

class AdhkarProvider extends ChangeNotifier {
  final StorageService _storage;
  List<AdkharModel> _adhkarList = [];
  List<AdhkarCategoryModel> _categories = [];
  String _selectedCategory = 'Adkaar Subax';
  String _selectedCategoryId = 'morning';
  String _searchQuery = '';
  int _tasbihCount = 0;
  static const int tasbihTarget = 100;
  bool _isCommentaryPlaying = false;
  bool _isLoading = false;

  AdhkarProvider(this._storage) {
    _categories = _getDefaultCategories();
    _initDefaultCategoryByTime();
    _init();
  }

  void _initDefaultCategoryByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      _selectedCategory = 'Adkaar Subax';
      _selectedCategoryId = 'morning';
    } else if (hour >= 12 && hour < 20) {
      _selectedCategory = 'Adkaar Galab';
      _selectedCategoryId = 'evening';
    } else {
      _selectedCategory = 'Hurdada & Tooska';
      _selectedCategoryId = 'sleeping';
    }
  }

  bool get isLoading => _isLoading;
  List<AdkharModel> get adhkarList => _adhkarList;
  List<AdhkarCategoryModel> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  int get tasbihCount => _tasbihCount;
  bool get isCommentaryPlaying => _isCommentaryPlaying;

  List<AdkharModel> get filteredList {
    Iterable<AdkharModel> list = _adhkarList;
    if (_selectedCategory != 'Dhammaan') {
      list = list.where((d) =>
          d.category == _selectedCategory ||
          d.categoryId == _selectedCategoryId ||
          d.categoryId == _selectedCategory);
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((d) =>
          d.title.toLowerCase().contains(q) ||
          d.somaliTranslation.toLowerCase().contains(q) ||
          d.arabicText.contains(q) ||
          d.reference.toLowerCase().contains(q));
    }
    return list.toList();
  }

  int get totalCompletedCount {
    return _adhkarList.where((d) => d.isCompleted).length;
  }

  int get categoryCompletedCount {
    return filteredList.where((d) => d.isCompleted).length;
  }

  int get totalCount => _adhkarList.length;

  double get overallProgress {
    if (_adhkarList.isEmpty) return 0.0;
    return (totalCompletedCount / _adhkarList.length).clamp(0.0, 1.0);
  }

  String get overallProgressText {
    return '$totalCompletedCount / ${_adhkarList.length} Dhammaystiran';
  }

  AdhkarCategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere(
        (c) => c.id == id || c.somaliTitle == id || c.arabicTitle == id,
      );
    } catch (_) {
      return null;
    }
  }

  List<AdkharModel> getDuasForCategory(String categoryIdOrName) {
    return _adhkarList.where((d) {
      return d.categoryId == categoryIdOrName ||
          d.category == categoryIdOrName ||
          _matchesCategory(d, categoryIdOrName);
    }).toList();
  }

  List<AdkharModel> getFilteredDuasForCategory(String categoryIdOrName, String query) {
    final list = getDuasForCategory(categoryIdOrName);
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((d) {
      return d.title.toLowerCase().contains(q) ||
          (d.arabicTitle != null && d.arabicTitle!.contains(q)) ||
          d.somaliTranslation.toLowerCase().contains(q) ||
          d.arabicText.contains(q) ||
          (d.transliteration != null && d.transliteration!.toLowerCase().contains(q)) ||
          d.reference.toLowerCase().contains(q);
    }).toList();
  }

  bool _matchesCategory(AdkharModel d, String identifier) {
    final idLower = identifier.toLowerCase();
    if (d.categoryId?.toLowerCase() == idLower) return true;
    if (d.category.toLowerCase() == idLower) return true;

    // Mapping aids for Somali variations
    if (idLower == 'morning' && (d.category.contains('Subax') || d.categoryId == 'morning')) return true;
    if (idLower == 'evening' && (d.category.contains('Galab') || d.categoryId == 'evening')) return true;
    if (idLower == 'after_salah' && (d.category.contains('Salaad') || d.categoryId == 'after_salah')) return true;
    if (idLower == 'market' && (d.category.contains('Suuq') || d.categoryId == 'market')) return true;
    if (idLower == 'sleeping' && (d.category.contains('Hurdo') || d.category.contains('Toos') || d.categoryId == 'sleeping')) return true;
    if (idLower == 'ruqyah' && (d.category.toLowerCase().contains('ruqyah') || d.categoryId == 'ruqyah')) return true;
    if (idLower == 'protection' && (d.category.contains('Ilaal') || d.category.contains('Xijaab') || d.categoryId == 'protection')) return true;
    if (idLower == 'forgiveness' && (d.category.contains('Dambi') || d.category.contains('Toobad') || d.categoryId == 'forgiveness')) return true;
    if (idLower == 'travel' && (d.category.contains('Safar') || d.categoryId == 'travel')) return true;
    if (idLower == 'eating' && (d.category.contains('Cunto') || d.categoryId == 'eating')) return true;
    if (idLower == 'home' && (d.category.contains('Guri') || d.categoryId == 'home')) return true;
    if (idLower == 'mosque' && (d.category.contains('Masaajid') || d.categoryId == 'mosque')) return true;
    if (idLower == 'general_duas' && (d.category.contains('Guud') || d.category.contains('Maalinle') || d.categoryId == 'general_duas')) return true;
    return false;
  }

  int getCategoryDuaCount(String categoryIdOrName) {
    return getDuasForCategory(categoryIdOrName).length;
  }

  int getCategoryCompletedCount(String categoryIdOrName) {
    return getDuasForCategory(categoryIdOrName).where((d) => d.isCompleted).length;
  }

  double getCategoryProgress(String categoryIdOrName) {
    final list = getDuasForCategory(categoryIdOrName);
    if (list.isEmpty) return 0.0;
    final done = list.where((d) => d.isCompleted).length;
    return (done / list.length).clamp(0.0, 1.0);
  }

  Future<void> _init() async {
    _tasbihCount = _storage.getTasbihCount();
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load Categories
      await _loadCategories();

      // 2. Load Duas from all JSON category files
      await _loadDuas();
    } catch (e) {
      debugPrint('Error initializing AdhkarProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/adhkar/categories.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      _categories = decoded
          .map((item) => AdhkarCategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading categories.json: $e');
      _categories = _getDefaultCategories();
    }
  }

  Future<void> _loadDuas() async {
    final completedIds = _storage.getTodayCompletedAdhkar();
    final List<AdkharModel> loadedDuas = [];

    // Helper to decode a JSON source that might be a List or a Map {"category": ..., "duas": [...]}
    void addDuasFromDecoded(dynamic decoded, {String? defaultCatId, String? defaultCatName}) {
      List<dynamic> items = [];
      String? catId = defaultCatId;
      String? catName = defaultCatName;

      if (decoded is Map<String, dynamic>) {
        final catKey = decoded['category']?.toString();
        if (catKey == 'morning') {
          catId ??= 'morning';
          catName ??= 'Adkaarta Subaxda';
        } else if (catKey == 'evening') {
          catId ??= 'evening';
          catName ??= 'Adkaarta Galabta';
        }
        if (decoded['duas'] is List) {
          items = decoded['duas'] as List;
        }
      } else if (decoded is List) {
        items = decoded;
      }

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final model = AdkharModel.fromJson(
            item,
            defaultCategory: catName,
            defaultCategoryId: catId,
          );
          final savedCount = _storage.getDhikrCount(model.id);
          final isDone = completedIds.contains(model.id) || savedCount >= model.targetCount;
          loadedDuas.add(model.copyWith(
            currentCount: isDone ? model.targetCount : savedCount,
            isCompleted: isDone,
          ));
        }
      }
    }

    // 1. Load Morning Adhkar (prioritize assets/data/morning_adhkar.json)
    bool morningLoaded = false;
    try {
      final morningContent = await rootBundle.loadString('assets/data/morning_adhkar.json');
      final decoded = jsonDecode(morningContent);
      addDuasFromDecoded(decoded, defaultCatId: 'morning', defaultCatName: 'Adkaarta Subaxda');
      morningLoaded = true;
    } catch (e) {
      debugPrint('Could not load assets/data/morning_adhkar.json: $e');
    }

    if (!morningLoaded) {
      try {
        final morningContent = await rootBundle.loadString('assets/data/adhkar/morning.json');
        final decoded = jsonDecode(morningContent);
        addDuasFromDecoded(decoded, defaultCatId: 'morning', defaultCatName: 'Adkaarta Subaxda');
      } catch (e) {
        debugPrint('Could not load assets/data/adhkar/morning.json: $e');
      }
    }

    // 2. Load Evening Adhkar (prioritize assets/data/evening_adhkar.json)
    bool eveningLoaded = false;
    try {
      final eveningContent = await rootBundle.loadString('assets/data/evening_adhkar.json');
      final decoded = jsonDecode(eveningContent);
      addDuasFromDecoded(decoded, defaultCatId: 'evening', defaultCatName: 'Adkaarta Galabta');
      eveningLoaded = true;
    } catch (e) {
      debugPrint('Could not load assets/data/evening_adhkar.json: $e');
    }

    if (!eveningLoaded) {
      try {
        final eveningContent = await rootBundle.loadString('assets/data/adhkar/evening.json');
        final decoded = jsonDecode(eveningContent);
        addDuasFromDecoded(decoded, defaultCatId: 'evening', defaultCatName: 'Adkaarta Galabta');
      } catch (e) {
        debugPrint('Could not load assets/data/adhkar/evening.json: $e');
      }
    }

    // 3. Load remaining categories from assets/data/adhkar/
    final otherCategoryFiles = [
      'after_salah.json',
      'market.json',
      'sleeping.json',
      'ruqyah.json',
      'protection.json',
      'forgiveness.json',
      'travel.json',
      'eating.json',
      'home.json',
      'mosque.json',
      'general_duas.json',
    ];

    for (final filename in otherCategoryFiles) {
      try {
        final content = await rootBundle.loadString('assets/data/adhkar/$filename');
        final decoded = jsonDecode(content);
        addDuasFromDecoded(decoded);
      } catch (e) {
        debugPrint('Could not load $filename: $e');
      }
    }

    // Fallback if loading failed: load from master adhkar.json
    if (loadedDuas.isEmpty) {
      try {
        final content = await rootBundle.loadString('assets/data/adhkar/adhkar.json');
        final decoded = jsonDecode(content);
        addDuasFromDecoded(decoded);
      } catch (e) {
        debugPrint('Error loading master adhkar.json: $e');
      }
    }

    if (loadedDuas.isNotEmpty) {
      _adhkarList = loadedDuas;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    final cat = getCategoryById(category);
    if (cat != null) {
      _selectedCategoryId = cat.id;
    }
    notifyListeners();
  }

  void setCategoryId(String id) {
    _selectedCategoryId = id;
    final cat = getCategoryById(id);
    if (cat != null) {
      _selectedCategory = cat.somaliTitle;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void incrementDhikr(String id) {
    final index = _adhkarList.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _adhkarList[index];
    if (item.currentCount < item.targetCount) {
      final newCount = item.currentCount + 1;
      final isNowCompleted = newCount >= item.targetCount;

      _adhkarList[index] = item.copyWith(
        currentCount: newCount,
        isCompleted: isNowCompleted,
      );

      _storage.setDhikrCount(id, newCount);
      _persistCompleted();
      notifyListeners();
    }
  }

  void resetDhikr(String id) {
    final index = _adhkarList.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _adhkarList[index];
    _adhkarList[index] = item.copyWith(
      currentCount: 0,
      isCompleted: false,
    );

    _storage.setDhikrCount(id, 0);
    _persistCompleted();
    notifyListeners();
  }

  void incrementTasbih() {
    if (_tasbihCount < tasbihTarget) {
      _tasbihCount++;
    } else {
      _tasbihCount = 1;
    }
    _storage.setTasbihCount(_tasbihCount);
    notifyListeners();
  }

  void resetTasbih() {
    _tasbihCount = 0;
    _storage.setTasbihCount(0);
    notifyListeners();
  }

  void toggleCommentaryPlay() {
    _isCommentaryPlaying = !_isCommentaryPlaying;
    notifyListeners();
  }

  void _persistCompleted() {
    final completedIds = _adhkarList
        .where((item) => item.isCompleted)
        .map((item) => item.id)
        .toList();
    _storage.setTodayCompletedAdhkar(completedIds);
  }

  List<AdhkarCategoryModel> _getDefaultCategories() {
    return const [
      AdhkarCategoryModel(
        id: 'morning',
        arabicTitle: 'أذكار الصباح',
        somaliTitle: 'Adkaar Subax',
        englishTitle: 'Morning Adhkar',
        description: 'Xuska iyo dhowrsoonaanta bilowga maalinta cusub.',
        icon: 'wb_sunny_rounded',
        duaCount: 23,
        jsonFile: 'morning.json',
      ),
      AdhkarCategoryModel(
        id: 'evening',
        arabicTitle: 'أذكار المساء',
        somaliTitle: 'Adkaar Galab',
        englishTitle: 'Evening Adhkar',
        description: 'Xuska iyo ilaalinta nafta xilliga gabbalka.',
        icon: 'wb_twilight_rounded',
        duaCount: 22,
        jsonFile: 'evening.json',
      ),
      AdhkarCategoryModel(
        id: 'after_salah',
        arabicTitle: 'أذكار بعد الصلاة',
        somaliTitle: 'Salaadda Kadib',
        englishTitle: 'After Salah Adhkar',
        description: 'Tasbiixda iyo ducooyinka salaadaha faradka kadib.',
        icon: 'mosque_rounded',
        duaCount: 10,
        jsonFile: 'after_salah.json',
      ),
      AdhkarCategoryModel(
        id: 'market',
        arabicTitle: 'دعاء السوق',
        somaliTitle: 'Ducada Suuqa',
        englishTitle: 'Market Dua',
        description: 'Ducada suuqa la galo iyo ajarteeda weyn.',
        icon: 'storefront_rounded',
        duaCount: 2,
        jsonFile: 'market.json',
      ),
      AdhkarCategoryModel(
        id: 'sleeping',
        arabicTitle: 'أذكار النوم والاستيقاظ',
        somaliTitle: 'Hurdada & Tooska',
        englishTitle: 'Sleeping & Waking Adhkar',
        description: 'Ducooyinka hurdada ka hor iyo soo tooska.',
        icon: 'bedtime_rounded',
        duaCount: 8,
        jsonFile: 'sleeping.json',
      ),
      AdhkarCategoryModel(
        id: 'ruqyah',
        arabicTitle: 'الرقية الشرعية',
        somaliTitle: 'Ruqyo Sharci ah',
        englishTitle: 'Ruqyah Shariah',
        description: 'Ku daweynta Quraanka indhaha, sixirka iyo jinka.',
        icon: 'health_and_safety_rounded',
        duaCount: 11,
        jsonFile: 'ruqyah.json',
      ),
      AdhkarCategoryModel(
        id: 'protection',
        arabicTitle: 'أدعية الحفظ والتحصين',
        somaliTitle: 'Ilaalinta Nafta',
        englishTitle: 'Protection and Safety Duas',
        description: 'Ilaalinta qofka ee shararka iyo balaayooyinka.',
        icon: 'shield_rounded',
        duaCount: 6,
        jsonFile: 'protection.json',
      ),
      AdhkarCategoryModel(
        id: 'forgiveness',
        arabicTitle: 'الاستغفار والتوبة',
        somaliTitle: 'Dambi-dhaafka',
        englishTitle: 'Forgiveness & Repentance',
        description: 'Dambi-dhaaf weydiisiga Alle iyo toobadda.',
        icon: 'favorite_rounded',
        duaCount: 6,
        jsonFile: 'forgiveness.json',
      ),
      AdhkarCategoryModel(
        id: 'travel',
        arabicTitle: 'أذكار السفر',
        somaliTitle: 'Ducada Safarka',
        englishTitle: 'Travel Duas',
        description: 'Ducada gaadiidka iyo badbaadada jidka dheer.',
        icon: 'directions_car_rounded',
        duaCount: 4,
        jsonFile: 'travel.json',
      ),
      AdhkarCategoryModel(
        id: 'eating',
        arabicTitle: 'أذكار الطعام والشراب',
        somaliTitle: 'Ducada Cuntada',
        englishTitle: 'Eating & Drinking Duas',
        description: 'Bismillaahida bilowga iyo xamdiga cuntada kadib.',
        icon: 'restaurant_rounded',
        duaCount: 4,
        jsonFile: 'eating.json',
      ),
      AdhkarCategoryModel(
        id: 'home',
        arabicTitle: 'أذكار دخول المنزل والخروج منه',
        somaliTitle: 'Ducada Guriga',
        englishTitle: 'Entering & Leaving Home',
        description: 'Ducada gelidda iyo ka bixidda guriga.',
        icon: 'home_rounded',
        duaCount: 4,
        jsonFile: 'home.json',
      ),
      AdhkarCategoryModel(
        id: 'mosque',
        arabicTitle: 'أذكار المسجد',
        somaliTitle: 'Ducada Masaajidka',
        englishTitle: 'Mosque Duas',
        description: 'Ducada socodka, gelidda iyo ka bixidda masaajidka.',
        icon: 'account_balance_rounded',
        duaCount: 3,
        jsonFile: 'mosque.json',
      ),
      AdhkarCategoryModel(
        id: 'general_duas',
        arabicTitle: 'أدعية متنوعة',
        somaliTitle: 'Ducooyin Guud',
        englishTitle: 'General Important Duas',
        description: 'Ducooyinka werwerka, culayska iyo dhibaatooyinka.',
        icon: 'auto_stories_rounded',
        duaCount: 6,
        jsonFile: 'general_duas.json',
      ),
    ];
  }
}
