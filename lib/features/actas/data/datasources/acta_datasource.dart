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
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas() async {
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteActasCollectionId,
    );

    return result.documents.map((e) => e.data).toList();
  }
}