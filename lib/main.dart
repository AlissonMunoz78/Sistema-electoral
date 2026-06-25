import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/appwrite_client.dart';
import 'features/actas/data/datasources/acta_datasource.dart';
import 'features/actas/data/repositories/acta_repository_impl.dart';
import 'features/actas/domain/usecases/crear_acta.dart';
import 'features/actas/domain/usecases/obtener_actas.dart';
import 'features/actas/presentation/bloc/acta_bloc.dart';
import 'features/actas/presentation/pages/form_acta_page.dart';

void main() {
  final datasource = ActaDatasource(databases);
  final repository = ActaRepositoryImpl(datasource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ActaRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => ActaBloc(
          crearActa: CrearActa(repository),
          obtenerActas: ObtenerActas(repository),
        ),
        child: FormActaPage(),
      ),
    );
  }
}