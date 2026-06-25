import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../../../actas/domain/entities/acta.dart';
import '../../../actas/presentation/bloc/acta_bloc.dart';
import '../../../actas/presentation/bloc/acta_event.dart';
import '../../../actas/presentation/bloc/acta_state.dart';

class CoordinadorRecintoPage extends StatefulWidget {
  final String recintoId;
  final String userId;

  const CoordinadorRecintoPage({super.key, required this.recintoId, required this.userId});

  @override
  State<CoordinadorRecintoPage> createState() => _CoordinadorRecintoPageState();
}

class _CoordinadorRecintoPageState extends State<CoordinadorRecintoPage> {
  final _emailCtrl = TextEditingController();
  final _mesaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Panel Coordinador de Recinto'),
        backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            icon: Icons.table_chart,
            title: 'Mesas del Recinto',
            child: BlocBuilder<ActaBloc, ActaState>(
              builder: (context, state) {
                if (state is ActaLoading) return const CircularProgressIndicator();
                if (state is ActasLoaded) {
                  final mesas = state.actas.map((a) => a.junta).toSet().toList()..sort();
                  if (mesas.isEmpty) return const Text('No hay mesas registradas aún.');
                  return Wrap(
                    spacing: 8, runSpacing: 8,
                    children: mesas.map((m) => Chip(
                      label: Text('Mesa $m'),
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                    )).toList(),
                  );
                }
                return ElevatedButton(
                  onPressed: () => context.read<ActaBloc>().add(CargarActasEvent()),
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
                TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 8),
                TextField(controller: _mesaCtrl, decoration: const InputDecoration(labelText: 'Mesa asignada (#)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 44,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Crear Veedor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
                    ),
                    onPressed: _crearVeedor,
                  ),
                ),
              ],
            ),
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
                backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<ActaBloc>().add(CargarActasEvent());
                _mostrarActasParaCorregir(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _crearVeedor() async {
    if (_nombreCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _mesaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre, email y mesa son obligatorios'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        documentId: ID.unique(),
        data: {
          'email': _emailCtrl.text,
          'nombre': _nombreCtrl.text,
          'role': 'observer',
          'mustChangePassword': true,
          'recintoId': widget.recintoId,
          'mesaId': int.tryParse(_mesaCtrl.text) ?? 0,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veedor creado. Contraseña inicial: Ecuador2026'),
          backgroundColor: Colors.green,
        ),
      );
      _nombreCtrl.clear();
      _emailCtrl.clear();
      _mesaCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear veedor: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _card({required IconData icon, required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF1A3A6B), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B))),
          ]),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))],
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
              final actas = state.actas;
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: actas.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Selecciona un acta para corregir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  }
                  final a = actas[i - 1];
                  return Card(
                    child: ListTile(
                      title: Text('Mesa ${a.junta} - ${a.dignidad}'),
                      subtitle: Text('Votos: ${a.votosOrganizaciones}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        Navigator.pop(ctx);
                        _navegarACorreccion(context, a);
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

  void _navegarACorreccion(BuildContext context, acta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CorregirActaPage(acta: acta),
      ),
    );
  }
}

class _CorregirActaPage extends StatefulWidget {
  final dynamic acta;
  const _CorregirActaPage({required this.acta});

  @override
  State<_CorregirActaPage> createState() => _CorregirActaPageState();
}

class _CorregirActaPageState extends State<_CorregirActaPage> {
  late List<TextEditingController> _votosCtrls;
  late TextEditingController _blancosCtrl;
  late TextEditingController _nulosCtrl;
  late TextEditingController _totalCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.acta;
    final votos = a.votosOrganizaciones is List ? List<int>.from(a.votosOrganizaciones) : List.filled(5, 0);
    _votosCtrls = votos.map((v) => TextEditingController(text: v.toString())).toList();
    _blancosCtrl = TextEditingController(text: a.blancos.toString());
    _nulosCtrl = TextEditingController(text: a.nulos.toString());
    _totalCtrl = TextEditingController(text: a.totalSufragantes.toString());
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.acta;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Corregir Acta - Mesa ${a.junta}'),
        backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
      ),
      body: BlocListener<ActaBloc, ActaState>(
        listener: (context, state) {
          if (state is ActaSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Acta actualizada correctamente'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
          if (state is ActaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${a.dignidad} — ${a.provincia} / ${a.canton}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            ...List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _votosCtrls[i],
                  decoration: InputDecoration(
                    labelText: 'Votos organización ${i + 1}',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                ),
              );
            }),
            _input(_blancosCtrl, 'Votos en blanco'),
            _input(_nulosCtrl, 'Votos nulos'),
            _input(_totalCtrl, 'Total sufragantes'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar corrección'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _guardarCorreccion,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.grey.shade50,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _guardarCorreccion() {
    final votos = _votosCtrls.map((c) => int.tryParse(c.text) ?? 0).toList();
    final blancos = int.tryParse(_blancosCtrl.text) ?? 0;
    final nulos = int.tryParse(_nulosCtrl.text) ?? 0;
    final total = int.tryParse(_totalCtrl.text) ?? 0;

    if (votos.fold(0, (a, b) => a + b) + blancos + nulos > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: La suma de votos supera el total de sufragantes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final a = widget.acta;
    context.read<ActaBloc>().add(ActualizarActaEvent(
      a.id ?? '',
      Acta(
        junta: a.junta,
        provincia: a.provincia,
        canton: a.canton,
        parroquia: a.parroquia,
        dignidad: a.dignidad,
        votosOrganizaciones: votos,
        blancos: blancos,
        nulos: nulos,
        totalSufragantes: total,
        fotoId: a.fotoId,
        fecha: a.fecha,
        imagenValida: a.imagenValida,
        latitud: a.latitud,
        longitud: a.longitud,
        userId: a.userId,
      ),
    ));
  }
}


