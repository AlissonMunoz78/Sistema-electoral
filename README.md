# Sistema Electoral

Aplicación Flutter para la gestión de actas electorales con tres roles de usuario, persistencia offline y sincronización automática.

## Requisitos

- Flutter SDK 3.11+
- Dispositivo con Android 5.0+ o iOS 12+ (cámara y GPS requeridos)

## Instalación y ejecución

```bash
flutter pub get
flutter run
```

## Credenciales de prueba

Las credenciales deben ser creadas en la consola de Appwrite. A continuación se describen los usuarios de prueba sugeridos:

| Rol | Email | Contraseña |
|---|---|---|
| Coordinador Provincial | provincial@test.com | password123 |
| Coordinador de Recinto | recinto@test.com | password123 |
| Veedor | veedor@test.com | password123 |

> **Nota**: Los usuarios se gestionan mediante la colección `app_users` de Appwrite. Para crear usuarios de prueba, usa la consola de Appwrite:
> 1. Crea los usuarios en Appwrite Authentication
> 2. Crea documentos en la colección `app_users` con los campos: `email`, `role` (coordinatorProvincial / coordinatorRecinto / observer), `mustChangePassword`, `recintoId` (opcional), `mesaId` (opcional)

## Modelo de datos

### Colección `actas`
| Campo | Tipo | Descripción |
|---|---|---|
| junta | number | Número de mesa (JRV) |
| provincia | string | Provincia electoral |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| dignidad | string | "alcalde" o "prefecto" |
| votosOrganizaciones | number[] | Array de 5 enteros (votos por organización política) |
| blancos | number | Votos en blanco |
| nulos | number | Votos nulos |
| totalSufragantes | number | Total de sufragantes registrados en la mesa |
| fotoId | string | ID del archivo en Appwrite Storage |
| fecha | datetime | Fecha y hora del registro |
| imagenValida | boolean | Resultado de validación de nitidez |
| latitud | number? | Coordenada GPS latitud |
| longitud | number? | Coordenada GPS longitud |
| userId | string? | ID del veedor que registró |

### Colección `recintos`
| Campo | Tipo | Descripción |
|---|---|---|
| nombre | string | Nombre del recinto |
| provincia | string | Provincia |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| numeroJRV | number | Cantidad de JRV en el recinto |
| coordinadorId | string? | ID del coordinador asignado |

### Colección `app_users`
| Campo | Tipo | Descripción |
|---|---|---|
| email | string | Correo electrónico |
| role | string | "coordinatorProvincial", "coordinatorRecinto", "observer" |
| mustChangePassword | boolean | Si debe cambiar contraseña en primer login |
| recintoId | string? | ID del recinto asignado (coordinador de recinto y veedor) |
| mesaId | number? | Número de mesa asignada (veedor) |

## Organizaciones políticas precargadas

### Alcalde
1. Pabel Muñoz — Movimiento Pueblo Igual
2. Jorge Yunda — Avanza
3. John Reimberg — ADN
4. Marlene Cevallos — Movimiento Social
5. Mario Jaramillo — Partido Liberal

### Prefecto
1. Rosa Cárdenas — Movimiento Pueblo Igual
2. Luis Torres — Avanza
3. Ana Belén — ADN
4. Fernando Vega — Movimiento Social
5. Carlos Rivas — Partido Liberal

## Arquitectura

El proyecto sigue una arquitectura limpia con separación en capas:
- **Presentación**: Flutter widgets + BLoC (flutter_bloc)
- **Dominio**: Entidades, casos de uso, repositorios abstractos
- **Datos**: DataSources (Appwrite), modelos, implementaciones de repositorios

Además incluye:
- **Offline**: Persistencia local con Hive para actas sin conexión
- **Sync**: Sincronización automática al recuperar conectividad mediante connectivity_plus
- **Backend**: Appwrite (Auth, Database, Storage)

## Funcionalidades por rol

### Veedor
- Registro de actas con foto, GPS y validación de nitidez (Laplacian variance)
- Registro de votos para 5 organizaciones en actas de Alcalde y Prefecto
- Validación: suma de votos no supera total de sufragantes
- Corrección de actas propias

### Coordinador de Recinto
- Visualización de mesas del recinto
- Creación de cuentas de veedores
- Asignación de veedores a mesas
- Corrección de cualquier acta del recinto

### Coordinador Provincial
- Listado de recintos con creación
- Asignación de coordinadores de recinto
- Avance por recinto (actas registradas vs pendientes)
- Visualización de coordenadas GPS de actas

## Limitaciones técnicas

- La creación de usuarios veedores requiere la Appwrite Admin API (no disponible desde el cliente). En la implementación actual se simula la creación guardando datos localmente.
- El flujo offline utiliza Hive como almacenamiento local; la sincronización automática ocurre al detectar reconexión, pero no incluye resolución avanzada de conflictos (último cambio gana).
- La validación de nitidez (Laplacian variance < 4.0) es un heurístico simple; puede fallar en condiciones de iluminación muy baja o con imágenes de texto muy pequeño.

## Generar APK

```bash
flutter build apk --release
```

La APK se generará en `build/app/outputs/flutter-apk/app-release.apk`.
