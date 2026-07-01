import '../repositories/auth_repository.dart';

class CompleteRecoveryUseCase {
  final AuthRepository repository;
  CompleteRecoveryUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String secret,
    required String password,
    required String passwordAgain,
  }) {
    return repository.completePasswordReset(
      userId: userId,
      secret: secret,
      password: password,
    );
  }
}
