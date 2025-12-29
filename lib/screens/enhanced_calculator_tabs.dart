import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

// Pond Area Calculator
class PondCalculatorTab extends StatefulWidget {
  const PondCalculatorTab({super.key});

  @override
  State<PondCalculatorTab> createState() => _PondCalculatorTabState();
}

class _PondCalculatorTabState extends State<PondCalculatorTab> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();
  
  String _selectedShape = 'আয়তাকার';
  double _area = 0;
  double _volume = 0;
  double _perimeter = 0;

  void _calculate() {
    final length = double.tryParse(_lengthController.text) ?? 0;
    final width = double.tryParse(_widthController.text) ?? 0;
    final depth = double.tryParse(_depthController.text) ?? 0;

    double area = 0;
    double perimeter = 0;

    if (_selectedShape == 'আয়তাকার') {
      area = length * width;
      perimeter = 2 * (length + width);
    } else if (_selectedShape == 'বর্গাকার') {
      area = length * length;
      perimeter = 4 * length;
    } else if (_selectedShape == 'বৃত্তাকার') {
      area = 3.1416 * length * length;
      perimeter = 2 * 3.1416 * length;
    }

    final volume = area * depth;

    setState(() {
      _area = area;
      _volume = volume;
      _perimeter = perimeter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('পুকুরের আয়তন, ক্ষেত্রফল ও পরিসীমা হিসাব করুন'),
            ),
          ),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            value: _selectedShape,
            decoration: InputDecoration(
              labelText: 'পুকুরের আকৃতি',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: ['আয়তাকার', 'বর্গাকার', 'বৃত্তাকার'].map((shape) {
              return DropdownMenuItem(value: shape, child: Text(shape));
            }).toList(),
            onChanged: (value) => setState(() => _selectedShape = value!),
          ),
          const SizedBox(height: 12),
          
          if (_selectedShape == 'বৃত্তাকার')
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(
                labelText: 'ব্যাসার্ধ (মিটার)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            )
          else ...[
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(
                labelText: 'দৈর্ঘ্য (মিটার)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            if (_selectedShape == 'আয়তাকার') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _widthController,
                decoration: InputDecoration(
                  labelText: 'প্রস্থ (মিটার)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
          const SizedBox(height: 12),
          
          TextField(
            controller: _depthController,
            decoration: InputDecoration(
              labelText: 'গভীরতা (মিটার)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('হিসাব করুন'),
          ),
          const SizedBox(height: 24),
          
          if (_area > 0) ...[
            _buildResultCard('ক্ষেত্রফল', '${_area.toStringAsFixed(2)} বর্গমিটার', Icons.crop_square),
            _buildResultCard('আয়তন', '${_volume.toStringAsFixed(2)} ঘনমিটার', Icons.view_in_ar),
            _buildResultCard('পরিসীমা', '${_perimeter.toStringAsFixed(2)} মিটার', Icons.straighten),
            _buildResultCard('শতাংশ', '${(_area / 40.47).toStringAsFixed(2)} শতাংশ', Icons.landscape),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    super.dispose();
  }
}

// Water Volume Calculator
class WaterCalculatorTab extends StatefulWidget {
  const WaterCalculatorTab({super.key});

  @override
  State<WaterCalculatorTab> createState() => _WaterCalculatorTabState();
}

class _WaterCalculatorTabState extends State<WaterCalculatorTab> {
  final _areaController = TextEditingController();
  final _depthController = TextEditingController();
  
  double _waterVolume = 0;
  double _waterWeight = 0;

  void _calculate() {
    final area = double.tryParse(_areaController.text) ?? 0;
    final depth = double.tryParse(_depthController.text) ?? 0;
    
    final volume = area * depth;
    final weight = volume * 1000; // 1 cubic meter = 1000 kg water
    
    setState(() {
      _waterVolume = volume;
      _waterWeight = weight;
    });
  }

  String _formatNumber(double num) {
    return NumberFormat('#,##,##0.00', 'bn_BD').format(num);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('পুকুরের পানির পরিমাণ হিসাব করুন'),
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _areaController,
            decoration: InputDecoration(
              labelText: 'পুকুরের ক্ষেত্রফল (বর্গমিটার)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _depthController,
            decoration: InputDecoration(
              labelText: 'পানির গভীরতা (মিটার)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,
            ),
            child: const Text('হিসাব করুন'),
          ),
          const SizedBox(height: 24),
          
          if (_waterVolume > 0) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: const Text('পানির আয়তন'),
                subtitle: Text('${_formatNumber(_waterVolume)} ঘনমিটার'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.scale, color: Colors.blue),
                title: const Text('পানির ওজন'),
                subtitle: Text('${_formatNumber(_waterWeight)} কেজি'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.water, color: Colors.blue),
                title: const Text('পানির পরিমাণ (লিটার)'),
                subtitle: Text('${_formatNumber(_waterVolume * 1000)} লিটার'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _depthController.dispose();
    super.dispose();
  }
}

// Stocking Density Calculator
class StockingDensityCalculatorTab extends StatefulWidget {
  const StockingDensityCalculatorTab({super.key});

  @override
  State<StockingDensityCalculatorTab> createState() => _StockingDensityCalculatorTabState();
}

class _StockingDensityCalculatorTabState extends State<StockingDensityCalculatorTab> {
  final _areaController = TextEditingController();
  final _depthController = TextEditingController();
  final _fishTypeController = TextEditingController(text: 'রুই/কাতলা');
  
  double _recommendedStocking = 0;
  double _minStocking = 0;
  double _maxStocking = 0;
  String _fishingMethod = 'মিশ্র চাষ';

  void _calculate() {
    final area = double.tryParse(_areaController.text) ?? 0;
    final depth = double.tryParse(_depthController.text) ?? 0;
    
    // Standard stocking density calculations
    double densityPerDecimal = 0;
    
    if (_fishingMethod == 'মিশ্র চাষ') {
      densityPerDecimal = 50; // 50 fish per decimal
    } else if (_fishingMethod == 'নিবিড় চাষ') {
      densityPerDecimal = 100;
    } else {
      densityPerDecimal = 25;
    }
    
    final areaInDecimal = area / 40.47;
    final recommended = areaInDecimal * densityPerDecimal;
    
    setState(() {
      _recommendedStocking = recommended;
      _minStocking = recommended * 0.7;
      _maxStocking = recommended * 1.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('পুকুরে মাছের মজুদ ঘনত্ব হিসাব করুন'),
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _areaController,
            decoration: InputDecoration(
              labelText: 'পুকুরের ক্ষেত্রফল (বর্গমিটার)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _depthController,
            decoration: InputDecoration(
              labelText: 'পানির গভীরতা (মিটার)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _fishTypeController,
            decoration: InputDecoration(
              labelText: 'মাছের ধরন',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: _fishingMethod,
            decoration: InputDecoration(
              labelText: 'চাষ পদ্ধতি',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: ['মিশ্র চাষ', 'নিবিড় চাষ', 'বিস্তৃত চাষ'].map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (value) => setState(() => _fishingMethod = value!),
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green,
            ),
            child: const Text('হিসাব করুন'),
          ),
          const SizedBox(height: 24),
          
          if (_recommendedStocking > 0) ...[
            Card(
              color: Colors.green.withValues(alpha: 0.1),
              child: ListTile(
                leading: const Icon(Icons.recommend, color: Colors.green),
                title: const Text('প্রস্তাবিত মজুদ'),
                subtitle: Text('${_recommendedStocking.toInt()} টি পোনা'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.orange),
                title: const Text('ন্যূনতম মজুদ'),
                subtitle: Text('${_minStocking.toInt()} টি পোনা'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('সর্বোচ্চ মজুদ'),
                subtitle: Text('${_maxStocking.toInt()} টি পোনা'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'পরামর্শ:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('• মজুদ ঘনত্ব পুকুরের অক্সিজেন স্তরের উপর নির্ভর করে'),
                    Text('• নিয়মিত পানির গুণমান পরীক্ষা করুন'),
                    Text('• প্রয়োজনে এরেটর ব্যবহার করুন'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _depthController.dispose();
    _fishTypeController.dispose();
    super.dispose();
  }
}
