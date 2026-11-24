class IslamicWisdomModel {
  final String id;
  final String arabic;
  final String somali;
  final String speaker;
  final String speakerTitle;
  final String speakerEra;
  final String categoryId;
  final String categoryName;
  final String reference;
  final String type;
  final int backgroundTheme;

  const IslamicWisdomModel({
    required this.id,
    required this.arabic,
    required this.somali,
    required this.speaker,
    required this.speakerTitle,
    required this.speakerEra,
    required this.categoryId,
    required this.categoryName,
    required this.reference,
    required this.type,
    this.backgroundTheme = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'somali': somali,
      'speaker': speaker,
      'speakerTitle': speakerTitle,
      'speakerEra': speakerEra,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'reference': reference,
      'type': type,
      'backgroundTheme': backgroundTheme,
    };
  }

  factory IslamicWisdomModel.fromJson(Map<String, dynamic> json) {
    return IslamicWisdomModel(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      somali: json['somali'] as String,
      speaker: json['speaker'] as String,
      speakerTitle: json['speakerTitle'] as String? ?? '',
      speakerEra: json['speakerEra'] as String? ?? 'Culimada Salafka',
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String? ?? 'caalim',
      backgroundTheme: (json['backgroundTheme'] as num?)?.toInt() ?? 0,
    );
  }
}
