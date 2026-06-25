import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/appwrite_client.dart';
import '../../../actas/data/datasources/acta_datasource.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';
import 'crear_recinto_page.dart';

class ListarRecintosPage extends StatefulWidget {
  const ListarRecintosPage({super.key});

  @override
  State<ListarRecintosPage> createState() => _ListarRecintosPageState();
}

class _ListarRecintosPageState extends State<ListarRecintosPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecintoBloc>().add(CargarRecintosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Recintos'),
        backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear recinto',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearRecintoPage()))
                .then((_) => context.read<RecintoBloc>().add(CargarRecintosEvent())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RecintoBloc>().add(CargarRecintosEvent()),
          ),
        ],
      ),
      body: BlocBuilder<RecintoBloc, RecintoState>(
        builder: (context, state) {
          if (state is RecintoLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A3A6B)));
          }
          if (state is RecintoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<RecintoBloc>().add(CargarRecintosEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is RecintosLoaded) {
            if (state.recintos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No hay recintos registrados', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 12),
                    Text('Presiona + para crear uno', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.recintos.length,
              itemBuilder: (context, index) {
                final r = state.recintos[index];
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
                      backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
                      child: Text('${r.numeroJRV}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.provincia} — ${r.canton} — ${r.parroquia}'),
                        Text('JRVs: ${r.numeroJRV}  |  Coordinador: ${r.coordinadorId ?? "Sin asignar"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _mostrarDetalle(context, r.id, r.nombre),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Presiona recargar para cargar'));
        },
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, String? id, String nombre) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Funciones disponibles:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _opcion(ctx, 'Asignar coordinador de recinto', Icons.person_add, () async {
              // En una implementación real, aquí se mostraría un selector de usuarios
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función: Asignar coordinador - requiere selector de usuarios')),
              );
            }),
            _opcion(ctx, 'Ver coordenadas GPS de actas', Icons.map, () async {
              Navigator.pop(ctx);
              await _mostrarGpsActas(context, id);
            }),
            _opcion(ctx, 'Ver avance (actas registradas vs pendientes)', Icons.bar_chart, () {
              Navigator.pop(ctx);
              _mostrarAvance(context, id, nombre);
            }),
          ],
        ),
      ),
    );
  }

  Widget _opcion(BuildContext ctx, String texto, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A3A6B)),
      title: Text(texto, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Future<void> _mostrarGpsActas(BuildContext context, String? recintoId) async {
    final datasource = ActaDatasource(databases);
    try {
      final actas = await datasource.obtenerActas();
      final actasConGps = actas.where((a) => a['latitud'] != null && a['longitud'] != null).toList();

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Coordenadas GPS de Actas'),
          content: SizedBox(
            width: double.maxFinite,
            child: actasConGps.isEmpty
                ? const Text('No hay actas con coordenadas registradas.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: actasConGps.length,
                    itemBuilder: (_, i) {
                      final a = actasConGps[i];
                      return ListTile(
                        dense: true,
                        title: Text('Mesa ${a['junta']} - ${a['dignidad'] ?? 'N/A'}'),
                        subtitle: Text('GPS: ${a['latitud']}, ${a['longitud']}'),
                      );
                    },
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrir'))],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar coordenadas'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _mostrarAvance(BuildContext context, String? recintoId, String nombre) {
    // Placeholder para avance
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Avance - $nombre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Actas registradas: (pendiente de implementar consulta)'),
            SizedBox(height: 8),
            Text('Actas pendientes: (pendiente de implementar consulta)'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrir'))],
      ),
    );
  }
}
