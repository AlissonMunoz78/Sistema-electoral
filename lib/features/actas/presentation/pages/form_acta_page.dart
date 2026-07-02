import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/storage_service.dart';
import '../../../../core/utils/image_sharpness.dart';
import '../../../../core/appwrite_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/provincias.dart';
import '../../../../core/political_organizations.dart';
import '../../../asignaciones/data/datasources/asignacion_datasource.dart';
import '../../../recintos/data/datasources/recinto_datasource.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import '../../domain/entities/acta.dart';

class FormActaPage extends StatefulWidget {
  final Acta? actaExistente;
  final AppUser? currentUser;
  const FormActaPage({super.key, this.actaExistente, this.currentUser});

  @override
  State<FormActaPage> createState() => _FormActaPageState();
}

class _FormActaPageState extends State<FormActaPage> {
  final picker = ImagePicker();
  File? imageFile;
  late StorageService storageService;
  bool _isSubmitting = false;

  final junta = TextEditingController();
  final canton = TextEditingController();
  final parroquia = TextEditingController();
  String _dignidadSeleccionada = 'alcalde';
  final List<TextEditingController> _votosOrg = List.generate(5, (_) => TextEditingController());
  final blancos = TextEditingController();
  final nulos = TextEditingController();
  final totalSufragantes = TextEditingController();

  String _provinciaSeleccionada = 'Pichincha';
  double? _latitud;
  double? _longitud;

  bool _actaAlcaldeCompletada = false;
  bool _actaPrefectoCompletada = false;
  List<int> _mesasAsignadas = [];
  bool _esVeedor = false;
  bool _lockedRecinto = false;
  String? _recintoNombre;
  String? _dignidadGuardando;
  @override
  void initState() {
    super.initState();
    storageService = StorageService(storage);

    final user = widget.currentUser;
    if (user != null && user.role == UserRole.observer) {
      _esVeedor = true;
      _cargarMesasAsignadas(user.authUserId);
    }

    if (widget.actaExistente != null) {
      final a = widget.actaExistente!;
      junta.text = a.junta.toString();
      canton.text = a.canton;
      parroquia.text = a.parroquia;
      _dignidadSeleccionada = a.dignidad;
      _provinciaSeleccionada = a.provincia;
      blancos.text = a.blancos.toString();
      nulos.text = a.nulos.toString();
      totalSufragantes.text = a.totalSufragantes.toString();
      for (int i = 0; i < a.votosOrganizaciones.length && i < 5; i++) {
        _votosOrg[i].text = a.votosOrganizaciones[i].toString();
      }
      _latitud = a.latitud;
      _longitud = a.longitud;
    }

    final st = context.read<ActaBloc>().state;
    if (st is ActasLoaded) {
      _checkExistingActas(st.actas);
    } else {
      context.read<ActaBloc>().add(CargarActasEvent());
    }
  }

  void _checkExistingActas(List<Acta> actas) {
    if (widget.actaExistente != null) return;
    if (widget.currentUser?.id == null) return;
    final mesa = int.tryParse(junta.text) ?? 0;
    final userId = widget.currentUser!.id;
    for (final a in actas) {
      if (a.userId == userId && a.junta == mesa) {
        if (a.dignidad == 'alcalde') _actaAlcaldeCompletada = true;
        if (a.dignidad == 'prefecto') _actaPrefectoCompletada = true;
      }
    }
  }

