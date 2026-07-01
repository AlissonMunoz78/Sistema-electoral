# Contexto Completo del Proyecto Flutter



================================================
📄 ARCHIVO: .gitignore
================================================

# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release



================================================
📄 ARCHIVO: .metadata
================================================

# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled and should not be manually edited.

version:
  revision: "00b0c91f06209d9e4a41f71b7a512d6eb3b9c694"
  channel: "stable"

project_type: app

# Tracks metadata for the flutter migrate command
migration:
  platforms:
    - platform: root
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: android
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: ios
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: linux
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: macos
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: web
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
    - platform: windows
      create_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694
      base_revision: 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694

  # User provided section

  # List of Local paths (relative to this file) that should be
  # ignored by the migrate tool.
  #
  # Files that are not part of the templates will be ignored by default.
  unmanaged_files:
    - 'lib/main.dart'
    - 'ios/Runner.xcodeproj/project.pbxproj'



================================================
📄 ARCHIVO: analysis_options.yaml
================================================

# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options



================================================
📄 ARCHIVO: lib\core\appwrite_client.dart
================================================

import 'package:appwrite/appwrite.dart';

const String appwriteEndpoint = 'https://sfo.cloud.appwrite.io/v1';
const String appwriteProjectId = 'sistema-electoral';
const String appwriteDatabaseId = '6a3ca5420008a6f70fe1';

// Colecciones (tablas) usadas por la app.
// NOTA: se corrigió el typo "ususarios" -> "users" y se agregaron las
// colecciones nuevas que el enunciado requiere (asignaciones de mesa y
// organizaciones políticas precargadas desde el backend).
const String appwriteActasCollectionId = 'actas';
const String appwriteUsersCollectionId = 'users';
const String appwriteRecintosCollectionId = 'recintos';
const String appwriteAsignacionesCollectionId = 'asignaciones_mesa';
const String appwriteOrganizacionesCollectionId = 'organizaciones_politicas';
const String appwriteBucketId = '6a3ca946002e1039870d';

Client client = Client()
    .setEndpoint(appwriteEndpoint)
    .setProject(appwriteProjectId);

Databases get databases => Databases(client);
TablesDB get tablesDB => TablesDB(client);
Storage get storage => Storage(client);
Account get account => Account(client);


================================================
📄 ARCHIVO: lib\core\cedula_validator.dart
================================================

// Validador de cédula ecuatoriana.
//
// Algoritmo oficial (módulo 10) usado por el Registro Civil del Ecuador:
// 1. Los dos primeros dígitos representan el código de provincia (01-24, o 30
//    para extranjeros residentes con cédula ecuatoriana en algunos casos).
// 2. El tercer dígito debe ser menor a 6 para personas naturales.
// 3. Se aplica el algoritmo de Luhn modificado (módulo 10) sobre los primeros
//    9 dígitos, y el resultado debe coincidir con el décimo dígito (verificador).
//
// Referencia pública del algoritmo: documentación técnica del Registro Civil
// y validaciones replicadas en múltiples SDKs de validación ecuatoriana.
class CedulaValidator {
  /// Valida que [cedula] sea una cédula ecuatoriana válida.
  /// Devuelve true si es válida, false en caso contrario.
  static bool isValid(String cedula) {
    final cleaned = cedula.trim();

    // Debe tener exactamente 10 dígitos numéricos.
    if (cleaned.length != 10) return false;
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned)) return false;

    final digits = cleaned.split('').map(int.parse).toList();

    // Código de provincia: 01-24 (más 30 para casos especiales registrados).
    final provincia = digits[0] * 10 + digits[1];
    if (provincia < 1 || (provincia > 24 && provincia != 30)) return false;

    // Tercer dígito debe ser menor a 6 para cédulas de personas naturales.
    final tercerDigito = digits[2];
    if (tercerDigito > 6) return false;

    // Algoritmo módulo 10 (Luhn modificado):
    // Posiciones impares (índice 0,2,4,6,8) se multiplican por 2;
    // si el resultado es >= 10, se le resta 9.
    const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;
    for (var i = 0; i < 9; i++) {
      var valor = digits[i] * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }

    final digitoVerificadorEsperado = (10 - (suma % 10)) % 10;
    final digitoVerificadorReal = digits[9];

    return digitoVerificadorEsperado == digitoVerificadorReal;
  }

  /// Devuelve un mensaje de error legible, o null si la cédula es válida.
  /// Útil para mostrar feedback directo en formularios.
  static String? validationMessage(String cedula) {
    final cleaned = cedula.trim();
    if (cleaned.isEmpty) return 'La cédula es obligatoria.';
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'La cédula debe contener solo números.';
    }
    if (cleaned.length != 10) {
      return 'La cédula debe tener exactamente 10 dígitos.';
    }
    if (!isValid(cleaned)) {
      return 'La cédula ingresada no es válida.';
    }
    return null;
  }
}


================================================
📄 ARCHIVO: lib\core\connectivity_service.dart
================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  void Function(bool)? onConnectivityChanged;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void startMonitoring() {
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
    });
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_isOnline) {
        onConnectivityChanged?.call(true);
      }
      _isOnline = online;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}



================================================
📄 ARCHIVO: lib\core\image_service.dart
================================================

import 'dart:io';
import 'package:image/image.dart' as img;

// Limitación conocida: Laplacian variance es un heurístico simple que puede
// clasificar incorrectamente imágenes con patrones repetitivos o texturas finas
// como borrosas. Un enfoque más robusto usaría redes neuronales (p.ej. MobileNet),
// pero incrementa el tamaño de la app y requiere permisos adicionales.
class ImageService {
  static bool isImageBlurry(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return false;

      if (decoded.width < 32 || decoded.height < 32) return false;

      final resized = img.copyResize(
        decoded,
        width: 100,
        height: 100,
        interpolation: img.Interpolation.average,
      );
      final gray = img.grayscale(resized);

      var laplacianVariance = 0.0;
      var count = 0;

      for (var y = 1; y < gray.height - 1; y++) {
        for (var x = 1; x < gray.width - 1; x++) {
          final center = gray.getPixel(x, y).r.toDouble();
          final up = gray.getPixel(x, y - 1).r.toDouble();
          final down = gray.getPixel(x, y + 1).r.toDouble();
          final left = gray.getPixel(x - 1, y).r.toDouble();
          final right = gray.getPixel(x + 1, y).r.toDouble();
          final laplacian = (up + down + left + right - (4 * center)).abs();
          laplacianVariance += laplacian;
          count++;
        }
      }

      if (count == 0) return false;

      final average = laplacianVariance / count;
      return average < 4.0;
    } catch (_) {
      return false;
    }
  }
}


================================================
📄 ARCHIVO: lib\core\political_organizations.dart
================================================

class PoliticalOrganization {
  final String name;
  final String party;
  PoliticalOrganization(this.name, this.party);
}

List<PoliticalOrganization> getOrganizacionesAlcalde() => [
  PoliticalOrganization('Pabel Muñoz', 'Movimiento Pueblo Igual'),
  PoliticalOrganization('Jorge Yunda', 'Avanza'),
  PoliticalOrganization('John Reimberg', 'ADN'),
  PoliticalOrganization('Marlene Cevallos', 'Movimiento Social'),
  PoliticalOrganization('Mario Jaramillo', 'Partido Liberal'),
];

List<PoliticalOrganization> getOrganizacionesPrefecto() => [
  PoliticalOrganization('Rosa Cárdenas', 'Movimiento Pueblo Igual'),
  PoliticalOrganization('Luis Torres', 'Avanza'),
  PoliticalOrganization('Ana Belén', 'ADN'),
  PoliticalOrganization('Fernando Vega', 'Movimiento Social'),
  PoliticalOrganization('Carlos Rivas', 'Partido Liberal'),
];

Map<String, List<PoliticalOrganization>> getOrganizacionesPorDignidad() => {
  'alcalde': getOrganizacionesAlcalde(),
  'prefecto': getOrganizacionesPrefecto(),
};



================================================
📄 ARCHIVO: lib\core\storage_service.dart
================================================

import 'dart:io';
import 'package:appwrite/appwrite.dart';

import 'appwrite_client.dart';

class StorageService {
  final Storage storage;

  StorageService(this.storage);

  Future<String> uploadImage(File file) async {
    final result = await storage.createFile(
      bucketId: appwriteBucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file.path),
    );

    return result.$id;
  }
}



================================================
📄 ARCHIVO: lib\features\actas\data\datasources\acta_datasource.dart
================================================

import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/acta_model.dart';

