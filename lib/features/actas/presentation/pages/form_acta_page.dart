import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import '../../domain/entities/acta.dart';

class FormActaPage extends StatelessWidget {
  FormActaPage({super.key});

  final junta = TextEditingController();
  final provincia = TextEditingController();
  final canton = TextEditingController();
  final parroquia = TextEditingController();
  final votosA = TextEditingController();
  final votosB = TextEditingController();
  final blancos = TextEditingController();
  final nulos = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActaBloc, ActaState>(
      listener: (context, state) {
        if (state is ActaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Acta guardada correctamente")),
          );
        }

        if (state is ActaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Registrar Acta")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: junta, decoration: const InputDecoration(labelText: "Junta")),
                TextField(controller: provincia),
                TextField(controller: canton),
                TextField(controller: parroquia),
                TextField(controller: votosA),
                TextField(controller: votosB),
                TextField(controller: blancos),
                TextField(controller: nulos),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (junta.text.isEmpty || votosA.text.isEmpty) return;

                    final acta = Acta(
                      junta: int.parse(junta.text),
                      provincia: provincia.text,
                      canton: canton.text,
                      parroquia: parroquia.text,
                      votosA: int.parse(votosA.text),
                      votosB: int.parse(votosB.text),
                      blancos: int.parse(blancos.text),
                      nulos: int.parse(nulos.text),
                      fotoId: "img123",
                      fecha: DateTime.now(),
                      imagenValida: true,
                    );

                    context.read<ActaBloc>().add(CrearActaEvent(acta));
                  },
                  child: const Text("Guardar Acta"),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    context.read<ActaBloc>().add(CargarActasEvent());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListActasPage()),
                    );
                  },
                  child: const Text("Ver Actas"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}