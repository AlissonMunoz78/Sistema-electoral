import '../../domain/entities/app_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

class AuthRequirePasswordChange extends AuthState {
  final AppUser user;
  AuthRequirePasswordChange(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthMessage extends AuthState {
  final String message;
  AuthMessage(this.message);
}

class AuthUsuarioCreado extends AuthState {
  final String? authUserId;
  final bool sessionRestored;
  AuthUsuarioCreado({this.authUserId, this.sessionRestored = true});
}