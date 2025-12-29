class SaleModel {
  String id;
  String invoiceNumber;
  List<SaleItem> items;
  double totalAmount;
  String customerName;
  String customerPhone;
  String saleType; // 'wholesale' or 'retail'
  String paymentMethod;
  DateTime saleDate;
  String? notes;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.saleType,
    required this.paymentMethod,
    required this.saleDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'saleType': saleType,
        'paymentMethod': paymentMethod,
        'saleDate': saleDate.toIso8601String(),
        'notes': notes,
      };

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        items: (json['items'] as List)
            .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        customerName: json['customerName'] as String,
        customerPhone: json['customerPhone'] as String,
        saleType: json['saleType'] as String,
        paymentMethod: json['paymentMethod'] as String,
        saleDate: DateTime.parse(json['saleDate'] as String),
        notes: json['notes'] as String?,
      );
}

class SaleItem {
  String fishId;
  String fishName;
  double pricePerMana;
  double quantityKg;
  double totalPrice;

  SaleItem({
    required this.fishId,
    required this.fishName,
    required this.pricePerMana,
    required this.quantityKg,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'fishId': fishId,
        'fishName': fishName,
        'pricePerMana': pricePerMana,
        'quantityKg': quantityKg,
        'totalPrice': totalPrice,
      };

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
        fishId: json['fishId'] as String,
        fishName: json['fishName'] as String,
        pricePerMana: (json['pricePerMana'] as num).toDouble(),
        quantityKg: (json['quantityKg'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}
