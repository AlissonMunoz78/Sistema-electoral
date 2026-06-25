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
📄 ARCHIVO: android\.gitignore
================================================

gradle-wrapper.jar
/.gradle
/captures/
/gradlew
/gradlew.bat
/local.properties
GeneratedPluginRegistrant.java
.cxx/

# Remember to never publicly share your keystore.
# See https://flutter.dev/to/reference-keystore
key.properties
**/*.keystore
**/*.jks


================================================
📄 ARCHIVO: ios\.gitignore
================================================

**/dgph
*.mode1v3
*.mode2v3
*.moved-aside
*.pbxuser
*.perspectivev3
**/*sync/
.sconsign.dblite
.tags*
**/.vagrant/
**/DerivedData/
Icon?
**/Pods/
**/.symlinks/
profile
xcuserdata
**/.generated/
Flutter/App.framework
Flutter/Flutter.framework
Flutter/Flutter.podspec
Flutter/Generated.xcconfig
Flutter/ephemeral/
Flutter/app.flx
Flutter/app.zip
Flutter/flutter_assets/
Flutter/flutter_export_environment.sh
ServiceDefinitions.json
Runner/GeneratedPluginRegistrant.*

# Exceptions to above rules.
!default.mode1v3
!default.mode2v3
!default.pbxuser
!default.perspectivev3


================================================
📄 ARCHIVO: ios\Flutter\Debug.xcconfig
================================================

#include "Generated.xcconfig"


================================================
📄 ARCHIVO: ios\Flutter\Generated.xcconfig
================================================

// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=C:\Universidad\2026\Moviles\flutter_windows_3.41.9-stable\flutter
FLUTTER_APPLICATION_PATH=C:\Universidad\2026\Moviles\ProyectFlutter\sistema_electoral
COCOAPODS_PARALLEL_CODE_SIGN=true
FLUTTER_TARGET=lib\main.dart
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_NAME=1.0.0
FLUTTER_BUILD_NUMBER=1
EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386
EXCLUDED_ARCHS[sdk=iphoneos*]=armv7
DART_OBFUSCATION=false
TRACK_WIDGET_CREATION=true
TREE_SHAKE_ICONS=false
PACKAGE_CONFIG=.dart_tool/package_config.json


================================================
📄 ARCHIVO: ios\Flutter\Release.xcconfig
================================================

#include "Generated.xcconfig"


================================================
📄 ARCHIVO: ios\Runner\Assets.xcassets\AppIcon.appiconset\Contents.json
================================================

{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}


================================================
📄 ARCHIVO: ios\Runner\Assets.xcassets\LaunchImage.imageset\Contents.json
================================================

