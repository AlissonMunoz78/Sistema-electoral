import 'package:appwrite/appwrite.dart';

class StorageDatasource {
  final Storage storage;
  StorageDatasource(this.storage);

  Future<String> subirImagen(String path) async {
    final file = await storage.createFile(
      bucketId: "6a3ca946002e1039870d",
      fileId: ID.unique(),
      file: InputFile.fromPath(path: path),
    );
    return file.$id;
  }
}