class ActaDatasource {
  final TablesDB db;

  ActaDatasource(this.db);

  Future<void> crearActa(ActaModel acta) async {
    await db.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      rowId: ID.unique(),
      data: acta.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas({String? userId}) async {
    final queries = <String>[];
    if (userId != null) queries.add('userId=$userId');
    final result = await db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      queries: queries,
    );
    return result.rows.map((e) => {...e.data, '\$id': e.$id}).toList();
  }

  Future<void> actualizarActa(String documentId, Map<String, dynamic> data) async {
    await db.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      rowId: documentId,
      data: data,
    );
  }
}



================================================
📄 ARCHIVO: lib\features\actas\data\datasources\storage_datasource.dart
================================================

import 'package:appwrite/appwrite.dart';

class StorageDatasource {
  final Storage storage;
  StorageDatasource(this.storage);

  Future<String> subirImagen(String path) async {
    final file = await storage.createFile(
      bucketId: "6a3ca946002e1039870d",
      fileId: ID.unique(),
      file: InputFile.fromPath(path: path),
    );
    return file.$id;
  }
}


================================================
📄 ARCHIVO: lib\features\actas\data\models\acta_model.dart
================================================

import '../../domain/entities/acta.dart';

class ActaModel extends Acta {
  ActaModel({
    required super.junta,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.dignidad,
    required super.votosOrganizaciones,
    required super.blancos,
    required super.nulos,
    required super.totalSufragantes,
    required super.fotoId,
    required super.fecha,
    required super.imagenValida,
    super.latitud,
    super.longitud,
    super.userId,
    super.id,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ActaModel(
      junta: _parseInt(json['junta']),
      provincia: _parseString(json['provincia']),
      canton: _parseString(json['canton']),
      parroquia: _parseString(json['parroquia']),
      dignidad: _parseString(json['dignidad']),
      votosOrganizaciones: _parseIntList(json['votosOrganizaciones']),
      blancos: _parseInt(json['blancos']),
      nulos: _parseInt(json['nulos']),
      totalSufragantes: _parseInt(json['totalSufragantes']),
      fotoId: _parseString(json['fotoId']),
      fecha: _parseDateTime(json['fecha']),
      imagenValida: _parseBool(json['imagenValida']),
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      userId: _parseStringNullable(json['userId']),
      id: docId ?? json['\$id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'junta': junta,
    'provincia': provincia,
    'canton': canton,
    'parroquia': parroquia,
    'dignidad': dignidad,
    'votosOrganizaciones': votosOrganizaciones,
    'blancos': blancos,
    'nulos': nulos,
    'totalSufragantes': totalSufragantes,
    'fotoId': fotoId,
    'fecha': fecha.toIso8601String(),
    'imagenValida': imagenValida,
    'latitud': latitud,
    'longitud': longitud,
    'userId': userId,
  };

  static double? _parseNullableDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value is String) return value;
    return '';
  }

  static String? _parseStringNullable(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static List<int> _parseIntList(dynamic value) {
    if (value is List) return value.map((e) => _parseInt(e)).toList();
    return List.filled(5, 0);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}



================================================
📄 ARCHIVO: lib\features\actas\data\repositories\acta_repository_impl.dart
================================================

import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../offline/hive_service.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../datasources/acta_datasource.dart';
import '../models/acta_model.dart';

// Limitación conocida: La sincronización offline usa estrategia "último en escribir gana".
// En escenarios con múltiples veedores offline en la misma mesa, podría haber pérdida de datos.
// Una solución más robusta requeriría MVCC o un servidor de reconciliación.
class ActaRepositoryImpl implements ActaRepository {
  final ActaDatasource datasource;
  final HiveService? hiveService;

  ActaRepositoryImpl(this.datasource, {this.hiveService});

  @override
  Future<void> crearActa(Acta acta) async {
    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity.any((r) => r != ConnectivityResult.none);

    if (!online && hiveService != null) {
      await hiveService!.saveActaLocal(acta);
      return;
    }

    try {
      await datasource.crearActa(ActaModel(
        junta: acta.junta,
        provincia: acta.provincia,
        canton: acta.canton,
        parroquia: acta.parroquia,
        dignidad: acta.dignidad,
        votosOrganizaciones: acta.votosOrganizaciones,
        blancos: acta.blancos,
        nulos: acta.nulos,
        totalSufragantes: acta.totalSufragantes,
        fotoId: acta.fotoId,
        fecha: acta.fecha,
        imagenValida: acta.imagenValida,
        latitud: acta.latitud,
        longitud: acta.longitud,
        userId: acta.userId,
      ));
    } catch (_) {
      if (hiveService != null) {
        await hiveService!.saveActaLocal(acta);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<List<Acta>> obtenerActas({String? userId}) async {
    try {
      final data = await datasource.obtenerActas(userId: userId);
      return data.map((e) {
        final docId = e['\$id'] as String?;
        return ActaModel.fromJson(e, docId: docId);
      }).toList();
    } catch (_) {
      if (hiveService != null) {
        return hiveService!.getAllLocalActas();
      }
      return [];
    }
  }

  @override
  Future<void> actualizarActa(String id, Acta acta) async {
    await datasource.actualizarActa(id, ActaModel(
      junta: acta.junta,
      provincia: acta.provincia,
      canton: acta.canton,
      parroquia: acta.parroquia,
      dignidad: acta.dignidad,
      votosOrganizaciones: acta.votosOrganizaciones,
      blancos: acta.blancos,
      nulos: acta.nulos,
      totalSufragantes: acta.totalSufragantes,
      fotoId: acta.fotoId,
      fecha: acta.fecha,
      imagenValida: acta.imagenValida,
      latitud: acta.latitud,
      longitud: acta.longitud,
      userId: acta.userId,
      id: id,
    ).toJson());
  }
}



================================================
📄 ARCHIVO: lib\features\actas\domain\entities\acta.dart
================================================

class Acta {
  final int junta;
  final String provincia;
  final String canton;
  final String parroquia;
  final String dignidad;
  final List<int> votosOrganizaciones;
  final int blancos;
  final int nulos;
  final int totalSufragantes;
  final String fotoId;
  final DateTime fecha;
  final bool imagenValida;
  final double? latitud;
  final double? longitud;
  final String? userId;
  final String? id;

  Acta({
    required this.junta,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.dignidad,
    required this.votosOrganizaciones,
    required this.blancos,
    required this.nulos,
    required this.totalSufragantes,
    required this.fotoId,
    required this.fecha,
    required this.imagenValida,
    this.latitud,
    this.longitud,
    this.userId,
    this.id,
  });

  int get totalVotos =>
      votosOrganizaciones.fold(0, (a, b) => a + b) + blancos + nulos;

  bool get isValid => totalVotos <= totalSufragantes;

  Acta copyWith({
    int? junta,
    String? provincia,
    String? canton,
    String? parroquia,
    String? dignidad,
    List<int>? votosOrganizaciones,
    int? blancos,
    int? nulos,
    int? totalSufragantes,
    String? fotoId,
    DateTime? fecha,
    bool? imagenValida,
    double? latitud,
    double? longitud,
    String? userId,
    String? id,
  }) {
    return Acta(
      junta: junta ?? this.junta,
      provincia: provincia ?? this.provincia,
      canton: canton ?? this.canton,
      parroquia: parroquia ?? this.parroquia,
      dignidad: dignidad ?? this.dignidad,
      votosOrganizaciones: votosOrganizaciones ?? List.from(this.votosOrganizaciones),
      blancos: blancos ?? this.blancos,
      nulos: nulos ?? this.nulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      fotoId: fotoId ?? this.fotoId,
      fecha: fecha ?? this.fecha,
      imagenValida: imagenValida ?? this.imagenValida,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }
}



================================================
📄 ARCHIVO: lib\features\actas\domain\repositories\acta_repository.dart
================================================

import '../entities/acta.dart';

abstract class ActaRepository {
  Future<void> crearActa(Acta acta);
  Future<List<Acta>> obtenerActas({String? userId});
  Future<void> actualizarActa(String id, Acta acta);
}



================================================
📄 ARCHIVO: lib\features\actas\domain\usecases\actualizar_acta.dart
================================================

import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ActualizarActa {
  final ActaRepository repository;

  ActualizarActa(this.repository);

  Future<void> call(String id, Acta acta) {
    return repository.actualizarActa(id, acta);
  }
}



================================================
📄 ARCHIVO: lib\features\actas\domain\usecases\create_acta.dart
================================================

import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class CrearActa {
  final ActaRepository repository;

  CrearActa(this.repository);

  Future<void> call(Acta acta) {
    return repository.crearActa(acta);
  }
}



================================================
📄 ARCHIVO: lib\features\actas\domain\usecases\obtener_actas.dart
================================================

import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ObtenerActas {
  final ActaRepository repository;

  ObtenerActas(this.repository);

  Future<List<Acta>> call({String? userId}) {
    return repository.obtenerActas(userId: userId);
  }
}



================================================
📄 ARCHIVO: lib\features\actas\presentation\bloc\acta_bloc.dart
================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'acta_event.dart';
import 'acta_state.dart';
import '../../domain/usecases/create_acta.dart';
import '../../domain/usecases/obtener_actas.dart';
import '../../domain/usecases/actualizar_acta.dart';

class ActaBloc extends Bloc<ActaEvent, ActaState> {
  final CrearActa crearActa;
  final ObtenerActas obtenerActas;
  final ActualizarActa actualizarActa;

  ActaBloc({
    required this.crearActa,
    required this.obtenerActas,
    required this.actualizarActa,
  }) : super(ActaInitial()) {

    on<CrearActaEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        await crearActa(event.acta);
        emit(ActaSuccess());
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });

    on<CargarActasEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        final actas = await obtenerActas(userId: event.userId);
        emit(ActasLoaded(actas));
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });

    on<ActualizarActaEvent>((event, emit) async {
      emit(ActaLoading());
      try {
        await actualizarActa(event.id, event.acta);
        emit(ActaSuccess());
      } catch (e) {
        emit(ActaError(e.toString()));
      }
    });
  }
}



================================================
📄 ARCHIVO: lib\features\actas\presentation\bloc\acta_event.dart
================================================

import '../../domain/entities/acta.dart';

abstract class ActaEvent {}

class CrearActaEvent extends ActaEvent {
  final Acta acta;
  CrearActaEvent(this.acta);
}

class CargarActasEvent extends ActaEvent {
  final String? userId;
  CargarActasEvent({this.userId});
}

class ActualizarActaEvent extends ActaEvent {
  final String id;
  final Acta acta;
  ActualizarActaEvent(this.id, this.acta);
}



================================================
📄 ARCHIVO: lib\features\actas\presentation\bloc\acta_state.dart
================================================

import '../../domain/entities/acta.dart';

abstract class ActaState {}

class ActaInitial extends ActaState {}

class ActaLoading extends ActaState {}

class ActaSuccess extends ActaState {}

class ActasLoaded extends ActaState {
  final List<Acta> actas;
  ActasLoaded(this.actas);
}

class ActaError extends ActaState {
  final String message;
  ActaError(this.message);
}



================================================
📄 ARCHIVO: lib\features\actas\presentation\pages\dashboard_page.dart
================================================

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
      final datasource = ActaDatasource(tablesDB);
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
      body: _loading
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


================================================
📄 ARCHIVO: lib\features\actas\presentation\pages\form_acta_page.dart
================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/image_service.dart';
import '../../../../core/storage_service.dart';
import '../../../../core/appwrite_client.dart';
import '../../../../core/political_organizations.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';
import '../../domain/entities/acta.dart';

class FormActaPage extends StatefulWidget {
  final Acta? actaExistente;
  const FormActaPage({super.key, this.actaExistente});

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
  final List<String> _provincias = ['Pichincha', 'Guayas', 'Azuay'];

  bool _actaAlcaldeCompletada = false;
  bool _actaPrefectoCompletada = false;

  @override
  void initState() {
    super.initState();
    storageService = StorageService(storage);

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
    final messenger = ScaffoldMessenger.of(context);
    await _obtenerGPS();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
    });

    if (_latitud == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Foto tomada. Advertencia: no se obtuvo GPS.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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

    if (imageFile == null && widget.actaExistente == null) {
      _mostrarError('Debe tomar una foto del acta.');
      return;
    }

    if (imageFile != null) {
      final isBlurry = ImageService.isImageBlurry(imageFile!);
      if (isBlurry) {
        _mostrarError('Imagen borrosa. Tome la foto nuevamente.');
        return;
      }
    }

    if (_latitud == null || _longitud == null) {
      _mostrarError('No se pudo obtener las coordenadas GPS.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String fotoId = widget.actaExistente?.fotoId ?? '';
      if (imageFile != null) {
        fotoId = await storageService.uploadImage(imageFile!);
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
      );

      if (!mounted) return;

      if (widget.actaExistente?.id != null && widget.actaExistente!.id!.isNotEmpty) {
        context.read<ActaBloc>().add(ActualizarActaEvent(widget.actaExistente!.id!, acta));
      } else {
        context.read<ActaBloc>().add(CrearActaEvent(acta));
      }

      if (dignidad == 'alcalde') {
        setState(() => _actaAlcaldeCompletada = true);
      } else {
        setState(() => _actaPrefectoCompletada = true);
      }

      _mostrarExito('Acta de $dignidad guardada correctamente.');

      if (_actaAlcaldeCompletada && _actaPrefectoCompletada) {
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarError('Error al guardar: $e');
    } finally {
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
      body: BlocListener<ActaBloc, ActaState>(
        listener: (context, state) {
          if (state is ActaError) {
            _mostrarError(state.message);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: 'Datos del recinto',
              icon: Icons.location_city,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _provinciaSeleccionada,
                  decoration: _inputDeco('Provincia'),
                  items: _provincias.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _provinciaSeleccionada = v!),
                ),
                _input(canton, 'Cantón'),
                _input(parroquia, 'Parroquia'),
                _input(junta, 'Número de mesa (JRV)', keyboardType: TextInputType.number),
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
                  onSelectionChanged: (v) => setState(() => _dignidadSeleccionada = v.first),
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
                        Text(
                          'GPS: ${_latitud!.toStringAsFixed(5)}, ${_longitud!.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                if (imageFile == null && widget.actaExistente == null)
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
                  )
                else if (imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, height: 200, fit: BoxFit.cover, width: double.infinity),
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
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      );

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



================================================
📄 ARCHIVO: lib\features\actas\presentation\pages\list_actas_page.dart
================================================

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



================================================
📄 ARCHIVO: lib\features\auth\data\datasources\auth_remote_datasource.dart
================================================

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../../../core/appwrite_client.dart';

// Limitación conocida: la creación de usuarios (coordinadores de recinto y
// veedores) requiere normalmente la Appwrite Admin API (server-side, con
// API Key), que no debería invocarse desde el cliente Flutter en producción
// por motivos de seguridad. Para esta entrega académica se usa
// `account.create()` que SÍ es válido desde el cliente, pero tiene una
// limitación: la sesión activa del creador (coordinador) se pierde al crear
// la cuenta del nuevo usuario, porque el SDK cliente de Appwrite cambia de
// contexto de sesión. Por eso, inmediatamente después de crear el usuario
// nuevo se debe restaurar la sesión original del coordinador (ver
// AuthRepositoryImpl.crearUsuario). En un entorno productivo real esto se
// resolvería con una Appwrite Function (server-side) que use la Admin API
// con API Key, sin tocar la sesión del cliente.
class AuthRemoteDataSource {
  AuthRemoteDataSource();

  Account get _account => Account(client);

  /// Login por cédula: primero se busca el documento de usuario por cédula
  /// para obtener el email real asociado, luego se autentica contra
  /// Appwrite Auth con ese email + password.
  Future<String> obtenerEmailPorCedula(String cedula) async {
    final result = await tablesDB.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      queries: [Query.equal('cedula', cedula)],
    );
    if (result.rows.isEmpty) {
      throw Exception('No existe una cuenta registrada con esa cédula.');
    }
    final email = result.rows.first.data['email'] as String?;
    if (email == null || email.isEmpty) {
      throw Exception('La cuenta no tiene un correo asociado. Contacte a su coordinador.');
    }
    return email;
  }

  Future<User> login(String email, String password) async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // No había sesión activa, continuar normalmente.
    }
    await _account.createEmailPasswordSession(email: email, password: password);
    return await _account.get();
  }

  Future<void> sendPasswordReset(String email) async {
    await _account.createRecovery(
      email: email,
      url: 'sistema-electoral://recovery',
    );
  }

  Future<User> changePassword(String newPassword, String oldPassword) async {
    return await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      await _account.deleteSessions();
    }
  }

  Future<User> getCurrentUser() async {
    return await _account.get();
  }

  /// Crea la cuenta real en Appwrite Auth (no solo el documento de la
  /// colección `users`). Devuelve el $id del usuario creado en Auth.
  ///
  /// IMPORTANTE: esto cierra la sesión actual del coordinador porque el SDK
  /// cliente de Appwrite no permite crear otro usuario sin afectar la
  /// sesión activa. El llamador debe volver a iniciar sesión con las
  /// credenciales del coordinador después de esta operación (ver
  /// AuthRepositoryImpl.crearUsuario, que orquesta esto).
  Future<String> crearCuentaAuth({
    required String email,
    required String password,
    required String nombreCompleto,
  }) async {
    final nuevoUsuario = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: nombreCompleto,
    );
    return nuevoUsuario.$id;
  }

  /// Envía el correo de verificación de cuenta. Debe llamarse estando
  /// autenticado como el usuario recién creado (por eso se invoca justo
  /// después de crearCuentaAuth, antes de restaurar la sesión original).
  Future<void> enviarVerificacionEmail() async {
    await _account.createVerification(
      url: 'sistema-electoral://verify',
    );
  }
}


================================================
📄 ARCHIVO: lib\features\auth\data\models\user_model.dart
================================================

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({
    required super.id,
    required super.authUserId,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.email,
    required super.role,
    required super.mustChangePassword,
    super.recintoId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return UserModel(
      id: docId ?? json['\$id'] as String? ?? '',
      authUserId: json['authUserId'] as String? ?? '',
      cedula: json['cedula'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _parseRole(json['rol'] as String? ?? 'observer'),
      mustChangePassword: _parseBool(json['mustChangePassword']),
      recintoId: json['recintoId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'authUserId': authUserId,
    'cedula': cedula,
    'nombres': nombres,
    'apellidos': apellidos,
    'telefono': telefono,
    'email': email,
    'rol': role.name,
    'mustChangePassword': mustChangePassword,
    'recintoId': recintoId,
  };

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true; // por defecto, todo usuario nuevo debe cambiar password
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'coordinatorProvincial':
        return UserRole.coordinatorProvincial;
      case 'coordinatorRecinto':
        return UserRole.coordinatorRecinto;
      default:
        return UserRole.observer;
    }
  }
}


================================================
📄 ARCHIVO: lib\features\auth\data\repositories\auth_repository_impl.dart
================================================

import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

const String _passwordInicial = 'Ecuador2026';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TablesDB db;

  AuthRepositoryImpl(this.remoteDataSource, this.db);

  @override
  Future<AppUser> loginConCedula(String cedula, String password) async {
    final email = await remoteDataSource.obtenerEmailPorCedula(cedula);
    final authUser = await remoteDataSource.login(email, password);
    return _obtenerPerfilPorAuthId(authUser.$id);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<AppUser> changePassword(String newPassword, String oldPassword) async {
    final authUser = await remoteDataSource.changePassword(newPassword, oldPassword);
    final perfilActual = await _obtenerPerfilPorAuthId(authUser.$id);
    await db.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      rowId: perfilActual.id,
      data: {'mustChangePassword': false},
    );
    return UserModel(
      id: perfilActual.id,
      authUserId: perfilActual.authUserId,
      cedula: perfilActual.cedula,
      nombres: perfilActual.nombres,
      apellidos: perfilActual.apellidos,
      telefono: perfilActual.telefono,
      email: perfilActual.email,
      role: perfilActual.role,
      mustChangePassword: false,
      recintoId: perfilActual.recintoId,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<AppUser?> getUsuarioActual() async {
    try {
      final authUser = await remoteDataSource.getCurrentUser();
      return await _obtenerPerfilPorAuthId(authUser.$id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> crearUsuario({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole rol,
    String? recintoId,
    required String emailCoordinadorActual,
    required String passwordCoordinadorActual,
  }) async {
    // 1) Crear la cuenta real en Appwrite Auth con password inicial fija.
    final authUserId = await remoteDataSource.crearCuentaAuth(
      email: email,
      password: _passwordInicial,
      nombreCompleto: '$nombres $apellidos'.trim(),
    );

    // 2) Mientras la sesión activa es la del usuario recién creado, se envía
    //    el correo de verificación de cuenta.
    try {
      await remoteDataSource.enviarVerificacionEmail();
    } catch (_) {
      // Si falla el envío de verificación no se bloquea la creación del
      // usuario; se podría reintentar manualmente desde el panel.
    }

    // 3) Crear el documento de perfil en la colección `users`.
    await db.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      rowId: ID.unique(),
      data: UserModel(
        id: '',
        authUserId: authUserId,
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        email: email,
        role: rol,
        mustChangePassword: true,
        recintoId: recintoId,
      ).toJson(),
    );

    // 4) Restaurar la sesión del coordinador que estaba autenticado antes de
    //    crear este usuario nuevo (ver nota en AuthRemoteDataSource).
    await remoteDataSource.login(emailCoordinadorActual, passwordCoordinadorActual);
  }

  Future<UserModel> _obtenerPerfilPorAuthId(String authUserId) async {
    final result = await db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      queries: [Query.equal('authUserId', authUserId)],
    );
    if (result.rows.isEmpty) {
      throw Exception('No se encontró un perfil asociado a esta cuenta.');
    }
    final row = result.rows.first;
    return UserModel.fromJson(row.data, docId: row.$id);
  }
}


================================================
📄 ARCHIVO: lib\features\auth\domain\entities\app_user.dart
================================================

enum UserRole { coordinatorProvincial, coordinatorRecinto, observer }

class AppUser {
  final String id; // $id del documento en la colección users
  final String authUserId; // $id del usuario real en Appwrite Auth
  final String cedula; // usada como nombre de usuario para login
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole role;
  final bool mustChangePassword;
  final String? recintoId; // coordinador de recinto

  AppUser({
    required this.id,
    required this.authUserId,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.role,
    required this.mustChangePassword,
    this.recintoId,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();
}


================================================
📄 ARCHIVO: lib\features\auth\domain\repositories\auth_repository.dart
================================================

import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> loginConCedula(String cedula, String password);
  Future<void> sendPasswordReset(String email);
  Future<AppUser> changePassword(String newPassword, String oldPassword);
  Future<void> logout();
  Future<AppUser?> getUsuarioActual();

  /// Crea un nuevo usuario (coordinador de recinto o veedor) y restaura la
  /// sesión del coordinador que lo está creando.
  Future<void> crearUsuario({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole rol,
    String? recintoId,
    required String emailCoordinadorActual,
    required String passwordCoordinadorActual,
  });
}


================================================
📄 ARCHIVO: lib\features\auth\presentation\bloc\auth_bloc.dart
================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.loginConCedula(event.cedula, event.password);
        if (user.mustChangePassword) {
          emit(AuthRequirePasswordChange(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.sendPasswordReset(event.email);
        emit(AuthMessage('Se envió el correo de recuperación. Revisa tu bandeja de entrada.'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthChangePasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.changePassword(event.newPassword, event.oldPassword);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      try {
        await repository.logout();
      } catch (_) {}
      emit(AuthInitial());
    });

    on<AuthCheckStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.getUsuarioActual();
        if (user != null) {
          if (user.mustChangePassword) {
            emit(AuthRequirePasswordChange(user));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          emit(AuthInitial());
        }
      } catch (_) {
        emit(AuthInitial());
      }
    });

    on<AuthCrearUsuarioRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.crearUsuario(
          cedula: event.cedula,
          nombres: event.nombres,
          apellidos: event.apellidos,
          telefono: event.telefono,
          email: event.email,
          rol: event.rol,
          recintoId: event.recintoId,
          emailCoordinadorActual: event.emailCoordinadorActual,
          passwordCoordinadorActual: event.passwordCoordinadorActual,
        );
        emit(AuthUsuarioCreado());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRoleChanged>((event, emit) {});
  }
}


================================================
📄 ARCHIVO: lib\features\auth\presentation\bloc\auth_event.dart
================================================

import '../../domain/entities/app_user.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String cedula;
  final String password;
  AuthLoginRequested(this.cedula, this.password);
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  AuthForgotPasswordRequested(this.email);
}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  AuthChangePasswordRequested(this.oldPassword, this.newPassword);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthRoleChanged extends AuthEvent {
  final AppUser user;
  AuthRoleChanged(this.user);
}

class AuthCrearUsuarioRequested extends AuthEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final UserRole rol;
  final String? recintoId;
  final String emailCoordinadorActual;
  final String passwordCoordinadorActual;

  AuthCrearUsuarioRequested({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.rol,
    this.recintoId,
    required this.emailCoordinadorActual,
    required this.passwordCoordinadorActual,
  });
}


================================================
📄 ARCHIVO: lib\features\auth\presentation\bloc\auth_state.dart
================================================

import '../../domain/entities/app_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

class AuthRequirePasswordChange extends AuthState {
  final AppUser user;
  AuthRequirePasswordChange(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthMessage extends AuthState {
  final String message;
  AuthMessage(this.message);
}

class AuthUsuarioCreado extends AuthState {}


================================================
📄 ARCHIVO: lib\features\auth\presentation\pages\change_password_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    oldPasswordController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recibe el usuario para mostrar info contextual
    final user = ModalRoute.of(context)?.settings.arguments as AppUser?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home',
                arguments: state.user);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Hola, ${user.nombreCompleto}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Debes cambiar tu contraseña antes de continuar. La contraseña inicial es Ecuador2026.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureOld = !_obscureOld),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: loading ? null : _cambiarPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Cambiar contraseña',
                              style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cambiarPassword() {
    if (oldPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ingresa tu contraseña actual'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La nueva contraseña debe tener al menos 8 caracteres'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthChangePasswordRequested(
          oldPasswordController.text,
          passwordController.text,
        ));
  }
}


================================================
📄 ARCHIVO: lib\features\auth\presentation\pages\forgot_password_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa tu correo electrónico para recibir un enlace de recuperación.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: loading
                          ? null
                          : () => context.read<AuthBloc>().add(
                                AuthForgotPasswordRequested(emailController.text.trim()),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enviar enlace de recuperación'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



================================================
📄 ARCHIVO: lib\features\auth\presentation\pages\login_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final cedulaController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    cedulaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home', arguments: state.user);
          }
          if (state is AuthRequirePasswordChange) {
            Navigator.pushReplacementNamed(context, '/change-password',
                arguments: state.user);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is AuthMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A6B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.how_to_vote, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sistema Electoral',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A6B)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: cedulaController,
                    decoration: InputDecoration(
                      labelText: 'Cédula de identidad',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final loading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: loading
                              ? null
                              : () => context.read<AuthBloc>().add(
                                    AuthLoginRequested(
                                      cedulaController.text.trim(),
                                      passwordController.text,
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Ingresar',
                                  style: TextStyle(fontSize: 16)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


================================================
📄 ARCHIVO: lib\features\recintos\data\datasources\recinto_datasource.dart
================================================

import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/recinto_model.dart';

class RecintoDatasource {
  final TablesDB db;

  RecintoDatasource(this.db);

  Future<void> crearRecinto(RecintoModel recinto) async {
    await db.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
      rowId: ID.unique(),
      data: recinto.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerRecintos() async {
    final result = await db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
    );
    return result.rows.map((e) => e.data).toList();
  }

  Future<Map<String, dynamic>?> obtenerRecinto(String id) async {
    try {
      final doc = await db.getRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteRecintosCollectionId,
        rowId: id,
      );
      return doc.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarRecinto(String id, Map<String, dynamic> data) async {
    await db.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
      rowId: id,
      data: data,
    );
  }
}



================================================
📄 ARCHIVO: lib\features\recintos\data\models\recinto_model.dart
================================================

import '../../domain/entities/recinto.dart';

class RecintoModel extends Recinto {
  RecintoModel({
    super.id,
    required super.nombre,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.numeroJRV,
    super.coordinadorId,
  });

  factory RecintoModel.fromJson(Map<String, dynamic> json) {
    return RecintoModel(
      id: json['\$id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      provincia: json['provincia'] as String? ?? '',
      canton: json['canton'] as String? ?? '',
      parroquia: json['parroquia'] as String? ?? '',
      numeroJRV: json['numeroJRV'] as int? ?? 0,
      coordinadorId: json['coordinadorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'provincia': provincia,
    'canton': canton,
    'parroquia': parroquia,
    'numeroJRV': numeroJRV,
    'coordinadorId': coordinadorId,
  };
}



================================================
📄 ARCHIVO: lib\features\recintos\data\repositories\recinto_repository_impl.dart
================================================

import '../../domain/entities/recinto.dart';
import '../../domain/repositories/recinto_repository.dart';
import '../datasources/recinto_datasource.dart';
import '../models/recinto_model.dart';

class RecintoRepositoryImpl implements RecintoRepository {
  final RecintoDatasource datasource;

  RecintoRepositoryImpl(this.datasource);

  @override
  Future<void> crearRecinto(Recinto recinto) async {
    await datasource.crearRecinto(RecintoModel(
      nombre: recinto.nombre,
      provincia: recinto.provincia,
      canton: recinto.canton,
      parroquia: recinto.parroquia,
      numeroJRV: recinto.numeroJRV,
      coordinadorId: recinto.coordinadorId,
    ));
  }

  @override
  Future<List<Recinto>> obtenerRecintos() async {
    final data = await datasource.obtenerRecintos();
    return data.map((e) => RecintoModel.fromJson(e)).toList();
  }

  @override
  Future<Recinto?> obtenerRecinto(String id) async {
    final data = await datasource.obtenerRecinto(id);
    if (data == null) return null;
    return RecintoModel.fromJson({...data, '\$id': id});
  }

  @override
  Future<void> asignarCoordinador(String recintoId, String userId) async {
    await datasource.actualizarRecinto(recintoId, {'coordinadorId': userId});
  }
}



================================================
📄 ARCHIVO: lib\features\recintos\domain\entities\recinto.dart
================================================

class Recinto {
  final String? id;
  final String nombre;
  final String provincia;
  final String canton;
  final String parroquia;
  final int numeroJRV;
  final String? coordinadorId;

  Recinto({
    this.id,
    required this.nombre,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.numeroJRV,
    this.coordinadorId,
  });
}



================================================
📄 ARCHIVO: lib\features\recintos\domain\repositories\recinto_repository.dart
================================================

import '../entities/recinto.dart';

abstract class RecintoRepository {
  Future<void> crearRecinto(Recinto recinto);
  Future<List<Recinto>> obtenerRecintos();
  Future<Recinto?> obtenerRecinto(String id);
  Future<void> asignarCoordinador(String recintoId, String userId);
}



================================================
📄 ARCHIVO: lib\features\recintos\domain\usecases\asignar_coordinador.dart
================================================

import '../repositories/recinto_repository.dart';

class AsignarCoordinador {
  final RecintoRepository repository;
  AsignarCoordinador(this.repository);

  Future<void> call(String recintoId, String userId) =>
      repository.asignarCoordinador(recintoId, userId);
}



================================================
📄 ARCHIVO: lib\features\recintos\domain\usecases\crear_recinto.dart
================================================

import '../entities/recinto.dart';
import '../repositories/recinto_repository.dart';

class CrearRecinto {
  final RecintoRepository repository;
  CrearRecinto(this.repository);

  Future<void> call(Recinto recinto) => repository.crearRecinto(recinto);
}



================================================
📄 ARCHIVO: lib\features\recintos\domain\usecases\obtener_recintos.dart
================================================

import '../entities/recinto.dart';
import '../repositories/recinto_repository.dart';

class ObtenerRecintos {
  final RecintoRepository repository;
  ObtenerRecintos(this.repository);

  Future<List<Recinto>> call() => repository.obtenerRecintos();
}



================================================
📄 ARCHIVO: lib\features\recintos\presentation\bloc\recinto_bloc.dart
================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'recinto_event.dart';
import 'recinto_state.dart';
import '../../domain/usecases/crear_recinto.dart';
import '../../domain/usecases/obtener_recintos.dart';
import '../../domain/usecases/asignar_coordinador.dart';

class RecintoBloc extends Bloc<RecintoEvent, RecintoState> {
  final CrearRecinto crearRecinto;
  final ObtenerRecintos obtenerRecintos;
  final AsignarCoordinador asignarCoordinador;

  RecintoBloc({
    required this.crearRecinto,
    required this.obtenerRecintos,
    required this.asignarCoordinador,
  }) : super(RecintoInitial()) {

    on<CrearRecintoEvent>((event, emit) async {
      emit(RecintoLoading());
      try {
        await crearRecinto(event.recinto);
        emit(RecintoSuccess());
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });

    on<CargarRecintosEvent>((event, emit) async {
      emit(RecintoLoading());
      try {
        final recintos = await obtenerRecintos();
        emit(RecintosLoaded(recintos));
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });

    on<AsignarCoordinadorEvent>((event, emit) async {
      try {
        await asignarCoordinador(event.recintoId, event.userId);
        add(CargarRecintosEvent());
      } catch (e) {
        emit(RecintoError(e.toString()));
      }
    });
  }
}



================================================
📄 ARCHIVO: lib\features\recintos\presentation\bloc\recinto_event.dart
================================================

import '../../domain/entities/recinto.dart';

abstract class RecintoEvent {}

class CrearRecintoEvent extends RecintoEvent {
  final Recinto recinto;
  CrearRecintoEvent(this.recinto);
}

class CargarRecintosEvent extends RecintoEvent {}

class AsignarCoordinadorEvent extends RecintoEvent {
  final String recintoId;
  final String userId;
  AsignarCoordinadorEvent(this.recintoId, this.userId);
}



================================================
📄 ARCHIVO: lib\features\recintos\presentation\bloc\recinto_state.dart
================================================

import '../../domain/entities/recinto.dart';

abstract class RecintoState {}

class RecintoInitial extends RecintoState {}

class RecintoLoading extends RecintoState {}

class RecintoSuccess extends RecintoState {}

class RecintosLoaded extends RecintoState {
  final List<Recinto> recintos;
  RecintosLoaded(this.recintos);
}

class RecintoError extends RecintoState {
  final String message;
  RecintoError(this.message);
}



================================================
📄 ARCHIVO: lib\features\recintos\presentation\pages\coordinador_recinto_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cedula_validator.dart';
import '../../../../core/appwrite_client.dart';
import '../../../actas/presentation/bloc/acta_bloc.dart';
import '../../../actas/presentation/bloc/acta_event.dart';
import '../../../actas/presentation/bloc/acta_state.dart';
import '../../../actas/presentation/pages/form_acta_page.dart';
import '../../../actas/domain/entities/acta.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/app_user.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<ActaBloc>().add(CargarActasEvent());
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _mesaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUsuarioCreado) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veedor creado. Contraseña inicial: Ecuador2026'),
              backgroundColor: Colors.green,
            ),
          );
          _limpiarFormulario();
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
          _card(
            icon: Icons.table_chart,
            title: 'Mesas del Recinto',
            child: BlocBuilder<ActaBloc, ActaState>(
              builder: (context, state) {
                if (state is ActaLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A3A6B)));
                }
                if (state is ActasLoaded) {
                  final mesas =
                      state.actas.map((a) => a.junta).toSet().toList()..sort();
                  if (mesas.isEmpty) {
                    return const Text('No hay mesas con actas registradas aún.');
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mesas
                        .map((m) => Chip(
                              label: Text('Mesa $m'),
                              avatar: const Icon(Icons.check_circle,
                                  size: 18, color: Colors.green),
                            ))
                        .toList(),
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
                MaterialPageRoute(builder: (_) => const FormActaPage()),
              ),
            ),
          ),
        ],
      ),
    );
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
          passwordCoordinadorActual: '',
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
              final actas = state.actas;
              if (actas.isEmpty) {
                return const Center(child: Text('No hay actas registradas.'));
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
                            builder: (_) => FormActaPage(actaExistente: a),
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
}


================================================
📄 ARCHIVO: lib\features\recintos\presentation\pages\crear_coordinador_page.dart
================================================




================================================
📄 ARCHIVO: lib\features\recintos\presentation\pages\crear_recinto_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recinto.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CrearRecintoPage extends StatefulWidget {
  const CrearRecintoPage({super.key});

  @override
  State<CrearRecintoPage> createState() => _CrearRecintoPageState();
}

class _CrearRecintoPageState extends State<CrearRecintoPage> {
  final nombreCtrl = TextEditingController();
  final provinciaCtrl = TextEditingController();
  final cantonCtrl = TextEditingController();
  final parroquiaCtrl = TextEditingController();
  final jrvCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Crear Recinto'),
        backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
      ),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is RecintoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recinto creado correctamente'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _input(nombreCtrl, 'Nombre del recinto'),
            _input(provinciaCtrl, 'Provincia'),
            _input(cantonCtrl, 'Cantón'),
            _input(parroquiaCtrl, 'Parroquia'),
            _input(jrvCtrl, 'Número de JRV', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: BlocBuilder<RecintoBloc, RecintoState>(
                builder: (context, state) {
                  final loading = state is RecintoLoading;
                  return ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(loading ? 'Guardando...' : 'Guardar Recinto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: loading ? null : () {
                      context.read<RecintoBloc>().add(CrearRecintoEvent(Recinto(
                        nombre: nombreCtrl.text,
                        provincia: provinciaCtrl.text,
                        canton: cantonCtrl.text,
                        parroquia: parroquiaCtrl.text,
                        numeroJRV: int.tryParse(jrvCtrl.text) ?? 0,
                      )));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          filled: true, fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}



================================================
📄 ARCHIVO: lib\features\recintos\presentation\pages\listar_recintos_page.dart
================================================

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
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearRecintoPage()));
              if (!context.mounted) return;
              context.read<RecintoBloc>().add(CargarRecintosEvent());
            },
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
                    onTap: () => _mostrarDetalle(context, r.id, r.nombre, r.numeroJRV),
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

  void _mostrarDetalle(BuildContext context, String? id, String nombre, int numeroJRV) {
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
            _opcion(ctx, 'Ver avance (actas registradas vs pendientes)', Icons.bar_chart, () async {
              Navigator.pop(ctx);
              await _mostrarAvance(context, id, nombre, numeroJRV);
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
    final datasource = ActaDatasource(tablesDB);
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
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
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

  Future<void> _mostrarAvance(BuildContext context, String? recintoId, String nombre, int numeroJRV) async {
    final datasource = ActaDatasource(tablesDB);
    try {
      final actas = await datasource.obtenerActas();
      final actasAlcalde = actas.where((a) => a['dignidad'] == 'alcalde').length;
      final actasPrefecto = actas.where((a) => a['dignidad'] == 'prefecto').length;
      final totalRegistradas = actasAlcalde + actasPrefecto;
      final totalEsperado = numeroJRV * 2;
      final pendientes = totalEsperado - totalRegistradas;

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Avance — $nombre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Actas de Alcalde registradas: $actasAlcalde / $numeroJRV'),
              const SizedBox(height: 4),
              Text('Actas de Prefecto registradas: $actasPrefecto / $numeroJRV'),
              const SizedBox(height: 4),
              Text('Total registradas: $totalRegistradas / $totalEsperado'),
              const SizedBox(height: 4),
              Text('Pendientes: $pendientes'),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar avance: $e'), backgroundColor: Colors.red),
      );
    }
  }
}



================================================
📄 ARCHIVO: lib\main.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/appwrite_client.dart';
import 'core/connectivity_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';

import 'features/actas/data/datasources/acta_datasource.dart';
import 'features/actas/data/repositories/acta_repository_impl.dart';
import 'features/actas/domain/repositories/acta_repository.dart';
import 'features/actas/domain/usecases/create_acta.dart';
import 'features/actas/domain/usecases/obtener_actas.dart';
import 'features/actas/domain/usecases/actualizar_acta.dart';
import 'features/actas/presentation/bloc/acta_bloc.dart';
import 'features/actas/presentation/bloc/acta_event.dart';
import 'features/actas/presentation/pages/form_acta_page.dart';
import 'features/actas/presentation/pages/list_actas_page.dart';
import 'features/actas/presentation/pages/dashboard_page.dart';

import 'features/recintos/data/datasources/recinto_datasource.dart';
import 'features/recintos/data/repositories/recinto_repository_impl.dart';
import 'features/recintos/domain/repositories/recinto_repository.dart';
import 'features/recintos/domain/usecases/crear_recinto.dart';
import 'features/recintos/domain/usecases/obtener_recintos.dart';
import 'features/recintos/domain/usecases/asignar_coordinador.dart';
import 'features/recintos/presentation/bloc/recinto_bloc.dart';
import 'features/recintos/presentation/pages/listar_recintos_page.dart';
import 'features/recintos/presentation/pages/coordinador_recinto_page.dart';

import 'offline/hive_service.dart';
import 'offline/sync_service.dart';

late final HiveService hiveService;
late final SyncService syncService;
final ConnectivityService connectivityService = ConnectivityService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hiveService = await HiveService.init();

  final actaDatasource = ActaDatasource(tablesDB);
  final actaRepository =
      ActaRepositoryImpl(actaDatasource, hiveService: hiveService);
  syncService = SyncService(hiveService, actaDatasource);

  connectivityService.onConnectivityChanged = (_) async {
    await syncService.syncPendingActas();
  };
  connectivityService.startMonitoring();

  final authRemoteDS = AuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(authRemoteDS, tablesDB);
  final recintoDatasource = RecintoDatasource(tablesDB);
  final recintoRepository = RecintoRepositoryImpl(recintoDatasource);

  runApp(MyApp(
    authRepository: authRepository,
    actaRepository: actaRepository,
    recintoRepository: recintoRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ActaRepository actaRepository;
  final RecintoRepository recintoRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.actaRepository,
    required this.recintoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository)..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => ActaBloc(
            crearActa: CrearActa(actaRepository),
            obtenerActas: ObtenerActas(actaRepository),
            actualizarActa: ActualizarActa(actaRepository),
          )..add(CargarActasEvent()),
        ),
        BlocProvider(
          create: (_) => RecintoBloc(
            crearRecinto: CrearRecinto(recintoRepository),
            obtenerRecintos: ObtenerRecintos(recintoRepository),
            asignarCoordinador: AsignarCoordinador(recintoRepository),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema Electoral',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1A3A6B),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/forgot-password':
              return MaterialPageRoute(
                  builder: (_) => const ForgotPasswordPage());
            case '/change-password':
              return MaterialPageRoute(
                builder: (_) => const ChangePasswordPage(),
                settings: settings,
              );
            case '/home':
              final args = settings.arguments as AppUser?;
              return MaterialPageRoute(builder: (_) => HomePage(user: args));
            default:
              return MaterialPageRoute(builder: (_) => const LoginPage());
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final AppUser? user;
  const HomePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final role = user?.role;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is AuthInitial) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('Sistema Electoral — ${_roleName(role)}'),
          backgroundColor: const Color(0xFF1A3A6B),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            if (user != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  user!.nombreCompleto,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthLogoutRequested()),
            ),
          ],
        ),
        body: role == UserRole.coordinatorProvincial
            ? _buildProvincialPanel(context)
            : role == UserRole.coordinatorRecinto
                ? CoordinadorRecintoPage(
                    recintoId: user?.recintoId ?? user?.id ?? '',
                    userId: user?.id ?? '',
                    currentUser: user,
                  )
                : _buildVeedorPanel(context),
      ),
    );
  }

  String _roleName(UserRole? role) {
    switch (role) {
      case UserRole.coordinatorProvincial:
        return 'Coordinador Provincial';
      case UserRole.coordinatorRecinto:
        return 'Coordinador de Recinto';
      case UserRole.observer:
        return 'Veedor';
      default:
        return 'Usuario';
    }
  }

  Widget _buildProvincialPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          icon: Icons.bar_chart,
          title: 'Dashboard de Votos',
          subtitle: 'Votos consolidados por candidato y recinto',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.location_city,
          title: 'Gestión de Recintos',
          subtitle: 'Crear y administrar recintos electorales',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<RecintoBloc>(),
                child: const ListarRecintosPage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.description,
          title: 'Ver todas las actas',
          subtitle: 'Actas registradas con coordenadas GPS y estado',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ActaBloc>(),
                child: const ListActasPage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.sync,
          title: 'Sincronizar datos pendientes',
          subtitle: 'Forzar sincronización de actas offline',
          onTap: () async {
            await syncService.syncPendingActas();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sincronización completada'),
                    backgroundColor: Colors.green),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVeedorPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          icon: Icons.add,
          title: 'Registrar Acta',
          subtitle: 'Tomar foto y registrar votos (Alcalde y Prefecto)',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormActaPage()),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.list_alt,
          title: 'Ver mis actas',
          subtitle: 'Actas registradas y su estado',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListActasPage()),
          ),
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A3A6B),
          foregroundColor: Colors.white,
          child: Icon(icon, size: 22),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}


