import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;

  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameBengaliController = TextEditingController();
  final _nameEnglishController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _dosageController = TextEditingController();
  final _manufacturerController = TextEditingController();
  
  String _selectedCategory = 'অ্যান্টিবায়োটিক';
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameBengaliController.text = widget.medicine!.nameBengali;
      _nameEnglishController.text = widget.medicine!.nameEnglish;
      _priceController.text = widget.medicine!.pricePerUnit.toString();
      _stockController.text = widget.medicine!.stockQuantity.toString();
      _dosageController.text = widget.medicine!.dosageInfo;
      _manufacturerController.text = widget.medicine!.manufacturer;
      _selectedCategory = widget.medicine!.category;
      _expiryDate = widget.medicine!.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameBengaliController.dispose();
    _nameEnglishController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _dosageController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      final medicine = MedicineModel(
        id: widget.medicine?.id ?? const Uuid().v4(),
        nameBengali: _nameBengaliController.text,
        nameEnglish: _nameEnglishController.text,
        category: _selectedCategory,
        pricePerUnit: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockController.text),
        dosageInfo: _dosageController.text,
        expiryDate: _expiryDate,
        manufacturer: _manufacturerController.text,
        lastUpdated: DateTime.now(),
      );
      
      Navigator.pop(context, medicine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'নতুন ঔষধ যোগ করুন' : 'ঔষধ সম্পাদনা'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMedicine,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ঔষধের তথ্য',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameBengaliController,
                        decoration: InputDecoration(
                          labelText: 'নাম (বাংলা) *',
                          prefixIcon: const Icon(Icons.medication),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'নাম লিখুন' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _nameEnglishController,
                        decoration: InputDecoration(
                          labelText: 'Name (English) *',
                          prefixIcon: const Icon(Icons.abc),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'ক্যাটাগরি *',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          'অ্যান্টিবায়োটিক',
                          'জীবাণুনাশক',
                          'ভিটামিন',
                          'খনিজ',
                          'প্রোবায়োটিক',
                          'হরমোন',
                          'অন্যান্য'
                        ].map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'মূল্য ও স্টক',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'প্রতি ইউনিট মূল্য (৳) *',
                          prefixIcon: const Icon(Icons.monetization_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'মূল্য লিখুন' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'মজুদ সংখ্যা *',
                          prefixIcon: const Icon(Icons.inventory),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'মজুদ লিখুন' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'অতিরিক্ত তথ্য',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: 'ডোজ তথ্য *',
                          prefixIcon: const Icon(Icons.info),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'যেমন: ৫০-৭৫ মিগ্রা/কেজি খাবারে',
                        ),
                        maxLines: 2,
                        validator: (v) => v?.isEmpty ?? true ? 'ডোজ তথ্য লিখুন' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _manufacturerController,
                        decoration: InputDecoration(
                          labelText: 'প্রস্তুতকারক *',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'প্রস্তুতকারক লিখুন' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      ListTile(
                        title: const Text('মেয়াদ উত্তীর্ণের তারিখ'),
                        subtitle: Text(
                          _expiryDate != null
                              ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                              : 'তারিখ নির্বাচন করুন',
                        ),
                        leading: const Icon(Icons.calendar_today),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onTap: _selectExpiryDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.medicine == null ? 'ঔষধ যোগ করুন' : 'পরিবর্তন সংরক্ষণ করুন',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
