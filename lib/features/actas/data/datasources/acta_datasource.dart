import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/acta_model.dart';

class ActaDatasource {
  final TablesDB db;

  ActaDatasource(this.db);

  Future<void> crearActa(ActaModel acta) async {
    await db.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      rowId: ID.unique(),
      data: acta.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerActas({String? userId}) async {
    final queries = <String>[];
    if (userId != null) queries.add('userId=$userId');
    final result = await db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      queries: queries,
    );
    return result.rows.map((e) => {...e.data, '\$id': e.$id}).toList();
  }

  Future<void> actualizarActa(String documentId, Map<String, dynamic> data) async {
    await db.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteActasCollectionId,
      rowId: documentId,
      data: data,
    );
  }
}
