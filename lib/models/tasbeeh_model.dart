import 'dart:convert';

/// Represents a Dhikr item in the standalone Tasbeeh system.
class TasbeehItem {
  final String id;
  final String arabic;
  final String transliteration;
  final String category;
  final int target;
  final int currentCount;
  final int cycleCount;
  final bool isCustom;

  const TasbeehItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    this.category = 'Tasbiix',
    this.target = 33,
    this.currentCount = 0,
    this.cycleCount = 0,
    this.isCustom = false,
  });

  TasbeehItem copyWith({
    String? id,
    String? arabic,
    String? transliteration,
    String? category,
    int? target,
    int? currentCount,
    int? cycleCount,
    bool? isCustom,
  }) {
    return TasbeehItem(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      category: category ?? this.category,
      target: target ?? this.target,
      currentCount: currentCount ?? this.currentCount,
      cycleCount: cycleCount ?? this.cycleCount,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'category': category,
      'target': target,
      'currentCount': currentCount,
      'cycleCount': cycleCount,
      'isCustom': isCustom,
    };
  }

  factory TasbeehItem.fromMap(Map<String, dynamic> map) {
    return TasbeehItem(
      id: map['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      arabic: map['arabic'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      category: map['category'] as String? ?? 'Gaar ah',
      target: (map['target'] as num?)?.toInt() ?? 33,
      currentCount: (map['currentCount'] as num?)?.toInt() ?? 0,
      cycleCount: (map['cycleCount'] as num?)?.toInt() ?? 0,
      isCustom: map['isCustom'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TasbeehItem.fromJson(String source) =>
      TasbeehItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
