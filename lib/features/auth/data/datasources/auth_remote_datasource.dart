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
    await _account.createEmailPasswordSession(email: email, password: password);
    return await _account.get();
  }

  Future<void> sendPasswordReset(String email) async {
    await _account.createRecovery(
      email: email,
      url: 'sistema-electoral://recovery',
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
  /// colección `users`). Devuelve el $id del usuario creado en Auth.
  ///
  /// IMPORTANTE: esto cierra la sesión actual del coordinador porque el SDK
  /// cliente de Appwrite no permite crear otro usuario sin afectar la
  /// sesión activa. El llamador debe volver a iniciar sesión con las
  /// credenciales del coordinador después de esta operación (ver
  /// AuthRepositoryImpl.crearUsuario, que orquesta esto).
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
    return nuevoUsuario.$id;
  }

  /// Envía el correo de verificación de cuenta. Debe llamarse estando
  /// autenticado como el usuario recién creado (por eso se invoca justo
  /// después de crearCuentaAuth, antes de restaurar la sesión original).
  Future<void> enviarVerificacionEmail() async {
    await _account.createVerification(
      url: 'sistema-electoral://verify',
    );
  }
}