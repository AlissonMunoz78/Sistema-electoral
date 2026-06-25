import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/recinto_model.dart';

class RecintoDatasource {
  final Databases db;

  RecintoDatasource(this.db);

  Future<void> crearRecinto(RecintoModel recinto) async {
    await db.createDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteRecintosCollectionId,
      documentId: ID.unique(),
      data: recinto.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerRecintos() async {
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteRecintosCollectionId,
    );
    return result.documents.map((e) => e.data).toList();
  }

  Future<Map<String, dynamic>?> obtenerRecinto(String id) async {
    try {
      final doc = await db.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteRecintosCollectionId,
        documentId: id,
      );
      return doc.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarRecinto(String id, Map<String, dynamic> data) async {
    await db.updateDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteRecintosCollectionId,
      documentId: id,
      data: data,
    );
  }
}
