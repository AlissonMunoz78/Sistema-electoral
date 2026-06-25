import 'package:appwrite/appwrite.dart';

const String appwriteEndpoint = 'https://sfo.cloud.appwrite.io/v1';
const String appwriteProjectId = 'sistema-electoral';
const String appwriteDatabaseId = '6a3ca5420008a6f70fe1';
const String appwriteActasCollectionId = 'actas';
const String appwriteUsersCollectionId = 'app_users';
const String appwriteRecintosCollectionId = 'recintos';
const String appwriteBucketId = '6a3ca946002e1039870d';

Client client = Client()
    .setEndpoint(appwriteEndpoint)
    .setProject(appwriteProjectId);

Databases get databases => Databases(client);
TablesDB get tablesDB => TablesDB(client);
Storage get storage => Storage(client);