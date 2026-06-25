import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/image_service.dart';
import '../../../../core/storage_service.dart';
import '../../../../core/appwrite_client.dart';

import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../../domain/entities/acta.dart';

class FormActaPage extends StatefulWidget {
  const FormActaPage({super.key});

  @override
  State<FormActaPage> createState() => _FormActaPageState();
}

class _FormActaPageState extends State<FormActaPage> {
  final picker = ImagePicker();
  File? imageFile;

  late StorageService storageService;

  final junta = TextEditingController();
  final provincia = TextEditingController();
  final canton = TextEditingController();
  final parroquia = TextEditingController();
  final votosA = TextEditingController();
  final votosB = TextEditingController();
  final blancos = TextEditingController();
  final nulos = TextEditingController();

  @override
  void initState() {
    super.initState();
    storageService = StorageService(storage);
  }

  Future<void> takePhoto() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
    });
  }

  Future<void> saveActa(BuildContext context) async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe tomar una foto")),
      );
      return;
    }

    /// 🔥 VALIDACIÓN BORROSIDAD
    final isBlurry = ImageService.isImageBlurry(imageFile!);

    if (isBlurry) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagen borrosa, no válida")),
      );
      return;
    }

    /// 📤 SUBIR A APPWRITE STORAGE
    final fotoId = await storageService.uploadImage(imageFile!);

    final acta = Acta(
      junta: int.parse(junta.text),
      provincia: provincia.text,
      canton: canton.text,
      parroquia: parroquia.text,
      votosA: int.parse(votosA.text),
      votosB: int.parse(votosB.text),
      blancos: int.parse(blancos.text),
      nulos: int.parse(nulos.text),
      fotoId: fotoId,
      fecha: DateTime.now(),
      imagenValida: true,
    );

    if (!mounted) return;

    context.read<ActaBloc>().add(CrearActaEvent(acta));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Acta guardada correctamente")),
    );
  }

  Widget input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Acta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          input(junta, "Junta"),
          input(provincia, "Provincia"),
          input(canton, "Cantón"),
          input(parroquia, "Parroquia"),
          input(votosA, "Votos A"),
          input(votosB, "Votos B"),
          input(blancos, "Blancos"),
          input(nulos, "Nulos"),

          const SizedBox(height: 10),

          imageFile == null
              ? const Text("⚠ Debe tomar foto", style: TextStyle(color: Colors.red))
              : Image.file(imageFile!, height: 200),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Tomar foto"),
            onPressed: takePhoto,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => saveActa(context),
            child: const Text("Guardar Acta"),
          )
        ],
      ),
    );
  }
}