import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.mustChangePassword,
    this.recintoId,
    this.mesaId,
    this.nombre,
  });

  final String? recintoId;
  final int? mesaId;
  final String? nombre;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['\$id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _parseRole(json['role'] as String? ?? 'observer'),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
      recintoId: json['recintoId'] as String?,
      mesaId: json['mesaId'] as int?,
      nombre: json['nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'role': role.name,
    'mustChangePassword': mustChangePassword,
    'recintoId': recintoId,
    'mesaId': mesaId,
    'nombre': nombre,
  };

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'coordinatorProvincial':
        return UserRole.coordinatorProvincial;
      case 'coordinatorRecinto':
        return UserRole.coordinatorRecinto;
      default:
        return UserRole.observer;
    }
  }
}
