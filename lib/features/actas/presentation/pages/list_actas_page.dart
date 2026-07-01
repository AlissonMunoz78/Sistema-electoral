import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../../core/appwrite_client.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import 'form_acta_page.dart';

class ListActasPage extends StatelessWidget {
  void _verFoto(BuildContext context, String fotoId) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: FutureBuilder<Uint8List>(
          future: storage.getFileDownload(bucketId: appwriteBucketId, fileId: fotoId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(snapshot.hasError ? 'Error al cargar la imagen' : 'Sin datos',
                      style: const TextStyle(color: Colors.grey)),
                ),
              );
            }
            return InteractiveViewer(
              child: Image.memory(snapshot.data!, fit: BoxFit.contain),
            );
          },
        ),
      ),
    );
  }
  final AppUser? currentUser;
  final bool readOnly;
  const ListActasPage({super.key, this.currentUser, this.readOnly = false});

  void _mostrarDetalleActa(BuildContext context, acta) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: Color(0xFF0D2137)),
                    const SizedBox(width: 8),
                    Text('Acta Mesa ${acta.junta}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2137))),
                  ],
                ),
                const Divider(height: 24),
                _detalleFila('Dignidad', acta.dignidad == 'alcalde' ? 'ALCALDE' : 'PREFECTO'),
                _detalleFila('Provincia', acta.provincia),
                _detalleFila('Cantón', acta.canton),
                _detalleFila('Parroquia', acta.parroquia),
                _detalleFila('Votos', '${acta.votosOrganizaciones}'),
                _detalleFila('Blancos', '${acta.blancos}'),
                _detalleFila('Nulos', '${acta.nulos}'),
                _detalleFila('Total sufragantes', '${acta.totalSufragantes}'),
                _detalleFila('Total votos', '${acta.totalVotos}'),
                if (acta.latitud != null) _detalleFila('GPS', '${acta.latitud!.toStringAsFixed(4)}, ${acta.longitud!.toStringAsFixed(4)}'),
                _detalleFila('Imagen', acta.imagenValida ? 'Válida' : 'Inválida'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detalleFila(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocBuilder<ActaBloc, ActaState>(
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
            var actas = state.actas;
            if (currentUser?.role == UserRole.observer && currentUser?.id != null) {
              actas = actas.where((a) => a.userId == currentUser!.id).toList();
            }
            if (actas.isEmpty) {
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
              itemCount: actas.length,
              itemBuilder: (context, index) {
                final acta = actas[index];
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
                        Row(
                          children: [
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
                            if (acta.fotoId.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _verFoto(context, acta.fotoId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.image, size: 12, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ver foto',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(readOnly ? Icons.visibility : Icons.chevron_right),
                    onTap: () {
                      if (readOnly) {
                        _mostrarDetalleActa(context, acta);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormActaPage(actaExistente: acta),
                          ),
                        );
                      }
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
      ),
    );
  }
}
