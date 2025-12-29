import 'package:flutter/material.dart';
import '../services/wordpress_service.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../models/fish_model.dart';
import '../models/medicine_model.dart';

/// WordPress Content Manager Screen
/// Centralized CMS for managing WordPress site from Flutter app
class WordPressContentManagerScreen extends StatefulWidget {
  const WordPressContentManagerScreen({Key? key}) : super(key: key);

  @override
  State<WordPressContentManagerScreen> createState() => _WordPressContentManagerScreenState();
}

class _WordPressContentManagerScreenState extends State<WordPressContentManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _wpService = WordPressService();
  final _dbService = DatabaseService();
  bool _isLoading = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeWordPress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeWordPress() async {
    setState(() => _isLoading = true);
    try {
      await _wpService.initialize();
      if (_wpService.isConfigured) {
        final isConnected = await _wpService.testConnection();
        setState(() {
          _connectionStatus = isConnected ? 'Connected' : 'Connection Failed';
        });
      } else {
        setState(() => _connectionStatus = 'Not Configured');
      }
    } catch (e) {
      setState(() => _connectionStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WordPress API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your WordPress API Key:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Get API Key from:\nWordPress Admin → FishCare API',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _wpService.setApiKey(controller.text);
                Navigator.pop(context);
                _initializeWordPress();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WordPress Content Manager'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Fish', icon: Icon(Icons.water_drop, size: 20)),
            Tab(text: 'Medicine', icon: Icon(Icons.medication, size: 20)),
            Tab(text: 'Posts', icon: Icon(Icons.article, size: 20)),
            Tab(text: 'Pages', icon: Icon(Icons.pages, size: 20)),
            Tab(text: 'Users', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'Sync', icon: Icon(Icons.sync, size: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FishManagementTab(wpService: _wpService),
                _MedicineManagementTab(wpService: _wpService),
                _PostsManagementTab(wpService: _wpService),
                _PagesManagementTab(wpService: _wpService),
                _UsersManagementTab(wpService: _wpService),
                _DataSyncTab(wpService: _wpService, dbService: _dbService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    if (_connectionStatus == null) return const SizedBox.shrink();
    
    final isConnected = _connectionStatus == 'Connected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'WordPress: $_connectionStatus',
            style: TextStyle(
              color: isConnected ? Colors.green.shade900 : Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (!isConnected)
            TextButton(
              onPressed: _showApiKeyDialog,
              child: const Text('Configure'),
            ),
        ],
      ),
    );
  }
}

// ==================== FISH MANAGEMENT TAB ====================

class _FishManagementTab extends StatefulWidget {
  final WordPressService wpService;
  const _FishManagementTab({required this.wpService});

  @override
  State<_FishManagementTab> createState() => _FishManagementTabState();
}

class _FishManagementTabState extends State<_FishManagementTab> {
  List<FishModel> _fishList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFish();
  }

  Future<void> _loadFish() async {
    setState(() => _isLoading = true);
    try {
      final fish = await widget.wpService.getFishProducts();
      setState(() => _fishList = fish);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFish(FishModel fish) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fish'),
        content: Text('Delete ${fish.nameBengali}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final wpId = int.tryParse(fish.id);
      if (wpId != null) {
        final success = await widget.wpService.deleteFishProduct(wpId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fish deleted from WordPress')),
          );
          _loadFish();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_fishList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No fish products found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFish,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFish,
      child: ListView.builder(
        itemCount: _fishList.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final fish = _fishList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.water_drop, color: AppTheme.primaryColor),
              ),
              title: Text(
                fish.nameBengali,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fish.nameEnglish),
                  const SizedBox(height: 4),
                  Text('Category: ${fish.category}'),
                  Text('Price: ৳${fish.pricePerMana.toStringAsFixed(0)}/kg'),
                  Text('Stock: ${fish.stockKg.toStringAsFixed(1)} kg'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteFish(fish);
                  }
                  // TODO: Implement edit
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== MEDICINE MANAGEMENT TAB ====================

class _MedicineManagementTab extends StatefulWidget {
  final WordPressService wpService;
  const _MedicineManagementTab({required this.wpService});

  @override
  State<_MedicineManagementTab> createState() => _MedicineManagementTabState();
}

class _MedicineManagementTabState extends State<_MedicineManagementTab> {
  List<MedicineModel> _medicineList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final medicines = await widget.wpService.getMedicines();
      setState(() => _medicineList = medicines);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_medicineList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No medicines found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMedicines,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedicines,
      child: ListView.builder(
        itemCount: _medicineList.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final medicine = _medicineList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.medication, color: Colors.green),
              ),
              title: Text(
                medicine.nameBengali,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.nameEnglish),
                  Text('Category: ${medicine.category}'),
                  Text('Price: ৳${medicine.pricePerUnit.toStringAsFixed(0)}'),
                  Text('Stock: ${medicine.stockQuantity}'),
                ],
              ),
              trailing: const Icon(Icons.edit),
            ),
          );
        },
      ),
    );
  }
}

