class QuoteModel {
  final String id;
  final String category;
  final String arabic;
  final String somali;
  final String source;
  final String? subSource;

  const QuoteModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.somali,
    required this.source,
    this.subSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'somali': somali,
      'source': source,
      'subSource': subSource,
    };
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      somali: json['somali'] as String,
      source: json['source'] as String,
      subSource: json['subSource'] as String?,
    );
  }
}
