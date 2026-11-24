import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/tasbeeh_model.dart';
import '../services/storage_service.dart';

class TasbeehProvider extends ChangeNotifier {
  final StorageService _storage;

  static const List<TasbeehItem> _defaultDhikrs = [
    TasbeehItem(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Subxaanallaah',
      category: 'Tasbiix',
      target: 33,
    ),
    TasbeehItem(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alxamdulillaah',
      category: 'Xamdiga Eebbe',
      target: 33,
    ),
    TasbeehItem(
      id: 'allahuakbar',
      arabic: 'اللهُ أَكْبَرُ',
      transliteration: 'Allaahu Akbar',
      category: 'Waynaynta Eebbe',
      target: 33,
    ),
    TasbeehItem(
      id: 'lailahaillallah',
      arabic: 'لَا إِلَهَ إِلَّا اللَّهُ',
      transliteration: 'Laa ilaaha illallaah',
      category: 'Towxiidka',
      target: 100,
    ),
    TasbeehItem(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      transliteration: 'Astaghfirullaaha wa atoobu ilayhi',
      category: 'Istiqfaar',
      target: 100,
    ),
    TasbeehItem(
      id: 'salawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
      transliteration: 'Saliga Nabiga (SCW)',
      category: 'Salawaat',
      target: 100,
    ),
    TasbeehItem(
      id: 'hawqalah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'Laa xawla walaa quwwata illaa billaah',
      category: 'Xusid',
      target: 100,
    ),
    TasbeehItem(
      id: 'subhanallah_wabihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      transliteration: 'Subhaanallaahi wabixamdihi, Subhaanallaahil Caziim',
      category: 'Fasalka Weyn',
      target: 100,
    ),
  ];

  List<TasbeehItem> _items = [];
  String _selectedId = 'subhanallah';
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;

  // Track if target was just reached for triggering celebration
  bool _targetCompletedEvent = false;

  TasbeehProvider(this._storage) {
    _loadState();
  }

  // --- Getters ---
  List<TasbeehItem> get items => List.unmodifiable(_items);
  String get selectedId => _selectedId;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get targetCompletedEvent => _targetCompletedEvent;

