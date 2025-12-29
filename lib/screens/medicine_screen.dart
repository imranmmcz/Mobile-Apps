import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'add_edit_medicine_screen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final _dbService = DatabaseService();
  List<MedicineModel> _medicines = [];
  bool _isLoading = true;
  String _filterCategory = 'সব';

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    final medicines = await _dbService.getAllMedicines();
    setState(() {
      _medicines = medicines;
      _isLoading = false;
    });
  }

  List<MedicineModel> get _filteredMedicines {
    if (_filterCategory == 'সব') return _medicines;
    return _medicines.where((m) => m.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ঔষধ ব্যবস্থাপনা'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditMedicineScreen(),
                ),
              );
              if (result != null) {
                await _dbService.addMedicine(result);
                _loadMedicines();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedicines,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                _buildAlerts(),
                Expanded(child: _buildMedicinesList()),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    final categories = ['সব', 'অ্যান্টিবায়োটিক', 'জীবাণুনাশক', 'ভিটামিন', 'খনিজ', 'প্রোবায়োটিক'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((category) {
            final isSelected = category == _filterCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _filterCategory = category);
                },
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    final lowStock = _medicines.where((m) => m.isLowStock).length;
    final expiring = _medicines.where((m) => m.isExpiringSoon).length;
    final expired = _medicines.where((m) => m.isExpired).length;

    if (lowStock == 0 && expiring == 0 && expired == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: AppTheme.warningColor),
              SizedBox(width: 8),
              Text(
                'সতর্কতা',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (lowStock > 0)
            Text('• $lowStock টি ঔষধের মজুদ কম', style: const TextStyle(fontSize: 14)),
          if (expiring > 0)
            Text('• $expiring টি ঔষধ শীঘ্রই মেয়াদ শেষ', style: const TextStyle(fontSize: 14)),
          if (expired > 0)
            Text('• $expired টি ঔষধের মেয়াদ শেষ', style: const TextStyle(fontSize: 14, color: AppTheme.errorColor)),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    if (_filteredMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'কোন ঔষধ পাওয়া যায়নি',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _filteredMedicines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditMedicineScreen(medicine: medicine),
                ),
              );
              if (result != null) {
                await _dbService.updateMedicine(index, result);
                _loadMedicines();
              }
            },
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getMedicineColor(medicine).withValues(alpha: 0.2),
              child: Icon(
                Icons.medical_services,
                color: _getMedicineColor(medicine),
              ),
            ),
            title: Text(
              medicine.nameBengali,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${medicine.nameEnglish} • ${medicine.category}'),
                const SizedBox(height: 4),
                Text('মাত্রা: ${medicine.dosageInfo}'),
                Text('প্রস্তুতকারক: ${medicine.manufacturer}'),
                if (medicine.expiryDate != null)
                  Text(
                    'মেয়াদ: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate!)}',
                    style: TextStyle(
                      color: medicine.isExpired
                          ? AppTheme.errorColor
                          : medicine.isExpiringSoon
                              ? AppTheme.warningColor
                              : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${medicine.pricePerUnit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: medicine.isLowStock
                        ? AppTheme.errorColor.withValues(alpha: 0.1)
                        : AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'স্টক: ${medicine.stockQuantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: medicine.isLowStock ? AppTheme.errorColor : AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getMedicineColor(MedicineModel medicine) {
    if (medicine.isExpired) return AppTheme.errorColor;
    if (medicine.isExpiringSoon) return AppTheme.warningColor;
    if (medicine.isLowStock) return AppTheme.warningColor;
    return AppTheme.primaryColor;
  }
}