================================================
📄 ARCHIVO: lib\offline\hive_service.dart
================================================

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/actas/domain/entities/acta.dart';

class HiveService {
  static const String _boxName = 'offline_actas';
  static const String _pendingBoxName = 'pending_sync';
  late Box<String> _box;
  late Box<String> _pendingBox;

  static Future<HiveService> init() async {
    await Hive.initFlutter();
    final service = HiveService();
    service._box = await Hive.openBox<String>(_boxName);
    service._pendingBox = await Hive.openBox<String>(_pendingBoxName);
    return service;
  }

  Future<void> saveActaLocal(Acta acta) async {
    final key = '${acta.junta}_${acta.dignidad}_${DateTime.now().millisecondsSinceEpoch}';
    await _box.put(key, jsonEncode({
      'junta': acta.junta,
      'provincia': acta.provincia,
      'canton': acta.canton,
      'parroquia': acta.parroquia,
      'dignidad': acta.dignidad,
      'votosOrganizaciones': acta.votosOrganizaciones,
      'blancos': acta.blancos,
      'nulos': acta.nulos,
      'totalSufragantes': acta.totalSufragantes,
      'fotoId': acta.fotoId,
      'fecha': acta.fecha.toIso8601String(),
      'imagenValida': acta.imagenValida,
      'latitud': acta.latitud,
      'longitud': acta.longitud,
      'userId': acta.userId,
      'synced': false,
    }));
    await _pendingBox.put(key, 'pending');
  }

