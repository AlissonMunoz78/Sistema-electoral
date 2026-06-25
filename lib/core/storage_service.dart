import 'dart:io';
import 'package:appwrite/appwrite.dart';

import 'appwrite_client.dart';

class StorageService {
  final Storage storage;

  StorageService(this.storage);

  Future<String> uploadImage(File file) async {
    final result = await storage.createFile(
      bucketId: appwriteBucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file.path),
    );

    return result.$id;
  }
}
