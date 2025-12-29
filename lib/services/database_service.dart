import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_model.dart';
import '../models/sale_model.dart';
import '../models/medicine_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  static const String _fishBoxName = 'fishes';
  static const String _salesBoxName = 'sales';
  static const String _medicineBoxName = 'medicines';
  static const String _customerBoxName = 'customers';
  static const String _orderBoxName = 'orders';

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _uuid = const Uuid();

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      print('✅ Hive initialized');
      
      // Open all boxes with timeout
      await Future.wait([
        Hive.openBox(_fishBoxName),
        Hive.openBox(_salesBoxName),
        Hive.openBox(_medicineBoxName),
        Hive.openBox(_customerBoxName),
        Hive.openBox(_orderBoxName),
      ]).timeout(const Duration(seconds: 10));
      print('✅ All boxes opened');

      // Initialize with sample data
      await _initializeSampleData();
      print('✅ Sample data initialized');
    } catch (e) {
      print('❌ Database initialization error: $e');
      // Try to open boxes one by one if batch opening fails
      try {
        await Hive.openBox(_fishBoxName);
        await Hive.openBox(_salesBoxName);
        await Hive.openBox(_medicineBoxName);
        await Hive.openBox(_customerBoxName);
        await Hive.openBox(_orderBoxName);
        print('✅ Boxes opened individually');
      } catch (e2) {
        print('❌ Individual box opening failed: $e2');
      }
    }
  }

  Future<void> _initializeSampleData() async {
    try {
      final fishBox = Hive.box(_fishBoxName);
      // Clear and reinitialize if empty to ensure data is always present
      if (fishBox.isEmpty) {
        await fishBox.clear();
        await _addSampleFish();
        print('✅ Fish data initialized: ${fishBox.length} items');
      }

      final medicineBox = Hive.box(_medicineBoxName);
      if (medicineBox.isEmpty) {
        await medicineBox.clear();
        await _addSampleMedicines();
        print('✅ Medicine data initialized: ${medicineBox.length} items');
      }
      
      // Add sample customers and orders
      final customerBox = Hive.box(_customerBoxName);
      if (customerBox.isEmpty) {
        await _addSampleCustomers();
        print('✅ Customer data initialized: ${customerBox.length} items');
      }
      
      final orderBox = Hive.box(_orderBoxName);
      if (orderBox.isEmpty) {
        await _addSampleOrders();
        print('✅ Order data initialized: ${orderBox.length} items');
      }
    } catch (e) {
      print('❌ Sample data initialization error: $e');
    }
  }

  Future<void> _addSampleFish() async {
    final bangladeshiFishes = [
      {'bengali': 'রুই', 'english': 'Rohu', 'price': 350.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'কাতলা', 'english': 'Catla', 'price': 320.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'মৃগেল', 'english': 'Mrigal', 'price': 280.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'সিলভার কার্প', 'english': 'Silver Carp', 'price': 250.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'গ্রাস কার্প', 'english': 'Grass Carp', 'price': 270.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'পাঙ্গাশ', 'english': 'Pangas', 'price': 220.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'তেলাপিয়া', 'english': 'Tilapia', 'price': 180.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'শিং', 'english': 'Stinging Catfish', 'price': 450.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'মাগুর', 'english': 'Magur', 'price': 420.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'কৈ', 'english': 'Climbing Perch', 'price': 380.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'শোল', 'english': 'Snakehead', 'price': 480.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'বোয়াল', 'english': 'Boal', 'price': 550.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'পাবদা', 'english': 'Pabda', 'price': 520.0, 'category': 'মিঠা পানির মাছ'},
      {'bengali': 'গলদা চিংড়ি', 'english': 'Freshwater Prawn', 'price': 850.0, 'category': 'চিংড়ি'},
      {'bengali': 'বাগদা চিংড়ি', 'english': 'Black Tiger Prawn', 'price': 950.0, 'category': 'চিংড়ি'},
      {'bengali': 'চাপিলা', 'english': 'Indian Pellona', 'price': 320.0, 'category': 'সামুদ্রিক মাছ'},
      {'bengali': 'ইলিশ', 'english': 'Hilsa', 'price': 1200.0, 'category': 'সামুদ্রিক মাছ'},
      {'bengali': 'চান্দা', 'english': 'Pomfret', 'price': 650.0, 'category': 'সামুদ্রিক মাছ'},
      {'bengali': 'কোরাল', 'english': 'Coral Fish', 'price': 580.0, 'category': 'সামুদ্রিক মাছ'},
      {'bengali': 'লইট্টা', 'english': 'Bombay Duck', 'price': 420.0, 'category': 'সামুদ্রিক মাছ'},
    ];

    final fishBox = Hive.box(_fishBoxName);
    for (var fish in bangladeshiFishes) {
      final fishModel = FishModel(
        id: _uuid.v4(),
        nameBengali: fish['bengali'] as String,
        nameEnglish: fish['english'] as String,
        pricePerMana: fish['price'] as double,
        stockKg: 50.0 + (fish['price'] as double) / 10,
        category: fish['category'] as String,
        lastUpdated: DateTime.now(),
      );
      await fishBox.add(fishModel.toJson());
    }
  }

  Future<void> _addSampleMedicines() async {
    final medicines = [
      {'bengali': 'অক্সিটেট্রাসাইক্লিন', 'english': 'Oxytetracycline', 'category': 'অ্যান্টিবায়োটিক', 'price': 150.0, 'dosage': '৫০-৭৫ মিগ্রা/কেজি', 'manufacturer': 'ACI'},
      {'bengali': 'অ্যামোক্সিসিলিন', 'english': 'Amoxicillin', 'category': 'অ্যান্টিবায়োটিক', 'price': 180.0, 'dosage': '৪০-৬০ মিগ্রা/কেজি', 'manufacturer': 'Square'},
      {'bengali': 'ফর্মালিন', 'english': 'Formalin', 'category': 'জীবাণুনাশক', 'price': 80.0, 'dosage': '২৫ পিপিএম', 'manufacturer': 'Renata'},
      {'bengali': 'ভিটামিন সি', 'english': 'Vitamin C', 'category': 'ভিটামিন', 'price': 120.0, 'dosage': '১০০-২০০ মিগ্রা/কেজি', 'manufacturer': 'SK+F'},
      {'bengali': 'মিনারেল মিক্স', 'english': 'Mineral Mix', 'category': 'খনিজ', 'price': 200.0, 'dosage': '১-২%', 'manufacturer': 'Novartis'},
      {'bengali': 'প্রোবায়োটিক', 'english': 'Probiotic', 'category': 'প্রোবায়োটিক', 'price': 250.0, 'dosage': '১ গ্রাম/কেজি', 'manufacturer': 'ACME'},
      {'bengali': 'অক্সিজেন ট্যাবলেট', 'english': 'Oxygen Tablet', 'category': 'অক্সিজেন সাপ্লিমেন্ট', 'price': 100.0, 'dosage': '১ ট্যাবলেট/১০০ লিটার', 'manufacturer': 'Healthcare'},
      {'bengali': 'ছত্রাকনাশক', 'english': 'Antifungal', 'category': 'ছত্রাকনাশক', 'price': 220.0, 'dosage': '৫-১০ পিপিএম', 'manufacturer': 'Beximco'},
    ];

    final medicineBox = Hive.box(_medicineBoxName);
    for (var med in medicines) {
      final medicineModel = MedicineModel(
        id: _uuid.v4(),
        nameBengali: med['bengali'] as String,
        nameEnglish: med['english'] as String,
        category: med['category'] as String,
        pricePerUnit: med['price'] as double,
        stockQuantity: 50,
        dosageInfo: med['dosage'] as String,
        manufacturer: med['manufacturer'] as String,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        lastUpdated: DateTime.now(),
      );
      await medicineBox.add(medicineModel.toJson());
    }
  }

  Future<void> _addSampleCustomers() async {
    final customers = [
      {'name': 'আব্দুল করিম', 'phone': '০১৭১২৩৪৫৬৭৮', 'type': 'retail'},
      {'name': 'রহিমা বেগম', 'phone': '০১৮১২৩৪৫৬৭৯', 'type': 'retail'},
      {'name': 'মোঃ আলম', 'phone': '০১৯১২৩৪৫৬৮০', 'type': 'wholesale'},
      {'name': 'ফাতেমা খাতুন', 'phone': '০১৬১২৩৪৫৬৮১', 'type': 'retail'},
      {'name': 'হাসান আলী', 'phone': '০১৫১২৩৪৫৬৮২', 'type': 'wholesale'},
    ];

    final customerBox = Hive.box(_customerBoxName);
    for (var cust in customers) {
      final customerModel = CustomerModel(
        id: _uuid.v4(),
        name: cust['name'] as String,
        phone: cust['phone'] as String,
        customerType: cust['type'] as String,
        loyaltyPoints: 100,
        totalPurchaseAmount: 5000.0 + (cust['type'] == 'wholesale' ? 10000.0 : 0.0),
        registrationDate: DateTime.now().subtract(Duration(days: 30)),
        lastPurchaseDate: DateTime.now().subtract(Duration(days: 5)),
      );
      await customerBox.add(customerModel.toJson());
    }
  }

  Future<void> _addSampleOrders() async {
    final orders = [
      {'number': 'ORD-001', 'customer': 'মোঃ আলম', 'type': 'wholesale', 'status': 'pending', 'amount': 15000.0},
      {'number': 'ORD-002', 'customer': 'হাসান আলী', 'type': 'wholesale', 'status': 'confirmed', 'amount': 25000.0},
      {'number': 'ORD-003', 'customer': 'আব্দুল করিম', 'type': 'retail', 'status': 'delivered', 'amount': 3500.0},
    ];

    final orderBox = Hive.box(_orderBoxName);
    for (var ord in orders) {
      final orderModel = OrderModel(
        id: _uuid.v4(),
        orderNumber: ord['number'] as String,
        customerId: _uuid.v4(),
        customerName: ord['customer'] as String,
        items: [
          OrderItem(
            productId: _uuid.v4(),
            productName: 'রুই মাছ',
            pricePerUnit: 350.0,
            quantity: 10.0,
            totalPrice: 3500.0,
          ),
        ],
        totalAmount: ord['amount'] as double,
        orderStatus: ord['status'] as String,
        orderType: ord['type'] as String,
        orderDate: DateTime.now().subtract(Duration(days: 3)),
      );
      await orderBox.add(orderModel.toJson());
    }
  }

  // Fish operations
  Box get fishBox => Hive.box(_fishBoxName);
  
  Future<List<FishModel>> getAllFish() async {
    final box = fishBox;
    return box.values
        .map((e) => FishModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addFish(FishModel fish) async {
    await fishBox.add(fish.toJson());
  }

  Future<void> updateFish(int index, FishModel fish) async {
    await fishBox.putAt(index, fish.toJson());
  }

  Future<void> deleteFish(int index) async {
    await fishBox.deleteAt(index);
  }

  // Sales operations
  Box get salesBox => Hive.box(_salesBoxName);
  
  Future<List<SaleModel>> getAllSales() async {
    final box = salesBox;
    return box.values
        .map((e) => SaleModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addSale(SaleModel sale) async {
    await salesBox.add(sale.toJson());
  }

  // Medicine operations
  Box get medicineBox => Hive.box(_medicineBoxName);
  
  Future<List<MedicineModel>> getAllMedicines() async {
    final box = medicineBox;
    return box.values
        .map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    await medicineBox.add(medicine.toJson());
  }

  Future<void> updateMedicine(int index, MedicineModel medicine) async {
    await medicineBox.putAt(index, medicine.toJson());
  }

  Future<void> deleteMedicine(int index) async {
    await medicineBox.deleteAt(index);
  }

  // Customer operations
  Box get customerBox => Hive.box(_customerBoxName);
  
  Future<List<CustomerModel>> getAllCustomers() async {
    final box = customerBox;
    return box.values
        .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await customerBox.add(customer.toJson());
  }

  Future<void> updateCustomer(int index, CustomerModel customer) async {
    await customerBox.putAt(index, customer.toJson());
  }

  // Order operations
  Box get orderBox => Hive.box(_orderBoxName);
  
  Future<List<OrderModel>> getAllOrders() async {
    final box = orderBox;
    return box.values
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addOrder(OrderModel order) async {
    await orderBox.add(order.toJson());
  }

  Future<void> updateOrder(int index, OrderModel order) async {
    await orderBox.putAt(index, order.toJson());
  }

  // Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final sales = await getAllSales();
    final customers = await getAllCustomers();
    final medicines = await getAllMedicines();
    final orders = await getAllOrders();

    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final todaySales = sales.where((s) => 
      s.saleDate.year == DateTime.now().year &&
      s.saleDate.month == DateTime.now().month &&
      s.saleDate.day == DateTime.now().day
    ).toList();
    final todayRevenue = todaySales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    final lowStockMedicines = medicines.where((m) => m.isLowStock).length;
    final pendingOrders = orders.where((o) => o.orderStatus == 'pending').length;

    return {
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'totalSales': sales.length,
      'todaySales': todaySales.length,
      'totalCustomers': customers.length,
      'lowStockMedicines': lowStockMedicines,
      'pendingOrders': pendingOrders,
    };
  }
}
