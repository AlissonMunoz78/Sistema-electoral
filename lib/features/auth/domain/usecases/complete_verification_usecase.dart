import '../repositories/auth_repository.dart';

class CompleteVerificationUseCase {
  final AuthRepository repository;
  CompleteVerificationUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String secret,
  }) {
    return repository.completeEmailVerification(
      userId: userId,
      secret: secret,
    );
  }
}
