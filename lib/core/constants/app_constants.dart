import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get appwriteEndpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  static String get appwriteProjectId =>
      dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  static String get databaseId =>
      dotenv.env['APPWRITE_DATABASE_ID'] ?? 'electoral_db';
  static String get appwriteApiKey => dotenv.env['APPWRITE_API_KEY'] ?? '';

  static String get colUsersProfiles =>
      dotenv.env['COLLECTION_USERS_PROFILES'] ?? 'users_profiles';
  static String get colRecintos =>
      dotenv.env['COLLECTION_RECINTOS'] ?? 'recintos';
  static String get colMesas => dotenv.env['COLLECTION_MESAS'] ?? 'mesas';
  static String get colActas => dotenv.env['COLLECTION_ACTAS'] ?? 'actas';
  static String get colVotosDetalle =>
      dotenv.env['COLLECTION_VOTOS_DETALLE'] ?? 'votos_detalle';
  static String get colOrganizaciones =>
      dotenv.env['COLLECTION_ORGANIZACIONES'] ?? 'organizaciones_politicas';
  static String get colLoginLookup =>
      dotenv.env['COLLECTION_LOGIN_LOOKUP'] ?? 'login_lookup';
  static String get storageBucketFotos =>
      dotenv.env['STORAGE_BUCKET_FOTOS'] ?? 'fotos_actas';

  static String get appName => dotenv.env['APP_NAME'] ?? 'Sistema Electoral';
  static String get canton => dotenv.env['CANTON'] ?? 'Rumiñahui';
  static String get provincia => dotenv.env['PROVINCIA'] ?? 'Pichincha';
  static String get defaultPassword =>
      dotenv.env['DEFAULT_PASSWORD'] ?? 'Ecuador2026';
  static String get accountVerificationUrl =>
      dotenv.env['APPWRITE_ACCOUNT_VERIFICATION_URL'] ?? '';
  static String get passwordRecoveryUrl =>
      dotenv.env['APPWRITE_PASSWORD_RECOVERY_URL'] ?? '';
  static double get sharpnessThreshold =>
      double.tryParse(dotenv.env['SHARPNESS_THRESHOLD'] ?? '220.0') ?? 220.0;
  static String get emailSuffix =>
      dotenv.env['EMAIL_SUFFIX'] ?? '@electoral.ec';
}
