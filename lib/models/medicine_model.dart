class MedicineModel {
  String id;
  String nameBengali;
  String nameEnglish;
  String category;
  double pricePerUnit;
  int stockQuantity;
  String dosageInfo;
  DateTime? expiryDate;
  String manufacturer;
  DateTime? lastUpdated;

  MedicineModel({
    required this.id,
    required this.nameBengali,
    required this.nameEnglish,
    required this.category,
    required this.pricePerUnit,
    required this.stockQuantity,
    required this.dosageInfo,
    this.expiryDate,
    required this.manufacturer,
    this.lastUpdated,
  });

  bool get isLowStock => stockQuantity < 10;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry < 30 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameBengali': nameBengali,
        'nameEnglish': nameEnglish,
        'category': category,
        'pricePerUnit': pricePerUnit,
        'stockQuantity': stockQuantity,
        'dosageInfo': dosageInfo,
        'expiryDate': expiryDate?.toIso8601String(),
        'manufacturer': manufacturer,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
        id: json['id'] as String,
        nameBengali: json['nameBengali'] as String,
        nameEnglish: json['nameEnglish'] as String,
        category: json['category'] as String,
        pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
        stockQuantity: json['stockQuantity'] as int,
        dosageInfo: json['dosageInfo'] as String,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        manufacturer: json['manufacturer'] as String,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : null,
      );
}
