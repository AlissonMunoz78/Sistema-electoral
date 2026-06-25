import 'package:appwrite/appwrite.dart' as appwrite;

import '../../../../core/appwrite_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final appwrite.Databases db;

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
    await _updateUserPrefs(user.$id, {'mustChangePassword': false});
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
      final doc = await db.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        documentId: userId,
      );
      return UserModel.fromJson(doc.data);
    } catch (_) {
      return UserModel(id: userId, email: '', role: UserRole.observer, mustChangePassword: true);
    }
  }

  Future<void> _updateUserPrefs(String userId, Map<String, dynamic> data) async {
    try {
      await db.updateDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (_) {}
  }
}
