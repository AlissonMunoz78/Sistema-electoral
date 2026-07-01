enum UserRole { coordinatorProvincial, coordinatorRecinto, observer }

class AppUser {
  final String id; // $id del documento en la colección users
  final String authUserId; // $id del usuario real en Appwrite Auth
  final String cedula; // usada como nombre de usuario para login
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole role;
  final bool mustChangePassword;
  final String? recintoId; // coordinador de recinto

  AppUser({
    required this.id,
    required this.authUserId,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.role,
    required this.mustChangePassword,
    this.recintoId,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();
}