  Future<List<Map<String, dynamic>>> getPendingActas() async {
    final keys = _pendingBox.keys.toList();
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      final data = _box.get(key);
      if (data != null) {
        result.add({...jsonDecode(data) as Map<String, dynamic>, '_key': key});
      }
    }
    return result;
  }

  Future<void> markSynced(String key) async {
    await _pendingBox.delete(key);
    final data = _box.get(key);
    if (data != null) {
      final map = jsonDecode(data) as Map<String, dynamic>;
      map['synced'] = true;
      await _box.put(key, jsonEncode(map));
    }
  }

  Future<void> removeActa(String key) async {
    await _box.delete(key);
    await _pendingBox.delete(key);
  }

  Future<List<Acta>> getAllLocalActas() async {
    final keys = _box.keys.toList();
    final result = <Acta>[];
    for (final key in keys) {
      final data = _box.get(key);
      if (data != null) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        result.add(Acta(
          junta: map['junta'] as int,
          provincia: map['provincia'] as String? ?? '',
          canton: map['canton'] as String? ?? '',
          parroquia: map['parroquia'] as String? ?? '',
          dignidad: map['dignidad'] as String? ?? 'alcalde',
          votosOrganizaciones: (map['votosOrganizaciones'] as List).cast<int>(),
          blancos: map['blancos'] as int? ?? 0,
          nulos: map['nulos'] as int? ?? 0,
          totalSufragantes: map['totalSufragantes'] as int? ?? 0,
          fotoId: map['fotoId'] as String? ?? '',
          fecha: DateTime.parse(map['fecha'] as String),
          imagenValida: map['imagenValida'] as bool? ?? true,
          latitud: map['latitud'] as double?,
          longitud: map['longitud'] as double?,
          userId: map['userId'] as String?,
        ));
      }
    }
    return result;
  }

  bool hasPending() => _pendingBox.isNotEmpty;
}



