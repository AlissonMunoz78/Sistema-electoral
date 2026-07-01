import 'package:flutter/material.dart';
import '../../data/datasources/acta_datasource.dart';
import '../../../../core/appwrite_client.dart';
import '../../../../core/political_organizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;

  List<int> _votosAlcaldeTotal = List.filled(5, 0);
  List<int> _votosPrefectoTotal = List.filled(5, 0);
  Map<String, List<int>> _votosPorRecintoAlcalde = {};
  Map<String, List<int>> _votosPorRecintoPrefecto = {};

  final _orgsAlcalde = getOrganizacionesAlcalde();
  final _orgsPrefecto = getOrganizacionesPrefecto();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final datasource = ActaDatasource(databases);
      final actas = await datasource.obtenerActas();

      final alcaldeTotal = List.filled(5, 0);
      final prefectoTotal = List.filled(5, 0);
      final porRecintoAlcalde = <String, List<int>>{};
      final porRecintoPrefecto = <String, List<int>>{};

      for (final a in actas) {
        final votos = a['votosOrganizaciones'];
        if (votos == null) continue;
        final lista = (votos as List).map((e) => (e as num).toInt()).toList();
        while (lista.length < 5) lista.add(0);

        final canton = a['canton'] as String? ?? 'Desconocido';
        final parroquia = a['parroquia'] as String? ?? '';
        final recintoKey = '$canton / $parroquia';

        if (a['dignidad'] == 'alcalde') {
          for (int i = 0; i < 5; i++) alcaldeTotal[i] += lista[i];
          porRecintoAlcalde[recintoKey] ??= List.filled(5, 0);
          for (int i = 0; i < 5; i++) porRecintoAlcalde[recintoKey]![i] += lista[i];
        } else if (a['dignidad'] == 'prefecto') {
          for (int i = 0; i < 5; i++) prefectoTotal[i] += lista[i];
          porRecintoPrefecto[recintoKey] ??= List.filled(5, 0);
          for (int i = 0; i < 5; i++) porRecintoPrefecto[recintoKey]![i] += lista[i];
        }
      }

      setState(() {
        _votosAlcaldeTotal = alcaldeTotal;
        _votosPrefectoTotal = prefectoTotal;
        _votosPorRecintoAlcalde = porRecintoAlcalde;
        _votosPorRecintoPrefecto = porRecintoPrefecto;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Dashboard Electoral'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarDatos,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'ALCALDE'),
            Tab(text: 'PREFECTO'),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A3A6B)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _cargarDatos,
                          child: const Text('Reintentar')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(
                      orgs: _orgsAlcalde,
                      totalVotos: _votosAlcaldeTotal,
                      porRecinto: _votosPorRecintoAlcalde,
                    ),
                    _buildTabContent(
                      orgs: _orgsPrefecto,
                      totalVotos: _votosPrefectoTotal,
                      porRecinto: _votosPorRecintoPrefecto,
                    ),
                  ],
                ),
        ),
    );
  }

  Widget _buildTabContent({
    required List orgs,
    required List<int> totalVotos,
    required Map<String, List<int>> porRecinto,
  }) {
    final grandTotal = totalVotos.fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          title: 'Consolidado General',
          icon: Icons.bar_chart,
          child: grandTotal == 0
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No hay votos registrados aún',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Column(
                  children: List.generate(orgs.length, (i) {
                    final votos = totalVotos[i];
                    final pct = grandTotal > 0 ? votos / grandTotal : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  orgs[i].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ),
                              Text(
                                '$votos votos (${(pct * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orgs[i].party,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct.toDouble(),
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _colorForIndex(i)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 16),
        if (porRecinto.isNotEmpty)
          _sectionCard(
            title: 'Por Recinto',
            icon: Icons.location_city,
            child: Column(
              children: porRecinto.entries.map((entry) {
                final recintoVotos = entry.value;
                final recintoTotal = recintoVotos.fold(0, (a, b) => a + b);
                return ExpansionTile(
                  title: Text(entry.key,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Total: $recintoTotal votos',
                      style: const TextStyle(fontSize: 12)),
                  children: List.generate(orgs.length, (i) {
                    final v = recintoVotos[i];
                    final p = recintoTotal > 0 ? v / recintoTotal : 0.0;
                    return ListTile(
                      dense: true,
                      title: Text(orgs[i].name,
                          style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                          '$v (${(p * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 12)),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      Color(0xFF1A3A6B),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
    ];
    return colors[i % colors.length];
  }

  Widget _sectionCard(
      {required String title,
      required IconData icon,
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
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}