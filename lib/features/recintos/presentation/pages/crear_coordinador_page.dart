import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cedula_validator.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/recinto.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CrearCoordinadorPage extends StatefulWidget {
  final AppUser currentUser;
  const CrearCoordinadorPage({super.key, required this.currentUser});

  @override
  State<CrearCoordinadorPage> createState() => _CrearCoordinadorPageState();
}

class _CrearCoordinadorPageState extends State<CrearCoordinadorPage> {
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  Recinto? _recintoSeleccionado;

  @override
  void initState() {
    super.initState();
    context.read<RecintoBloc>().add(CargarRecintosEvent());
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Crear Coordinador de Recinto'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUsuarioCreado) {
            if (_recintoSeleccionado != null && state.authUserId != null) {
              context.read<RecintoBloc>().add(AsignarCoordinadorEvent(
                    _recintoSeleccionado!.id!,
                    state.authUserId!,
                  ));
            }
            if (!state.sessionRestored) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coordinador creado. Por favor, inicia sesión de nuevo.'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coordinador creado y asignado. Contraseña inicial: Ecuador2026'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _input(_cedulaCtrl, 'Cédula de identidad',
                keyboard: TextInputType.number, maxLen: 10),
            _input(_nombresCtrl, 'Nombres completos'),
            _input(_apellidosCtrl, 'Apellidos completos'),
            _input(_telefonoCtrl, 'Teléfono de contacto',
                keyboard: TextInputType.phone),
            _input(_emailCtrl, 'Correo electrónico',
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            BlocBuilder<RecintoBloc, RecintoState>(
              builder: (context, state) {
                if (state is RecintosLoaded) {
                  final disponibles = state.recintos
                      .where((r) => r.coordinadorId == null || r.coordinadorId!.isEmpty)
                      .toList();
                  return DropdownButtonFormField<Recinto>(
                    value: _recintoSeleccionado,
                    decoration: _inputDeco('Seleccionar recinto'),
                    items: disponibles.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text('${r.nombre} — ${r.canton} / ${r.parroquia}'),
                    )).toList(),
                    onChanged: (v) => setState(() => _recintoSeleccionado = v),
                  );
                }
                if (state is RecintoLoading) {
                  return const LinearProgressIndicator();
                }
                return const Text('Cargando recintos...');
              },
            ),
            if (_recintoSeleccionado == null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Selecciona un recinto sin coordinador asignado',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            const SizedBox(height: 16),
            _input(_passwordCtrl, 'Tu contraseña actual (para restaurar sesión)',
                keyboard: TextInputType.visiblePassword),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.person_add, size: 18),
                    label: Text(loading ? 'Creando...' : 'Crear Coordinador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: loading ? null : _crearCoordinador,
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _crearCoordinador() {
    final cedula = _cedulaCtrl.text.trim();
    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (cedula.isEmpty || nombres.isEmpty || apellidos.isEmpty ||
        telefono.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Todos los campos son obligatorios'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_recintoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes seleccionar un recinto'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final cedulaError = CedulaValidator.validationMessage(cedula);
    if (cedulaError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cedulaError), backgroundColor: Colors.red),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Correo electrónico inválido'),
            backgroundColor: Colors.red),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthCrearUsuarioRequested(
          cedula: cedula,
          nombres: nombres,
          apellidos: apellidos,
          telefono: telefono,
          email: email,
          rol: UserRole.coordinatorRecinto,
          recintoId: _recintoSeleccionado!.id,
          emailCoordinadorActual: widget.currentUser.email,
          passwordCoordinadorActual: password,
        ));
  }

  Widget _input(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text, int? maxLen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLength: maxLen,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
          counterText: maxLen != null ? null : '',
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      );
}