================================================
📄 ARCHIVO: lib\offline\sync_service.dart
================================================

import '../features/actas/data/datasources/acta_datasource.dart';
import '../features/actas/data/models/acta_model.dart';
import 'hive_service.dart';

class SyncService {
  final HiveService _hive;
  final ActaDatasource _datasource;

  SyncService(this._hive, this._datasource);

  Future<void> syncPendingActas() async {
    final pending = await _hive.getPendingActas();
    for (final item in pending) {
      try {
        final key = item['_key'] as String;
        await _datasource.crearActa(ActaModel(
          junta: item['junta'] as int,
          provincia: item['provincia'] as String? ?? '',
          canton: item['canton'] as String? ?? '',
          parroquia: item['parroquia'] as String? ?? '',
          dignidad: item['dignidad'] as String? ?? 'alcalde',
          votosOrganizaciones: (item['votosOrganizaciones'] as List).cast<int>(),
          blancos: item['blancos'] as int? ?? 0,
          nulos: item['nulos'] as int? ?? 0,
          totalSufragantes: item['totalSufragantes'] as int? ?? 0,
          fotoId: item['fotoId'] as String? ?? '',
          fecha: DateTime.parse(item['fecha'] as String),
          imagenValida: item['imagenValida'] as bool? ?? true,
          latitud: item['latitud'] as double?,
          longitud: item['longitud'] as double?,
          userId: item['userId'] as String?,
        ));
        await _hive.markSynced(key);
      } catch (_) {
        // Conflict: keep as pending for next sync
      }
    }
  }
}



