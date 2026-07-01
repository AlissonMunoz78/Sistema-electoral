/**
 * Seed.js — Poblar la base de datos de Appwrite para pruebas
 *
 * Uso:
 *   1. node seed.js
 *
 * Requisitos:
 *   - Node.js 18+
 *   - npm install node-appwrite
 *
 * Configuración:
 *   Antes de ejecutar, crea una API Key en Appwrite Console:
 *   Project → Settings → API Keys → + Create API Key
 *   Permisos necesarios: users.write, databases.write, documents.write
 *
 *   Luego asigna la API Key a la variable de entorno APPWRITE_API_KEY
 *   o pégala directamente en la constante más abajo.
 */

const sdk = require('node-appwrite');

// ─── Config ──────────────────────────────────────────────────────────────────
const ENDPOINT = 'https://sfo.cloud.appwrite.io/v1';
const PROJECT_ID = 'sistema-electoral';
const DATABASE_ID = '6a3ca5420008a6f70fe1';
const API_KEY = process.env.APPWRITE_API_KEY || 'COLOCA_TU_API_KEY_AQUI';

// IDs de colecciones (deben coincidir con los que ya creaste en Appwrite Console)
const COLLECTIONS = {
  ususarios: 'ususarios',
  recintos: 'recintos',
  actas: 'actas',
  organizaciones_politicas: 'organizaciones',
  asignaciones_mesa: 'asignaciones_mesa',
};

const PASSWORD_INICIAL = 'Ecuador2026';

const PERMS = [
  sdk.Permission.write(sdk.Role.any()),
  sdk.Permission.read(sdk.Role.any()),
];

// ─── Cliente ─────────────────────────────────────────────────────────────────
const client = new sdk.Client()
  .setEndpoint(ENDPOINT)
  .setProject(PROJECT_ID)
  .setKey(API_KEY);

const users = new sdk.Users(client);
const db = new sdk.Databases(client);

// ─── Helper ──────────────────────────────────────────────────────────────────
async function crearUsuarioAuth({ email, password, nombre, cedula, rol, recintoId }) {
  // Nota: no podemos crear usuarios Auth desde el seed con API Key.
  // Creamos el documento en ususarios con authUserId pendiente.
  // Luego en Appwrite Console: Users → Add user → copiar $id → edit document.
  const doc = await db.createDocument(
    DATABASE_ID,
    COLLECTIONS.ususarios,
    sdk.ID.unique(),
    {
      authUserId: 'PENDIENTE',
      cedula,
      nombres: nombre.split(' ').slice(0, -1).join(' '),
      apellidos: nombre.split(' ').slice(-1).join(' '),
      telefono: '0999999999',
      correo: email,
      rol,
      primerLogin: false,
      recintoId: recintoId || '',
    },
    PERMS,
  );

  console.log(`  ✔ Documento creado: ${nombre} (${email}) — rol: ${rol}`);
  console.log(`    ⚠ Luego asigna el Auth ID a: ${doc.$id}`);
  return { authUserId: 'PENDIENTE', docId: doc.$id };
}

