import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cedula_validator.dart';
import '../../../../core/appwrite_client.dart';
import 'package:appwrite/appwrite.dart';
import '../../../actas/presentation/bloc/acta_bloc.dart';
import '../../../actas/presentation/bloc/acta_event.dart';
import '../../../actas/presentation/bloc/acta_state.dart';
import '../../../actas/presentation/pages/form_acta_page.dart';
import '../../../actas/domain/entities/acta.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../asignaciones/data/datasources/asignacion_datasource.dart';
import '../../domain/entities/recinto.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CoordinadorRecintoPage extends StatefulWidget {
  final String recintoId;
  final String userId;
  final AppUser? currentUser;

  const CoordinadorRecintoPage({
    super.key,
    required this.recintoId,
    required this.userId,
    this.currentUser,
  });

  @override
  State<CoordinadorRecintoPage> createState() => _CoordinadorRecintoPageState();
}

class _CoordinadorRecintoPageState extends State<CoordinadorRecintoPage> {
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mesaCtrl = TextEditingController();
  final _passwordCoordinadorCtrl = TextEditingController();
  Recinto? _recinto;
  final _asignacionDs = AsignacionDatasource(databases);
  List<Map<String, dynamic>> _asignaciones = [];
  Map<String, String> _veedorNombres = {};

  @override
  void initState() {
    super.initState();
    context.read<RecintoBloc>().add(CargarRecintosEvent());
    context.read<ActaBloc>().add(CargarActasEvent());
    _cargarAsignaciones();
    _cargarNombresVeedores();
  }

