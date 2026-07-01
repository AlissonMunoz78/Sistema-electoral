import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/provincias.dart';
import '../../domain/entities/recinto.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CrearRecintoPage extends StatefulWidget {
  const CrearRecintoPage({super.key});

  @override
  State<CrearRecintoPage> createState() => _CrearRecintoPageState();
}

class _CrearRecintoPageState extends State<CrearRecintoPage> {
  final nombreCtrl = TextEditingController();
  final cantonCtrl = TextEditingController();
  final parroquiaCtrl = TextEditingController();
  final jrvCtrl = TextEditingController();
  String _provinciaSeleccionada = 'Pichincha';

  @override
  void dispose() {
    nombreCtrl.dispose();
    cantonCtrl.dispose();
    parroquiaCtrl.dispose();
    jrvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Crear Recinto'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF1A3A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: Color(0xFF0D2137), size: 20),
                      const SizedBox(width: 8),
                      const Text('Información del recinto',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D2137))),
                    ],
                  ),
                  const Divider(height: 24),
                  _input(nombreCtrl, 'Nombre del recinto'),
                  DropdownButtonFormField<String>(
                    initialValue: _provinciaSeleccionada,
                    decoration: _inputDeco('Provincia'),
                    items: provinciasEcuador.map((p) =>
                      DropdownMenuItem(value: p, child: Text(p))
                    ).toList(),
                    onChanged: (v) => setState(() => _provinciaSeleccionada = v!),
                  ),
                  const SizedBox(height: 12),
                  _input(cantonCtrl, 'Cantón'),
                  _input(parroquiaCtrl, 'Parroquia'),
                  _input(jrvCtrl, 'Número de JRV', keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: BlocBuilder<RecintoBloc, RecintoState>(
                builder: (context, state) {
                  final loading = state is RecintoLoading;
                  return ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(loading ? 'Guardando...' : 'Guardar Recinto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2137),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: loading ? null : () {
                      context.read<RecintoBloc>().add(CrearRecintoEvent(Recinto(
                        nombre: nombreCtrl.text,
                        provincia: _provinciaSeleccionada,
                        canton: cantonCtrl.text,
                        parroquia: parroquiaCtrl.text,
                        numeroJRV: int.tryParse(jrvCtrl.text) ?? 0,
                      )));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: _inputDeco(label),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      );
}
