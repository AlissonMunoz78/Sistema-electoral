import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';

class ListActasPage extends StatelessWidget {
  const ListActasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actas registradas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ActaBloc>().add(CargarActasEvent());
            },
          )
        ],
      ),
      body: BlocBuilder<ActaBloc, ActaState>(
        builder: (context, state) {
          if (state is ActaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActaError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is ActasLoaded) {
            if (state.actas.isEmpty) {
              return const Center(child: Text("No hay actas registradas"));
            }

            return ListView.builder(
              itemCount: state.actas.length,
              itemBuilder: (context, index) {
                final acta = state.actas[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(acta.junta.toString()),
                    ),
                    title: Text(
                      "${acta.provincia.isEmpty ? 'Provincia' : acta.provincia} - ${acta.canton.isEmpty ? 'Cantón' : acta.canton}",
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Parroquia: ${acta.parroquia.isEmpty ? 'Sin registrar' : acta.parroquia}"),
                        Text("A: ${acta.votosA} | B: ${acta.votosB}"),
                        Text(
                          acta.imagenValida ? 'Imagen válida' : 'Imagen inválida',
                          style: TextStyle(
                            color: acta.imagenValida ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text("Presiona refrescar para cargar datos"),
          );
        },
      ),
    );
  }
}