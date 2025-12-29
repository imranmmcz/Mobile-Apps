import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_model.dart';
import '../models/sale_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'invoice_screen.dart';

class FishSalesScreen extends StatefulWidget {
  const FishSalesScreen({super.key});

  @override
  State<FishSalesScreen> createState() => _FishSalesScreenState();
}

class _FishSalesScreenState extends State<FishSalesScreen> {
  final _dbService = DatabaseService();
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  
  List<FishModel> _fishes = [];
  final List<SaleItemData> _cartItems = [];
  
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'নগদ';
  String _selectedSaleType = 'খুচরা';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFishes();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFishes() async {
    setState(() => _isLoading = true);
    final fishes = await _dbService.getAllFish();
    setState(() {
      _fishes = fishes;
      _isLoading = false;
    });
  }

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _addToCart(FishModel fish) {
    showDialog(
      context: context,
      builder: (context) {
        final quantityController = TextEditingController();
        return AlertDialog(
          title: Text('${fish.nameBengali} যোগ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('মূল্য প্রতি মানা: ৳${fish.pricePerMana.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'পরিমাণ (কেজি)',
                  hintText: 'যেমন: ২.৫',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = double.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  setState(() {
                    _cartItems.add(SaleItemData(
                      fish: fish,
                      quantityKg: quantity,
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${fish.nameBengali} যোগ হয়েছে')),
                  );
                }
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _generateInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে মাছ যোগ করুন')),
      );
      return;
    }

    final sale = SaleModel(
      id: _uuid.v4(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: _cartItems.map((item) => SaleItem(
        fishId: item.fish.id,
        fishName: item.fish.nameBengali,
        pricePerMana: item.fish.pricePerMana,
        quantityKg: item.quantityKg,
        totalPrice: item.totalPrice,
      )).toList(),
      totalAmount: _totalAmount,
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      saleType: _selectedSaleType,
      paymentMethod: _selectedPaymentMethod,
      saleDate: DateTime.now(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await _dbService.addSale(sale);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(sale: sale),
      ),
    ).then((_) {
      // Clear form
      setState(() {
        _cartItems.clear();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _notesController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিক্রয়'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerInfoCard(),
                          const SizedBox(height: 16),
                          _buildFishSelectionCard(),
                          const SizedBox(height: 16),
                          _buildCartCard(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'গ্রাহক তথ্য',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'গ্রাহকের নাম *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'নাম প্রয়োজন' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'ফোন নম্বর *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'ফোন নম্বর প্রয়োজন' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSaleType,
                    decoration: const InputDecoration(
                      labelText: 'বিক্রয়ের ধরন',
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    items: ['খুচরা', 'পাইকারি'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSaleType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'পেমেন্ট পদ্ধতি',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: ['নগদ', 'বিকাশ', 'নগদ', 'রকেট', 'ব্যাংক'].map((method) {
                      return DropdownMenuItem(value: method, child: Text(method));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'নোট (ঐচ্ছিক)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'মাছ নির্বাচন',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fishes.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final fish = _fishes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.set_meal, color: AppTheme.primaryColor),
                  ),
                  title: Text(fish.nameBengali),
                  subtitle: Text('${fish.nameEnglish} • ${fish.category}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${fish.pricePerMana}/মানা',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'মজুদ: ${fish.stockKg.toStringAsFixed(1)} কেজি',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => _addToCart(fish),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCard() {
    if (_cartItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'কার্ট খালি',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'কার্ট',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  title: Text(item.fish.nameBengali),
                  subtitle: Text(
                    '৳${item.fish.pricePerMana}/মানা × ${item.quantityKg} কেজি',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '৳${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => _removeFromCart(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মোট:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '৳${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateInvoice,
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'ইনভয়েস তৈরি করুন',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaleItemData {
  final FishModel fish;
  final double quantityKg;

  SaleItemData({
    required this.fish,
    required this.quantityKg,
  });

  double get totalPrice => fish.pricePerMana * quantityKg;
}
