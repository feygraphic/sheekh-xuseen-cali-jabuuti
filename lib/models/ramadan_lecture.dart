/// Model representing a Ramadan Lecture record from the CSV.
class RamadanLecture {
  final String id;
  final String scholarId;
  final String scholarName;
  final String title;
  final String youtubeUrl;
  final String category;
  final String language;
  final int sortOrder;

  const RamadanLecture({
    required this.id,
    required this.scholarId,
    required this.scholarName,
    required this.title,
    required this.youtubeUrl,
    required this.category,
    required this.language,
    required this.sortOrder,
  });

  /// Extracts the 11-character YouTube video ID from various YouTube URL formats.
  String? get videoId {
    return extractVideoId(youtubeUrl);
  }

  /// High quality YouTube thumbnail URL
  String get thumbnailUrl {
    final vId = videoId;
    if (vId != null && vId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$vId/hqdefault.jpg';
    }
    return '';
  }

  /// Medium quality YouTube thumbnail URL (fallback)
  String get mqThumbnailUrl {
    final vId = videoId;
    if (vId != null && vId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$vId/mqdefault.jpg';
    }
    return '';
  }

  /// Capitalized title for elegant display while preserving original content
  String get displayTitle {
    if (title.isEmpty) return title;
    // Capitalize first character of each word for clean presentation
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  factory RamadanLecture.fromJson(Map<String, dynamic> json) {
    return RamadanLecture(
      id: json['id'] as String,
      scholarId: json['scholar_id'] as String,
      scholarName: json['scholar_name'] as String,
      title: json['title'] as String,
      youtubeUrl: json['youtube_url'] as String,
      category: json['category'] as String? ?? 'Ramadan',
      language: json['language'] as String? ?? 'Somali',
      sortOrder: (json['sort_order'] is int)
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scholar_id': scholarId,
      'scholar_name': scholarName,
      'title': title,
      'youtube_url': youtubeUrl,
      'category': category,
      'language': language,
      'sort_order': sortOrder,
    };
  }

  /// Helper to extract YouTube video ID from any standard or shortened YouTube URL.
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    final trimmed = url.trim();

    // Standard regex covering youtu.be, youtube.com/watch, embed, shorts, etc.
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }
}

/// Model representing one of the 5 Ramadan Scholars.
class RamadanScholar {
  final String id;
  final String name;
  final String arabicTitle;
  final String? imageAsset;
  final String title;
  final int expectedLectures;

  const RamadanScholar({
    required this.id,
    required this.name,
    required this.arabicTitle,
    this.imageAsset,
    required this.title,
    required this.expectedLectures,
  });
}
