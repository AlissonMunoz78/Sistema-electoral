import 'package:appwrite/appwrite.dart';

Client client = Client()
    .setEndpoint("https://sfo.cloud.appwrite.io/v1")
    .setProject("sistema-electoral");

Databases get databases => Databases(client);