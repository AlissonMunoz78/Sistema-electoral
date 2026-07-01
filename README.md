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

| Rol | Cédula | Contraseña |
|---|---|---|
| Coordinador Provincial | (la cédula real del usuario en Appwrite) | Ecuador2026 |
| Coordinador de Recinto | (la cédula real) | Ecuador2026 |
| Veedor | (la cédula real) | Ecuador2026 |

> **Nota**: El login usa cédula, no email. Los usuarios deben tener su cédula registrada en el campo `cedula` de la colección `ususarios`, y su email registrado en Appwrite Authentication.

## Modelo de datos

### Colección `ususarios` (ID: ususarios)
| Campo | Tipo | Descripción |
|---|---|---|
| authUserId | string | $id del usuario en Appwrite Authentication |
| cedula | string | Cédula de identidad (usada como username) |
| nombres | string | Nombres completos |
| apellidos | string | Apellidos completos |
| telefono | string | Teléfono de contacto |
| correo | string | Correo electrónico |
| rol | string | coordinatorProvincial / coordinatorRecinto / observer |
| primerLogin | boolean | true hasta que cambie la contraseña |
| recintold | string? | ID del recinto asignado |

### Colección `actas` (ID: actas)
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

### Colección `recintos` (ID: recintos)
| Campo | Tipo | Descripción |
|---|---|---|
| nombre | string | Nombre del recinto |
| provincia | string | Provincia |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| numeroJRV | number | Cantidad de JRV en el recinto |
| coordinadorId | string? | ID del coordinador asignado |

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
- Registro de actas con foto (cámara), GPS obligatorio y validación de nitidez (Laplacian variance)
- Registro de votos para 5 organizaciones políticas en actas de Alcalde y Prefecto
- Validación de consistencia: suma de votos no supera total de sufragantes
- Corrección de actas propias en cualquier momento
- Persistencia offline con Hive y sincronización automática al recuperar conectividad

### Coordinador de Recinto
- Visualización de TODAS las mesas del recinto (1 a N) con estado (registrada / pendiente)
- Creación de cuentas de veedores con todos los campos obligatorios
- Corrección de cualquier acta del recinto sin restricción
- Registro de nuevas actas

### Coordinador Provincial
- Listado de recintos con creación
- Creación de cuentas de coordinadores de recinto y asignación a un recinto
- Dashboard de votos consolidados por dignidad (Alcalde / Prefecto)
- Avance por recinto (actas registradas vs pendientes)
- Visualización de coordenadas GPS de actas
- Sincronización manual de datos pendientes

## Limitaciones técnicas

- La creación de usuarios (coordinadores y veedores) usa `account.create()` desde el cliente Flutter, lo que pierde la sesión activa del creador y requiere restaurarla después. En producción se recomienda una Appwrite Function server-side con API Key.
- El flujo offline utiliza Hive como almacenamiento local; la sincronización automática ocurre al detectar reconexión, pero no incluye resolución avanzada de conflictos (último cambio gana).
- La validación de nitidez (Laplacian variance < 4.0) es un heurístico simple; puede fallar en condiciones de iluminación muy baja o con imágenes de texto muy pequeño.
- Las reglas de acceso por rol no están configuradas en Appwrite (todos los clientes usan la misma API Key). En producción se deben implementar permisos a nivel de documento.

## Generar APK

```bash
flutter build apk --release
```

La APK se generará en `build/app/outputs/flutter-apk/app-release.apk`.
