import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> loginConCedula(String cedula, String password);
  Future<void> sendPasswordReset(String email);
  Future<AppUser> changePassword(String newPassword, String oldPassword);
  Future<void> logout();
  Future<AppUser?> getUsuarioActual();

  /// Crea un nuevo usuario (coordinador de recinto o veedor) y restaura la
  /// sesión del coordinador que lo está creando.
  /// Devuelve el authUserId y si se logró restaurar la sesión.
  Future<({String authUserId, bool sessionRestored})> crearUsuario({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole rol,
    String? recintoId,
    required String emailCoordinadorActual,
    required String passwordCoordinadorActual,
  });
}