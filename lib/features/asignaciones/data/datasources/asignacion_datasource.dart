import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';

class AsignacionDatasource {
  final Databases db;
  AsignacionDatasource(this.db);

  Future<void> crearAsignacion({
    required String veedorAuthId,
    required int mesa,
    required String recintoId,
  }) async {
    await db.createDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteAsignacionesCollectionId,
      documentId: ID.unique(),
      data: {
        'veedorId': veedorAuthId,
        'mesa': mesa,
        'recintoId': recintoId,
      },
      permissions: [
        Permission.read(Role.any()),
        Permission.write(Role.any()),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerPorVeedor(String veedorAuthId) async {
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteAsignacionesCollectionId,
      queries: [Query.equal('veedorId', veedorAuthId)],
    );
    return result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerPorRecinto(String recintoId) async {
    final result = await db.listDocuments(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteAsignacionesCollectionId,
      queries: [Query.equal('recintoId', recintoId)],
    );
    return result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();
  }

  Future<void> eliminarAsignacion(String id) async {
    await db.deleteDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteAsignacionesCollectionId,
      documentId: id,
    );
  }

  Future<void> actualizarMesa(String id, int nuevaMesa) async {
    await db.updateDocument(
      databaseId: appwriteDatabaseId,
      collectionId: appwriteAsignacionesCollectionId,
      documentId: id,
      data: {'mesa': nuevaMesa},
    );
  }
}
