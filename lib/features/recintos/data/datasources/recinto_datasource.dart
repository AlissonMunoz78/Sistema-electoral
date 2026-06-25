import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../models/recinto_model.dart';

class RecintoDatasource {
  final TablesDB db;

  RecintoDatasource(this.db);

  Future<void> crearRecinto(RecintoModel recinto) async {
    await db.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
      rowId: ID.unique(),
      data: recinto.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerRecintos() async {
    final result = await db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
    );
    return result.rows.map((e) => e.data).toList();
  }

  Future<Map<String, dynamic>?> obtenerRecinto(String id) async {
    try {
      final doc = await db.getRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteRecintosCollectionId,
        rowId: id,
      );
      return doc.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarRecinto(String id, Map<String, dynamic> data) async {
    await db.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteRecintosCollectionId,
      rowId: id,
      data: data,
    );
  }
}
