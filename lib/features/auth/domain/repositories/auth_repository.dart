import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<AppUser> changePassword(String newPassword);
  Future<void> logout();
}
