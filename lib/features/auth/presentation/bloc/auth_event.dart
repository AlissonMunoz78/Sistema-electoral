import '../../domain/entities/app_user.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String cedula;
  final String password;
  AuthLoginRequested(this.cedula, this.password);
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  AuthForgotPasswordRequested(this.email);
}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  AuthChangePasswordRequested(this.oldPassword, this.newPassword);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthRoleChanged extends AuthEvent {
  final AppUser user;
  AuthRoleChanged(this.user);
}

class AuthCrearUsuarioRequested extends AuthEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole rol;
  final String? recintoId;
  final String emailCoordinadorActual;
  final String passwordCoordinadorActual;

  AuthCrearUsuarioRequested({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.rol,
    this.recintoId,
    required this.emailCoordinadorActual,
    required this.passwordCoordinadorActual,
  });
}

class AuthCompleteRecoveryRequested extends AuthEvent {
  final String userId;
  final String secret;
  final String password;
  final String passwordAgain;
  AuthCompleteRecoveryRequested({
    required this.userId,
    required this.secret,
    required this.password,
    required this.passwordAgain,
  });
}

class AuthCompleteVerificationRequested extends AuthEvent {
  final String userId;
  final String secret;
  AuthCompleteVerificationRequested({
    required this.userId,
    required this.secret,
  });
}
