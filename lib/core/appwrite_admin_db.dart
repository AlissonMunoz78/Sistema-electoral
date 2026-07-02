import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_client.dart';

/// Acceso a la REST API de Databases usando la Admin API Key.
class AppwriteAdminDb {
  static String get _apiKey => dotenv.env['APPWRITE_API_KEY'] ?? '';
  static bool get isAvailable => _apiKey.isNotEmpty;

  static Future<Map<String, dynamic>> createDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(
        '$appwriteEndpoint/databases/$databaseId/collections/$collectionId/documents',
      ));
      request.headers.set('X-Appwrite-Project', appwriteProjectId);
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode({
        'documentId': documentId,
        'data': data,
        if (permissions != null) 'permissions': permissions,
      }));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 201) {
        throw Exception('Error creando documento ($collectionId): $body');
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  static Future<void> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    Map<String, dynamic>? data,
    List<String>? permissions,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.patchUrl(Uri.parse(
        '$appwriteEndpoint/databases/$databaseId/collections/$collectionId/documents/$documentId',
      ));
      request.headers.set('X-Appwrite-Project', appwriteProjectId);
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode({
        if (data != null) 'data': data,
        if (permissions != null) 'permissions': permissions,
      }));
      final response = await request.close();
      if (response.statusCode != 200) {
        final body = await response.transform(utf8.decoder).join();
        debugPrint('Error actualizando documento ($collectionId): $body');
      }
      client.close();
    } catch (e) {
      debugPrint('Error actualizando documento admin: $e');
    }
  }
}