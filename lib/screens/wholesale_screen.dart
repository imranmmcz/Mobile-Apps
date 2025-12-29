import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/order_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class WholesaleScreen extends StatefulWidget {
  const WholesaleScreen({super.key});

  @override
  State<WholesaleScreen> createState() => _WholesaleScreenState();
}

class _WholesaleScreenState extends State<WholesaleScreen> {
  final _dbService = DatabaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String _filterStatus = 'সব';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _dbService.getAllOrders();
    final wholesaleOrders = orders.where((o) => o.orderType == 'wholesale').toList();
    setState(() {
      _orders = wholesaleOrders;
      _isLoading = false;
    });
  }

  List<OrderModel> get _filteredOrders {
    if (_filterStatus == 'সব') return _orders;
    return _orders.where((o) => _getStatusInBengali(o.orderStatus) == _filterStatus).toList();
  }

  String _getStatusInBengali(String status) {
    switch (status) {
      case 'pending': return 'অপেক্ষমাণ';
      case 'confirmed': return 'নিশ্চিত';
      case 'processing': return 'প্রক্রিয়াধীন';
      case 'shipped': return 'প্রেরিত';
      case 'delivered': return 'বিতরণ';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppTheme.warningColor;
      case 'confirmed': return AppTheme.accentColor;
      case 'processing': return AppTheme.primaryColor;
      case 'shipped': return AppTheme.secondaryColor;
      case 'delivered': return AppTheme.successColor;
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পাইকারি বিক্রয়'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                _buildStatsCards(),
                Expanded(child: _buildOrdersList()),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['সব', 'অপেক্ষমাণ', 'নিশ্চিত', 'প্রক্রিয়াধীন', 'প্রেরিত', 'বিতরণ'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: statuses.map((status) {
            final isSelected = status == _filterStatus;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (_) => setState(() => _filterStatus = status),
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

  Widget _buildStatsCards() {
    final pending = _orders.where((o) => o.orderStatus == 'pending').length;
    final processing = _orders.where((o) => o.orderStatus == 'processing').length;
    final delivered = _orders.where((o) => o.orderStatus == 'delivered').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('অপেক্ষমাণ', '$pending', AppTheme.warningColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('প্রক্রিয়াধীন', '$processing', AppTheme.primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('সম্পন্ন', '$delivered', AppTheme.successColor)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'কোন অর্ডার পাওয়া যায়নি',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.orderStatus).withValues(alpha: 0.2),
              child: Icon(
                Icons.shopping_bag,
                color: _getStatusColor(order.orderStatus),
              ),
            ),
            title: Text(
              order.orderNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName),
                Text(
                  DateFormat('dd/MM/yyyy hh:mm a', 'bn_BD').format(order.orderDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusInBengali(order.orderStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.orderStatus),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'অর্ডার বিস্তারিত',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} × ${item.quantity}',
                                ),
                              ),
                              Text(
                                '৳${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                    if (order.notes != null) ...[
                      const Divider(),
                      Text('নোট: ${order.notes}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
