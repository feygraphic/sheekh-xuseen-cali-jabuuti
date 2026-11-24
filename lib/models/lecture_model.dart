class LectureModel {
  final String id;
  final int trackNumber;
  final String arabicTitle;
  final String somaliTitle;
  final int seriesNumber;
  final String seriesName;
  final String category;
  final Duration duration;
  final String audioUrl;
  final bool isLocalAsset;
  final String sheikhName;
  final String listenCount;
  final String imageUrl;
  final String description;

  const LectureModel({
    required this.id,
    required this.trackNumber,
    required this.arabicTitle,
    required this.somaliTitle,
    required this.seriesNumber,
    required this.seriesName,
    required this.category,
    required this.duration,
    required this.audioUrl,
    this.isLocalAsset = false,
    this.sheikhName = 'Sheekh Xuseen Cali Jabuuti (Xafidahullaah)',
    this.listenCount = '48.5k',
    this.imageUrl = 'assets/images/sheikh_lectures.jpg',
    this.description = '',
  });

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackNumber': trackNumber,
      'arabicTitle': arabicTitle,
      'somaliTitle': somaliTitle,
      'seriesNumber': seriesNumber,
      'seriesName': seriesName,
      'category': category,
      'durationMs': duration.inMilliseconds,
      'audioUrl': audioUrl,
      'isLocalAsset': isLocalAsset,
      'sheikhName': sheikhName,
      'listenCount': listenCount,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  static String extractCleanTitleFromUrl(String url) {
    if (url.trim().isEmpty) return 'Muxaadaro';
    try {
      final uri = Uri.parse(url);
      String filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
      filename = Uri.decodeComponent(filename.replaceAll('+', ' '));
      if (filename.toLowerCase().endsWith('.mp3')) {
        filename = filename.substring(0, filename.length - 4);
      }
      // Clean up common prefixes and suffixes
      filename = filename.replaceAll(RegExp(r'\s*-\s*Sheekh.*$', caseSensitive: false), '');
      filename = filename.replaceAll(RegExp(r'\s*-\s*Sh\b.*$', caseSensitive: false), '');
      filename = filename.replaceAllMapped(RegExp(r'(\d+)([a-zA-Z])'), (m) => '${m[1]} ${m[2]}');
      return filename.trim();
    } catch (_) {
      return 'Muxaadaro';
    }
  }

  factory LectureModel.fromJson(Map<String, dynamic> json, {int defaultIndex = 1}) {
    final audioUrl = (json['audioUrl'] ?? json['audiourl'] ?? '').toString();
    final bool isLocal = json['isLocalAsset'] as bool? ??
        (!audioUrl.startsWith('http://') && !audioUrl.startsWith('https://'));

    final int catNum = json['categorynumber'] as int? ??
        json['categoryNumber'] as int? ??
        json['seriesNumber'] as int? ??
        1;

    final String extractedTitle = extractCleanTitleFromUrl(audioUrl);

    // Somali title handling: if generic or placeholder, enhance with extracted title
    String sTitle = (json['somaliTitle'] ?? json['somalititle'] ?? '').toString().trim();
    if (sTitle.isEmpty || sTitle.toLowerCase() == 'muxadaro sheekh xusen' || sTitle.toLowerCase() == 'muxaadaro sheekh xuseen') {
      sTitle = extractedTitle.isNotEmpty ? extractedTitle : 'Muxaadaro $defaultIndex';
    }

    // Arabic title handling: if empty or generic placeholder, append topic
    String aTitle = (json['arabicTitle'] ?? json['arabictitle'] ?? '').toString().trim();
    if (aTitle.isEmpty || aTitle == 'محاضرة الشيخ حسين علي') {
      aTitle = 'محاضرة الشيخ حسين علي - $sTitle';
    }

    // Series name & Category
    String sName = (json['seriesName'] ?? json['seriesname'] ?? 'Qaybta ${catNum}aad').toString();
    String cat = (json['category'] ?? (catNum == 1 ? 'Muxaadaro' : catNum == 2 ? 'Akhlaaq' : catNum == 3 ? 'Qalbiga' : 'Duruus')).toString();

    // Duration handling
    final int durationMs = json['durationMs'] as int? ??
        (json['durationMinutes'] != null ? (json['durationMinutes'] as int) * 60 * 1000 : null) ??
        (45 * 60 * 1000);

    final int track = json['trackNumber'] as int? ??
        json['tracknumber'] as int? ??
        defaultIndex;

    final String id = (json['id'] ?? 'lec_b2_$track').toString();

    return LectureModel(
      id: id,
      trackNumber: track,
      arabicTitle: aTitle,
      somaliTitle: sTitle,
      seriesNumber: catNum,
      seriesName: sName,
      category: cat,
      duration: Duration(milliseconds: durationMs),
      audioUrl: audioUrl,
      isLocalAsset: isLocal,
      sheikhName: json['sheikhName'] as String? ?? 'Sheekh Xuseen Cali Jabuuti (Xafidahullaah)',
      listenCount: json['listenCount'] as String? ?? '48.5k',
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/sheikh_lectures.jpg',
      description: json['description'] as String? ??
          'Muxaadaro qiimo badan oo ka mid ah taxanaha muxaadarooyinka Sheekh Xuseen Cali Jabuuti.',
    );
  }
}
