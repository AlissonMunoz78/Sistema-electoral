import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import '../../../../core/political_organizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<int> _votosAlcaldeTotal = List.filled(5, 0);
  List<int> _votosPrefectoTotal = List.filled(5, 0);
  Map<String, List<int>> _votosPorRecintoAlcalde = {};
  Map<String, List<int>> _votosPorRecintoPrefecto = {};

  final _orgsAlcalde = getOrganizacionesAlcalde();
  final _orgsPrefecto = getOrganizacionesPrefecto();
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ActaBloc>().add(CargarActasEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _procesarActas(List actas) {
    final alcaldeTotal = List.filled(5, 0);
    final prefectoTotal = List.filled(5, 0);
    final porRecintoAlcalde = <String, List<int>>{};
    final porRecintoPrefecto = <String, List<int>>{};

    for (final a in actas) {
      final votos = a.votosOrganizaciones;
      if (votos == null) continue;
      final lista = (votos as List).map((e) => (e as num).toInt()).toList();
      while (lista.length < 5) lista.add(0);

      final canton = a.canton as String? ?? 'Desconocido';
      final parroquia = a.parroquia as String? ?? '';
      final recintoKey = '$canton / $parroquia';

      if (a.dignidad == 'alcalde') {
        for (int i = 0; i < 5; i++) alcaldeTotal[i] += lista[i];
        porRecintoAlcalde[recintoKey] ??= List.filled(5, 0);
        for (int i = 0; i < 5; i++) porRecintoAlcalde[recintoKey]![i] += lista[i];
      } else if (a.dignidad == 'prefecto') {
        for (int i = 0; i < 5; i++) prefectoTotal[i] += lista[i];
        porRecintoPrefecto[recintoKey] ??= List.filled(5, 0);
        for (int i = 0; i < 5; i++) porRecintoPrefecto[recintoKey]![i] += lista[i];
      }
    }

    if (mounted) {
      setState(() {
        _votosAlcaldeTotal = alcaldeTotal;
        _votosPrefectoTotal = prefectoTotal;
        _votosPorRecintoAlcalde = porRecintoAlcalde;
        _votosPorRecintoPrefecto = porRecintoPrefecto;
        _dataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Dashboard Electoral'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF1A3A6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              setState(() => _dataLoaded = false);
              context.read<ActaBloc>().add(CargarActasEvent());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4A843),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'ALCALDE'),
            Tab(text: 'PREFECTO'),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<ActaBloc, ActaState>(
          listener: (context, state) {
            if (state is ActasLoaded && !_dataLoaded) {
              _procesarActas(state.actas);
            }
          },
          child: BlocBuilder<ActaBloc, ActaState>(
            builder: (context, state) {
              if (state is ActaLoading && !_dataLoaded) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D2137)),
                );
              }

              if (state is ActaError && !_dataLoaded) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Color(0xFFE74C3C)),
                      const SizedBox(height: 12),
                      Text('Error: ${state.message}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _dataLoaded = false);
                          context.read<ActaBloc>().add(CargarActasEvent());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (!_dataLoaded) {
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
                        label: const Text('Cargar datos'),
                        onPressed: () {
                          setState(() => _dataLoaded = false);
                          context.read<ActaBloc>().add(CargarActasEvent());
                        },
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
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
              );
            },
          ),
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
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No hay votos registrados aún',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: List.generate(orgs.length, (i) {
                    final votos = totalVotos[i];
                    final pct = grandTotal > 0 ? votos / grandTotal : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
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
                                      fontSize: 13,
                                      color: Color(0xFF0D2137)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$votos votos (${(pct * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD4A843),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orgs[i].party,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct.toDouble().clamp(0.0, 1.0),
                              minHeight: 8,
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Total: $recintoTotal votos',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: List.generate(orgs.length, (i) {
                      final v = recintoVotos[i];
                      final p = recintoTotal > 0 ? v / recintoTotal : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _colorForIndex(i),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(orgs[i].name,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Text(
                              '$v (${(p * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      Color(0xFF0D2137),
      Color(0xFFD4A843),
      Color(0xFF27AE60),
      Color(0xFF2980B9),
      Color(0xFFE74C3C),
    ];
    return colors[i % colors.length];
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF0D2137), size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D2137))),
          ]),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}
