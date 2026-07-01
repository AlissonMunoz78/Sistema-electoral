import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<AppUser> call(String newPassword, String oldPassword) {
    return repository.changePassword(newPassword, oldPassword);
  }
}
