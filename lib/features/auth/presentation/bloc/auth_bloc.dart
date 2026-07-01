import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.loginConCedula(event.cedula, event.password);
        if (user.mustChangePassword) {
          emit(AuthRequirePasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.sendPasswordReset(event.email);
        emit(AuthMessage('Se envió el correo de recuperación. Revisa tu bandeja de entrada.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.changePassword(event.newPassword, event.oldPassword);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      try {
        await repository.logout();
      } catch (_) {}
      emit(AuthInitial());
    });

    on<AuthCheckStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.getUsuarioActual();
        if (user != null) {
          if (user.mustChangePassword) {
            emit(AuthRequirePasswordChange(user));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          emit(AuthInitial());
        }
      } catch (_) {
        emit(AuthInitial());
      }
    });

    on<AuthCrearUsuarioRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await repository.crearUsuario(
          cedula: event.cedula,
          nombres: event.nombres,
          apellidos: event.apellidos,
          telefono: event.telefono,
          email: event.email,
          rol: event.rol,
          recintoId: event.recintoId,
          emailCoordinadorActual: event.emailCoordinadorActual,
          passwordCoordinadorActual: event.passwordCoordinadorActual,
        );
        emit(AuthUsuarioCreado(
          authUserId: result.authUserId,
          sessionRestored: result.sessionRestored,
        ));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRoleChanged>((event, emit) {});
  }
}