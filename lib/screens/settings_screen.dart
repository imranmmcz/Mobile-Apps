import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _websiteController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();
  
  bool _autoBackup = false;
  bool _notifications = true;
  bool _darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _websiteController.text = prefs.getString('website_url') ?? '';
      _whatsappController.text = prefs.getString('whatsapp') ?? '+8801712345678';
      _facebookController.text = prefs.getString('facebook') ?? '';
      _youtubeController.text = prefs.getString('youtube') ?? '';
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('website_url', _websiteController.text);
    await prefs.setString('whatsapp', _whatsappController.text);
    await prefs.setString('facebook', _facebookController.text);
    await prefs.setString('youtube', _youtubeController.text);
    await prefs.setBool('auto_backup', _autoBackup);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('dark_mode', _darkMode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সেটিংস সফলভাবে সংরক্ষিত হয়েছে'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংক খুলতে ব্যর্থ')),
        );
      }
    }
  }

  void _connectGoogleDrive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Drive Backup'),
        content: const Text('Google Drive সংযোগ শীঘ্রই আসছে...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _testWebsiteConnection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('সংযোগ সফল'),
          ],
        ),
        content: Text('${_websiteController.text} এর সাথে সংযোগ স্থাপিত হয়েছে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Website Connection Section
            _buildSectionHeader('ওয়েবসাইট সংযোগ', Icons.language),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _websiteController,
                      decoration: InputDecoration(
                        labelText: 'ওয়েবসাইট URL',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'https://example.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _testWebsiteConnection,
                        icon: const Icon(Icons.sync),
                        label: const Text('সংযোগ পরীক্ষা করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ওয়েবসাইট থেকে পণ্য তথ্য সরাসরি অ্যাপে প্রদর্শিত হবে',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Social Media Section
            _buildSectionHeader('সোশ্যাল মিডিয়া', Icons.share),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _whatsappController,
                            decoration: InputDecoration(
                              labelText: 'WhatsApp নম্বর',
                              prefixIcon: Icon(Icons.phone, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: '+8801712345678',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_whatsappController.text.isNotEmpty) {
                              _launchURL('https://wa.me/${_whatsappController.text.replaceAll('+', '')}');
                            }
                          },
                          icon: Icon(Icons.open_in_new, color: Colors.green[700]),
                          tooltip: 'WhatsApp খুলুন',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _facebookController,
                            decoration: InputDecoration(
                              labelText: 'Facebook Page URL',
                              prefixIcon: Icon(Icons.facebook, color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'https://facebook.com/yourpage',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_facebookController.text.isNotEmpty) {
                              _launchURL(_facebookController.text);
                            }
                          },
                          icon: Icon(Icons.open_in_new, color: Colors.blue[800]),
                          tooltip: 'Facebook খুলুন',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _youtubeController,
                            decoration: InputDecoration(
                              labelText: 'YouTube Channel URL',
                              prefixIcon: Icon(Icons.video_library, color: Colors.red[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'https://youtube.com/@yourchannel',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_youtubeController.text.isNotEmpty) {
                              _launchURL(_youtubeController.text);
                            }
                          },
                          icon: Icon(Icons.open_in_new, color: Colors.red[700]),
                          tooltip: 'YouTube খুলুন',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Backup Section
            _buildSectionHeader('ব্যাকআপ সেটিংস', Icons.backup),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('স্বয়ংক্রিয় ব্যাকআপ'),
                    subtitle: const Text('দৈনিক স্বয়ংক্রিয় ব্যাকআপ সক্রিয় করুন'),
                    value: _autoBackup,
                    onChanged: (value) {
                      setState(() {
                        _autoBackup = value;
                      });
                    },
                    secondary: const Icon(Icons.schedule),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Image.network(
                      'https://www.google.com/drive/static/images/drive/logo_googledrive_48dp.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud, size: 40);
                      },
                    ),
                    title: const Text('Google Drive সংযোগ'),
                    subtitle: const Text('Google Drive এ ব্যাকআপ সংরক্ষণ করুন'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _connectGoogleDrive,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.file_download),
                    title: const Text('ম্যানুয়াল ব্যাকআপ'),
                    subtitle: const Text('এখনই ব্যাকআপ তৈরি করুন'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ব্যাকআপ তৈরি হচ্ছে...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App Settings Section
            _buildSectionHeader('অ্যাপ সেটিংস', Icons.settings),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('নোটিফিকেশন'),
                    subtitle: const Text('পুশ নোটিফিকেশন সক্রিয় করুন'),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('ডার্ক মোড'),
                    subtitle: const Text('গাঢ় থিম সক্রিয় করুন'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('ভাষা'),
                    subtitle: const Text('বাংলা'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Section
            _buildSectionHeader('অ্যাপ সম্পর্কে', Icons.info),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('লাইসেন্স'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('গোপনীয়তা নীতি'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
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
