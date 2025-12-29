import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fish_model.dart';
import '../models/medicine_model.dart';

/// WordPress REST API Integration Service
/// Connects Flutter FishCare app with WordPress site (fishcare.com.bd)
class WordPressService {
  // WordPress API Base URLs
  static const String _baseUrl = 'https://fishcare.com.bd/wp-json';
  static const String _apiVersion = 'fishcare/v1';
  static const String _apiBaseUrl = '$_baseUrl/$_apiVersion';
  
  // API Configuration
  String? _apiKey;
  String? _userRole;
  
  // Singleton pattern
  static final WordPressService _instance = WordPressService._internal();
  factory WordPressService() => _instance;
  WordPressService._internal();
  
  /// Initialize service with API credentials
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('wordpress_api_key');
    _userRole = prefs.getString('user_role') ?? 'customer';
  }
  
  /// Set API credentials
  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wordpress_api_key', apiKey);
  }
  
  /// Set user role
  Future<void> setUserRole(String role) async {
    _userRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }
  
  /// Get common headers for API requests
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_apiKey != null) {
      headers['X-API-Key'] = _apiKey!;
    }
    
    if (requiresAuth && _userRole != null) {
      headers['X-User-Role'] = _userRole!;
    }
    
    return headers;
  }
  
  /// Check if API is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  
  // ==================== FISH PRODUCTS CRUD ====================
  
  /// Get all fish products from WordPress
  Future<List<FishModel>> getFishProducts({String? category}) async {
    try {
      var url = '$_apiBaseUrl/fish-products';
      if (category != null && category != 'সব') {
        url += '?category=$category';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _wpFishToFishModel(json)).toList();
      } else {
        throw Exception('Failed to load fish products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fish products: $e');
      return [];
    }
  }
  
  /// Get single fish product by ID
  Future<FishModel?> getFishProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/fish-products/$id'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _wpFishToFishModel(data);
      }
      return null;
    } catch (e) {
      print('Error fetching fish product: $e');
      return null;
    }
  }
  
  /// Create new fish product in WordPress
  Future<FishModel?> createFishProduct(FishModel fish) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/fish-products'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(_fishModelToWp(fish)),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return _wpFishToFishModel(data);
      } else {
        throw Exception('Failed to create fish product: ${response.body}');
      }
    } catch (e) {
      print('Error creating fish product: $e');
      return null;
    }
  }
  
  /// Update fish product in WordPress
  Future<FishModel?> updateFishProduct(int id, FishModel fish) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/fish-products/$id'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(_fishModelToWp(fish)),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _wpFishToFishModel(data);
      }
      return null;
    } catch (e) {
      print('Error updating fish product: $e');
      return null;
    }
  }
  
  /// Delete fish product from WordPress
  Future<bool> deleteFishProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/fish-products/$id'),
        headers: _getHeaders(requiresAuth: true),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting fish product: $e');
      return false;
    }
  }
  
  // ==================== MEDICINE CRUD ====================
  
  /// Get all medicines from WordPress
  Future<List<MedicineModel>> getMedicines({String? category}) async {
    try {
      var url = '$_apiBaseUrl/medicines';
      if (category != null && category != 'সব') {
        url += '?category=$category';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _wpMedicineToMedicineModel(json)).toList();
      } else {
        throw Exception('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }
  
  /// Get single medicine by ID
  Future<MedicineModel?> getMedicine(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/medicines/$id'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _wpMedicineToMedicineModel(data);
      }
      return null;
    } catch (e) {
      print('Error fetching medicine: $e');
      return null;
    }
  }
  
  /// Create new medicine in WordPress
  Future<MedicineModel?> createMedicine(MedicineModel medicine) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/medicines'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(_medicineModelToWp(medicine)),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return _wpMedicineToMedicineModel(data);
      } else {
        throw Exception('Failed to create medicine: ${response.body}');
      }
    } catch (e) {
      print('Error creating medicine: $e');
      return null;
    }
  }
  
  /// Update medicine in WordPress
  Future<MedicineModel?> updateMedicine(int id, MedicineModel medicine) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/medicines/$id'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(_medicineModelToWp(medicine)),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _wpMedicineToMedicineModel(data);
      }
      return null;
    } catch (e) {
      print('Error updating medicine: $e');
      return null;
    }
  }
  
  /// Delete medicine from WordPress
  Future<bool> deleteMedicine(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/medicines/$id'),
        headers: _getHeaders(requiresAuth: true),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting medicine: $e');
      return false;
    }
  }
  
  // ==================== MARKET PRICES ====================
  
  /// Get market prices from WordPress
  Future<List<Map<String, dynamic>>> getMarketPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/market-prices'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching market prices: $e');
      return [];
    }
  }
  
  /// Create market price in WordPress
  Future<bool> createMarketPrice({
    required String productName,
    required double price,
    required String unit,
    required String market,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/market-prices'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({
          'product_name': productName,
          'price': price,
          'unit': unit,
          'market': market,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating market price: $e');
      return false;
    }
  }
  
  // ==================== POSTS & PAGES ====================
  
  /// Get WordPress posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/posts'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }
  
  /// Create WordPress post
  Future<bool> createPost({
    required String title,
    required String content,
    String? excerpt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/posts'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({
          'title': title,
          'content': content,
          'excerpt': excerpt ?? '',
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }
  
  /// Get WordPress pages
  Future<List<Map<String, dynamic>>> getPages() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/pages'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching pages: $e');
      return [];
    }
  }
  
  /// Create WordPress page
  Future<bool> createPage({
    required String title,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/pages'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating page: $e');
      return false;
    }
  }
  
  // ==================== USERS MANAGEMENT ====================
  
  /// Get WordPress users (Admin only)
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/users'),
        headers: _getHeaders(requiresAuth: true),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
  
  /// Create WordPress user (Admin only)
  Future<bool> createUser({
    required String username,
    required String email,
    required String password,
    String role = 'subscriber',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }
  
  // ==================== SETTINGS ====================
  
  /// Get WordPress site settings
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/settings'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching settings: $e');
      return null;
    }
  }
  
  /// Update WordPress site settings (Admin only)
  Future<bool> updateSettings({
    String? siteTitle,
    String? siteDescription,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (siteTitle != null) body['site_title'] = siteTitle;
      if (siteDescription != null) body['site_description'] = siteDescription;
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/settings'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }
  
  // ==================== TEST CONNECTION ====================
  
  /// Test WordPress API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/fish-products'),
        headers: _getHeaders(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
  
  // ==================== DATA SYNC ====================
  
  /// Sync local fish data to WordPress
  Future<void> syncFishDataToWordPress(List<FishModel> localFish) async {
    for (final fish in localFish) {
      try {
        // Check if fish exists in WordPress (by name matching)
        final wpFish = await getFishProducts();
        final existing = wpFish.firstWhere(
          (f) => f.nameBengali == fish.nameBengali,
          orElse: () => FishModel(
            id: '',
            nameBengali: '',
            nameEnglish: '',
            pricePerMana: 0,
            stockKg: 0,
            category: '',
          ),
        );
        
        if (existing.id.isEmpty) {
          // Create new
          await createFishProduct(fish);
        } else {
          // Update existing
          final wpId = int.tryParse(existing.id);
          if (wpId != null) {
            await updateFishProduct(wpId, fish);
          }
        }
      } catch (e) {
        print('Error syncing fish ${fish.nameBengali}: $e');
      }
    }
  }
  
  /// Sync local medicine data to WordPress
  Future<void> syncMedicineDataToWordPress(List<MedicineModel> localMedicines) async {
    for (final medicine in localMedicines) {
      try {
        final wpMedicines = await getMedicines();
        final existing = wpMedicines.firstWhere(
          (m) => m.nameBengali == medicine.nameBengali,
          orElse: () => MedicineModel(
            id: '',
            nameBengali: '',
            nameEnglish: '',
            category: '',
            pricePerUnit: 0,
            stockQuantity: 0,
            dosageInfo: '',
            manufacturer: '',
          ),
        );
        
        if (existing.id.isEmpty) {
          await createMedicine(medicine);
        } else {
          final wpId = int.tryParse(existing.id);
          if (wpId != null) {
            await updateMedicine(wpId, medicine);
          }
        }
      } catch (e) {
        print('Error syncing medicine ${medicine.nameBengali}: $e');
      }
    }
  }
  
  // ==================== DATA CONVERTERS ====================
  
  /// Convert WordPress fish data to FishModel
  FishModel _wpFishToFishModel(Map<String, dynamic> json) {
    return FishModel(
      id: json['id']?.toString() ?? '',
      nameBengali: json['name_bengali'] ?? '',
      nameEnglish: json['name_english'] ?? '',
      pricePerMana: (json['price_per_kg'] ?? 0).toDouble(),
      stockKg: (json['stock_kg'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      lastUpdated: json['last_updated'] != null 
          ? DateTime.tryParse(json['last_updated'])
          : null,
    );
  }
  
  /// Convert FishModel to WordPress format
  Map<String, dynamic> _fishModelToWp(FishModel fish) {
    return {
      'name_bengali': fish.nameBengali,
      'name_english': fish.nameEnglish,
      'category': fish.category,
      'price_per_kg': fish.pricePerMana,
      'stock_kg': fish.stockKg,
      'description': '',
      'image_url': '',
    };
  }
  
  /// Convert WordPress medicine data to MedicineModel
  MedicineModel _wpMedicineToMedicineModel(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id']?.toString() ?? '',
      nameBengali: json['name_bengali'] ?? '',
      nameEnglish: json['name_english'] ?? '',
      category: json['category'] ?? '',
      pricePerUnit: (json['price_per_unit'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      dosageInfo: json['dosage_info'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      expiryDate: json['expiry_date'] != null 
          ? DateTime.tryParse(json['expiry_date'])
          : null,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.tryParse(json['last_updated'])
          : null,
    );
  }
  
  /// Convert MedicineModel to WordPress format
  Map<String, dynamic> _medicineModelToWp(MedicineModel medicine) {
    return {
      'name_bengali': medicine.nameBengali,
      'name_english': medicine.nameEnglish,
      'category': medicine.category,
      'price_per_unit': medicine.pricePerUnit,
      'stock_quantity': medicine.stockQuantity,
      'dosage_info': medicine.dosageInfo,
      'manufacturer': medicine.manufacturer,
      'expiry_date': medicine.expiryDate?.toIso8601String() ?? '',
    };
  }
}
