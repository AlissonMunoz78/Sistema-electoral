import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPage extends StatefulWidget {
  final String userId;
  final String secret;
  const EmailVerificationPage({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _verificado = false;
  bool _error = false;
  String _mensajeError = '';

  @override
  void initState() {
    super.initState();
    _verificarEmail();
  }

  void _verificarEmail() {
    context.read<AuthBloc>().add(AuthCompleteVerificationRequested(
      userId: widget.userId,
      secret: widget.secret,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Verificación de correo'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF1A3A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              setState(() {
                _verificado = true;
                _error = false;
              });
            }
            if (state is AuthFailure) {
              setState(() {
                _error = true;
                _mensajeError = state.message;
              });
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_verificado) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle,
                            size: 64, color: Color(0xFF27AE60)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Correo verificado',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2137),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu correo electrónico ha sido verificado correctamente. Ahora puedes iniciar sesión.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (_) => true),
                          child: const Text('Ir a iniciar sesión'),
                        ),
                      ),
                    ] else if (_error) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline,
                            size: 64, color: Color(0xFFE74C3C)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Error de verificación',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2137),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mensajeError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _verificarEmail,
                          child: const Text('Reintentar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (_) => true),
                        child: const Text('Ir a iniciar sesión'),
                      ),
                    ] else ...[
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                            color: Color(0xFF0D2137)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verificando correo electrónico...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
