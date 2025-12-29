import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/cart_service.dart';
import '../models/fish_model.dart';
import '../models/medicine_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dbService = DatabaseService();
  final _cartService = CartService();
  
  List<FishModel> _allFish = [];
  List<MedicineModel> _allMedicines = [];
  Map<String, List<FishModel>> _fishByCategory = {};
  Map<String, List<MedicineModel>> _medicinesByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // Load fish
      _allFish = await _dbService.getAllFish();
      _fishByCategory = {};
      for (var fish in _allFish) {
        if (!_fishByCategory.containsKey(fish.category)) {
          _fishByCategory[fish.category] = [];
        }
        _fishByCategory[fish.category]!.add(fish);
      }

      // Load medicines
      _allMedicines = await _dbService.getAllMedicines();
      _medicinesByCategory = {};
      for (var medicine in _allMedicines) {
        if (!_medicinesByCategory.containsKey(medicine.category)) {
          _medicinesByCategory[medicine.category] = [];
        }
        _medicinesByCategory[medicine.category]!.add(medicine);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(double amount) {
    return '৳${NumberFormat('#,##,##0.00', 'bn_BD').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য তালিকা'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.set_meal), text: 'মাছ'),
            Tab(icon: Icon(Icons.medical_services), text: 'ওষুধ'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFishCategoriesTab(),
                  _buildMedicinesCategoriesTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildFishCategoriesTab() {
    if (_fishByCategory.isEmpty) {
      return const Center(
        child: Text('কোন মাছ পাওয়া যায়নি'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fishByCategory.length,
      itemBuilder: (context, index) {
        final category = _fishByCategory.keys.toList()[index];
        final fish = _fishByCategory[category]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryLight,
              child: const Icon(Icons.category, color: Colors.white),
            ),
            title: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('${fish.length} টি পণ্য'),
            children: fish.map((f) => _buildFishItem(f)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFishItem(FishModel fish) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.set_meal, color: AppTheme.accentColor),
      ),
      title: Text(
        fish.nameBengali,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fish.nameEnglish, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.inventory_2, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'স্টক: ${fish.stockKg.toStringAsFixed(1)} কেজি',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatCurrency(fish.pricePerMana),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'প্রতি মান',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesCategoriesTab() {
    if (_medicinesByCategory.isEmpty) {
      return const Center(
        child: Text('কোন ওষুধ পাওয়া যায়নি'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicinesByCategory.length,
      itemBuilder: (context, index) {
        final category = _medicinesByCategory.keys.toList()[index];
        final medicines = _medicinesByCategory[category]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.medical_services, color: Colors.white),
            ),
            title: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('${medicines.length} টি পণ্য'),
            children: medicines.map((m) => _buildMedicineItem(m)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMedicineItem(MedicineModel medicine) {
    final isLowStock = medicine.isLowStock;
    final isExpiringSoon = medicine.isExpiringSoon;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.medication, color: AppTheme.secondaryColor),
      ),
      title: Text(
        medicine.nameBengali,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medicine.nameEnglish, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            'ডোজ: ${medicine.dosageInfo}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.inventory_2, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'স্টক: ${medicine.stockQuantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: isLowStock ? Colors.red : Colors.grey[600],
                  fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isExpiringSoon) ...[
                const SizedBox(width: 12),
                const Icon(Icons.warning, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                const Text(
                  'শীঘ্রই মেয়াদ শেষ',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatCurrency(medicine.pricePerUnit),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'প্রতি ইউনিট',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'কার্ট',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _cartService.items.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('কার্ট খালি', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _cartService.items.length,
                        itemBuilder: (context, index) {
                          final item = _cartService.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('৳${item.price.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _cartService.updateQuantity(item.id, item.quantity - 1);
                                      });
                                    },
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _cartService.updateQuantity(item.id, item.quantity + 1);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _cartService.removeItem(item.id);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_cartService.items.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'মোট:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(_cartService.totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('অর্ডার প্রক্রিয়া শীঘ্রই যোগ হবে')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('অর্ডার করুন', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
