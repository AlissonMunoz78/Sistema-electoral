class AppwriteAuthException implements Exception {
  final String message;
  final int? code;
  AppwriteAuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

class AppwriteServerException implements Exception {
  final String message;
  final int? code;
  AppwriteServerException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexión']);

  @override
  String toString() => message;
}

class LocationException implements Exception {
  final String message;
  LocationException([this.message = 'Error de ubicación']);

  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  @override
  String toString() =>
      'Permiso de ubicación denegado. Actívalo para continuar.';
}

class LocalDatabaseException implements Exception {
  final String message;
  LocalDatabaseException([this.message = 'Error SQLite']);

  @override
  String toString() => message;
}
