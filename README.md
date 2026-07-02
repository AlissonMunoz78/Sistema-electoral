# Sistema Electoral

Aplicación Flutter para la gestión de actas electorales con tres roles de usuario,
persistencia offline y sincronización automática mediante Appwrite.

## Requisitos

- Flutter SDK 3.11+
- Dispositivo con Android 5.0+ o iOS 12+ (cámara y GPS requeridos)
- Cuenta en Appwrite Cloud (o instancia propia)

## Configuración de Appwrite Console

### 1. Crear el proyecto
- Ve a [Appwrite Console](https://cloud.appwrite.io)
- Crea un proyecto con ID: `sistema-electoral`

### 2. Crear las colecciones en Database

#### Colección `ususarios`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| authUserId | string | $id del usuario en Appwrite Auth |
| cedula | string | Cédula de identidad (10 dígitos) |
| nombres | string | Nombres completos |
| apellidos | string | Apellidos completos |
| telefono | string | Teléfono de contacto |
| correo | string | Correo electrónico |
| rol | string | `coordinatorProvincial` / `coordinatorRecinto` / `observer` |
| primerLogin | boolean | `true` hasta que cambie la contraseña |
| recintoId | string? | ID del recinto asignado (solo coordinadores de recinto) |

#### Colección `actas`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| junta | number | Número de mesa (JRV) |
| provincia | string | Provincia |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| dignidad | string | `alcalde` o `prefecto` |
| votosOrganizaciones | number[] | Array de 5 enteros |
| blancos | number | Votos en blanco |
| nulos | number | Votos nulos |
| totalSufragantes | number | Total de sufragantes |
| fotoId | string | ID del archivo en Storage |
| fecha | datetime | Fecha del registro |
| imagenValida | boolean | Nitidez validada |
| latitud | number? | GPS latitud |
| longitud | number? | GPS longitud |
| userId | string? | ID del veedor que registró |

#### Colección `recintos`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| nombre | string | Nombre del recinto |
| provincia | string | Provincia |
| canton | string | Cantón |
| parroquia | string | Parroquia |
| numeroJRV | number | Cantidad de JRV |
| coordinadorId | string? | ID del coordinador asignado |

#### Colección `asignaciones_mesa`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| veedorId | string | `authUserId` del veedor |
| mesa | number | Número de mesa (JRV) |
| recintoId | string | ID del recinto |

### 3. Configurar Autenticación

- En **Auth > Settings**, habilita el método **Email/Password**.
- Ve a **Auth > Teams** y crea los equipos si lo deseas (no obligatorio).

### 4. Registrar plataformas para recovery y verification (método anterior)

Para que funcione la recuperación de contraseña y la verificación de correo
(este método usa URL completa, puede dejar de funcionar en versiones recientes
de Appwrite; ver sección 7 para el método recomendado):

1. Ve a **Project Settings > Platforms**
2. Haz clic en **Add Platform**
3. Selecciona **Web**
4. Name: `Sistema Electoral Recovery`
5. URL: `sistema-electoral://recovery`
6. Repite para:
   - Name: `Sistema Electoral Verify`
   - URL: `sistema-electoral://verify`

> **Nota:** Los correos de recuperación y verificación usan estas URLs como
> redirect. Si usas un hosting web, puedes registrar URLs HTTP/HTTPS en su lugar.

### 5. Configurar Storage

- Crea un bucket con ID `6a3ca946002e1039870d` (o actualiza `appwriteBucketId` en `lib/core/appwrite_client.dart`)
- Permisos: `read("any")`, `write("any")`

### 6. Configurar reglas de acceso (opcional pero recomendado)

En cada colección, ve a **Settings > Permissions** y añade:
- `read: users` (para que solo usuarios autenticados puedan leer)
- `write: users` (para escritura)

### Registrar plataformas para deep links (verificación y recuperación)

1. Buscar "platform" con el buscador global de la consola de Appwrite (icono de lupa o Ctrl/Cmd+K).
2. Si no aparece ahí, revisar dentro del servicio "Auth" del proyecto (no en Settings/Overview).
3. Alternativa confiable vía CLI: instalar appwrite-cli, correr `appwrite login`, `appwrite init project`, `appwrite pull project`, editar `appwrite.config.json` agregando dos entradas en el array `"platforms"` (`type`: `"web"`, `hostname`/`key`: `"recovery"` y `"verify"`), y correr `appwrite push project`.
4. Verificar en la pestaña SMTP del proyecto que haya un proveedor de correo configurado; si se usa el mailer por defecto de Appwrite Cloud, advertir que puede tener límites de envío y que los correos pueden llegar a spam.

> **Nota importante:** No uses protocolo (`https://`) ni barras (`/`) en el
> campo Hostname. Solo la palabra `recovery` o `verify`. Tampoco es necesario
> registrar `sistema-electoral://` como URL completa; el esquema se resuelve
> automáticamente por el deep link nativo de la app.

## Instalación

```bash
git clone <repo-url>
cd sistema-electoral
flutter pub get
flutter run
```

## Credenciales

| Rol | Cédula | Contraseña |
|-----|--------|------------|
| Coordinador Provincial | (creada manualmente en Auth) | Ecuador2026 |
| Coordinador de Recinto | (asignada al crear) | Ecuador2026 |
| Veedor | (asignada al crear) | Ecuador2026 |

> El login usa **cédula** (10 dígitos numéricos), no email.
> La contraseña inicial para todos los usuarios nuevos es **Ecuador2026**.

## Flujo de registro

### Coordinador Provincial (creado manualmente en Appwrite Console)
1. Crear usuario en **Auth > Users** con email y contraseña `Ecuador2026`
2. Crear documento en `ususarios` con rol `coordinatorProvincial`

### Coordinador de Recinto (creado desde la app)
1. Coordinador Provincial accede a **Crear Coordinador de Recinto**
2. Ingresa cédula, nombres, email, selecciona recinto
3. El sistema crea la cuenta, envía correo de verificación
4. El coordinador de recinto verifica su email
5. Inicia sesión y cambia contraseña obligatoriamente

### Veedor (creado desde la app)
1. Coordinador de Recinto accede a **Crear cuenta de Veedor**
2. Ingresa datos y número de mesa
3. El sistema crea la cuenta, envía correo de verificación
4. El veedor verifica su email
5. Inicia sesión y cambia contraseña obligatoriamente

## Roles y funcionalidades

### Veedor
- Registro de actas con foto (cámara), GPS obligatorio
- Validación de nitidez de imagen (Laplacian variance)
- 5 organizaciones políticas por dignidad (Alcalde / Prefecto)
- Validación: suma de votos ≤ total de sufragantes
- Corrección de actas propias

### Coordinador de Recinto
- Visualización de mesas del recinto con estado
- Creación de cuentas de veedores
- Asignación de veedores existentes a mesas
- Corrección de cualquier acta del recinto

### Coordinador Provincial
- Dashboard de votos consolidados
- Gestión de recintos (crear, asignar coordinador)
- Creación de coordinadores de recinto
- Ver todas las actas con GPS
- Sincronización manual/automática

## Organizaciones políticas

### Alcalde
1. María Fernanda Salazar — Acción Democrática Nacional (ADN)
2. Pabel Muñoz — Revolución Ciudadana (RC5)
3. Esteban Cárdenas — Partido Social Cristiano (PSC)
4. Luis Herrera — Avanza
5. Andrés Quishpe — Pachakutik

### Prefecto
1. Diego Almeida — Acción Democrática Nacional (ADN)
2. Paola Pabón — Revolución Ciudadana (RC5)
3. Roberto Freire — Partido Social Cristiano (PSC)
4. Cristina Vallejo — Avanza
5. José Guamán — Pachakutik

## Validación de nitidez

La app usa **Laplacian Variance** sobre la imagen redimensionada a 300×300 px
con interpolación `nearest`. El umbral de varianza es 30.0 — si la varianza
del Laplaciano es menor, la imagen se clasifica como borrosa y se rechaza.

Justificación del algoritmo:
- La varianza del Laplaciano mide la dispersión de la intensidad de bordes
- Imágenes nítidas tienen bordes muy definidos → alta varianza
- Imágenes borrosas tienen bordes suaves → baja varianza
- La media del Laplaciano (usada anteriormente) es un mal discriminante porque
  los píxeles de fondo plano dominan el promedio

## Sincronización offline

### Estrategia
- **Almacenamiento local**: Hive con dos boxes (`offline_actas`, `pending_sync`)
- **Foto offline**: Cuando no hay internet, la foto se copia al directorio de
  documentos de la app y su ruta se guarda junto al acta en Hive
- **Sincronización**: Al recuperar conectividad, el `SyncService` recorre las
  actas pendientes, sube la foto local a Appwrite Storage, crea el documento
  y marca como sincronizado
- **Resolución de conflictos**: Estrategia "último en escribir gana" (LWW)

### Flujo
```
Usuario guarda acta offline
  → Foto copiada a documentos/
  → Acta + ruta de foto guardados en Hive
  → Mostrar: "Guardado localmente. Se sincronizará automáticamente."

Al reconectar WiFi/datos
  → connectivity_plus detecta cambio
  → SyncService.syncPendingActas()
  → Por cada acta pendiente:
      1. Leer foto del path local
      2. Subir a Appwrite Storage
      3. Crear documento en colección actas
      4. Marcar como sincronizado
      5. Eliminar foto local
```

## Arquitectura

El proyecto sigue Clean Architecture con BLoC:

```
lib/
├── core/              # Utilidades compartidas
│   ├── appwrite_client.dart
│   ├── cedula_validator.dart
│   ├── connectivity_service.dart
│   ├── image_service.dart
│   ├── political_organizations.dart
│   ├── provincias.dart
│   └── storage_service.dart
├── offline/           # Persistencia offline
│   ├── hive_service.dart
│   └── sync_service.dart
├── features/
│   ├── actas/         # Módulo de actas
│   │   ├── data/      # Datasources, modelos, repositorios
│   │   ├── domain/    # Entidades, use cases, repositorios abstractos
│   │   └── presentation/  # BLoC, páginas
│   ├── asignaciones/  # Asignaciones veedor-mesa
│   ├── auth/          # Autenticación y usuarios
│   └── recintos/      # Gestión de recintos
└── main.dart
```

## Verificación de correo electrónico

Todo usuario nuevo recibe un correo de verificación automático.
Si intenta iniciar sesión sin verificar, la app muestra:
*"Debes verificar tu correo electrónico antes de iniciar sesión."*

El flujo completo:
1. Se crea el usuario en Appwrite Auth
2. Se envía el correo de verificación mediante `account.createVerification()`
3. El usuario hace clic en el enlace del correo
4. Appwrite marca la cuenta como verificada
5. El usuario puede iniciar sesión
6. En el primer login se le obliga a cambiar la contraseña

## Recuperación de contraseña

En la pantalla de login, "¿Olvidaste tu contraseña?" abre el formulario
de recuperación. El usuario ingresa su email y recibe un enlace para
restablecer la contraseña.

**Importante:** La URL `sistema-electoral://recovery` debe estar registrada
como plataforma en Appwrite Console (ver sección de configuración arriba).

## Generar APK

```bash
flutter build apk --release --dart-define=APPWRITE_API_KEY=<clave_desde_Appwrite_Console>
```

> La API Key se inyecta en tiempo de compilación mediante `--dart-define`. Si no
> se proporciona, `appwriteApiKey` queda como cadena vacía y las funciones que
> la requieren (auto-verificación de correo, eliminación de cuentas Auth) no
> estarán disponibles. Obtenla en Appwrite Console > Settings > API Keys con
> los permisos `users.read` y `users.write`.

La APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Limitaciones técnicas

- La creación de usuarios desde el cliente Flutter pierde la sesión activa
  del creador. Se restaura automáticamente con reintentos, pero en producción
  se recomienda una Appwrite Function server-side con API Key.
- La sincronización offline usa estrategia "último en escribir gana" (LWW).
  Múltiples veedores offline en la misma mesa podrían sobrescribirse.
- La validación de nitidez es un heurístico que puede fallar en condiciones
  extremas de iluminación o con texto muy pequeño.
- Las reglas de acceso a nivel de documento no están configuradas en Appwrite.
  Todos los documentos usan `read("any")` y `write("any")`.