// ==================== POSTS MANAGEMENT TAB ====================

class _PostsManagementTab extends StatefulWidget {
  final WordPressService wpService;
  const _PostsManagementTab({required this.wpService});

  @override
  State<_PostsManagementTab> createState() => _PostsManagementTabState();
}

class _PostsManagementTabState extends State<_PostsManagementTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await widget.wpService.getPosts();
      setState(() => _posts = posts);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewPost() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Post Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Post Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final success = await widget.wpService.createPost(
                  title: titleController.text,
                  content: contentController.text,
                );
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post created successfully!')),
                  );
                  _loadPosts();
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('No posts found'))
              : ListView.builder(
                  itemCount: _posts.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.article),
                        title: Text(
                          post['title'] ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          post['date'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewPost,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}

// ==================== PAGES MANAGEMENT TAB ====================

class _PagesManagementTab extends StatefulWidget {
  final WordPressService wpService;
  const _PagesManagementTab({required this.wpService});

  @override
  State<_PagesManagementTab> createState() => _PagesManagementTabState();
}

class _PagesManagementTabState extends State<_PagesManagementTab> {
  List<Map<String, dynamic>> _pages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() => _isLoading = true);
    try {
      final pages = await widget.wpService.getPages();
      setState(() => _pages = pages);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _pages.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final page = _pages[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.pages),
            title: Text(page['title'] ?? 'Untitled'),
            subtitle: Text(page['slug'] ?? ''),
          ),
        );
      },
    );
  }
}

// ==================== USERS MANAGEMENT TAB ====================

class _UsersManagementTab extends StatefulWidget {
  final WordPressService wpService;
  const _UsersManagementTab({required this.wpService});

  @override
  State<_UsersManagementTab> createState() => _UsersManagementTabState();
}

class _UsersManagementTabState extends State<_UsersManagementTab> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await widget.wpService.getUsers();
      setState(() => _users = users);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user['username']?[0]?.toUpperCase() ?? 'U'),
            ),
            title: Text(user['display_name'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                Text('Role: ${user['role'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== DATA SYNC TAB ====================

class _DataSyncTab extends StatefulWidget {
  final WordPressService wpService;
  final DatabaseService dbService;
  const _DataSyncTab({required this.wpService, required this.dbService});

  @override
  State<_DataSyncTab> createState() => _DataSyncTabState();
}

class _DataSyncTabState extends State<_DataSyncTab> {
  bool _isSyncing = false;
  String _syncStatus = 'Ready to sync';

  Future<void> _syncAllData() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing fish data...';
    });

    try {
      // Sync fish data
      final localFish = await widget.dbService.getAllFish();
      await widget.wpService.syncFishDataToWordPress(localFish);
      
      setState(() => _syncStatus = 'Syncing medicine data...');
      
      // Sync medicine data
      final localMedicines = await widget.dbService.getAllMedicines();
      await widget.wpService.syncMedicineDataToWordPress(localMedicines);
      
      setState(() => _syncStatus = 'Sync completed successfully!');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data synced to WordPress!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _syncStatus = 'Sync failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text(
              'Data Synchronization',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _syncStatus,
              style: TextStyle(
                fontSize: 16,
                color: _isSyncing ? Colors.orange : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_isSyncing)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _syncAllData,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Sync All Data to WordPress'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Information:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Local fish data → WordPress'),
                    const Text('• Local medicine data → WordPress'),
                    const Text('• Creates or updates records'),
                    const Text('• Real-time website updates'),
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
