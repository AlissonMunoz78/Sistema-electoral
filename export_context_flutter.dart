import 'dart:io';

// Archivo de salida
const outputFileName = 'contexto_proyecto.md';

// Directorio raíz del proyecto
final rootDir = Directory.current;

// Carpetas a ignorar (comparadas por nombre de segmento, no por ruta completa)
const ignoreDirs = {
  '.dart_tool',
  '.idea',
  '.vscode',
  '.git',
  'build',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  'android',
  'ios',
  'linux',
  'macos',
  'windows',
  'web',
};

// Archivos que no queremos incluir
const ignoreFiles = {
  'pubspec.lock',
  outputFileName,
  'export_context_flutter.dart',
};

// Extensiones permitidas
const allowedExtensions = {
  '.dart',
  '.yaml',
  '.yml',
  '.json',
  '.md',
  '.arb',
};

// Verifica si un directorio debe ignorarse
bool shouldIgnorePath(String path) {
  final segments = path.split(Platform.pathSeparator);
  return segments.any((segment) => ignoreDirs.contains(segment));
}

void buildContext(Directory dir, IOSink sink) {
  for (final entity in dir.listSync(followLinks: false)) {
    final path = entity.path;
    final name = path.split(Platform.pathSeparator).last;

    // IGNORAR directorios
    if (entity is Directory) {
      if (!shouldIgnorePath(path)) {
        buildContext(entity, sink);
      }
      continue;
    }

    // SOLO archivos
    if (entity is File) {
      final ext = name.contains('.') ? '.${name.split('.').last}' : '';

      final isAllowedExtension = allowedExtensions.contains(ext);

      final isConfigFile =
          name == 'pubspec.yaml' ||
          name == 'analysis_options.yaml' ||
          name.startsWith('.') ||
          name.contains('config');

      if (ignoreFiles.contains(name)) continue;

      if (!(isAllowedExtension || isConfigFile)) continue;

      try {
        final content = entity.readAsStringSync();

        final relativePath = path.replaceFirst(
          '${rootDir.path}${Platform.pathSeparator}',
          '',
        );

        sink.writeln('\n\n================================================');
        sink.writeln('📄 ARCHIVO: $relativePath');
        sink.writeln('================================================\n');
        sink.writeln(content);
      } catch (e) {
        stderr.writeln('⚠️ Error leyendo $path: $e');
      }
    }
  }
}

void main() {
  final outputFile = File('${rootDir.path}${Platform.pathSeparator}$outputFileName');
  final sink = outputFile.openWrite();

  sink.writeln('# Contexto Completo del Proyecto Flutter\n');

  stdout.writeln('🔍 Escaneando proyecto completo...');

  buildContext(rootDir, sink);

  sink.close().then((_) {
    stdout.writeln('✅ Listo. Archivo generado: $outputFileName');
  });
}