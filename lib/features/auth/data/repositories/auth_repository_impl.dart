import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

const String _passwordInicial = 'Ecuador2026';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Databases db;

  AuthRepositoryImpl(this.remoteDataSource, this.db);

  @override
  Future<AppUser> loginConCedula(String cedula, String password) async {
    final email = await remoteDataSource.obtenerEmailPorCedula(cedula);
    final authUser = await remoteDataSource.login(email, password);
    return _obtenerPerfilPorAuthId(authUser.$id);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<AppUser> changePassword(String newPassword, String oldPassword) async {
    final authUser = await remoteDataSource.changePassword(newPassword, oldPassword);
    final perfilActual = await _obtenerPerfilPorAuthId(authUser.$id);
    await db.updateDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteUsersCollectionId,
      documentId: perfilActual.id,
      data: {'primerLogin': false},
    );
    return UserModel(
      id: perfilActual.id,
      authUserId: perfilActual.authUserId,
      cedula: perfilActual.cedula,
      nombres: perfilActual.nombres,
      apellidos: perfilActual.apellidos,
      telefono: perfilActual.telefono,
      email: perfilActual.email,
      role: perfilActual.role,
      mustChangePassword: false,
      recintoId: perfilActual.recintoId,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<AppUser?> getUsuarioActual() async {
    try {
      final authUser = await remoteDataSource.getCurrentUser();
      return await _obtenerPerfilPorAuthId(authUser.$id);
    } catch (_) {
      return null;
    }
  }

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
  }) async {
    // 1) Crear la cuenta real en Appwrite Auth con password inicial fija.
    final authUserId = await remoteDataSource.crearCuentaAuth(
      email: email,
      password: _passwordInicial,
      nombreCompleto: '$nombres $apellidos'.trim(),
    );

    // 2) Mientras la sesión activa es la del usuario recién creado, se envía
    //    el correo de verificación de cuenta.
    try {
      await remoteDataSource.enviarVerificacionEmail();
    } catch (_) {
      // Si falla el envío de verificación no se bloquea la creación del
      // usuario; se podría reintentar manualmente desde el panel.
    }

    // 3) Crear el documento de perfil en la colección `users`.
    await db.createDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteUsersCollectionId,
      documentId: ID.unique(),
      data: {
        'authUserId': authUserId,
        'cedula': cedula,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': email,
        'rol': rol.name,
        'primerLogin': true,
        'recintoId': recintoId ?? '',
      },
      permissions: [
        Permission.read(Role.any()),
        Permission.write(Role.any()),
      ],
    );

    // 4) Restaurar la sesión del coordinador que estaba autenticado antes de
    //    crear este usuario nuevo (ver nota en AuthRemoteDataSource).
    //    Se intenta varias veces con pausa porque Appwrite Cloud puede tardar
    //    en propagar la creación del usuario anterior.
    bool restored = false;
    for (int i = 0; i < 3; i++) {
      try {
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        await remoteDataSource.login(emailCoordinadorActual, passwordCoordinadorActual);
        restored = true;
        break;
      } catch (_) {
        // Reintentar
      }
    }
    if (!restored) {
      // No se pudo restaurar la sesión; forzamos logout para que el usuario
      // inicie sesión de nuevo manualmente. La creación del usuario ya se
      // completó exitosamente.
      try {
        await remoteDataSource.logout();
      } catch (_) {}
    }
    return (authUserId: authUserId, sessionRestored: restored);
  }

  @override
  Future<void> completePasswordReset({
    required String userId,
    required String secret,
    required String password,
  }) async {
    await remoteDataSource.completePasswordReset(
      userId: userId,
      secret: secret,
      password: password,
    );
  }

  @override
  Future<void> completeEmailVerification({
    required String userId,
    required String secret,
  }) async {
    await remoteDataSource.completeEmailVerification(
      userId: userId,
      secret: secret,
    );
  }

  Future<UserModel> _obtenerPerfilPorAuthId(String authUserId) async {
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteUsersCollectionId,
      queries: [Query.equal('authUserId', authUserId)],
    );
    if (result.documents.isEmpty) {
      throw Exception('No se encontró un perfil asociado a esta cuenta.');
    }
    final row = result.documents.first;
    return UserModel.fromJson(row.data, docId: row.$id);
  }
}