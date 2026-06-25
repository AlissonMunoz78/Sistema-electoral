import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/appwrite_client.dart';
import 'core/connectivity_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';

import 'features/actas/data/datasources/acta_datasource.dart';
import 'features/actas/data/repositories/acta_repository_impl.dart';
import 'features/actas/domain/usecases/create_acta.dart';
import 'features/actas/domain/usecases/obtener_actas.dart';
import 'features/actas/domain/usecases/actualizar_acta.dart';
import 'features/actas/presentation/bloc/acta_bloc.dart';
import 'features/actas/presentation/bloc/acta_event.dart';
import 'features/actas/presentation/pages/form_acta_page.dart';
import 'features/actas/presentation/pages/list_actas_page.dart';

import 'features/recintos/data/datasources/recinto_datasource.dart';
import 'features/recintos/data/repositories/recinto_repository_impl.dart';
import 'features/recintos/domain/usecases/crear_recinto.dart';
import 'features/recintos/domain/usecases/obtener_recintos.dart';
import 'features/recintos/domain/usecases/asignar_coordinador.dart';
import 'features/recintos/presentation/bloc/recinto_bloc.dart';
import 'features/recintos/presentation/pages/listar_recintos_page.dart';
import 'features/recintos/presentation/pages/coordinador_recinto_page.dart';

import 'offline/hive_service.dart';
import 'offline/sync_service.dart';

late final HiveService hiveService;
late final SyncService syncService;
final ConnectivityService connectivityService = ConnectivityService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hiveService = await HiveService.init();

  final actaDatasource = ActaDatasource(databases);
  final actaRepository = ActaRepositoryImpl(actaDatasource, hiveService: hiveService);
  syncService = SyncService(hiveService, actaDatasource);

  connectivityService.onConnectivityChanged = (_) async {
    await syncService.syncPendingActas();
  };
  connectivityService.startMonitoring();

  final authRemoteDS = AuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(authRemoteDS, databases);
  final recintoDatasource = RecintoDatasource(databases);
  final recintoRepository = RecintoRepositoryImpl(recintoDatasource);

  runApp(MyApp(
    authRepository: authRepository,
    actaRepository: actaRepository,
    recintoRepository: recintoRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ActaRepositoryImpl actaRepository;
  final RecintoRepositoryImpl recintoRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.actaRepository,
    required this.recintoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository),
        ),
        BlocProvider(
          create: (_) => ActaBloc(
            crearActa: CrearActa(actaRepository),
            obtenerActas: ObtenerActas(actaRepository),
            actualizarActa: ActualizarActa(actaRepository),
          )..add(CargarActasEvent()),
        ),
        BlocProvider(
          create: (_) => RecintoBloc(
            crearRecinto: CrearRecinto(recintoRepository),
            obtenerRecintos: ObtenerRecintos(recintoRepository),
            asignarCoordinador: AsignarCoordinador(recintoRepository),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema Electoral',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1A3A6B),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/forgot-password':
              return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
            case '/change-password':
              return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
            case '/home':
              final args = settings.arguments as AppUser?;
              return MaterialPageRoute(builder: (_) => HomePage(user: args));
            default:
              return MaterialPageRoute(builder: (_) => const LoginPage());
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final AppUser? user;
  const HomePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final role = user?.role;
    final userId = user?.id ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is AuthInitial) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('Sistema Electoral - ${_roleName(role)}'),
          backgroundColor: const Color(0xFF1A3A6B),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            ),
          ],
        ),
        body: role == UserRole.coordinatorProvincial
            ? _buildProvincialPanel(context)
            : role == UserRole.coordinatorRecinto
                ? CoordinadorRecintoPage(recintoId: user?.id ?? '', userId: userId)
                : _buildVeedorPanel(context),
      ),
    );
  }

  String _roleName(UserRole? role) {
    switch (role) {
      case UserRole.coordinatorProvincial:
        return 'Coordinador Provincial';
      case UserRole.coordinatorRecinto:
        return 'Coordinador de Recinto';
      case UserRole.observer:
        return 'Veedor';
      default:
        return 'Usuario';
    }
  }

  Widget _buildProvincialPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          icon: Icons.location_city,
          title: 'Gestión de Recintos',
          subtitle: 'Crear y administrar recintos electorales',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BlocProvider.value(
              value: context.read<RecintoBloc>(),
              child: const ListarRecintosPage(),
            )),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.description,
          title: 'Ver todas las actas',
          subtitle: 'Actas registradas con coordenadas GPS y estado',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BlocProvider.value(
              value: context.read<ActaBloc>(),
              child: const ListActasPage(),
            )),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.sync,
          title: 'Sincronizar datos pendientes',
          subtitle: 'Forzar sincronización de actas offline',
          onTap: () async {
            await syncService.syncPendingActas();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronización completada'), backgroundColor: Colors.green),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVeedorPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          icon: Icons.add,
          title: 'Registrar Acta',
          subtitle: 'Tomar foto y registrar votos (Alcalde y Prefecto)',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormActaPage()),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          icon: Icons.list_alt,
          title: 'Ver mis actas',
          subtitle: 'Actas registradas y su estado',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListActasPage()),
          ),
        ),
      ],
    );
  }

  Widget _card({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A3A6B),
          foregroundColor: Colors.white,
          child: Icon(icon, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
