import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'মাছের রোগ';
  String _selectedUrgency = 'সাধারণ';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();

  final List<String> _categories = [
    'মাছের রোগ',
    'খাবার ব্যবস্থাপনা',
    'পুকুর ব্যবস্থাপনা',
    'ওষুধ পরামর্শ',
    'মাছ চাষ পদ্ধতি',
    'অন্যান্য',
  ];

  final List<String> _urgencyLevels = [
    'জরুরি',
    'গুরুত্বপূর্ণ',
    'সাধারণ',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitConsultation() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('সফল'),
            ],
          ),
          content: const Text(
            'আপনার পরামর্শ অনুরোধ সফলভাবে জমা হয়েছে। আমাদের বিশেষজ্ঞ শীঘ্রই আপনার সাথে যোগাযোগ করবেন।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _detailsController.clear();
    setState(() {
      _selectedCategory = 'মাছের রোগ';
      _selectedUrgency = 'সাধারণ';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিশেষজ্ঞ পরামর্শ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Info card
              Card(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accentColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'আমাদের অভিজ্ঞ বিশেষজ্ঞদের কাছ থেকে মাছ চাষ সম্পর্কিত যেকোনো সমস্যার সমাধান পান',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'আপনার নাম *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'নাম লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'মোবাইল নম্বর *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '০১৭xxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'মোবাইল নম্বর লিখুন';
                  }
                  if (value.length < 11) {
                    return 'সঠিক মোবাইল নম্বর লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: null,
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'পরামর্শের ধরন *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Urgency dropdown
              DropdownButtonFormField<String>(
                value: null,
                initialValue: _selectedUrgency,
                decoration: InputDecoration(
                  labelText: 'জরুরি মাত্রা *',
                  prefixIcon: const Icon(Icons.priority_high),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _urgencyLevels.map((urgency) {
                  return DropdownMenuItem(
                    value: urgency,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: urgency == 'জরুরি'
                              ? Colors.red
                              : urgency == 'গুরুত্বপূর্ণ'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(urgency),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUrgency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Details field
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'বিস্তারিত বর্ণনা *',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'আপনার সমস্যা বিস্তারিত লিখুন...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'সমস্যার বর্ণনা লিখুন';
                  }
                  if (value.length < 20) {
                    return 'অন্তত ২০ অক্ষরের বর্ণনা লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitConsultation,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'পরামর্শ অনুরোধ পাঠান',
                    style: TextStyle(fontSize: 16),
                  ),
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

              // Common questions
              const Text(
                'সাধারণ প্রশ্ন',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFAQCard(
                'পরামর্শ পেতে কত সময় লাগে?',
                'সাধারণত ২৪ ঘণ্টার মধ্যে আমাদের বিশেষজ্ঞ আপনার সাথে যোগাযোগ করবেন।',
              ),
              _buildFAQCard(
                'পরামর্শ সেবা কি বিনামূল্যে?',
                'হ্যাঁ, প্রথম পরামর্শ সম্পূর্ণ বিনামূল্যে।',
              ),
              _buildFAQCard(
                'জরুরি সমস্যার জন্য কী করব?',
                'জরুরি হিসেবে চিহ্নিত করুন, আমরা অগ্রাধিকার ভিত্তিতে সাড়া দেব।',
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: AppTheme.accentColor),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