{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "LaunchImage.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@3x.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}


================================================
📄 ARCHIVO: ios\Runner\Assets.xcassets\LaunchImage.imageset\README.md
================================================

# Launch Screen Assets

You can customize the launch screen with your own desired assets by replacing the image files in this directory.

You can also do it by opening your Flutter project's Xcode project with `open ios/Runner.xcworkspace`, selecting `Runner/Assets.xcassets` in the Project Navigator and dropping in the desired images.

================================================
📄 ARCHIVO: lib\core\appwrite_client.dart
================================================

import 'package:appwrite/appwrite.dart';

Client client = Client()
    .setEndpoint("https://sfo.cloud.appwrite.io/v1")
    .setProject("sistema-electoral");

Databases get databases => Databases(client);

================================================
📄 ARCHIVO: lib\features\actas\data\datasources\acta_datasource.dart
================================================

import 'package:appwrite/appwrite.dart';
import '../models/acta_model.dart';

class ActaDatasource {
  final Databases db;

  ActaDatasource(this.db);

  Future<void> crearActa(ActaModel acta) async {
    await db.createDocument(
      databaseId: "db_electoral",
      collectionId: "actas",
      documentId: ID.unique(),
      data: acta.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas() async {
    final result = await db.listDocuments(
      databaseId: "db_electoral",
      collectionId: "actas",
    );

    return result.documents.map((e) => e.data).toList();
  }
}

================================================
📄 ARCHIVO: lib\features\actas\data\datasources\appwrite_acta_datasource.dart
================================================



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
    required super.votosA,
    required super.votosB,
    required super.blancos,
    required super.nulos,
    required super.fotoId,
    required super.fecha,
    required super.imagenValida,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json) {
    return ActaModel(
      junta: json['junta'],
      provincia: json['provincia'],
      canton: json['canton'],
      parroquia: json['parroquia'],
      votosA: json['votosA'],
      votosB: json['votosB'],
      blancos: json['blancos'],
      nulos: json['nulos'],
      fotoId: json['fotoId'],
      fecha: DateTime.parse(json['fecha']),
      imagenValida: json['imagenValida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'junta': junta,
      'provincia': provincia,
      'canton': canton,
      'parroquia': parroquia,
      'votosA': votosA,
      'votosB': votosB,
      'blancos': blancos,
      'nulos': nulos,
      'fotoId': fotoId,
      'fecha': fecha.toIso8601String(),
      'imagenValida': imagenValida,
    };
  }
}

================================================
📄 ARCHIVO: lib\features\actas\data\repositories\acta_repository_impl.dart
================================================

import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../datasources/acta_datasource.dart';
import '../models/acta_model.dart';

class ActaRepositoryImpl implements ActaRepository {
  final ActaDatasource datasource;

  ActaRepositoryImpl(this.datasource);

  @override
  Future<void> crearActa(Acta acta) {
    return datasource.crearActa(ActaModel(
      junta: acta.junta,
      provincia: acta.provincia,
      canton: acta.canton,
      parroquia: acta.parroquia,
      votosA: acta.votosA,
      votosB: acta.votosB,
      blancos: acta.blancos,
      nulos: acta.nulos,
      fotoId: acta.fotoId,
      fecha: acta.fecha,
      imagenValida: acta.imagenValida,
    ));
  }

  @override
  Future<List<Acta>> obtenerActas() async {
    final data = await datasource.obtenerActas();

    return data.map((e) => ActaModel.fromJson(e)).toList();
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
  final int votosA;
  final int votosB;
  final int blancos;
  final int nulos;
  final String fotoId;
  final DateTime fecha;
  final bool imagenValida;

  Acta({
    required this.junta,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.votosA,
    required this.votosB,
    required this.blancos,
    required this.nulos,
    required this.fotoId,
    required this.fecha,
    required this.imagenValida,
  });
}

================================================
📄 ARCHIVO: lib\features\actas\domain\repositories\acta_repository.dart
================================================

import '../entities/acta.dart';

abstract class ActaRepository {
  Future<void> crearActa(Acta acta);
  Future<List<Acta>> obtenerActas();
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

  Future<List<Acta>> call() {
    return repository.obtenerActas();
  }
}

================================================
📄 ARCHIVO: lib\features\actas\presentation\bloc\acta_bloc.dart
================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'acta_event.dart';
import 'acta_state.dart';
import '../../domain/usecases/crear_acta.dart';
import '../../domain/usecases/obtener_actas.dart';

class ActaBloc extends Bloc<ActaEvent, ActaState> {
  final CrearActa crearActa;
  final ObtenerActas obtenerActas;

  ActaBloc({
    required this.crearActa,
    required this.obtenerActas,
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
        final actas = await obtenerActas();
        emit(ActasLoaded(actas));
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

class CargarActasEvent extends ActaEvent {}

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
📄 ARCHIVO: lib\features\actas\presentation\pages\form_acta_page.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../../domain/entities/acta.dart';

class FormActaPage extends StatelessWidget {
  FormActaPage({super.key});

  final junta = TextEditingController();
  final provincia = TextEditingController();
  final canton = TextEditingController();
  final parroquia = TextEditingController();
  final votosA = TextEditingController();
  final votosB = TextEditingController();
  final blancos = TextEditingController();
  final nulos = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: junta, decoration: const InputDecoration(labelText: "Junta")),
            TextField(controller: provincia),
            TextField(controller: canton),
            TextField(controller: parroquia),
            TextField(controller: votosA),
            TextField(controller: votosB),
            TextField(controller: blancos),
            TextField(controller: nulos),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final acta = Acta(
                  junta: int.parse(junta.text),
                  provincia: provincia.text,
                  canton: canton.text,
                  parroquia: parroquia.text,
                  votosA: int.parse(votosA.text),
                  votosB: int.parse(votosB.text),
                  blancos: int.parse(blancos.text),
                  nulos: int.parse(nulos.text),
                  fotoId: "img123",
                  fecha: DateTime.now(),
                  imagenValida: true,
                );

                context.read<ActaBloc>().add(CrearActaEvent(acta));
              },
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }
}

================================================
📄 ARCHIVO: lib\features\actas\presentation\pages\list_actas_page.dart
================================================



================================================
📄 ARCHIVO: lib\main.dart
================================================

import 'package:flutter/material.dart';
import 'core/appwrite_client.dart';
import 'features/actas/data/datasources/acta_datasource.dart';
import 'features/actas/data/repositories/acta_repository_impl.dart';
import 'features/actas/domain/usecases/crear_acta.dart';
import 'features/actas/domain/usecases/obtener_actas.dart';
import 'features/actas/presentation/bloc/acta_bloc.dart';
import 'features/actas/presentation/pages/form_acta_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final datasource = ActaDatasource(databases);
  final repository = ActaRepositoryImpl(datasource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ActaRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ActaBloc(
          crearActa: CrearActa(repository),
          obtenerActas: ObtenerActas(repository),
        ),
        child: const FormActaPage(),
      ),
    );
  }
}

================================================
📄 ARCHIVO: pubspec.yaml
================================================

name: sistema_electoral
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package


================================================
📄 ARCHIVO: README.md
================================================

# sistema_electoral

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


================================================
📄 ARCHIVO: test\widget_test.dart
================================================

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sistema_electoral/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
