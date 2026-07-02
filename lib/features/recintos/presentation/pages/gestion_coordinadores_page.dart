import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import '../../../../core/appwrite_client.dart';

class GestionCoordinadoresPage extends StatefulWidget {
  const GestionCoordinadoresPage({super.key});

  @override
  State<GestionCoordinadoresPage> createState() => _GestionCoordinadoresPageState();
}

class _GestionCoordinadoresPageState extends State<GestionCoordinadoresPage> {
  List<Map<String, dynamic>> _coordinadores = [];
  Map<String, String> _recintoNombres = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _loading = true);
    try {
      final usersResult = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        queries: [Query.equal('rol', 'coordinatorRecinto')],
      );
      final recintosResult = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteRecintosCollectionId,
      );

      final recintos = <String, String>{};
      for (final doc in recintosResult.documents) {
        recintos[doc.$id] = doc.data['nombre'] as String? ?? '---';
      }

      final coordis = usersResult.documents
          .map((d) => Map<String, dynamic>.from(d.data)..['\$id'] = d.$id)
          .toList();

      if (mounted) {
        setState(() {
          _coordinadores = coordis;
          _recintoNombres = recintos;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _desasignarRecinto(String userId, String recintoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desasignar coordinador'),
        content: const Text('¿Desasignar este coordinador de su recinto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await databases.updateDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteRecintosCollectionId,
        documentId: recintoId,
        data: {'coordinadorId': ''},
      );
      await _cargarDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinador desasignado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Coordinadores de Recinto'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A6B)))
          : _coordinadores.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No hay coordinadores de recinto registrados',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _coordinadores.length,
                    itemBuilder: (_, i) {
                      final c = _coordinadores[i];
                      final nombre = '${c['nombres'] ?? ''} ${c['apellidos'] ?? ''}'.trim();
                      final cedula = c['cedula'] as String? ?? '';
                      final telefono = c['telefono'] as String? ?? '';
                      final email = c['correo'] ?? c['email'] ?? '';
                      final recintoId = c['recintoId'] as String?;
                      final recintoNombre = recintoId != null && recintoId.isNotEmpty
                          ? _recintoNombres[recintoId] ?? 'Recinto desconocido'
                          : 'Sin recinto asignado';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1A3A6B),
                            foregroundColor: Colors.white,
                            child: Text(
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cédula: $cedula | Tel: $telefono', style: const TextStyle(fontSize: 12)),
                              Text('Email: $email', style: const TextStyle(fontSize: 12)),
                              Row(
                                children: [
                                  Text('Recinto: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Expanded(
                                    child: Text(recintoNombre,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: recintoId != null && recintoId.isNotEmpty
                                              ? const Color(0xFF1A3A6B)
                                              : Colors.orange,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: recintoId != null && recintoId.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.person_remove, color: Colors.red, size: 20),
                                  tooltip: 'Desasignar recinto',
                                  onPressed: () => _desasignarRecinto(c['authUserId'] as String? ?? '', recintoId),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
