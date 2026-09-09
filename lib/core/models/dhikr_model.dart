import 'dart:convert';

class DhikrModel {
  final String id;
  final String title;
  final String category;
  final int targetCount;
  int currentCount;
  final String benefit;
  final String transliteration;
  final bool isCustom;
  bool isFavorite;

  DhikrModel({
    required this.id,
    required this.title,
    required this.category,
    this.targetCount = 33,
    this.currentCount = 0,
    this.benefit = '',
    this.transliteration = '',
    this.isCustom = false,
    this.isFavorite = false,
  });

  DhikrModel copyWith({
    String? id,
    String? title,
    String? category,
    int? targetCount,
    int? currentCount,
    String? benefit,
    String? transliteration,
    bool? isCustom,
    bool? isFavorite,
  }) {
    return DhikrModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      benefit: benefit ?? this.benefit,
      transliteration: transliteration ?? this.transliteration,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'benefit': benefit,
      'transliteration': transliteration,
      'isCustom': isCustom,
      'isFavorite': isFavorite,
    };
  }

  factory DhikrModel.fromMap(Map<String, dynamic> map) {
    return DhikrModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'عام',
      targetCount: map['targetCount'] ?? 33,
      currentCount: map['currentCount'] ?? 0,
      benefit: map['benefit'] ?? '',
      transliteration: map['transliteration'] ?? '',
      isCustom: map['isCustom'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory DhikrModel.fromJson(String source) =>
      DhikrModel.fromMap(json.decode(source));
}
