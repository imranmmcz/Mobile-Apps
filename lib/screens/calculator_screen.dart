import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'enhanced_calculator_tabs.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ক্যালকুলেটর'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: 'খাবার'),
            Tab(icon: Icon(Icons.medical_services), text: 'ওষুধ'),
            Tab(icon: Icon(Icons.calculate), text: 'লাভ-ক্ষতি'),
            Tab(icon: Icon(Icons.pool), text: 'পুকুর'),
            Tab(icon: Icon(Icons.water_drop), text: 'পানি'),
            Tab(icon: Icon(Icons.storage), text: 'মজুদ'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            FoodCalculatorTab(),
            MedicineCalculatorTab(),
            ProfitLossCalculatorTab(),
            PondCalculatorTab(),
            WaterCalculatorTab(),
            StockingDensityCalculatorTab(),
          ],
        ),
      ),
    );
  }
}

// Food Calculator Tab
class FoodCalculatorTab extends StatefulWidget {
  const FoodCalculatorTab({super.key});

  @override
  State<FoodCalculatorTab> createState() => _FoodCalculatorTabState();
}

class _FoodCalculatorTabState extends State<FoodCalculatorTab> {
  final _fishWeightController = TextEditingController();
  final _numberOfFishController = TextEditingController();
  final _feedingPercentController = TextEditingController(text: '3');
  final _feedPriceController = TextEditingController(text: '50');
  final _feedingsPerDayController = TextEditingController(text: '2');

  double _dailyFeed = 0;
  double _dailyCost = 0;
  double _monthlyCost = 0;

  @override
  void dispose() {
    _fishWeightController.dispose();
    _numberOfFishController.dispose();
    _feedingPercentController.dispose();
    _feedPriceController.dispose();
    _feedingsPerDayController.dispose();
    super.dispose();
  }

  void _calculate() {
    final fishWeight = double.tryParse(_fishWeightController.text) ?? 0;
    final numberOfFish = double.tryParse(_numberOfFishController.text) ?? 0;
    final feedingPercent = double.tryParse(_feedingPercentController.text) ?? 3;
    final feedPrice = double.tryParse(_feedPriceController.text) ?? 50;
    final feedingsPerDay = int.tryParse(_feedingsPerDayController.text) ?? 2;

    final totalWeight = fishWeight * numberOfFish;
    final dailyFeedPerFeeding = (totalWeight * feedingPercent / 100) / feedingsPerDay;
    final totalDailyFeed = dailyFeedPerFeeding * feedingsPerDay;
    final dailyCost = totalDailyFeed * feedPrice;
    final monthlyCost = dailyCost * 30;

    setState(() {
      _dailyFeed = totalDailyFeed;
      _dailyCost = dailyCost;
      _monthlyCost = monthlyCost;
    });
  }

