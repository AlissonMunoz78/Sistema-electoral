import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import 'form_acta_page.dart';

class ListActasPage extends StatelessWidget {
  const ListActasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Actas registradas'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () => context.read<ActaBloc>().add(CargarActasEvent()),
          ),
        ],
      ),
      body: BlocBuilder<ActaBloc, ActaState>(
        builder: (context, state) {
          if (state is ActaLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A6B)));
          }

          if (state is ActaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ActaBloc>().add(CargarActasEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ActasLoaded) {
            if (state.actas.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No hay actas registradas', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.actas.length,
              itemBuilder: (context, index) {
                final acta = state.actas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1A3A6B),
                      foregroundColor: Colors.white,
                      child: Text('${acta.junta}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      'Mesa ${acta.junta} — ${acta.provincia}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${acta.dignidad == "alcalde" ? "ALCALDE" : "PREFECTO"} | ${acta.canton} / ${acta.parroquia}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Votos: ${acta.votosOrganizaciones} | Blancos: ${acta.blancos} | Nulos: ${acta.nulos}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Total sufragantes: ${acta.totalSufragantes} | Votos emitidos: ${acta.totalVotos}',
                          style: TextStyle(
                            fontSize: 11,
                            color: acta.isValid ? Colors.green : Colors.red,
                          ),
                        ),
                        if (acta.latitud != null)
                          Text(
                            'GPS: ${acta.latitud!.toStringAsFixed(4)}, ${acta.longitud!.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: acta.imagenValida ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            acta.imagenValida ? 'Imagen válida' : 'Imagen inválida',
                            style: TextStyle(
                              fontSize: 11,
                              color: acta.imagenValida ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormActaPage(actaExistente: acta),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Presiona recargar para ver los datos', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Cargar actas'),
                  onPressed: () => context.read<ActaBloc>().add(CargarActasEvent()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
