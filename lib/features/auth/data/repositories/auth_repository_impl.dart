import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TablesDB db;

  AuthRepositoryImpl(this.remoteDataSource, this.db);

  @override
  Future<AppUser> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    final prefs = await _getUserPrefs(user.$id);
    return prefs;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<AppUser> changePassword(String newPassword) async {
    final user = await remoteDataSource.changePassword(newPassword);
    final prefs = await _getUserPrefs(user.$id);
    await _updateUserPrefs(user.$id, {'primerLogin': 'false'});
    return UserModel(
      id: user.$id,
      email: user.email,
      role: prefs.role,
      mustChangePassword: false,
      recintoId: prefs.recintoId,
      mesaId: prefs.mesaId,
      nombre: prefs.nombre,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  Future<UserModel> _getUserPrefs(String userId) async {
    try {
      final doc = await db.getRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteUsersCollectionId,
        rowId: userId,
      );
      return UserModel.fromJson(doc.data);
    } catch (_) {
      return UserModel(id: userId, email: '', role: UserRole.observer, mustChangePassword: true);
    }
  }

  Future<void> _updateUserPrefs(String userId, Map<String, dynamic> data) async {
    try {
      await db.updateRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteUsersCollectionId,
        rowId: userId,
        data: data,
      );
    } catch (_) {
      try {
        await db.createRow(
          databaseId: appwriteDatabaseId,
          tableId: appwriteUsersCollectionId,
          rowId: userId,
          data: data,
        );
      } catch (_) {}
    }
  }
}
