import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class MarketAnalyticsScreen extends StatefulWidget {
  const MarketAnalyticsScreen({super.key});

  @override
  State<MarketAnalyticsScreen> createState() => _MarketAnalyticsScreenState();
}

class _MarketAnalyticsScreenState extends State<MarketAnalyticsScreen> {
  final _dbService = DatabaseService();
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    final sales = await _dbService.getAllSales();
    final customers = await _dbService.getAllCustomers();
    final orders = await _dbService.getAllOrders();

    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final wholesaleRevenue = sales
        .where((s) => s.saleType == 'পাইকারি')
        .fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final retailRevenue = sales
        .where((s) => s.saleType == 'খুচরা')
        .fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    final wholesaleCustomers = customers.where((c) => c.customerType == 'wholesale').length;
    final retailCustomers = customers.where((c) => c.customerType == 'retail').length;

    final last7Days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
    final dailyRevenue = last7Days.map((date) {
      return sales
          .where((s) =>
              s.saleDate.year == date.year &&
              s.saleDate.month == date.month &&
              s.saleDate.day == date.day)
          .fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    }).toList();

    setState(() {
      _analytics = {
        'totalRevenue': totalRevenue,
        'wholesaleRevenue': wholesaleRevenue,
        'retailRevenue': retailRevenue,
        'wholesaleCustomers': wholesaleCustomers,
        'retailCustomers': retailCustomers,
        'dailyRevenue': dailyRevenue,
        'last7Days': last7Days,
        'totalOrders': orders.length,
        'pendingOrders': orders.where((o) => o.orderStatus == 'pending').length,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বাজার বিশ্লেষণ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRevenueCard(),
                    const SizedBox(height: 16),
                    _buildRevenueChart(),
                    const SizedBox(height: 16),
                    _buildSalesTypeComparison(),
                    const SizedBox(height: 16),
                    _buildCustomerMetrics(),
                    const SizedBox(height: 16),
                    _buildOrderMetrics(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRevenueCard() {
    final totalRevenue = _analytics['totalRevenue'] ?? 0.0;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'মোট আয়',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${NumberFormat('#,##,##0.00', 'bn_BD').format(totalRevenue)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final dailyRevenue = _analytics['dailyRevenue'] as List<double>;
    final maxY = dailyRevenue.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'গত ৭ দিনের আয়',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < 7) {
                            final dates = _analytics['last7Days'] as List<DateTime>;
                            return Text(
                              DateFormat('d/M').format(dates[value.toInt()]),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyRevenue
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTypeComparison() {
    final wholesaleRevenue = _analytics['wholesaleRevenue'] ?? 0.0;
    final retailRevenue = _analytics['retailRevenue'] ?? 0.0;
    final total = wholesaleRevenue + retailRevenue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'পাইকারি বনাম খুচরা',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRevenueTypeCard(
                    'পাইকারি',
                    wholesaleRevenue,
                    total > 0 ? (wholesaleRevenue / total * 100) : 0,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRevenueTypeCard(
                    'খুচরা',
                    retailRevenue,
                    total > 0 ? (retailRevenue / total * 100) : 0,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTypeCard(String type, double revenue, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '৳${NumberFormat('#,##0', 'bn_BD').format(revenue)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetrics() {
    final wholesaleCustomers = _analytics['wholesaleCustomers'] ?? 0;
    final retailCustomers = _analytics['retailCustomers'] ?? 0;
    final total = wholesaleCustomers + retailCustomers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'গ্রাহক বিশ্লেষণ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('মোট গ্রাহক', '$total', Icons.people),
            const Divider(),
            _buildMetricRow('পাইকারি গ্রাহক', '$wholesaleCustomers', Icons.store),
            const Divider(),
            _buildMetricRow('খুচরা গ্রাহক', '$retailCustomers', Icons.shopping_cart),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderMetrics() {
    final totalOrders = _analytics['totalOrders'] ?? 0;
    final pendingOrders = _analytics['pendingOrders'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'অর্ডার বিশ্লেষণ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('মোট অর্ডার', '$totalOrders', Icons.receipt_long),
            const Divider(),
            _buildMetricRow('অপেক্ষমাণ অর্ডার', '$pendingOrders', Icons.pending),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
