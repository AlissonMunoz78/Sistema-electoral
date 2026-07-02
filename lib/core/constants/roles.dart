enum UserRole {
  coordinadorProvincial,
  coordinadorRecinto,
  veedor;

  static UserRole fromString(String value) {
    switch (value) {
      case 'coordinador_provincial':
        return UserRole.coordinadorProvincial;
      case 'coordinador_recinto':
        return UserRole.coordinadorRecinto;
      case 'veedor':
        return UserRole.veedor;
      default:
        throw ArgumentError('Rol desconocido: $value');
    }
  }

  String toAppwriteLabel() {
    switch (this) {
      case UserRole.coordinadorProvincial:
        return 'coordinador_provincial';
      case UserRole.coordinadorRecinto:
        return 'coordinador_recinto';
      case UserRole.veedor:
        return 'veedor';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.coordinadorProvincial:
        return 'Coordinador Provincial';
      case UserRole.coordinadorRecinto:
        return 'Coordinador de Recinto';
      case UserRole.veedor:
        return 'Veedor de Mesa';
    }
  }
}
