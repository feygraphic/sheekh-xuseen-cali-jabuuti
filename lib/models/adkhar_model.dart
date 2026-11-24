class AdkharModel {
  final String id;
  final String? categoryId;
  final String category;
  final String title;
  final String? arabicTitle;
  final String arabicText;
  final String somaliTranslation;
  final String? transliteration;
  final String reference;
  final String? authenticity;
  final int targetCount;
  final int currentCount;
  final bool isCompleted;
  final String? audioUrl;
  final bool isLocalAudio;
  final String? virtue;

  const AdkharModel({
    required this.id,
    this.categoryId,
    required this.category,
    required this.title,
    this.arabicTitle,
    required this.arabicText,
    required this.somaliTranslation,
    this.transliteration,
    required this.reference,
    this.authenticity = 'Saxiix',
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
    this.audioUrl,
    this.isLocalAudio = false,
    this.virtue,
  });

  AdkharModel copyWith({
    int? currentCount,
    bool? isCompleted,
    String? categoryId,
    String? category,
    String? title,
    String? arabicTitle,
    String? arabicText,
    String? somaliTranslation,
    String? transliteration,
    String? reference,
    String? authenticity,
    int? targetCount,
    String? audioUrl,
    bool? isLocalAudio,
    String? virtue,
  }) {
    return AdkharModel(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      title: title ?? this.title,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      arabicText: arabicText ?? this.arabicText,
      somaliTranslation: somaliTranslation ?? this.somaliTranslation,
      transliteration: transliteration ?? this.transliteration,
      reference: reference ?? this.reference,
      authenticity: authenticity ?? this.authenticity,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
      audioUrl: audioUrl ?? this.audioUrl,
      isLocalAudio: isLocalAudio ?? this.isLocalAudio,
      virtue: virtue ?? this.virtue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'category': category,
      'title': title,
      'arabicTitle': arabicTitle,
      'arabicText': arabicText,
      'somaliTranslation': somaliTranslation,
      'transliteration': transliteration,
      'reference': reference,
      'authenticity': authenticity,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
      'audioUrl': audioUrl,
      'isLocalAudio': isLocalAudio,
      'virtue': virtue,
      // Compatibility aliases
      'title_ar': arabicTitle,
      'title_so': title,
      'arabic_text': arabicText,
      'somali_translation': somaliTranslation,
      'repetition_count': targetCount,
      'audio_url': audioUrl,
    };
  }

  factory AdkharModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultCategory,
    String? defaultCategoryId,
  }) {
    final id = json['id'] as String;
    String inferredCatId = defaultCategoryId ?? json['categoryId'] as String? ?? '';
    String inferredCat = defaultCategory ?? json['category'] as String? ?? '';

    if (inferredCatId.isEmpty) {
      if (id.startsWith('morning')) {
        inferredCatId = 'morning';
      } else if (id.startsWith('evening') || id.startsWith('galab')) {
        inferredCatId = 'evening';
      }
    }

    if (inferredCat.isEmpty) {
      if (inferredCatId == 'morning') {
        inferredCat = 'Adkaarta Subaxda';
      } else if (inferredCatId == 'evening') {
        inferredCat = 'Adkaarta Galabta';
      } else {
        inferredCat = 'Adkaar';
      }
    }

    final target = (json['repetition_count'] ?? json['targetCount'] ?? 1) as int;

    return AdkharModel(
      id: id,
      categoryId: inferredCatId.isNotEmpty ? inferredCatId : null,
      category: inferredCat,
      title: (json['title_so'] ?? json['title'] ?? '') as String,
      arabicTitle: (json['title_ar'] ?? json['arabicTitle']) as String?,
      arabicText: (json['arabic_text'] ?? json['arabicText'] ?? '') as String,
      somaliTranslation: (json['somali_translation'] ?? json['somaliTranslation'] ?? '') as String,
      transliteration: json['transliteration'] as String?,
      reference: (json['reference'] ?? '') as String,
      authenticity: json['authenticity'] as String? ?? 'Saxiix',
      targetCount: target,
      currentCount: json['currentCount'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      audioUrl: (json['audio_url'] ?? json['audioUrl']) as String?,
      isLocalAudio: json['isLocalAudio'] as bool? ?? false,
      virtue: json['virtue'] as String?,
    );
  }
}
