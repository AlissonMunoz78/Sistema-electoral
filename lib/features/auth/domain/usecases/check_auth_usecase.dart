import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository repository;
  CheckAuthUseCase(this.repository);

  Future<AppUser?> call() {
    return repository.getUsuarioActual();
  }
}