  TasbeehItem get currentItem {
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx != -1) return _items[idx];
    if (_items.isNotEmpty) return _items.first;
    return _defaultDhikrs.first;
  }

  int get currentCount => currentItem.currentCount;
  int get currentTarget => currentItem.target;
  int get currentCycles => currentItem.cycleCount;
  double get currentProgress =>
      currentTarget > 0 ? (currentCount / currentTarget).clamp(0.0, 1.0) : 0.0;

  // Statistics
  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  int get todayCount {
    final todayKey = _formatDate(DateTime.now());
    return _storage.getTasbeehDateCount(todayKey);
  }

  int get yesterdayCount {
    final yesterdayKey = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
    return _storage.getTasbeehDateCount(yesterdayKey);
  }

  int get totalCount => _storage.getTasbeehTotalCount();

  // --- Load State ---
  void _loadState() {
    _vibrationEnabled = _storage.getTasbeehVibrationEnabled();
    _soundEnabled = _storage.getTasbeehSoundEnabled();

    // 1. Build initial items from default + custom
    final List<TasbeehItem> list = [];
    for (final def in _defaultDhikrs) {
      final savedCount = _storage.getTasbeehItemCount(def.id);
      final savedTarget = _storage.getTasbeehItemTarget(def.id, def.target);
      final savedCycles = _storage.getTasbeehItemCycles(def.id);
      list.add(def.copyWith(
        currentCount: savedCount,
        target: savedTarget,
        cycleCount: savedCycles,
      ));
    }

    // Load custom dhikrs
    final customRaw = _storage.getTasbeehCustomDhikrs();
    for (final raw in customRaw) {
      try {
        final parsed = TasbeehItem.fromJson(raw);
        final savedCount = _storage.getTasbeehItemCount(parsed.id);
        final savedTarget = _storage.getTasbeehItemTarget(parsed.id, parsed.target);
        final savedCycles = _storage.getTasbeehItemCycles(parsed.id);
        list.add(parsed.copyWith(
          currentCount: savedCount,
          target: savedTarget,
          cycleCount: savedCycles,
        ));
      } catch (e) {
        debugPrint('Error parsing custom dhikr: $e');
      }
    }

    _items = list;
    _selectedId = _storage.getTasbeehSelectedId();
    if (!_items.any((e) => e.id == _selectedId)) {
      _selectedId = _items.first.id;
    }

    notifyListeners();
  }

  // --- Actions ---

  /// Primary increment action on tapping the counter
  void increment() {
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx == -1) return;

    final item = _items[idx];
    int newCount = item.currentCount + 1;
    int newCycles = item.cycleCount;
    bool isCompleted = false;

    if (newCount >= item.target) {
      isCompleted = true;
      newCycles += 1;
    }

    _items[idx] = item.copyWith(
      currentCount: newCount,
      cycleCount: newCycles,
    );

    // Update statistics
    final todayKey = _formatDate(DateTime.now());
    final currentToday = _storage.getTasbeehDateCount(todayKey);
    _storage.setTasbeehDateCount(todayKey, currentToday + 1);

    final currentTotal = _storage.getTasbeehTotalCount();
    _storage.setTasbeehTotalCount(currentTotal + 1);

    // Save item state
    _storage.setTasbeehItemCount(item.id, newCount);
    _storage.setTasbeehItemCycles(item.id, newCycles);

    // Trigger haptics
    if (_vibrationEnabled) {
      if (isCompleted) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    if (isCompleted) {
      _targetCompletedEvent = true;
    }

    notifyListeners();
  }

  void consumeTargetCompletedEvent() {
    _targetCompletedEvent = false;
  }

  /// Undo the last count
  bool undo() {
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx == -1) return false;

    final item = _items[idx];
    if (item.currentCount <= 0 && item.cycleCount <= 0) {
      return false;
    }

    int newCount = item.currentCount - 1;
    int newCycles = item.cycleCount;

    if (newCount < 0) {
      if (newCycles > 0) {
        newCycles -= 1;
        newCount = item.target > 0 ? item.target - 1 : 0;
      } else {
        newCount = 0;
      }
    }

    _items[idx] = item.copyWith(
      currentCount: newCount,
      cycleCount: newCycles,
    );

    // Decrement today & total stats
    final todayKey = _formatDate(DateTime.now());
    final currentToday = _storage.getTasbeehDateCount(todayKey);
    if (currentToday > 0) {
      _storage.setTasbeehDateCount(todayKey, currentToday - 1);
    }

    final currentTotal = _storage.getTasbeehTotalCount();
    if (currentTotal > 0) {
      _storage.setTasbeehTotalCount(currentTotal - 1);
    }

    _storage.setTasbeehItemCount(item.id, newCount);
    _storage.setTasbeehItemCycles(item.id, newCycles);

    if (_vibrationEnabled) {
      HapticFeedback.selectionClick();
    }

    notifyListeners();
    return true;
  }

  /// Reset the current Dhikr's count (preserves today and total stats)
  void resetCurrentDhikr() {
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx == -1) return;

    final item = _items[idx];
    _items[idx] = item.copyWith(
      currentCount: 0,
      cycleCount: 0,
    );

    _storage.setTasbeehItemCount(item.id, 0);
    _storage.setTasbeehItemCycles(item.id, 0);

    if (_vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    notifyListeners();
  }

  /// Reset count after completing a round to start next round
  void continueNextRound() {
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx == -1) return;

    final item = _items[idx];
    _items[idx] = item.copyWith(currentCount: 0);
    _storage.setTasbeehItemCount(item.id, 0);
    notifyListeners();
  }

  /// Set the counting target (e.g. 33, 100, 1000, or custom)
  void setTarget(int target) {
    if (target <= 0) return;
    final idx = _items.indexWhere((e) => e.id == _selectedId);
    if (idx == -1) return;

    final item = _items[idx];
    _items[idx] = item.copyWith(target: target);
    _storage.setTasbeehItemTarget(item.id, target);

    if (item.isCustom) {
      _persistCustomDhikrs();
    }

    notifyListeners();
  }

  /// Select a different Dhikr
  void selectDhikr(String id) {
    if (!_items.any((e) => e.id == id)) return;
    _selectedId = id;
    _storage.setTasbeehSelectedId(id);
    if (_vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    notifyListeners();
  }

  /// Add a brand new custom Dhikr
  void addCustomDhikr({
    required String arabic,
    required String transliteration,
    String category = 'Gaar ah',
    int target = 33,
  }) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = TasbeehItem(
      id: id,
      arabic: arabic.trim(),
      transliteration: transliteration.trim().isEmpty ? 'Dhikr Gaar ah' : transliteration.trim(),
      category: category,
      target: target,
      currentCount: 0,
      cycleCount: 0,
      isCustom: true,
    );

    _items.add(newItem);
    _selectedId = id;
    _storage.setTasbeehSelectedId(id);
    _storage.setTasbeehItemTarget(id, target);
    _storage.setTasbeehItemCount(id, 0);
    _storage.setTasbeehItemCycles(id, 0);
    _persistCustomDhikrs();

    notifyListeners();
  }

  /// Delete a custom Dhikr
  void deleteCustomDhikr(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1 || !_items[idx].isCustom) return;

    _items.removeAt(idx);
    if (_selectedId == id) {
      _selectedId = _items.first.id;
      _storage.setTasbeehSelectedId(_selectedId);
    }
    _persistCustomDhikrs();
    notifyListeners();
  }

  void _persistCustomDhikrs() {
    final customList = _items.where((e) => e.isCustom).map((e) => e.toJson()).toList();
    _storage.setTasbeehCustomDhikrs(customList);
  }

  // --- Settings ---
  void setVibration(bool enabled) {
    _vibrationEnabled = enabled;
    _storage.setTasbeehVibrationEnabled(enabled);
    notifyListeners();
  }

  void setSound(bool enabled) {
    _soundEnabled = enabled;
    _storage.setTasbeehSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> resetAllStats() async {
    await _storage.resetAllTasbeehStats();
    notifyListeners();
  }
}
