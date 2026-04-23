import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles disponibles en la aplicación.
/// - admin: puede eliminar experiencias
/// - viewer: solo lectura + crear
enum UserRole { admin, viewer }

class UserModel {
  final String uid;
  final String name;
  final String company;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.company,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  /// Retorna las iniciales del nombre para el avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      company: data['company'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: (data['role'] as String?) == 'admin'
          ? UserRole.admin
          : UserRole.viewer,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'company': company,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'viewer',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
