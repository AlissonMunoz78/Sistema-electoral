import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_state.dart';

class ListActasPage extends StatelessWidget {
  const ListActasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actas registradas")),
      body: BlocBuilder<ActaBloc, ActaState>(
        builder: (context, state) {
          if (state is ActaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActasLoaded) {
            return ListView.builder(
              itemCount: state.actas.length,
              itemBuilder: (context, index) {
                final acta = state.actas[index];
                return Card(
                  child: ListTile(
                    title: Text("Junta ${acta.junta}"),
                    subtitle: Text("${acta.provincia} - ${acta.canton}"),
                  ),
                );
              },
            );
          }

          return const Center(child: Text("No hay datos"));
        },
      ),
    );
  }
}