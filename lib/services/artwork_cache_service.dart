import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Caches local artwork assets into temporary storage so Android's native
/// MediaSession / MediaStyle notification and Samsung One UI lock-screen can
/// immediately resolve full-resolution album art bitmaps via file:// URIs.
class ArtworkCacheService {
  static final Map<String, Uri> _cache = {};

  static Future<Uri?> getArtUri(String? assetOrUrl) async {
    if (assetOrUrl == null || assetOrUrl.isEmpty) return null;

    if (assetOrUrl.startsWith('http://') || assetOrUrl.startsWith('https://')) {
      return Uri.parse(assetOrUrl);
    }

    if (_cache.containsKey(assetOrUrl)) {
      return _cache[assetOrUrl];
    }

    if (kIsWeb) {
      final uri = Uri.parse(assetOrUrl);
      _cache[assetOrUrl] = uri;
      return uri;
    }

    try {
      final cleanPath = assetOrUrl.startsWith('assets/') ? assetOrUrl : 'assets/$assetOrUrl';
      final byteData = await rootBundle.load(cleanPath);
      final tempDir = await getTemporaryDirectory();
      final sanitizedName = cleanPath.replaceAll('/', '_').replaceAll('\\', '_');
      final file = File('${tempDir.path}/$sanitizedName');

      if (!await file.exists() || await file.length() != byteData.lengthInBytes) {
        await file.writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          flush: true,
        );
      }
      final uri = Uri.file(file.path);
      _cache[assetOrUrl] = uri;
      return uri;
    } catch (e) {
      debugPrint('ArtworkCacheService: Failed to cache asset artwork ($assetOrUrl): $e');
      return null;
    }
  }
}
