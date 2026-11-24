import 'package:flutter/foundation.dart';
import '../models/islamic_wisdom_model.dart';
import '../services/wisdom_service.dart';
import 'favorites_provider.dart';

class WisdomProvider extends ChangeNotifier {
  final WisdomService _service = WisdomService();

  List<IslamicWisdomModel> _allWisdom = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _selectedSpeaker = 'all';
  String _searchQuery = '';
  bool _showOnlyFavorites = false;
  int _carouselIndex = 0;

  WisdomProvider() {
    loadData();
  }

  bool get isLoading => _isLoading;
  List<IslamicWisdomModel> get allWisdom => _allWisdom;
  String get selectedCategory => _selectedCategory;
  String get selectedSpeaker => _selectedSpeaker;
  String get searchQuery => _searchQuery;
  bool get showOnlyFavorites => _showOnlyFavorites;
  int get carouselIndex => _carouselIndex;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _allWisdom = await _service.loadWisdom();
    _isLoading = false;

    // Set initial carousel index to daily wisdom index
    final daily = _service.getDailyWisdom();
    if (daily != null) {
      final idx = _allWisdom.indexWhere((w) => w.id == daily.id);
      if (idx != -1) {
        _carouselIndex = idx;
      }
    }
    notifyListeners();
  }

  IslamicWisdomModel? get currentCarouselWisdom {
    if (_allWisdom.isEmpty) return null;
    return _allWisdom[_carouselIndex % _allWisdom.length];
  }

  void nextWisdom() {
    if (_allWisdom.isEmpty) return;
    _carouselIndex = (_carouselIndex + 1) % _allWisdom.length;
    notifyListeners();
  }

  void previousWisdom() {
    if (_allWisdom.isEmpty) return;
    _carouselIndex = (_carouselIndex - 1 + _allWisdom.length) % _allWisdom.length;
    notifyListeners();
  }

  void setCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSpeaker(String speaker) {
    _selectedSpeaker = speaker;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void toggleShowOnlyFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  List<IslamicWisdomModel> getFilteredWisdom(FavoritesProvider favProvider) {
    return _allWisdom.where((w) {
      // Category filter
      if (_selectedCategory != 'all' && w.categoryId != _selectedCategory) {
        return false;
      }

      // Speaker filter
      if (_selectedSpeaker != 'all' && w.speaker != _selectedSpeaker) {
        return false;
      }

      // Favorites filter
      if (_showOnlyFavorites && !favProvider.isWisdomBookmarked(w.id)) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final inSomali = w.somali.toLowerCase().contains(_searchQuery);
        final inArabic = w.arabic.contains(_searchQuery);
        final inSpeaker = w.speaker.toLowerCase().contains(_searchQuery);
        final inCategory = w.categoryName.toLowerCase().contains(_searchQuery);
        final inRef = w.reference.toLowerCase().contains(_searchQuery);
        if (!inSomali && !inArabic && !inSpeaker && !inCategory && !inRef) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<String> get availableSpeakers => _service.getUniqueSpeakers();

  String formatShareText(IslamicWisdomModel wisdom) {
    return """
✨ HIKMAD IYO HADAL QAALI AH ✨

« ${wisdom.arabic} »

"${wisdom.somali}"

🎙️ Hadalkii: ${wisdom.speaker}
📌 Maqaamka: ${wisdom.speakerTitle}
📖 Xigashada: ${wisdom.reference}
🏷️ Qaybta: ${wisdom.categoryName}

📱 Laga soo xigtay: App-ka Sheekh Xuseen Cali Jabuuti
""".trim();
  }
}
