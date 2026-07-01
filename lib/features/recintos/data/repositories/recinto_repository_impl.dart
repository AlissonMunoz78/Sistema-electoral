import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite_client.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/repositories/recinto_repository.dart';
import '../datasources/recinto_datasource.dart';
import '../models/recinto_model.dart';

class RecintoRepositoryImpl implements RecintoRepository {
  final RecintoDatasource datasource;

  RecintoRepositoryImpl(this.datasource);

  @override
  Future<void> crearRecinto(Recinto recinto) async {
    await datasource.crearRecinto(RecintoModel(
      nombre: recinto.nombre,
      provincia: recinto.provincia,
      canton: recinto.canton,
      parroquia: recinto.parroquia,
      numeroJRV: recinto.numeroJRV,
      coordinadorId: recinto.coordinadorId,
    ));
  }

  @override
  Future<List<Recinto>> obtenerRecintos() async {
    final data = await datasource.obtenerRecintos();
    return data.map((e) => RecintoModel.fromJson(e)).toList();
  }

  @override
  Future<Recinto?> obtenerRecinto(String id) async {
    final data = await datasource.obtenerRecinto(id);
    if (data == null) return null;
    return RecintoModel.fromJson({...data, '\$id': id});
  }

  @override
  Future<void> asignarCoordinador(String recintoId, String authUserId) async {
    try {
      // Buscar documento del usuario para obtener su recintoId actual
      final userResult = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteUsersCollectionId,
        queries: [Query.equal('authUserId', authUserId)],
      );
      if (userResult.documents.isNotEmpty) {
        final userDoc = userResult.documents.first;
        final oldRecintoId = userDoc.data['recintoId'] as String? ?? '';

        // Si el coordinador estaba asignado a otro recinto, limpiar ese recinto
        if (oldRecintoId.isNotEmpty && oldRecintoId != recintoId) {
          await datasource.actualizarRecinto(oldRecintoId, {'coordinadorId': ''});
        }

        // Actualizar el recinto nuevo
        await datasource.actualizarRecinto(recintoId, {'coordinadorId': authUserId});

        // Actualizar el documento del usuario
        await databases.updateDocument(
          databaseId: appwriteDatabaseId,
          collectionId: appwriteUsersCollectionId,
          documentId: userDoc.$id,
          data: {'recintoId': recintoId},
        );
      }
    } catch (_) {
      // Si falla la reasignación no bloqueamos
    }
  }
}
