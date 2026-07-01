import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({
    required super.id,
    required super.authUserId,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.email,
    required super.role,
    required super.mustChangePassword,
    super.recintoId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return UserModel(
      id: docId ?? json['\$id'] as String? ?? '',
      authUserId: json['authUserId'] as String? ?? json['\$id'] as String? ?? '',
      cedula: json['cedula'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['correo'] as String? ?? json['email'] as String? ?? '',
      role: _parseRole(json['rol'] as String? ?? 'observer'),
      mustChangePassword: _parseBool(json['primerLogin'] ?? json['mustChangePassword']),
      recintoId: json['recintoId'] as String? ?? json['recintold'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'authUserId': authUserId,
    'cedula': cedula,
    'nombres': nombres,
    'apellidos': apellidos,
    'telefono': telefono,
    'correo': email,
    'rol': role.name,
    'primerLogin': mustChangePassword,
    'recintoId': recintoId,
  };

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true; // por defecto, todo usuario nuevo debe cambiar password
  }

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