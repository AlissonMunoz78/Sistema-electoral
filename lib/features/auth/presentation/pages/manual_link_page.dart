import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'reset_password_page.dart';

class ManualLinkPage extends StatefulWidget {
  const ManualLinkPage({super.key});

  @override
  State<ManualLinkPage> createState() => _ManualLinkPageState();
}

class _ManualLinkPageState extends State<ManualLinkPage> {
  final _linkCtrl = TextEditingController();
  String? _userId;
  String? _secret;
  bool _isVerify = false;
  bool _isRecovery = false;
  bool _parsed = false;

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  void _analizarEnlace() {
    final raw = _linkCtrl.text.trim();
    if (raw.isEmpty) {
      _mostrarError('Pega el enlace del correo primero.');
      return;
    }

    Uri? uri;
    try {
      uri = Uri.parse(raw);
    } catch (_) {}

    final userId = uri?.queryParameters['userId'];
    final secret = uri?.queryParameters['secret'];

    if (userId == null || userId.isEmpty || secret == null || secret.isEmpty) {
      _mostrarError('El enlace pegado no es válido. Asegúrate de copiar el enlace completo del correo.');
      return;
    }

    final host = uri?.host ?? '';
    final lower = raw.toLowerCase();
    final isVerify = host == 'verify' || lower.contains('verify');
    final isRecovery = host == 'recovery' || lower.contains('recovery');

    if (!isVerify && !isRecovery) {
      _mostrarError('No se pudo determinar si el enlace es de verificación o recuperación de contraseña.');
      return;
    }

    setState(() {
      _userId = userId;
      _secret = secret;
      _isVerify = isVerify;
      _isRecovery = isRecovery;
      _parsed = true;
    });
  }

  void _continuar() {
    if (_userId == null || _secret == null) return;
    if (_isVerify) {
      context.read<AuthBloc>().add(AuthCompleteVerificationRequested(
        userId: _userId!,
        secret: _secret!,
      ));
    } else if (_isRecovery) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: ResetPasswordPage(
              userId: _userId!,
              secret: _secret!,
            ),
          ),
        ),
      );
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pegar enlace del correo'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/login');
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Si el enlace del correo de verificación o recuperación no abrió la app automáticamente, copia el enlace completo y pégalo aquí.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _linkCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Enlace completo del correo',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _parsed ? null : _analizarEnlace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Analizar enlace'),
                  ),
                ),
                if (_parsed && _userId != null && _secret != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isVerify
                                  ? Icons.verified_user
                                  : Icons.lock_reset,
                              color: const Color(0xFF27AE60),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isVerify
                                  ? 'Enlace de verificación detectado'
                                  : 'Enlace de recuperación detectado',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D2137),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _continuar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27AE60),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_isVerify
                                ? 'Continuar verificación'
                                : 'Continuar recuperación'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
