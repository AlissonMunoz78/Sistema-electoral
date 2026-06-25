import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../../../core/appwrite_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource();

  Account get account => Account(client);

  Future<User> login(String email, String password) async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (_) {
      // No había sesión activa, continuar normalmente
    }
    await account.createEmailPasswordSession(email: email, password: password);
    return await account.get();
  }

  Future<void> sendPasswordReset(String email) async {
    await account.createRecovery(email: email, url: 'sistema-electoral://recovery');
  }

  Future<User> changePassword(String password) async {
    return await account.updatePassword(
      password: password,
      oldPassword: 'Ecuador2026',
    );
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (_) {
      await account.deleteSessions();
    }
  }

  Future<User> getCurrentUser() async {
    return await account.get();
  }
}
