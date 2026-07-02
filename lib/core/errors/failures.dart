abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Credenciales incorrectas']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Sin permisos para esta acción']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(
      [super.message = 'No se pudo obtener la ubicación. Activa el GPS.']);
}

class BlurryImageFailure extends Failure {
  const BlurryImageFailure([
    super.message =
        'La foto está borrosa. Tómala nuevamente con buena iluminación y sin movimiento.',
  ]);
}

class ImageFailure extends Failure {
  const ImageFailure([super.message = 'Error al procesar la imagen']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure([super.message = 'Error en base de datos local']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Error inesperado']);
}