  Future<void> _cargarMesasAsignadas(String authUserId) async {
    try {
      final ds = AsignacionDatasource(databases);
      final data = await ds.obtenerPorVeedor(authUserId);
      if (mounted) {
        setState(() {
          _mesasAsignadas = data.map((e) => e['mesa'] as int).toList();
        });
        if (data.isNotEmpty) {
          final recintoId = data.first['recintoId'] as String?;
          if (recintoId != null) {
            await _cargarRecintoInfo(recintoId);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _cargarRecintoInfo(String recintoId) async {
    try {
      final recintoDs = RecintoDatasource(databases);
      final data = await recintoDs.obtenerRecinto(recintoId);
      if (data != null && mounted) {
        setState(() {
          _recintoNombre = data['nombre'] as String?;
          _provinciaSeleccionada = data['provincia'] as String? ?? _provinciaSeleccionada;
          canton.text = data['canton'] as String? ?? canton.text;
          parroquia.text = data['parroquia'] as String? ?? parroquia.text;
          _lockedRecinto = true;
        });
      }
    } catch (_) {}
  }

  void _verFoto(String fotoId) {
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
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('Error al cargar la imagen', style: TextStyle(color: Colors.grey))),
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

  @override
  void dispose() {
    junta.dispose();
    canton.dispose();
    parroquia.dispose();
    for (final c in _votosOrg) {
      c.dispose();
    }
    blancos.dispose();
    nulos.dispose();
    totalSufragantes.dispose();
    super.dispose();
  }

  Future<void> _obtenerGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _mostrarError('El GPS está desactivado. Actívalo para continuar.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _mostrarError('Permiso de ubicación denegado. Es necesario para registrar el acta.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _mostrarError('Permiso de ubicación bloqueado permanentemente. Ve a configuración para habilitarlo.');
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _latitud = pos.latitude;
      _longitud = pos.longitude;
    });
  }

  Future<void> takePhoto() async {
    await _obtenerGPS();
    if (_latitud == null || _longitud == null) return;

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
    });
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  bool _validarVotos() {
    final total = int.tryParse(totalSufragantes.text) ?? 0;
    if (total <= 0) {
      _mostrarError('Debe ingresar el total de sufragantes.');
      return false;
    }
    final votos = _votosOrg.map((c) => int.tryParse(c.text) ?? 0).toList();
    final suma = votos.fold(0, (a, b) => a + b) + (int.tryParse(blancos.text) ?? 0) + (int.tryParse(nulos.text) ?? 0);
    if (suma > total) {
      _mostrarError('La suma de votos ($suma) supera el total de sufragantes ($total).');
      return false;
    }
    return true;
  }

  Future<void> guardarActaDignidad(String dignidad) async {
    if (!_validarVotos()) return;

    if (_esVeedor && _lockedRecinto) {
      final mesa = int.tryParse(junta.text) ?? 0;
      if (!_mesasAsignadas.contains(mesa)) {
        _mostrarError('La mesa $mesa no está asignada a usted. Seleccione una mesa asignada.');
        return;
      }
    }

    if (imageFile == null && widget.actaExistente == null) {
      _mostrarError('Debe tomar una foto del acta.');
      return;
    }

    if (imageFile != null) {
      final bytes = imageFile!.readAsBytesSync();
      final metrics = ImageSharpnessValidator.analyze(bytes, threshold: AppConstants.sharpnessThreshold);
      if (!metrics.isAcceptable) {
        _mostrarError(metrics.rejectionReason ?? 'Imagen borrosa. Tome la foto nuevamente.');
        return;
      }
    }

    if (_latitud == null || _longitud == null) {
      _mostrarError('No se pudo obtener las coordenadas GPS.');
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity.any((r) => r != ConnectivityResult.none);

    setState(() => _isSubmitting = true);

    try {
      String fotoId = widget.actaExistente?.fotoId ?? '';
      String? fotoLocalPath;

      if (imageFile != null) {
        if (online) {
          fotoId = await storageService.uploadImage(imageFile!);
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final fileName = 'acta_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final localPath = '${dir.path}/$fileName';
          await imageFile!.copy(localPath);
          fotoLocalPath = localPath;
        }
      }

      if (widget.actaExistente?.id != null && widget.actaExistente!.id!.isNotEmpty && online) {
        final acta = Acta(
          junta: int.tryParse(junta.text) ?? 0,
          provincia: _provinciaSeleccionada,
          canton: canton.text,
          parroquia: parroquia.text,
          dignidad: dignidad,
          votosOrganizaciones: _votosOrg.map((c) => int.tryParse(c.text) ?? 0).toList(),
          blancos: int.tryParse(blancos.text) ?? 0,
          nulos: int.tryParse(nulos.text) ?? 0,
          totalSufragantes: int.tryParse(totalSufragantes.text) ?? 0,
          fotoId: fotoId,
          fecha: DateTime.now(),
          imagenValida: true,
          latitud: _latitud,
          longitud: _longitud,
          userId: widget.currentUser?.id ?? widget.actaExistente?.userId,
        );

        if (!mounted) return;
        setState(() => _dignidadGuardando = dignidad);
        context.read<ActaBloc>().add(ActualizarActaEvent(widget.actaExistente!.id!, acta));
        return;
      }

      final acta = Acta(
        junta: int.tryParse(junta.text) ?? 0,
        provincia: _provinciaSeleccionada,
        canton: canton.text,
        parroquia: parroquia.text,
        dignidad: dignidad,
        votosOrganizaciones: _votosOrg.map((c) => int.tryParse(c.text) ?? 0).toList(),
        blancos: int.tryParse(blancos.text) ?? 0,
        nulos: int.tryParse(nulos.text) ?? 0,
        totalSufragantes: int.tryParse(totalSufragantes.text) ?? 0,
        fotoId: fotoId,
        fecha: DateTime.now(),
        imagenValida: true,
        latitud: _latitud,
        longitud: _longitud,
        userId: widget.currentUser?.id ?? widget.actaExistente?.userId,
      );

      if (!online) {
        if (!mounted) return;
        setState(() => _dignidadGuardando = dignidad);
        context.read<ActaBloc>().add(CrearActaEvent(acta, fotoLocalPath: fotoLocalPath));
        return;
      }

      if (!mounted) return;
      setState(() => _dignidadGuardando = dignidad);

      if (widget.actaExistente?.id != null && widget.actaExistente!.id!.isNotEmpty) {
        context.read<ActaBloc>().add(ActualizarActaEvent(widget.actaExistente!.id!, acta));
      } else {
        context.read<ActaBloc>().add(CrearActaEvent(acta));
      }
    } catch (e) {
      _mostrarError('Error al guardar: $e');
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _input(TextEditingController c, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgs = getOrganizacionesPorDignidad();
    final orgsActuales = orgs[_dignidadSeleccionada] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.actaExistente != null ? 'Corregir Acta' : 'Registrar Acta'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<ActaBloc, ActaState>(
        listener: (context, state) {
          if (state is ActaSuccess) {
            if (_dignidadGuardando == null) return;
            final d = _dignidadGuardando!;
            setState(() {
              if (d == 'alcalde') _actaAlcaldeCompletada = true;
              else _actaPrefectoCompletada = true;
              _isSubmitting = false;
              _dignidadGuardando = null;
            });
            _mostrarExito('Acta de $d guardada correctamente.');
            if (_actaAlcaldeCompletada && _actaPrefectoCompletada) {
              Navigator.pop(context);
            }
          }
          if (state is ActasLoaded) {
            _checkExistingActas(state.actas);
          }
          if (state is ActaError) {
            _mostrarError(state.message);
            setState(() {
              _isSubmitting = false;
              _dignidadGuardando = null;
            });
          }
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: _lockedRecinto ? 'Recinto asignado: $_recintoNombre' : 'Datos del recinto',
              icon: Icons.location_city,
              children: _lockedRecinto
                  ? [
                      _readOnlyField('Provincia', _provinciaSeleccionada),
                      _readOnlyField('Cantón', canton.text),
                      _readOnlyField('Parroquia', parroquia.text),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<int>(
                          value: int.tryParse(junta.text),
                          decoration: _inputDeco('Mesa (JRV) asignada'),
                          items: _mesasAsignadas.map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('Mesa $m'),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) junta.text = v.toString();
                          },
                        ),
                      ),
                    ]
                  : [
                      DropdownButtonFormField<String>(
                        initialValue: _provinciaSeleccionada,
                        decoration: _inputDeco('Provincia'),
                        items: provinciasEcuador.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setState(() => _provinciaSeleccionada = v!),
                      ),
                      _input(canton, 'Cantón'),
                      _input(parroquia, 'Parroquia'),
                      _esVeedor && _mesasAsignadas.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<int>(
                                value: int.tryParse(junta.text),
                                decoration: _inputDeco('Mesa (JRV) asignada'),
                                items: _mesasAsignadas.map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('Mesa $m'),
                                )).toList(),
                                onChanged: (v) {
                                  if (v != null) junta.text = v.toString();
                                },
                              ),
                            )
                          : _input(junta, 'Número de mesa (JRV)', keyboardType: TextInputType.number),
                    ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Dignidad',
              icon: Icons.assignment,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'alcalde', label: Text('Alcalde')),
                    ButtonSegment(value: 'prefecto', label: Text('Prefecto')),
                  ],
                  selected: {_dignidadSeleccionada},
                  onSelectionChanged: (v) {
                    for (final c in _votosOrg) c.clear();
                    blancos.clear();
                    nulos.clear();
                    totalSufragantes.clear();
                    setState(() {
                      _dignidadSeleccionada = v.first;
                      imageFile = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Votos por organización — ${_dignidadSeleccionada == "alcalde" ? "ALCALDE" : "PREFECTO"}',
              icon: Icons.how_to_vote,
              children: [
                ...List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: _votosOrg[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${orgsActuales[i].name} (${orgsActuales[i].party})',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  );
                }),
                const Divider(height: 20),
                _input(blancos, 'Votos en blanco', keyboardType: TextInputType.number),
                _input(nulos, 'Votos nulos', keyboardType: TextInputType.number),
                _input(totalSufragantes, 'Total sufragantes', keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Fotografía del acta',
              icon: Icons.camera_alt,
              children: [
                if (_latitud != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'GPS: ${_latitud!.toStringAsFixed(5)}, ${_longitud!.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18, color: Colors.green),
                          onPressed: _obtenerGPS,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off, color: Colors.orange, size: 18),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text('GPS requerido para guardar',
                              style: TextStyle(fontSize: 12, color: Colors.orange)),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                          onPressed: _obtenerGPS,
                          style: TextButton.styleFrom(foregroundColor: Colors.orange, padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                if (imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, height: 200, fit: BoxFit.cover, width: double.infinity),
                  )
                else if (widget.actaExistente?.fotoId != null)
                  GestureDetector(
                    onTap: () => _verFoto(widget.actaExistente!.fotoId),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FutureBuilder<Uint8List>(
                        future: storage.getFileDownload(bucketId: appwriteBucketId, fileId: widget.actaExistente!.fotoId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(child: Text('Error al cargar imagen', style: TextStyle(color: Colors.grey))),
                            );
                          }
                          return Image.memory(snapshot.data!, height: 200, fit: BoxFit.cover, width: double.infinity);
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Sin foto aún', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar foto del acta'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFF1A3A6B)),
                      foregroundColor: const Color(0xFF1A3A6B),
                    ),
                    onPressed: takePhoto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isSubmitting
                    ? 'Guardando...'
                    : (widget.actaExistente != null
                        ? 'Guardar corrección'
                        : 'Guardar Acta de ${_dignidadSeleccionada == "alcalde" ? "Alcalde" : "Prefecto"}')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.actaExistente != null ? Colors.orange.shade700 : const Color(0xFF1A3A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSubmitting ? null : () => guardarActaDignidad(_dignidadSeleccionada),
              ),
            ),
            if (widget.actaExistente == null) ...[
              const SizedBox(height: 8),
              Text(
                _actaAlcaldeCompletada
                    ? '✓ Acta de Alcalde completada'
                    : '⏳ Pendiente: Acta de Alcalde',
                style: TextStyle(
                  fontSize: 13,
                  color: _actaAlcaldeCompletada ? Colors.green : Colors.grey,
                ),
              ),
              Text(
                _actaPrefectoCompletada
                    ? '✓ Acta de Prefecto completada'
                    : '⏳ Pendiente: Acta de Prefecto',
                style: TextStyle(
                  fontSize: 13,
                  color: _actaPrefectoCompletada ? Colors.green : Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      );

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        child: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A3A6B), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B))),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}
