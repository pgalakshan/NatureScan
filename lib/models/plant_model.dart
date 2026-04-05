class PlantModel {
  final String id;
  final String nameEnglish;
  final String nameSinhala;
  final String scientificName;
  final String description;
  final String descriptionSinhala;
  final List<String> medicinalUses;
  final List<String> medicinalUsesSinhala;
  final String habitat;
  final String habitatSinhala;
  final String safetyStatus; // 'safe', 'caution', 'toxic'
  final List<String> regions;
  final String category; // 'tree', 'herb', 'plant'
  final String emoji;
  final int colorValue;
  bool isFavorite;

  PlantModel({
    required this.id,
    required this.nameEnglish,
    required this.nameSinhala,
    required this.scientificName,
    required this.description,
    required this.descriptionSinhala,
    required this.medicinalUses,
    required this.medicinalUsesSinhala,
    required this.habitat,
    required this.habitatSinhala,
    required this.safetyStatus,
    required this.regions,
    required this.category,
    required this.emoji,
    required this.colorValue,
    this.isFavorite = false,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      nameSinhala: json['nameSinhala'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
      descriptionSinhala: json['descriptionSinhala'] ?? '',
      medicinalUses: List<String>.from(json['medicinalUses'] ?? []),
      medicinalUsesSinhala: List<String>.from(json['medicinalUsesSinhala'] ?? []),
      habitat: json['habitat'] ?? '',
      habitatSinhala: json['habitatSinhala'] ?? '',
      safetyStatus: json['safetyStatus'] ?? 'safe',
      regions: List<String>.from(json['regions'] ?? []),
      category: json['category'] ?? 'plant',
      emoji: json['emoji'] ?? '🌿',
      colorValue: json['colorValue'] ?? 0xFF1E4D2B,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEnglish': nameEnglish,
      'nameSinhala': nameSinhala,
      'scientificName': scientificName,
      'description': description,
      'descriptionSinhala': descriptionSinhala,
      'medicinalUses': medicinalUses,
      'medicinalUsesSinhala': medicinalUsesSinhala,
      'habitat': habitat,
      'habitatSinhala': habitatSinhala,
      'safetyStatus': safetyStatus,
      'regions': regions,
      'category': category,
      'emoji': emoji,
      'colorValue': colorValue,
      'isFavorite': isFavorite,
    };
  }

  PlantModel copyWith({
    String? id,
    String? nameEnglish,
    String? nameSinhala,
    String? scientificName,
    String? description,
    String? descriptionSinhala,
    List<String>? medicinalUses,
    List<String>? medicinalUsesSinhala,
    String? habitat,
    String? habitatSinhala,
    String? safetyStatus,
    List<String>? regions,
    String? category,
    String? emoji,
    int? colorValue,
    bool? isFavorite,
  }) {
    return PlantModel(
      id: id ?? this.id,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameSinhala: nameSinhala ?? this.nameSinhala,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      descriptionSinhala: descriptionSinhala ?? this.descriptionSinhala,
      medicinalUses: medicinalUses ?? this.medicinalUses,
      medicinalUsesSinhala: medicinalUsesSinhala ?? this.medicinalUsesSinhala,
      habitat: habitat ?? this.habitat,
      habitatSinhala: habitatSinhala ?? this.habitatSinhala,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      regions: regions ?? this.regions,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
