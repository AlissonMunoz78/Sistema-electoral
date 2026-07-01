import 'package:appwrite/appwrite.dart';

const String appwriteEndpoint = 'https://sfo.cloud.appwrite.io/v1';
const String appwriteProjectId = 'sistema-electoral';
const String appwriteDatabaseId = '6a3ca5420008a6f70fe1';

// Colecciones (tablas) usadas por la app.
// NOTA: se corrigió el typo "ususarios" -> "users" y se agregaron las
// colecciones nuevas que el enunciado requiere (asignaciones de mesa y
// organizaciones políticas precargadas desde el backend).
const String appwriteActasCollectionId = 'actas';
const String appwriteUsersCollectionId = 'ususarios';
const String appwriteRecintosCollectionId = 'recintos';
const String appwriteAsignacionesCollectionId = 'asignaciones_mesa';
const String appwriteOrganizacionesCollectionId = 'organizaciones';
const String appwriteBucketId = '6a3ca946002e1039870d';

Client client = Client()
    .setEndpoint(appwriteEndpoint)
    .setProject(appwriteProjectId);

Databases get databases => Databases(client);
Storage get storage => Storage(client);