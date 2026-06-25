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
        final user = await repository.login(event.email, event.password);
        if (user.mustChangePassword) {
          emit(AuthRequirePasswordChange());
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
        final user = await repository.changePassword(event.password);
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
        // Intenta recuperar sesión activa
        emit(AuthInitial());
      } catch (_) {
        emit(AuthInitial());
      }
    });

    // Nota técnica: AuthRoleChanged no se usa actualmente porque los roles son fijos
    // tras la creación del usuario. Si en el futuro se requiere cambio de rol en
    // caliente, aquí se podría reemitir el estado con el nuevo AppUser.
    on<AuthRoleChanged>((event, emit) {});
  }
}
