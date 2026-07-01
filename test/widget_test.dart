import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_electoral/main.dart';
import 'package:sistema_electoral/features/auth/domain/entities/app_user.dart';
import 'package:sistema_electoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:sistema_electoral/features/actas/domain/entities/acta.dart';
import 'package:sistema_electoral/features/actas/domain/repositories/acta_repository.dart';
import 'package:sistema_electoral/features/recintos/domain/entities/recinto.dart';
import 'package:sistema_electoral/features/recintos/domain/repositories/recinto_repository.dart';

// Usuario de prueba que cumple todos los campos requeridos por AppUser
AppUser _fakeUser() => AppUser(
      id: 'test-id',
      authUserId: 'auth-test-id',
      cedula: '1713175071',
      nombres: 'Test',
      apellidos: 'Usuario',
      telefono: '0991234567',
      email: 'test@test.com',
      role: UserRole.observer,
      mustChangePassword: false,
    );

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser> loginConCedula(String cedula, String password) async =>
      _fakeUser();

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<AppUser> changePassword(
          String newPassword, String oldPassword) async =>
      _fakeUser();

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> getUsuarioActual() async => null;

  @override
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
  }) async => (authUserId: '', sessionRestored: true);
}

class FakeActaRepository implements ActaRepository {
  @override
  Future<void> crearActa(Acta acta) async {}

  @override
  Future<List<Acta>> obtenerActas({String? userId}) async => [];

  @override
  Future<void> actualizarActa(String id, Acta acta) async {}
}

class FakeRecintoRepository implements RecintoRepository {
  @override
  Future<void> crearRecinto(Recinto recinto) async {}

  @override
  Future<List<Recinto>> obtenerRecintos() async => [];

  @override
  Future<Recinto?> obtenerRecinto(String id) async => null;

  @override
  Future<void> asignarCoordinador(String recintoId, String userId) async {}
}

void main() {
  testWidgets('Login page muestra campos de inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authRepository: FakeAuthRepository(),
      actaRepository: FakeActaRepository(),
      recintoRepository: FakeRecintoRepository(),
    ));

    expect(find.text('Sistema Electoral'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Cédula de identidad'), findsOneWidget);
  });
}