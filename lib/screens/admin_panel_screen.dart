import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wordpress_content_manager_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _authService = AuthService();
  final _heroTitleController = TextEditingController();
  final _heroSubtitleController = TextEditingController();
  final _heroDescriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadHeroSection();
  }

  @override
  void dispose() {
    _heroTitleController.dispose();
    _heroSubtitleController.dispose();
    _heroDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadHeroSection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _heroTitleController.text = prefs.getString('hero_title') ?? 'Fish Care';
      _heroSubtitleController.text = prefs.getString('hero_subtitle') ?? 'সম্পূর্ণ মাছ ব্যবস্থাপনা';
      _heroDescriptionController.text = prefs.getString('hero_description') ?? 'আধুনিক প্রযুক্তিতে মাছ চাষ ব্যবস্থাপনা';
    });
  }

  Future<void> _saveHeroSection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hero_title', _heroTitleController.text);
    await prefs.setString('hero_subtitle', _heroSubtitleController.text);
    await prefs.setString('hero_description', _heroDescriptionController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hero Section সংরক্ষিত হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dashboard, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Hero Section সম্পাদনা',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _heroTitleController,
                      decoration: InputDecoration(
                        labelText: 'Hero Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _heroSubtitleController,
                      decoration: InputDecoration(
                        labelText: 'Hero Subtitle (বাংলা)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.subtitles),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _heroDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Hero Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveHeroSection,
                        icon: const Icon(Icons.save),
                        label: const Text('Hero Section সংরক্ষণ করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // WordPress Website Management Card
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.language, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WordPress Website',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ওয়েবসাইট কনটেন্ট পরিচালনা করুন',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WordPressContentManagerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('WordPress Manager খুলুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.blue),
                    title: const Text('ইউজার ম্যানেজমেন্ট'),
                    subtitle: const Text('সকল ইউজার দেখুন এবং পরিচালনা করুন'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User Management শীঘ্রই আসছে')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.green),
                    title: const Text('প্রোডাক্ট ম্যানেজমেন্ট'),
                    subtitle: const Text('মাছ ও ঔষধ যোগ/সম্পাদনা করুন'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product Management এ যান মেনু থেকে')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.orange),
                    title: const Text('বিক্রয় রিপোর্ট'),
                    subtitle: const Text('সম্পূর্ণ বিক্রয় বিশ্লেষণ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Market Analytics এ যান মেনু থেকে')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'আপনি সকল সেটিংস এবং ডাটা পরিচালনা করতে পারবেন',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
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
}
