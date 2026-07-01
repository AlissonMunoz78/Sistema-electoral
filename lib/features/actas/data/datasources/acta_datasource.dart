import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/acta_model.dart';

class ActaDatasource {
  final Databases db;

  ActaDatasource(this.db);

  Future<void> crearActa(ActaModel acta) async {
    await db.createDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteActasCollectionId,
      documentId: ID.unique(),
      data: acta.toJson(),
      permissions: [
        Permission.read(Role.any()),
        Permission.write(Role.any()),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas({String? userId}) async {
    final queries = <String>[];
    if (userId != null && userId.isNotEmpty) {
      queries.add(Query.equal('userId', userId));
    }
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteActasCollectionId,
      queries: queries,
    );
    return result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();
  }

  Future<void> actualizarActa(String documentId, Map<String, dynamic> data) async {
    await db.updateDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteActasCollectionId,
      documentId: documentId,
      data: data,
    );
  }
}