  String _formatCurrency(double amount) {
    return '৳${NumberFormat('#,##,##0.00', 'bn_BD').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.accentColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'মাছের দৈনিক খাবারের পরিমাণ ও খরচ হিসাব করুন',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Input fields
          TextField(
            controller: _fishWeightController,
            decoration: InputDecoration(
              labelText: 'প্রতিটি মাছের ওজন (কেজি)',
              prefixIcon: const Icon(Icons.scale),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _numberOfFishController,
            decoration: InputDecoration(
              labelText: 'মাছের সংখ্যা',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _feedingPercentController,
            decoration: InputDecoration(
              labelText: 'খাবারের শতাংশ (শরীরের ওজনের %)',
              prefixIcon: const Icon(Icons.percent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'সাধারণত ৩-৫%',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _feedPriceController,
            decoration: InputDecoration(
              labelText: 'খাবারের দাম (টাকা/কেজি)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _feedingsPerDayController,
            decoration: InputDecoration(
              labelText: 'দৈনিক খাবারের বার',
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'সাধারণত ২-৩ বার',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('হিসাব করুন', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Results
          if (_dailyFeed > 0) ...[
            const Text(
              'হিসাবের ফলাফল:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              'দৈনিক খাবার',
              '${_dailyFeed.toStringAsFixed(2)} কেজি',
              Icons.restaurant,
              AppTheme.primaryColor,
            ),
            _buildResultCard(
              'দৈনিক খরচ',
              _formatCurrency(_dailyCost),
              Icons.today,
              AppTheme.accentColor,
            ),
            _buildResultCard(
              'মাসিক খরচ (৩০ দিন)',
              _formatCurrency(_monthlyCost),
              Icons.calendar_month,
              AppTheme.secondaryColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// Medicine Calculator Tab
class MedicineCalculatorTab extends StatefulWidget {
  const MedicineCalculatorTab({super.key});

  @override
  State<MedicineCalculatorTab> createState() => _MedicineCalculatorTabState();
}

class _MedicineCalculatorTabState extends State<MedicineCalculatorTab> {
  final _fishWeightController = TextEditingController();
  final _dosageController = TextEditingController();
  final _medicinePriceController = TextEditingController();
  final _treatmentDaysController = TextEditingController(text: '5');

  double _dosePerFish = 0;
  double _totalDose = 0;
  double _costPerDay = 0;
  double _totalCost = 0;

  @override
  void dispose() {
    _fishWeightController.dispose();
    _dosageController.dispose();
    _medicinePriceController.dispose();
    _treatmentDaysController.dispose();
    super.dispose();
  }

  void _calculate() {
    final fishWeight = double.tryParse(_fishWeightController.text) ?? 0;
    final dosage = double.tryParse(_dosageController.text) ?? 0;
    final medicinePrice = double.tryParse(_medicinePriceController.text) ?? 0;
    final treatmentDays = int.tryParse(_treatmentDaysController.text) ?? 5;

    final dosePerFish = fishWeight * dosage;
    final totalDose = dosePerFish * treatmentDays;
    final costPerDay = (dosePerFish / 1000) * medicinePrice; // Convert mg to g
    final totalCost = costPerDay * treatmentDays;

    setState(() {
      _dosePerFish = dosePerFish;
      _totalDose = totalDose;
      _costPerDay = costPerDay;
      _totalCost = totalCost;
    });
  }

  String _formatCurrency(double amount) {
    return '৳${NumberFormat('#,##,##0.00', 'bn_BD').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.secondaryColor.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.secondaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'মাছের ওষুধের পরিমাণ ও চিকিৎসা খরচ হিসাব করুন',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _fishWeightController,
            decoration: InputDecoration(
              labelText: 'মাছের ওজন (কেজি)',
              prefixIcon: const Icon(Icons.scale),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _dosageController,
            decoration: InputDecoration(
              labelText: 'ডোজ (মিলিগ্রাম/কেজি)',
              prefixIcon: const Icon(Icons.medication),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'যেমন: 50-75 mg/kg',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _medicinePriceController,
            decoration: InputDecoration(
              labelText: 'ওষুধের দাম (টাকা/গ্রাম)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _treatmentDaysController,
            decoration: InputDecoration(
              labelText: 'চিকিৎসার দিন',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'সাধারণত ৫-৭ দিন',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('হিসাব করুন', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_dosePerFish > 0) ...[
            const Text(
              'হিসাবের ফলাফল:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              'প্রতিদিনের ডোজ',
              '${_dosePerFish.toStringAsFixed(2)} মিলিগ্রাম',
              Icons.medication,
              AppTheme.secondaryColor,
            ),
            _buildResultCard(
              'মোট ডোজ (সম্পূর্ণ কোর্স)',
              '${_totalDose.toStringAsFixed(2)} মিলিগ্রাম',
              Icons.medical_services,
              AppTheme.primaryColor,
            ),
            _buildResultCard(
              'দৈনিক খরচ',
              _formatCurrency(_costPerDay),
              Icons.today,
              AppTheme.accentColor,
            ),
            _buildResultCard(
              'মোট চিকিৎসা খরচ',
              _formatCurrency(_totalCost),
              Icons.attach_money,
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// Profit/Loss Calculator Tab
class ProfitLossCalculatorTab extends StatefulWidget {
  const ProfitLossCalculatorTab({super.key});

  @override
  State<ProfitLossCalculatorTab> createState() => _ProfitLossCalculatorTabState();
}

class _ProfitLossCalculatorTabState extends State<ProfitLossCalculatorTab> {
  final _initialCostController = TextEditingController();
  final _feedCostController = TextEditingController();
  final _medicineCostController = TextEditingController();
  final _laborCostController = TextEditingController();
  final _otherCostController = TextEditingController();
  final _totalSalesController = TextEditingController();

  double _totalCost = 0;
  double _profit = 0;
  double _profitPercent = 0;

  @override
  void dispose() {
    _initialCostController.dispose();
    _feedCostController.dispose();
    _medicineCostController.dispose();
    _laborCostController.dispose();
    _otherCostController.dispose();
    _totalSalesController.dispose();
    super.dispose();
  }

  void _calculate() {
    final initialCost = double.tryParse(_initialCostController.text) ?? 0;
    final feedCost = double.tryParse(_feedCostController.text) ?? 0;
    final medicineCost = double.tryParse(_medicineCostController.text) ?? 0;
    final laborCost = double.tryParse(_laborCostController.text) ?? 0;
    final otherCost = double.tryParse(_otherCostController.text) ?? 0;
    final totalSales = double.tryParse(_totalSalesController.text) ?? 0;

    final totalCost = initialCost + feedCost + medicineCost + laborCost + otherCost;
    final profit = totalSales - totalCost;
    final profitPercent = totalSales > 0 ? (profit / totalSales) * 100 : 0.0;

    setState(() {
      _totalCost = totalCost;
      _profit = profit;
      _profitPercent = profitPercent.toDouble();
    });
  }

  String _formatCurrency(double amount) {
    return '৳${NumberFormat('#,##,##0.00', 'bn_BD').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'মাছ চাষের মোট লাভ-ক্ষতি হিসাব করুন',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'খরচের তালিকা:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _initialCostController,
            decoration: InputDecoration(
              labelText: 'প্রাথমিক খরচ (পোনা, পুকুর ইত্যাদি)',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _feedCostController,
            decoration: InputDecoration(
              labelText: 'খাবার খরচ',
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _medicineCostController,
            decoration: InputDecoration(
              labelText: 'ওষুধ খরচ',
              prefixIcon: const Icon(Icons.medical_services),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _laborCostController,
            decoration: InputDecoration(
              labelText: 'শ্রমিক খরচ',
              prefixIcon: const Icon(Icons.people),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _otherCostController,
            decoration: InputDecoration(
              labelText: 'অন্যান্য খরচ',
              prefixIcon: const Icon(Icons.more_horiz),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          const Text(
            'আয়:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _totalSalesController,
            decoration: InputDecoration(
              labelText: 'মোট বিক্রয়',
              prefixIcon: const Icon(Icons.payments),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('লাভ-ক্ষতি হিসাব করুন', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_totalCost > 0) ...[
            const Text(
              'হিসাবের ফলাফল:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.red.withValues(alpha: 0.1),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.trending_down, color: Colors.white),
                ),
                title: const Text('মোট খরচ'),
                trailing: Text(
                  _formatCurrency(_totalCost),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Card(
              color: _profit >= 0
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _profit >= 0 ? Colors.green : Colors.red,
                  child: Icon(
                    _profit >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                  ),
                ),
                title: Text(_profit >= 0 ? 'নিট লাভ' : 'নিট ক্ষতি'),
                trailing: Text(
                  _formatCurrency(_profit.abs()),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            Card(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.accentColor,
                  child: Icon(Icons.percent, color: Colors.white),
                ),
                title: const Text('লাভের শতাংশ'),
                trailing: Text(
                  '${_profitPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
