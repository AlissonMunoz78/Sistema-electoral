import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class CrearUsuarioUseCase {
  final AuthRepository repository;
  CrearUsuarioUseCase(this.repository);

  Future<({String authUserId, bool sessionRestored})> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole rol,
    String? recintoId,
    required String emailCoordinadorActual,
    required String passwordCoordinadorActual,
  }) {
    return repository.crearUsuario(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      email: email,
      rol: rol,
      recintoId: recintoId,
      emailCoordinadorActual: emailCoordinadorActual,
      passwordCoordinadorActual: passwordCoordinadorActual,
    );
  }
}
