class SurahModel {
  final int number;
  final String arabicName;
  final String somaliName;
  final String meaning;
  final int versesCount;
  final String revelationType; // Makkiyah or Madaniyah
  final int juzNumber;
  final int hizbNumber;
  final String audioTafsiirTitle;
  final String audioUrl;
  final bool isLocalAsset;
  final String? tag;
  final int currentVersePosition;
  final double progressPercent;

  const SurahModel({
    required this.number,
    required this.arabicName,
    required this.somaliName,
    required this.meaning,
    required this.versesCount,
    required this.revelationType,
    required this.juzNumber,
    required this.hizbNumber,
    required this.audioTafsiirTitle,
    required this.audioUrl,
    this.isLocalAsset = false,
    this.tag,
    this.currentVersePosition = 0,
    this.progressPercent = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabicName': arabicName,
      'somaliName': somaliName,
      'meaning': meaning,
      'versesCount': versesCount,
      'revelationType': revelationType,
      'juzNumber': juzNumber,
      'hizbNumber': hizbNumber,
      'audioTafsiirTitle': audioTafsiirTitle,
      'audioUrl': audioUrl,
      'isLocalAsset': isLocalAsset,
      'tag': tag,
      'currentVersePosition': currentVersePosition,
      'progressPercent': progressPercent,
    };
  }

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      arabicName: json['arabicName'] as String,
      somaliName: json['somaliName'] as String,
      meaning: json['meaning'] as String,
      versesCount: json['versesCount'] as int,
      revelationType: json['revelationType'] as String,
      juzNumber: json['juzNumber'] as int,
      hizbNumber: json['hizbNumber'] as int,
      audioTafsiirTitle: json['audioTafsiirTitle'] as String,
      audioUrl: json['audioUrl'] as String,
      isLocalAsset: json['isLocalAsset'] as bool? ?? false,
      tag: json['tag'] as String?,
      currentVersePosition: json['currentVersePosition'] as int? ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
