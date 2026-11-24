import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reciter_model.dart';
import 'storage_service.dart';

class QuranAudioService {
  static const String _apiEndpoint = 'https://www.mp3quran.net/api/v3/reciters?language=ar';
  static const String _apiEndpointFallback = 'https://mp3quran.net/api/v3/reciters?language=ar';

  final StorageService? _storage;
  List<ReciterModel> _cachedReciters = List.from(ReciterModel.popularReciters);
  bool _isLoading = false;

  QuranAudioService([this._storage]) {
    _initFromStorage();
  }

  List<ReciterModel> get cachedReciters => _cachedReciters;
  bool get isLoading => _isLoading;
  ReciterModel get defaultReciter => ReciterModel.defaultReciter;

  void _initFromStorage() {
    // If stored reciters exist, load them
    final storedJson = _storage?.getCustomSetting('cached_mp3quran_reciters');
    if (storedJson != null && storedJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        final loaded = list.map((item) => ReciterModel.fromJson(item as Map<String, dynamic>)).toList();
        if (loaded.isNotEmpty) {
          _cachedReciters = loaded;
        }
      } catch (e) {
        debugPrint('Error loading cached reciters: $e');
      }
    }
  }

  ReciterModel getReciterById(int id) {
    return _cachedReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => ReciterModel.defaultReciter,
    );
  }

  Future<List<ReciterModel>> fetchReciters({bool forceRefresh = false}) async {
    if (_isLoading) return _cachedReciters;
    _isLoading = true;

    try {
      http.Response response;
      try {
        response = await http.get(
          Uri.parse(_apiEndpoint),
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; SomaliQuranApp/2.0)'},
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        response = await http.get(
          Uri.parse(_apiEndpointFallback),
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; SomaliQuranApp/2.0)'},
        ).timeout(const Duration(seconds: 10));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('reciters') && data['reciters'] is List) {
          final List<dynamic> recitersRaw = data['reciters'];
          final List<ReciterModel> parsed = [];

          for (final item in recitersRaw) {
            if (item is! Map<String, dynamic>) continue;
            final moshafs = item['moshaf'];
            if (moshafs is! List || moshafs.isEmpty) continue;

            // Find best moshaf with 114 surahs
            Map<String, dynamic>? selectedMoshaf;
            for (final m in moshafs) {
              if (m is Map<String, dynamic> && m['surah_total'] == 114 && m['server'] != null && (m['server'] as String).isNotEmpty) {
                if ((m['name'] as String? ?? '').contains('حفص') || (m['name'] as String? ?? '').contains('مرتل')) {
                  selectedMoshaf = m;
                  break;
                }
                selectedMoshaf ??= m;
              }
            }

            if (selectedMoshaf != null) {
              parsed.add(
                ReciterModel(
                  id: item['id'] as int? ?? 0,
                  nameAr: item['name'] as String? ?? '',
                  nameEn: item['name'] as String? ?? '',
                  server: selectedMoshaf['server'] as String,
                  surahTotal: selectedMoshaf['surah_total'] as int? ?? 114,
                  moshafName: selectedMoshaf['name'] as String? ?? 'حفص عن عاصم',
                ),
              );
            }
          }

          if (parsed.isNotEmpty) {
            // Keep popular reciters at the top, then append new ones
            final popularIds = ReciterModel.popularReciters.map((r) => r.id).toSet();
            final remaining = parsed.where((r) => !popularIds.contains(r.id)).toList();
            _cachedReciters = [...ReciterModel.popularReciters, ...remaining];

            // Cache in storage
            _storage?.setCustomSetting(
              'cached_mp3quran_reciters',
              jsonEncode(_cachedReciters.map((r) => r.toJson()).toList()),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching MP3Quran reciters: $e');
    } finally {
      _isLoading = false;
    }

    return _cachedReciters;
  }
}