  Future<void> _cargarNombresVeedores() async {
    try {
      final result = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        queries: [Query.equal('rol', 'observer')],
      );
      final nombres = <String, String>{};
      for (final doc in result.documents) {
        final authId = doc.data['authUserId'] as String?;
        if (authId != null && authId.isNotEmpty) {
          nombres[authId] = '${doc.data['nombres'] ?? ''} ${doc.data['apellidos'] ?? ''}'.trim();
        }
      }
      if (mounted) setState(() => _veedorNombres = nombres);
    } catch (_) {}
  }

  Future<void> _cargarAsignaciones() async {
    try {
      final data = await _asignacionDs.obtenerPorRecinto(widget.recintoId);
      if (mounted) setState(() => _asignaciones = data);
    } catch (_) {}
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _mesaCtrl.dispose();
    _passwordCoordinadorCtrl.dispose();
    super.dispose();
  }

  List<Acta> _filtrarActasDelRecinto(List<Acta> actas) {
    if (_recinto == null) return [];
    return actas.latestPerJuntaDignidad().where((a) =>
        a.provincia == _recinto!.provincia &&
        a.canton == _recinto!.canton &&
        a.parroquia == _recinto!.parroquia
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUsuarioCreado) {
          _guardarAsignacion(state.authUserId);
          if (!state.sessionRestored) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veedor creado. Por favor, inicia sesión de nuevo.'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AuthBloc>().add(AuthLogoutRequested());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veedor creado. Contraseña inicial: Ecuador2026'),
                backgroundColor: Colors.green,
              ),
            );
            _limpiarFormulario();
          }
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<RecintoBloc, RecintoState>(
            builder: (context, state) {
              if (state is RecintosLoaded) {
                _recinto = state.recintos.cast<Recinto?>().firstWhere(
                  (r) => r?.id == widget.recintoId,
                  orElse: () => null,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          _card(
            icon: Icons.table_chart,
            title: 'Mesas del Recinto${_recinto != null ? ' (${_recinto!.numeroJRV} JRV)' : ''}',
            child: BlocBuilder<ActaBloc, ActaState>(
              builder: (context, state) {
                if (state is ActaLoading || _recinto == null) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A3A6B)));
                }
                if (state is ActasLoaded) {
                  final actasRecinto = _filtrarActasDelRecinto(state.actas);
                  final mesasConActa = actasRecinto.map((a) => a.junta).toSet();
                  final totalMesas = _recinto!.numeroJRV;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${mesasConActa.length} de $totalMesas mesas registradas',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 12),
                      ...List.generate(totalMesas, (i) {
                        final mesaNum = i + 1;
                        final tieneActa = mesasConActa.contains(mesaNum);
                        final alcaldeOk = actasRecinto.any(
                            (a) => a.junta == mesaNum && a.dignidad == 'alcalde');
                        final prefectoOk = actasRecinto.any(
                            (a) => a.junta == mesaNum && a.dignidad == 'prefecto');
                        final asignacion = _asignaciones.where(
                            (a) => a['mesa'] == mesaNum).toList();
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            tieneActa ? Icons.check_circle : Icons.pending,
                            color: tieneActa ? Colors.green : Colors.grey,
                          ),
                          title: Text('Mesa $mesaNum',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: tieneActa ? Colors.green.shade700 : Colors.grey)),
                          subtitle: Text(
                            '${alcaldeOk ? "✓ Alcalde" : "✗ Alcalde"} | ${prefectoOk ? "✓ Prefecto" : "✗ Prefecto"}'
                            '${asignacion.isNotEmpty ? " | Veedor asignado" : " | Sin veedor"}',
                            style: const TextStyle(fontSize: 12)),
                          trailing: asignacion.isNotEmpty
                              ? TextButton(
                                  onPressed: () => _reasignarMesa(asignacion.first['\$id'] as String, mesaNum),
                                  child: const Text('Reasignar', style: TextStyle(fontSize: 12)),
                                )
                              : null,
                        );
                      }),
                    ],
                  );
                }
                return ElevatedButton(
                  onPressed: () =>
                      context.read<ActaBloc>().add(CargarActasEvent()),
                  child: const Text('Cargar mesas'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _card(
            icon: Icons.person_add,
            title: 'Crear cuenta de Veedor',
            child: Column(
              children: [
                _input(_cedulaCtrl, 'Cédula de identidad',
                    keyboard: TextInputType.number, maxLen: 10),
                _input(_nombresCtrl, 'Nombres completos'),
                _input(_apellidosCtrl, 'Apellidos completos'),
                _input(_telefonoCtrl, 'Teléfono de contacto',
                    keyboard: TextInputType.phone),
                _input(_emailCtrl, 'Correo electrónico',
                    keyboard: TextInputType.emailAddress),
                _input(_mesaCtrl, 'Mesa asignada (número JRV)',
                    keyboard: TextInputType.number),
                _input(_passwordCoordinadorCtrl, 'Tu contraseña actual (para restaurar sesión)',
                    keyboard: TextInputType.visiblePassword),
                const SizedBox(height: 12),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.person_add, size: 18),
                        label: Text(loading ? 'Creando...' : 'Crear Veedor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A6B),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: loading ? null : _crearVeedor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            icon: Icons.link,
            title: 'Asignar veedor existente a mesa',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_search, size: 18),
              label: const Text('Seleccionar veedor y asignar mesa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _mostrarDialogoAsignarVeedor(context),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            icon: Icons.people,
            title: 'Gestión de Usuarios (Veedores)',
            child: _buildListaVeedores(),
          ),
          const SizedBox(height: 16),
          _card(
            icon: Icons.edit_note,
            title: 'Corregir Acta',
            subtitle: 'Selecciona y edita cualquier acta del recinto',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Ir a corrección de actas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<ActaBloc>().add(CargarActasEvent());
                _mostrarActasParaCorregir(context);
              },
            ),
          ),
          const SizedBox(height: 16),
          _card(
            icon: Icons.add_circle_outline,
            title: 'Registrar nueva acta',
            subtitle: 'Registrar acta de una mesa del recinto',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva acta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormActaPage(currentUser: widget.currentUser)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarAsignacion(String? veedorAuthId) async {
    if (veedorAuthId == null || veedorAuthId.isEmpty) return;
    final mesa = int.tryParse(_mesaCtrl.text.trim());
    if (mesa == null) return;
    try {
      await _asignacionDs.crearAsignacion(
        veedorAuthId: veedorAuthId,
        mesa: mesa,
        recintoId: widget.recintoId,
      );
      await _cargarAsignaciones();
    } catch (_) {}
  }

  Future<void> _reasignarMesa(String asignacionId, int mesaActual) async {
    final mesaCtrl = TextEditingController(text: mesaActual.toString());
    final nuevaMesa = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reasignar mesa'),
        content: TextField(
          controller: mesaCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nuevo número de mesa (JRV)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(mesaCtrl.text.trim())),
            child: const Text('Reasignar'),
          ),
        ],
      ),
    );
    if (nuevaMesa == null || nuevaMesa == mesaActual) return;
    try {
      await _asignacionDs.actualizarMesa(asignacionId, nuevaMesa);
      await _cargarAsignaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesa reasignada a JRV $nuevaMesa'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reasignar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _input(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text, int? maxLen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLength: maxLen,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: maxLen != null ? null : '',
          isDense: true,
        ),
      ),
    );
  }

  void _limpiarFormulario() {
    _cedulaCtrl.clear();
    _nombresCtrl.clear();
    _apellidosCtrl.clear();
    _telefonoCtrl.clear();
    _emailCtrl.clear();
    _mesaCtrl.clear();
    _passwordCoordinadorCtrl.clear();
  }

  Widget _buildListaVeedores() {
    final agrupados = <String, Map<String, dynamic>>{};
    for (final asig in _asignaciones) {
      final vid = asig['veedorId'] as String? ?? '';
      if (vid.isEmpty) continue;
      if (!agrupados.containsKey(vid)) {
        agrupados[vid] = {
          'veedorId': vid,
          'nombre': _veedorNombres[vid] ?? 'Veedor $vid',
          'mesas': <int>[],
        };
      }
      (agrupados[vid]!['mesas'] as List<int>).add(asig['mesa'] as int);
    }

    if (agrupados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No hay veedores asignados a este recinto.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Column(
      children: agrupados.values.map((v) {
        final mesas = (v['mesas'] as List<int>)..sort();
        return ListTile(
          dense: true,
          leading: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1A3A6B),
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          title: Text(v['nombre'] as String,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text('Recinto: ${_recinto?.nombre ?? "---"} | Mesas: ${mesas.join(", ")}',
              style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: 'Desasignar todas las mesas',
            onPressed: () => _eliminarAsignacionesVeedor(v['veedorId'] as String),
          ),
          onTap: () => _pedirMesaYAsignar(v['veedorId'] as String, v['nombre'] as String, mesas),
        );
      }).toList(),
    );
  }

  Future<void> _eliminarAsignacionesVeedor(String veedorAuthId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desasignar veedor'),
        content: const Text('¿Eliminar todas las asignaciones de mesas de este veedor?'),
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
      final pendientes = _asignaciones.where((a) => a['veedorId'] == veedorAuthId).toList();
      for (final asig in pendientes) {
        await _asignacionDs.eliminarAsignacion(asig['\$id'] as String);
      }
      await _cargarAsignaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veedor desasignado correctamente'), backgroundColor: Colors.green),
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

  void _crearVeedor() {
    final cedula = _cedulaCtrl.text.trim();
    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final mesa = _mesaCtrl.text.trim();

    if (cedula.isEmpty || nombres.isEmpty || apellidos.isEmpty ||
        telefono.isEmpty || email.isEmpty || mesa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Todos los campos son obligatorios'),
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

    if (_passwordCoordinadorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu contraseña para continuar'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final currentUser = widget.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesión inválida. Vuelve a iniciar sesión.'),
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
          rol: UserRole.observer,
          recintoId: widget.recintoId,
          emailCoordinadorActual: currentUser.email,
          passwordCoordinadorActual: _passwordCoordinadorCtrl.text,
        ));
  }

  Widget _card(
      {required IconData icon,
      required String title,
      String? subtitle,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF1A3A6B), size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3A6B))),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey))
          ],
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  void _mostrarActasParaCorregir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (_, scrollCtrl) => BlocBuilder<ActaBloc, ActaState>(
          builder: (context, state) {
            if (state is ActasLoaded) {
              final actas = _filtrarActasDelRecinto(state.actas);
              if (actas.isEmpty) {
                return const Center(child: Text('No hay actas en este recinto.'));
              }
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: actas.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Selecciona un acta para corregir',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  }
                  final a = actas[i - 1];
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Mesa ${a.junta} — ${a.dignidad == "alcalde" ? "ALCALDE" : "PREFECTO"}'),
                      subtitle: Text('${a.canton} / ${a.parroquia}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormActaPage(actaExistente: a, currentUser: widget.currentUser),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _mostrarDialogoAsignarVeedor(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarVeedores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
          }
          final veedores = snapshot.data ?? [];
          if (veedores.isEmpty) {
            return AlertDialog(
              title: const Text('Sin veedores'),
              content: const Text('No hay veedores registrados. Crea uno primero.'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
            );
          }
          return AlertDialog(
            title: const Text('Seleccionar veedor'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: veedores.length,
                itemBuilder: (_, i) {
                  final v = veedores[i];
                  final veedorId = v['authUserId'] as String? ?? '';
                  final nombre = '${v['nombres'] ?? ''} ${v['apellidos'] ?? ''}'.trim();
                  final cedula = v['cedula'] as String? ?? '';
                  final mesasActuales = _asignaciones
                      .where((a) => a['veedorId'] == veedorId)
                      .map((a) => a['mesa'] as int)
                      .toList()
                    ..sort();
                  return Card(
                    child: ListTile(
                      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Cédula: $cedula${mesasActuales.isNotEmpty ? " | Mesas: ${mesasActuales.join(", ")}" : " | Sin mesas"}'),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pedirMesaYAsignar(veedorId, nombre, mesasActuales);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarVeedores() async {
    try {
      final result = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        queries: [Query.equal('rol', 'observer')],
      );
      return result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _pedirMesaYAsignar(String veedorId, String nombre, List<int> mesasActuales) async {
    final mesaCtrl = TextEditingController();
    final mesa = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Asignar mesa a $nombre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mesasActuales.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Mesas actuales: ${mesasActuales.join(", ")}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ),
            TextField(
              controller: mesaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número de mesa (JRV)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(mesaCtrl.text.trim())),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
    if (mesa == null) return;
    if (mesasActuales.contains(mesa)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La mesa $mesa ya está asignada a $nombre'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    try {
      await _asignacionDs.crearAsignacion(
        veedorAuthId: veedorId,
        mesa: mesa,
        recintoId: widget.recintoId,
      );
      await _cargarAsignaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesa $mesa asignada a $nombre'), backgroundColor: Colors.green),
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
}
