# Sistema Electoral

Aplicación Flutter para registrar actas de escrutinio en una mesa receptora del voto.

## Qué incluye

- Registro de actas con datos de junta, provincia, cantón y parroquia.
- Captura de foto desde cámara.
- Validación básica de imagen para rechazar fotos borrosas.
- Integración preparada con Appwrite para almacenamiento y persistencia.
- Vista de actas registradas para consulta rápida.

## Requisitos

- Flutter SDK 3.11+
- Android/iOS/Windows/macOS con permisos de cámara

## Ejecutar

```bash
flutter pub get
flutter test
flutter run
```

## Nota técnica

- La app está preparada para usar Appwrite, pero incluye un respaldo local para pruebas cuando la conexión no está disponible.
