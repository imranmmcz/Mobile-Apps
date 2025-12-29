import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'fish_sales_screen.dart';
import 'medicine_screen.dart';
import 'market_analytics_screen.dart';
import 'wholesale_screen.dart';
import 'retail_screen.dart';
import 'ai_assistant_screen.dart';
import 'products_screen.dart';
import 'consultation_screen.dart';
import 'calculator_screen.dart';
import 'settings_screen.dart';
import 'admin_panel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dbService = DatabaseService();
  Map<String, dynamic> _stats = {};
  List<dynamic> _fishes = [];
  List<dynamic> _medicines = [];
  bool _isLoading = true;
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _stats = {
      'totalRevenue': 0.0,
      'todayRevenue': 0.0,
      'totalSales': 0,
      'todaySales': 0,
      'totalCustomers': 0,
      'lowStockMedicines': 0,
      'pendingOrders': 0,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
      _startBannerAutoScroll();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _bannerController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _dbService.getDashboardStats().timeout(
        const Duration(seconds: 5),
        onTimeout: () => {
          'totalRevenue': 0.0,
          'todayRevenue': 0.0,
          'totalSales': 0,
          'todaySales': 0,
          'totalCustomers': 0,
          'lowStockMedicines': 0,
          'pendingOrders': 0,
        },
      );
      
      final fishes = await _dbService.getAllFish().timeout(
        const Duration(seconds: 3),
        onTimeout: () => [],
      );
      
      final medicines = await _dbService.getAllMedicines().timeout(
        const Duration(seconds: 3),
        onTimeout: () => [],
      );

      if (mounted) {
        setState(() {
          _stats = stats;
          _fishes = fishes;
          _medicines = medicines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fish Care',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'সম্পূর্ণ মাছ ব্যবস্থাপনা',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Slider
                      _buildBannerSlider(),
                      const SizedBox(height: 16),
                      
                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStatsGrid(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Medicine Products Slider
                      _buildSectionHeader('ঔষধ সমূহ', Icons.medication, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MedicineScreen()),
                        );
                      }),
                      _buildMedicineSlider(),
                      const SizedBox(height: 20),
                      
                      // Fish Products Slider
                      _buildSectionHeader('মাছের তালিকা', Icons.water, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductsScreen()),
                        );
                      }),
                      _buildFishSlider(),
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'দ্রুত অ্যাক্সেস',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionsGrid(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 180,
      child: PageView(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerPage = index;
          });
        },
        children: [
          _buildBannerCard(
            'মাছ চাষে নতুন যুগ',
            'আধুনিক প্রযুক্তিতে মাছ ব্যবস্থাপনা',
            Colors.blue,
            Icons.water_drop,
          ),
          _buildBannerCard(
            'ঔষধ ও চিকিৎসা',
            'সঠিক সময়ে সঠিক ঔষধ প্রয়োগ',
            Colors.green,
            Icons.medical_services,
          ),
          _buildBannerCard(
            'AI Assistant',
            'মাছ চাষের সকল সমস্যার সমাধান',
            Colors.purple,
            Icons.smart_toy,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('সব দেখুন →'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSlider() {
    if (_medicines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('কোন ঔষধ পাওয়া যায়নি')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          final medicine = _medicines[index];
          return _buildMedicineCard(medicine);
        },
      ),
    );
  }

  Widget _buildMedicineCard(dynamic medicine) {
    final isLowStock = medicine.stockQuantity < 10;
    final isExpiringSoon = medicine.expiryDate != null && medicine.expiryDate.isBefore(
      DateTime.now().add(const Duration(days: 30)),
    );

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(
                Icons.medication,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.nameBengali ?? medicine.nameEnglish,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(medicine.pricePerUnit ?? 0),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLowStock || isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLowStock ? 'কম মজুদ' : 'শেষ হবে',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishSlider() {
    if (_fishes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('কোন মাছ পাওয়া যায়নি')),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _fishes.length,
        itemBuilder: (context, index) {
          final fish = _fishes[index];
          return _buildFishCard(fish);
        },
      ),
    );
  }

  Widget _buildFishCard(dynamic fish) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water,
              size: 40,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              fish.nameBengali ?? fish.nameEnglish,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(fish.pricePerMana ?? 0),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'প্রতি কেজি',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'মোট বিক্রয়',
          _formatCurrency(_stats['totalRevenue'] ?? 0.0),
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'আজকের বিক্রয়',
          _formatCurrency(_stats['todayRevenue'] ?? 0.0),
          Icons.today,
          Colors.blue,
        ),
        _buildStatCard(
          'মোট অর্ডার',
          '${_stats['totalSales'] ?? 0}',
          Icons.shopping_cart,
          Colors.orange,
        ),
        _buildStatCard(
          'গ্রাহক',
          '${_stats['totalCustomers'] ?? 0}',
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildQuickActionCard('বিক্রয়', Icons.point_of_sale, Colors.green, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FishSalesScreen()));
        }),
        _buildQuickActionCard('ঔষধ', Icons.medication, Colors.red, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicineScreen()));
        }),
        _buildQuickActionCard('বিশ্লেষণ', Icons.analytics, Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketAnalyticsScreen()));
        }),
        _buildQuickActionCard('ক্যালকুলেটর', Icons.calculate, Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen()));
        }),
        _buildQuickActionCard('AI সহায়ক', Icons.smart_toy, Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AIAssistantScreen()));
        }),
        _buildQuickActionCard('সেটিংস', Icons.settings, Colors.grey, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        }),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fish Care',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'সম্পূর্ণ মাছ ব্যবস্থাপনা',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'ড্যাশবোর্ড', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.point_of_sale, 'বিক্রয়', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FishSalesScreen()));
          }),
          _buildDrawerItem(Icons.medication, 'ঔষধ ব্যবস্থাপনা', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicineScreen()));
          }),
          _buildDrawerItem(Icons.analytics, 'বাজার বিশ্লেষণ', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketAnalyticsScreen()));
          }),
          _buildDrawerItem(Icons.shopping_cart, 'পাইকারি বিক্রয়', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WholesaleScreen()));
          }),
          _buildDrawerItem(Icons.store, 'খুচরা বিক্রয়', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RetailScreen()));
          }),
          _buildDrawerItem(Icons.category, 'পণ্য তালিকা', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductsScreen()));
          }),
          _buildDrawerItem(Icons.calculate, 'ক্যালকুলেটর', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen()));
          }),
          _buildDrawerItem(Icons.support_agent, 'বিশেষজ্ঞ পরামর্শ', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationScreen()));
          }),
          _buildDrawerItem(Icons.smart_toy, 'AI Assistant', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AIAssistantScreen()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.admin_panel_settings, 'Admin Panel', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
          }),
          _buildDrawerItem(Icons.settings, 'সেটিংস', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
