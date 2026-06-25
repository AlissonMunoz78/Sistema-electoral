import '../../domain/entities/app_user.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  AuthForgotPasswordRequested(this.email);
}

class AuthChangePasswordRequested extends AuthEvent {
  final String password;
  AuthChangePasswordRequested(this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthRoleChanged extends AuthEvent {
  final UserRole role;
  AuthRoleChanged(this.role);
}