================================================
📄 ARCHIVO: pubspec.yaml
================================================

name: sistema_electoral
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.11.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  appwrite: ^25.2.0
  flutter_bloc: ^9.1.1
  image_picker: ^1.2.2
  image: ^4.9.1
  geolocator: ^13.0.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^7.1.1
  path_provider: ^2.0.17

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true


================================================
📄 ARCHIVO: README.md
================================================

# Sistema Electoral

Aplicación Flutter para la gestión de actas electorales con tres roles de usuario, persistencia offline y sincronización automática.

## Requisitos

- Flutter SDK 3.11+
- Dispositivo con Android 5.0+ o iOS 12+ (cámara y GPS requeridos)

## Instalación y ejecución

```bash
flutter pub get
flutter run
```

## Credenciales de prueba

Las credenciales deben ser creadas en la consola de Appwrite. A continuación se describen los usuarios de prueba sugeridos:

| Rol | Email | Contraseña |
|---|---|---|
| Coordinador Provincial | provincial@test.com | password123 |
| Coordinador de Recinto | recinto@test.com | password123 |
| Veedor | veedor@test.com | password123 |

> **Nota**: Los usuarios se gestionan mediante la colección `app_users` de Appwrite. Para crear usuarios de prueba, usa la consola de Appwrite:
> 1. Crea los usuarios en Appwrite Authentication
> 2. Crea documentos en la colección `app_users` con los campos: `email`, `role` (coordinatorProvincial / coordinatorRecinto / observer), `mustChangePassword`, `recintoId` (opcional), `mesaId` (opcional)

