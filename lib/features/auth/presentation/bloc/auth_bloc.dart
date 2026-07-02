import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/crear_usuario_usecase.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/complete_recovery_usecase.dart';
import '../../domain/usecases/complete_verification_usecase.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final CrearUsuarioUseCase crearUsuarioUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;
  final CompleteRecoveryUseCase completeRecoveryUseCase;
  final CompleteVerificationUseCase completeVerificationUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.changePasswordUseCase,
    required this.crearUsuarioUseCase,
    required this.checkAuthUseCase,
    required this.logoutUseCase,
    required this.completeRecoveryUseCase,
    required this.completeVerificationUseCase,
  }) : super(AuthInitial()) {

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.cedula, event.password);
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
        await forgotPasswordUseCase(event.email);
        emit(AuthMessage('Se envio el correo de recuperacion. Revisa tu bandeja de entrada.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await changePasswordUseCase(event.newPassword, event.oldPassword);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      try {
        await logoutUseCase();
      } catch (_) {}
      emit(AuthInitial());
    });

    on<AuthCheckStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await checkAuthUseCase();
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
        final result = await crearUsuarioUseCase(
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
        if (result.sessionRestored) {
          final user = await checkAuthUseCase();
          if (user != null) {
            emit(AuthAuthenticated(user));
          }
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRoleChanged>((event, emit) {});

    on<AuthCompleteRecoveryRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await completeRecoveryUseCase(
          userId: event.userId,
          secret: event.secret,
          password: event.password,
          passwordAgain: event.passwordAgain,
        );
        emit(AuthMessage('Contraseña restablecida correctamente. Ahora puedes iniciar sesión.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthCompleteVerificationRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await completeVerificationUseCase(
          userId: event.userId,
          secret: event.secret,
        );
        emit(AuthMessage('Correo electrónico verificado correctamente.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
