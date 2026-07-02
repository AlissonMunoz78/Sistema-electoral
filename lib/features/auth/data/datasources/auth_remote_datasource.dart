import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../../../core/appwrite_client.dart';

// Limitación conocida: la creación de usuarios (coordinadores de recinto y
// veedores) requiere normalmente la Appwrite Admin API (server-side, con
// API Key), que no debería invocarse desde el cliente Flutter en producción
// por motivos de seguridad. Para esta entrega académica se usa
// `account.create()` que SÍ es válido desde el cliente, pero tiene una
// limitación: la sesión activa del creador (coordinador) se pierde al crear
// la cuenta del nuevo usuario, porque el SDK cliente de Appwrite cambia de
// contexto de sesión. Por eso, inmediatamente después de crear el usuario
// nuevo se debe restaurar la sesión original del coordinador (ver
// AuthRepositoryImpl.crearUsuario). En un entorno productivo real esto se
// resolvería con una Appwrite Function (server-side) que use la Admin API
// con API Key, sin tocar la sesión del cliente.
class AuthRemoteDataSource {
  AuthRemoteDataSource();

  Account get _account => Account(client);

  /// Login por cédula: primero se busca el documento de usuario por cédula
  /// para obtener el email real asociado, luego se autentica contra
  /// Appwrite Auth con ese email + password.
  Future<String> obtenerEmailPorCedula(String cedula) async {
    final result = await databases.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteUsersCollectionId,
      queries: [Query.equal('cedula', cedula)],
    );
    if (result.documents.isEmpty) {
      throw Exception('No existe una cuenta registrada con esa cédula.');
    }
    final email = result.documents.first.data['correo'] as String?;
    if (email == null || email.isEmpty) {
      throw Exception('La cuenta no tiene un correo asociado. Contacte a su coordinador.');
    }
    return email;
  }

  Future<User> login(String email, String password) async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}

    await _account.createEmailPasswordSession(email: email, password: password);
    final user = await _account.get();
    if (!user.emailVerification) {
      await _account.deleteSession(sessionId: 'current');
      throw Exception('Debes verificar tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada.');
    }
    return user;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'sistema-electoral://recovery',
      );
    } on AppwriteException catch (e) {
      if (e.message?.contains('register your new client') == true ||
          e.message?.contains('platform') == true) {
        throw Exception(
          'Error de configuración: debes registrar "sistema-electoral://" '
          'como plataforma Web en Appwrite Console (Settings → Platforms). '
          'Contacta al administrador.',
        );
      }
      rethrow;
    }
  }

  Future<void> completePasswordReset({
    required String userId,
    required String secret,
    required String password,
  }) async {
    await _account.updateRecovery(
      userId: userId,
      secret: secret,
      password: password,
    );
  }

  Future<void> completeEmailVerification({
    required String userId,
    required String secret,
  }) async {
    await _account.updateEmailVerification(
      userId: userId,
      secret: secret,
    );
  }

  Future<User> changePassword(String newPassword, String oldPassword) async {
    return await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      await _account.deleteSessions();
    }
  }

  Future<User> getCurrentUser() async {
    return await _account.get();
  }

  /// Crea la cuenta real en Appwrite Auth (no solo el documento de la
  /// colección `users`) e inicia sesión como el usuario recién creado.
  /// Devuelve el $id del usuario creado en Auth.
  ///
  /// IMPORTANTE: `account.create()` NO inicia sesión automáticamente.
  /// Se inicia sesión explícitamente aquí para que el llamador pueda
  /// ejecutar `enviarVerificacionEmail()` (que opera sobre la sesión
  /// activa) y el correo llegue al usuario nuevo, no al coordinador
  /// original. El llamador debe restaurar la sesión del coordinador
  /// después (ver `AuthRepositoryImpl.crearUsuario`).
  Future<String> crearCuentaAuth({
    required String email,
    required String password,
    required String nombreCompleto,
  }) async {
    final nuevoUsuario = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: nombreCompleto,
    );

    // Appwrite no permite dos sesiones activas en el mismo cliente.
    // Cerramos la sesión del coordinador para poder loguearnos como el
    // usuario recién creado y enviarle SU propio correo de verificación.
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // No había sesión activa o ya expiró; no es crítico.
    }

    await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    return nuevoUsuario.$id;
  }

  /// Envía el correo de verificación de cuenta. Debe llamarse estando
  /// autenticado como el usuario recién creado (por eso se invoca justo
  /// después de crearCuentaAuth, antes de restaurar la sesión original).
  Future<void> enviarVerificacionEmail() async {
    try {
      await _account.createEmailVerification(
        url: 'sistema-electoral://verify',
      );
    } on AppwriteException catch (e) {
      if (e.message?.contains('register your new client') == true ||
          e.message?.contains('platform') == true) {
        throw Exception(
          'Error de configuración: debes registrar "sistema-electoral://" '
          'como plataforma Web en Appwrite Console (Settings → Platforms). '
          'Además, configura SMTP en Appwrite para que los correos se puedan enviar.',
        );
      }
      rethrow;
    }
  }
}