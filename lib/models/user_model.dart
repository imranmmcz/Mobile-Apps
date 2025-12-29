enum UserRole {
  admin,
  manager,
  customer,
  guest,
}

class UserModel {
  String id;
  String name;
  String email;
  String phone;
  UserRole role;
  DateTime createdAt;
  DateTime? lastLogin;
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  // Check permissions
  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isCustomer => role == UserRole.customer;
  bool get isGuest => role == UserRole.guest;
  
  bool get canEditProducts => isAdmin || isManager;
  bool get canEditSettings => isAdmin;
  bool get canViewAnalytics => isAdmin || isManager;
  bool get canManageUsers => isAdmin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.toString(),
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'isActive': isActive,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString() == json['role'],
          orElse: () => UserRole.guest,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLogin: json['lastLogin'] != null
            ? DateTime.parse(json['lastLogin'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  String get roleInBengali {
    switch (role) {
      case UserRole.admin:
        return 'অ্যাডমিন';
      case UserRole.manager:
        return 'ম্যানেজার';
      case UserRole.customer:
        return 'কাস্টমার';
      case UserRole.guest:
        return 'অতিথি';
    }
  }
}