## Modelo de datos

### Colección `actas`
| Campo | Tipo | Descripción |
|---|---|---|
| junta | number | Número de mesa (JRV) |
| provincia | string | Provincia electoral |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| dignidad | string | "alcalde" o "prefecto" |
| votosOrganizaciones | number[] | Array de 5 enteros (votos por organización política) |
| blancos | number | Votos en blanco |
| nulos | number | Votos nulos |
| totalSufragantes | number | Total de sufragantes registrados en la mesa |
| fotoId | string | ID del archivo en Appwrite Storage |
| fecha | datetime | Fecha y hora del registro |
| imagenValida | boolean | Resultado de validación de nitidez |
| latitud | number? | Coordenada GPS latitud |
| longitud | number? | Coordenada GPS longitud |
| userId | string? | ID del veedor que registró |

### Colección `recintos`
| Campo | Tipo | Descripción |
|---|---|---|
| nombre | string | Nombre del recinto |
| provincia | string | Provincia |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| numeroJRV | number | Cantidad de JRV en el recinto |
| coordinadorId | string? | ID del coordinador asignado |

### Colección `app_users`
| Campo | Tipo | Descripción |
|---|---|---|
| email | string | Correo electrónico |
| role | string | "coordinatorProvincial", "coordinatorRecinto", "observer" |
| mustChangePassword | boolean | Si debe cambiar contraseña en primer login |
| recintoId | string? | ID del recinto asignado (coordinador de recinto y veedor) |
| mesaId | number? | Número de mesa asignada (veedor) |

