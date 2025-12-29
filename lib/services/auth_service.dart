import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_id';
  static const String _usersBoxName = 'users';

  Box<Map> get usersBox => Hive.box<Map>(_usersBoxName);

  // Initialize with default admin user
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      await Hive.openBox<Map>(_usersBoxName);
    }

    // Create default admin if not exists
    if (usersBox.isEmpty) {
      final admin = UserModel(
        id: 'admin_001',
        name: 'Admin',
        email: 'admin@fishcare.com',
        phone: '+8801712345678',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      await usersBox.put(admin.id, admin.toJson());
      
      // Set admin as current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, admin.id);
    }
  }

  // Get current logged in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    
    if (userId == null) return null;
    
    final userData = usersBox.get(userId);
    if (userData == null) return null;
    
    return UserModel.fromJson(Map<String, dynamic>.from(userData));
  }

  // Login
  Future<bool> login(String email, String password) async {
    // Simple authentication (in production, use proper password hashing)
    final users = usersBox.values
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    
    final user = users.firstWhere(
      (u) => u.email == email && u.isActive,
      orElse: () => users.first,
    );
    
    if (user.id.isNotEmpty) {
      user.lastLogin = DateTime.now();
      await usersBox.put(user.id, user.toJson());
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, user.id);
      return true;
    }
    
    return false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Add new user (Admin only)
  Future<void> addUser(UserModel user) async {
    await usersBox.put(user.id, user.toJson());
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await usersBox.put(user.id, user.toJson());
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await usersBox.delete(userId);
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    return usersBox.values
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Switch user role (Admin only)
  Future<void> changeUserRole(String userId, UserRole newRole) async {
    final userData = usersBox.get(userId);
    if (userData != null) {
      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      user.role = newRole;
      await usersBox.put(userId, user.toJson());
    }
  }
}
