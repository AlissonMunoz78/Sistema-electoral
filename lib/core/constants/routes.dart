class AppRoutes {
  AppRoutes._();

  static const String loading = '/loading';
  static const String login = '/login';
  static const String verifyEmail = '/verify';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String provincial = '/provincial';
  static const String recinto = '/recinto';
  static const String veedor = '/veedor';

  static String recintoDetalle(String id) => '/provincial/recinto/$id';
  static String veedorActa(String mesaId, String tipo) =>
      '/veedor/acta/$mesaId/$tipo';
}
