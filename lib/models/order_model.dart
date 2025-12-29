class OrderModel {
  String id;
  String orderNumber;
  String customerId;
  String customerName;
  List<OrderItem> items;
  double totalAmount;
  String orderStatus; // 'pending', 'confirmed', 'processing', 'shipped', 'delivered'
  String orderType; // 'wholesale' or 'retail'
  DateTime orderDate;
  DateTime? deliveryDate;
  String? notes;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.orderType,
    required this.orderDate,
    this.deliveryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'orderStatus': orderStatus,
        'orderType': orderType,
        'orderDate': orderDate.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'notes': notes,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        orderStatus: json['orderStatus'] as String,
        orderType: json['orderType'] as String,
        orderDate: DateTime.parse(json['orderDate'] as String),
        deliveryDate: json['deliveryDate'] != null
            ? DateTime.parse(json['deliveryDate'] as String)
            : null,
        notes: json['notes'] as String?,
      );
}

class OrderItem {
  String productId;
  String productName;
  double pricePerUnit;
  double quantity;
  double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.pricePerUnit,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'pricePerUnit': pricePerUnit,
        'quantity': quantity,
        'totalPrice': totalPrice,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
        quantity: (json['quantity'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}
