import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final provinciaCtrl = TextEditingController();
  final cantonCtrl = TextEditingController();
  final parroquiaCtrl = TextEditingController();
  final jrvCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Crear Recinto'),
        backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
      ),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is RecintoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recinto creado correctamente'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _input(nombreCtrl, 'Nombre del recinto'),
            _input(provinciaCtrl, 'Provincia'),
            _input(cantonCtrl, 'Cantón'),
            _input(parroquiaCtrl, 'Parroquia'),
            _input(jrvCtrl, 'Número de JRV', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: BlocBuilder<RecintoBloc, RecintoState>(
                builder: (context, state) {
                  final loading = state is RecintoLoading;
                  return ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(loading ? 'Guardando...' : 'Guardar Recinto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: loading ? null : () {
                      context.read<RecintoBloc>().add(CrearRecintoEvent(Recinto(
                        nombre: nombreCtrl.text,
                        provincia: provinciaCtrl.text,
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

  Widget _input(TextEditingController c, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