// ─── Main ────────────────────────────────────────────────────────────────────
async function main() {
  console.log('\n=== POBLANDO BASE DE DATOS DEL SISTEMA ELECTORAL ===\n');

  // =========================================================================
  // 1. RECINTOS
  // =========================================================================
  console.log('--- Recintos Electorales ---');

  const recintos = [
    { nombre: 'Unidad Educativa Benalcázar', provincia: 'Pichincha', canton: 'Quito', parroquia: 'La Mariscal', numeroJRV: 20 },
    { nombre: 'Colegio Nacional Mejía', provincia: 'Pichincha', canton: 'Quito', parroquia: 'Centro Histórico', numeroJRV: 18 },
    { nombre: 'Unidad Educativa Manuela Cañizares', provincia: 'Pichincha', canton: 'Quito', parroquia: 'La Floresta', numeroJRV: 15 },
    { nombre: 'Colegio 24 de Mayo', provincia: 'Pichincha', canton: 'Quito', parroquia: 'Iñaquito', numeroJRV: 22 },
    { nombre: 'Unidad Educativa Espejo', provincia: 'Pichincha', canton: 'Quito', parroquia: 'Cotocollao', numeroJRV: 17 },
    { nombre: 'Unidad Educativa Fernández Madrid', provincia: 'Pichincha', canton: 'Quito', parroquia: 'San Juan', numeroJRV: 14 },
    { nombre: 'Unidad Educativa Sebastián de Benalcázar', provincia: 'Pichincha', canton: 'Quito', parroquia: 'Belisario Quevedo', numeroJRV: 16 },
    { nombre: 'Universidad Central del Ecuador', provincia: 'Pichincha', canton: 'Quito', parroquia: 'Belisario Quevedo', numeroJRV: 25 },
    { nombre: 'Universidad de Guayaquil', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Tarqui', numeroJRV: 24 },
    { nombre: 'Unidad Educativa Fiscal 28 de Mayo', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Pascuales', numeroJRV: 18 },
    { nombre: 'Unidad Educativa Julio María Matovelle', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Febres Cordero', numeroJRV: 20 },
    { nombre: 'Unidad Educativa Otto Arosemena Gómez', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Ximena', numeroJRV: 16 },
    { nombre: 'Unidad Educativa Joaquín Gallegos Lara', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Febres Cordero', numeroJRV: 15 },
    { nombre: 'Universidad Agraria del Ecuador', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Febres Cordero', numeroJRV: 19 },
    { nombre: 'Unidad Educativa Particular Javier', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Tarqui', numeroJRV: 17 },
    { nombre: 'Unidad Educativa Los Vergeles', provincia: 'Guayas', canton: 'Guayaquil', parroquia: 'Pascuales', numeroJRV: 14 },
  ];

  const recintoDocs = [];
  for (const r of recintos) {
    const doc = await db.createDocument(
      DATABASE_ID,
      COLLECTIONS.recintos,
      sdk.ID.unique(),
      r,
      PERMS,
    );
    recintoDocs.push(doc);
    console.log(`  ✔ Recinto: ${r.nombre} (${r.provincia}, ${r.canton}) — ${r.numeroJRV} JRV`);
  }

  // =========================================================================
  // 2. ORGANIZACIONES POLÍTICAS (candidatos para Alcalde y Prefecto)
  // =========================================================================
  console.log('\n--- Organizaciones Políticas ---');

  const organizaciones = [
    // Alcalde de Quito (Pichincha)
    { nombre: 'Acción Democrática Nacional (ADN)', candidato: 'María Fernanda Salazar', provincia: 'Pichincha', dignidad: 'alcalde' },
    { nombre: 'Revolución Ciudadana (RC5)', candidato: 'Pabel Muñoz', provincia: 'Pichincha', dignidad: 'alcalde' },
    { nombre: 'Partido Social Cristiano (PSC)', candidato: 'Esteban Cárdenas', provincia: 'Pichincha', dignidad: 'alcalde' },
    { nombre: 'Avanza', candidato: 'Luis Herrera', provincia: 'Pichincha', dignidad: 'alcalde' },
    { nombre: 'Pachakutik', candidato: 'Andrés Quishpe', provincia: 'Pichincha', dignidad: 'alcalde' },
    // Prefecto de Pichincha
    { nombre: 'Acción Democrática Nacional (ADN)', candidato: 'Diego Almeida', provincia: 'Pichincha', dignidad: 'prefecto' },
    { nombre: 'Revolución Ciudadana (RC5)', candidato: 'Paola Pabón', provincia: 'Pichincha', dignidad: 'prefecto' },
    { nombre: 'Partido Social Cristiano (PSC)', candidato: 'Roberto Freire', provincia: 'Pichincha', dignidad: 'prefecto' },
    { nombre: 'Avanza', candidato: 'Cristina Vallejo', provincia: 'Pichincha', dignidad: 'prefecto' },
    { nombre: 'Pachakutik', candidato: 'José Guamán', provincia: 'Pichincha', dignidad: 'prefecto' },
    // Alcalde de Guayaquil (Guayas)
    { nombre: 'Acción Democrática Nacional (ADN)', candidato: 'John Reimberg', provincia: 'Guayas', dignidad: 'alcalde' },
    { nombre: 'Revolución Ciudadana (RC5)', candidato: 'Aquiles Álvarez', provincia: 'Guayas', dignidad: 'alcalde' },
    { nombre: 'Partido Social Cristiano (PSC)', candidato: 'Cynthia Viteri', provincia: 'Guayas', dignidad: 'alcalde' },
    { nombre: 'Avanza', candidato: 'Carlos Medina', provincia: 'Guayas', dignidad: 'alcalde' },
    { nombre: 'Pachakutik', candidato: 'Andrea Chang', provincia: 'Guayas', dignidad: 'alcalde' },
    // Prefecto del Guayas
    { nombre: 'Acción Democrática Nacional (ADN)', candidato: 'María José Pinto', provincia: 'Guayas', dignidad: 'prefecto' },
    { nombre: 'Revolución Ciudadana (RC5)', candidato: 'Marcela Aguiñaga', provincia: 'Guayas', dignidad: 'prefecto' },
    { nombre: 'Partido Social Cristiano (PSC)', candidato: 'Susana González', provincia: 'Guayas', dignidad: 'prefecto' },
    { nombre: 'Avanza', candidato: 'Jimmy Jairala', provincia: 'Guayas', dignidad: 'prefecto' },
    { nombre: 'Pachakutik', candidato: 'Carlos Sucuzhañay', provincia: 'Guayas', dignidad: 'prefecto' },
  ];

  for (const org of organizaciones) {
    await db.createDocument(
      DATABASE_ID,
      COLLECTIONS.organizaciones_politicas,
      sdk.ID.unique(),
      org,
      PERMS,
    );
  }
  console.log(`  ✔ ${organizaciones.length} organizaciones políticas insertadas`);

  // =========================================================================
  // 3. USUARIOS (Auth + documentos en colección)
  // =========================================================================
  console.log('\n--- Usuarios del Sistema ---');

  // 3a. Coordinador Provincial
  const prov = await crearUsuarioAuth({
    email: 'maria.garcia@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'María García',
    cedula: '1701111111',
    rol: 'coordinatorProvincial',
  });

  // 3b. Coordinadores de Recinto (asignados a los recintos creados)
  const coord1 = await crearUsuarioAuth({
    email: 'carlos.lopez@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'Carlos López',
    cedula: '1702222222',
    rol: 'coordinatorRecinto',
    recintold: recintoDocs[0].$id,
  });

  const coord2 = await crearUsuarioAuth({
    email: 'ana.martinez@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'Ana Martínez',
    cedula: '1703333333',
    rol: 'coordinatorRecinto',
    recintold: recintoDocs[1].$id,
  });

  // Actualizar coordinadorId en los recintos (usar docId del documento en ususarios)
  await db.updateDocument(DATABASE_ID, COLLECTIONS.recintos, recintoDocs[0].$id, {
    coordinadorId: coord1.docId,
  }, PERMS);
  await db.updateDocument(DATABASE_ID, COLLECTIONS.recintos, recintoDocs[1].$id, {
    coordinadorId: coord2.docId,
  }, PERMS);

  // 3c. Veedores (observadores)
  const veedor1 = await crearUsuarioAuth({
    email: 'pedro.ramirez@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'Pedro Ramírez',
    cedula: '1704444444',
    rol: 'observer',
  });

  const veedor2 = await crearUsuarioAuth({
    email: 'laura.sanchez@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'Laura Sánchez',
    cedula: '1705555555',
    rol: 'observer',
  });

  const veedor3 = await crearUsuarioAuth({
    email: 'diego.torres@test.com',
    password: PASSWORD_INICIAL,
    nombre: 'Diego Torres',
    cedula: '1706666666',
    rol: 'observer',
  });

  // =========================================================================
  // 4. ASIGNACIONES DE MESA (veedor → mesa)
  // =========================================================================
  console.log('\n--- Asignaciones Mesa-Veedor ---');

  await db.createDocument(DATABASE_ID, COLLECTIONS.asignaciones_mesa, sdk.ID.unique(), {
    veedorId: veedor1.authUserId,
    mesa: 1,
    recintoId: recintoDocs[0].$id,
  }, PERMS);
  console.log(`  ✔ Veedor Pedro → Recinto "${recintoDocs[0].nombre}", Mesa 1`);

  await db.createDocument(DATABASE_ID, COLLECTIONS.asignaciones_mesa, sdk.ID.unique(), {
    veedorId: veedor2.authUserId,
    mesa: 2,
    recintoId: recintoDocs[0].$id,
  }, PERMS);
  console.log(`  ✔ Veedora Laura → Recinto "${recintoDocs[0].nombre}", Mesa 2`);

  await db.createDocument(DATABASE_ID, COLLECTIONS.asignaciones_mesa, sdk.ID.unique(), {
    veedorId: veedor3.authUserId,
    mesa: 1,
    recintoId: recintoDocs[1].$id,
  }, PERMS);
  console.log(`  ✔ Veedor Diego → Recinto "${recintoDocs[1].nombre}", Mesa 1`);

  // =========================================================================
  // 5. ACTAS DE EJEMPLO (opcional, se llenan desde la app)
  // =========================================================================
  console.log('\n--- Actas de Ejemplo ---');

  const actas = [
    {
      junta: 1,
      provincia: 'Pichincha',
      canton: 'Quito',
      parroquia: 'La Mariscal',
      dignidad: 'alcalde',
      votosOrganizaciones: [120, 85, 60, 30, 15],
      blancos: 10,
      nulos: 5,
      totalSufragantes: 325,
      fotoId: 'seed-ejemplo',
      fecha: new Date().toISOString(),
      imagenValida: true,
      latitud: -0.1807,
      longitud: -78.4678,
      userId: veedor1.docId,
    },
    {
      junta: 2,
      provincia: 'Pichincha',
      canton: 'Quito',
      parroquia: 'La Mariscal',
      dignidad: 'prefecto',
      votosOrganizaciones: [95, 110, 45, 40, 20],
      blancos: 8,
      nulos: 3,
      totalSufragantes: 321,
      fotoId: 'seed-ejemplo-2',
      fecha: new Date().toISOString(),
      imagenValida: true,
      latitud: -0.1810,
      longitud: -78.4685,
      userId: veedor2.docId,
    },
  ];

  for (const acta of actas) {
    await db.createDocument(
      DATABASE_ID,
      COLLECTIONS.actas,
      sdk.ID.unique(),
      acta,
      PERMS,
    );
  }
  console.log(`  ✔ ${actas.length} actas de ejemplo insertadas`);

  // =========================================================================
  // RESUMEN
  // =========================================================================
  console.log('\n============================================');
  console.log('  BASE DE DATOS POBLADA EXITOSAMENTE');
  console.log('============================================\n');
  console.log('Credenciales de prueba:');
  console.log('  Coord. Provincial:  1701111111 / Ecuador2026  (maria.garcia@test.com)');
  console.log('  Coord. Recinto 1:   1702222222 / Ecuador2026  (carlos.lopez@test.com)');
  console.log('  Coord. Recinto 2:   1703333333 / Ecuador2026  (ana.martinez@test.com)');
  console.log('  Veedor 1:           1704444444 / Ecuador2026  (pedro.ramirez@test.com)');
  console.log('  Veedor 2:           1705555555 / Ecuador2026  (laura.sanchez@test.com)');
  console.log('  Veedor 3:           1706666666 / Ecuador2026  (diego.torres@test.com)');
  console.log('');
}

main().catch((err) => {
  console.error('ERROR:', err);
  process.exit(1);
});
