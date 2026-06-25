import 'package:appwrite/appwrite.dart';
import '../models/acta_model.dart';

class ActaDatasource {
  final Databases db;

  ActaDatasource(this.db);

  Future<void> crearActa(ActaModel acta) async {
    await db.createDocument(
      databaseId: "6a3ca5420008a6f70fe1", // Database ID
      collectionId: "actas", // Table ID
      documentId: ID.unique(),
      data: acta.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas() async {
    final result = await db.listDocuments(
      databaseId: "6a3ca5420008a6f70fe1",
      collectionId: "actas",
    );

    return result.documents.map((e) => e.data).toList();
  }
}