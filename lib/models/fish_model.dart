class FishModel {
  String id;
  String nameBengali;
  String nameEnglish;
  double pricePerMana; // Price per Mana (unit)
  double stockKg;
  String category;
  DateTime? lastUpdated;

  FishModel({
    required this.id,
    required this.nameBengali,
    required this.nameEnglish,
    required this.pricePerMana,
    required this.stockKg,
    required this.category,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameBengali': nameBengali,
        'nameEnglish': nameEnglish,
        'pricePerMana': pricePerMana,
        'stockKg': stockKg,
        'category': category,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory FishModel.fromJson(Map<String, dynamic> json) => FishModel(
        id: json['id'] as String,
        nameBengali: json['nameBengali'] as String,
        nameEnglish: json['nameEnglish'] as String,
        pricePerMana: (json['pricePerMana'] as num).toDouble(),
        stockKg: (json['stockKg'] as num).toDouble(),
        category: json['category'] as String,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : null,
      );
}