## Organizaciones políticas precargadas

### Alcalde
1. Pabel Muñoz — Movimiento Pueblo Igual
2. Jorge Yunda — Avanza
3. John Reimberg — ADN
4. Marlene Cevallos — Movimiento Social
5. Mario Jaramillo — Partido Liberal

### Prefecto
1. Rosa Cárdenas — Movimiento Pueblo Igual
2. Luis Torres — Avanza
3. Ana Belén — ADN
4. Fernando Vega — Movimiento Social
5. Carlos Rivas — Partido Liberal

## Arquitectura

El proyecto sigue una arquitectura limpia con separación en capas:
- **Presentación**: Flutter widgets + BLoC (flutter_bloc)
- **Dominio**: Entidades, casos de uso, repositorios abstractos
- **Datos**: DataSources (Appwrite), modelos, implementaciones de repositorios

Además incluye:
- **Offline**: Persistencia local con Hive para actas sin conexión
- **Sync**: Sincronización automática al recuperar conectividad mediante connectivity_plus
- **Backend**: Appwrite (Auth, Database, Storage)

## Funcionalidades por rol

### Veedor
- Registro de actas con foto, GPS y validación de nitidez (Laplacian variance)
- Registro de votos para 5 organizaciones en actas de Alcalde y Prefecto
- Validación: suma de votos no supera total de sufragantes
- Corrección de actas propias

### Coordinador de Recinto
- Visualización de mesas del recinto
- Creación de cuentas de veedores
- Asignación de veedores a mesas
- Corrección de cualquier acta del recinto

### Coordinador Provincial
- Listado de recintos con creación
- Asignación de coordinadores de recinto
- Avance por recinto (actas registradas vs pendientes)
- Visualización de coordenadas GPS de actas

## Limitaciones técnicas

- La creación de usuarios veedores requiere la Appwrite Admin API (no disponible desde el cliente). En la implementación actual se simula la creación guardando datos localmente.
- El flujo offline utiliza Hive como almacenamiento local; la sincronización automática ocurre al detectar reconexión, pero no incluye resolución avanzada de conflictos (último cambio gana).
- La validación de nitidez (Laplacian variance < 4.0) es un heurístico simple; puede fallar en condiciones de iluminación muy baja o con imágenes de texto muy pequeño.

## Generar APK

```bash
flutter build apk --release
```

La APK se generará en `build/app/outputs/flutter-apk/app-release.apk`.



================================================
📄 ARCHIVO: test\image_service_test.dart
================================================

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sistema_electoral/core/image_service.dart';

void main() {
  test('detecta una imagen con borde nítido como no borrosa', () {
    final image = img.Image(width: 200, height: 200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
    for (var y = 0; y < 100; y++) {
      for (var x = 0; x < 100; x++) {
        image.setPixelRgba(x, y, 0, 0, 0, 255);
      }
    }
    final tempDir = Directory.systemTemp.createTempSync('sharp-image');
    final file = File('${tempDir.path}/sharp.jpg');
    file.writeAsBytesSync(img.encodeJpg(image));
    expect(ImageService.isImageBlurry(file), isFalse);
  });

  test('detecta una imagen muy suave como borrosa', () {
    final image = img.Image(width: 200, height: 200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final value = (x * 0.5 + y * 0.5).round();
        image.setPixelRgba(x, y, value, value, value, 255);
      }
    }
    final tempDir = Directory.systemTemp.createTempSync('blur-image');
    final file = File('${tempDir.path}/blur.jpg');
    file.writeAsBytesSync(img.encodeJpg(image));
    expect(ImageService.isImageBlurry(file), isTrue);
  });
}


================================================
📄 ARCHIVO: test\widget_test.dart
================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_electoral/main.dart';
import 'package:sistema_electoral/features/auth/domain/entities/app_user.dart';
import 'package:sistema_electoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:sistema_electoral/features/actas/domain/entities/acta.dart';
import 'package:sistema_electoral/features/actas/domain/repositories/acta_repository.dart';
import 'package:sistema_electoral/features/recintos/domain/entities/recinto.dart';
import 'package:sistema_electoral/features/recintos/domain/repositories/recinto_repository.dart';

// Usuario de prueba que cumple todos los campos requeridos por AppUser
AppUser _fakeUser() => AppUser(
      id: 'test-id',
      authUserId: 'auth-test-id',
      cedula: '1713175071',
      nombres: 'Test',
      apellidos: 'Usuario',
      telefono: '0991234567',
      email: 'test@test.com',
      role: UserRole.observer,
      mustChangePassword: false,
    );

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser> loginConCedula(String cedula, String password) async =>
      _fakeUser();

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<AppUser> changePassword(
          String newPassword, String oldPassword) async =>
      _fakeUser();

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> getUsuarioActual() async => null;

  @override
  Future<void> crearUsuario({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole rol,
    String? recintoId,
    required String emailCoordinadorActual,
    required String passwordCoordinadorActual,
  }) async {}
}

class FakeActaRepository implements ActaRepository {
  @override
  Future<void> crearActa(Acta acta) async {}

  @override
  Future<List<Acta>> obtenerActas({String? userId}) async => [];

  @override
  Future<void> actualizarActa(String id, Acta acta) async {}
}

class FakeRecintoRepository implements RecintoRepository {
  @override
  Future<void> crearRecinto(Recinto recinto) async {}

  @override
  Future<List<Recinto>> obtenerRecintos() async => [];

  @override
  Future<Recinto?> obtenerRecinto(String id) async => null;

  @override
  Future<void> asignarCoordinador(String recintoId, String userId) async {}
}

void main() {
  testWidgets('Login page muestra campos de inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authRepository: FakeAuthRepository(),
      actaRepository: FakeActaRepository(),
      recintoRepository: FakeRecintoRepository(),
    ));

    expect(find.text('Sistema Electoral'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Cédula de identidad'), findsOneWidget);
  });
}
