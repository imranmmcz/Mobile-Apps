class CustomerModel {
  String id;
  String name;
  String phone;
  String? email;
  String? address;
  String customerType; // 'wholesale' or 'retail'
  int loyaltyPoints;
  double totalPurchaseAmount;
  DateTime registrationDate;
  DateTime? lastPurchaseDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.customerType,
    this.loyaltyPoints = 0,
    this.totalPurchaseAmount = 0.0,
    required this.registrationDate,
    this.lastPurchaseDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'customerType': customerType,
        'loyaltyPoints': loyaltyPoints,
        'totalPurchaseAmount': totalPurchaseAmount,
        'registrationDate': registrationDate.toIso8601String(),
        'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      };

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        address: json['address'] as String?,
        customerType: json['customerType'] as String,
        loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
        totalPurchaseAmount:
            (json['totalPurchaseAmount'] as num?)?.toDouble() ?? 0.0,
        registrationDate: DateTime.parse(json['registrationDate'] as String),
        lastPurchaseDate: json['lastPurchaseDate'] != null
            ? DateTime.parse(json['lastPurchaseDate'] as String)
            : null,
      );
}
