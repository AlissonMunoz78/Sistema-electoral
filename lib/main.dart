import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/appwrite_client.dart';
import 'core/connectivity_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/crear_usuario_usecase.dart';
import 'features/auth/domain/usecases/check_auth_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/complete_recovery_usecase.dart';
import 'features/auth/domain/usecases/complete_verification_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';

import 'features/actas/data/datasources/acta_datasource.dart';
import 'features/actas/data/repositories/acta_repository_impl.dart';
import 'features/actas/domain/repositories/acta_repository.dart';
import 'features/actas/domain/usecases/create_acta.dart';
import 'features/actas/domain/usecases/obtener_actas.dart';
import 'features/actas/domain/usecases/actualizar_acta.dart';
import 'features/actas/presentation/bloc/acta_bloc.dart';
import 'features/actas/presentation/bloc/acta_event.dart';
import 'features/actas/presentation/pages/form_acta_page.dart';
import 'features/actas/presentation/pages/list_actas_page.dart';
import 'features/actas/presentation/pages/dashboard_page.dart';
import 'features/recintos/presentation/pages/gestion_coordinadores_page.dart';

import 'features/recintos/data/datasources/recinto_datasource.dart';
import 'features/recintos/data/repositories/recinto_repository_impl.dart';
import 'features/recintos/domain/repositories/recinto_repository.dart';
import 'features/recintos/domain/usecases/crear_recinto.dart';
import 'features/recintos/domain/usecases/obtener_recintos.dart';
import 'features/recintos/domain/usecases/asignar_coordinador.dart';
import 'features/recintos/presentation/bloc/recinto_bloc.dart';
import 'features/recintos/presentation/pages/listar_recintos_page.dart';
import 'features/recintos/presentation/pages/crear_coordinador_page.dart';
import 'features/recintos/presentation/pages/coordinador_recinto_page.dart';
import 'features/asignaciones/data/datasources/asignacion_datasource.dart';

import 'offline/hive_service.dart';
import 'offline/sync_service.dart';

late final HiveService hiveService;
late final SyncService syncService;
final ConnectivityService connectivityService = ConnectivityService();

class AuthGuard extends ChangeNotifier {
  AuthState? _authState;
  AuthState? get authState => _authState;

  void update(AuthState state) {
    if (_authState.runtimeType != state.runtimeType) {
      _authState = state;
      notifyListeners();
    }
  }
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D2137),
    primary: const Color(0xFF0D2137),
    secondary: const Color(0xFFD4A843),
    tertiary: const Color(0xFF27AE60),
    error: const Color(0xFFE74C3C),
    surface: Colors.white,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF0F2F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D2137),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFF0D2137),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFF0D2137)),
      foregroundColor: const Color(0xFF0D2137),
    ),
  ),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      selectedBackgroundColor: const Color(0xFF0D2137),
      selectedForegroundColor: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0D2137), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade100,
    thickness: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF0F2F5),
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await dotenv.load(fileName: '.env');
  hiveService = await HiveService.init();

  final actaDatasource = ActaDatasource(databases);
  final actaRepository = ActaRepositoryImpl(actaDatasource, hiveService: hiveService);
  syncService = SyncService(hiveService, actaDatasource);

  connectivityService.onConnectivityChanged = (_) async {
    await syncService.syncPendingActas();
  };
  connectivityService.startMonitoring();

  await syncService.syncPendingActas();

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

final AuthGuard authGuard = AuthGuard();

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final ActaRepository actaRepository;
  final RecintoRepository recintoRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.actaRepository,
    required this.recintoRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  late final GoRouter _router;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  GoRouter _createRouter() {
    return GoRouter(
      refreshListenable: authGuard,
      initialLocation: '/login',
      redirect: (context, state) {
        final s = authGuard.authState;
        final location = state.matchedLocation;

        if (s == null || s is AuthInitial || s is AuthLoading || s is AuthFailure) {
          if (location != '/login' && location != '/forgot-password' &&
              !location.startsWith('/recovery') && !location.startsWith('/verify')) {
            return '/login';
          }
          return null;
        }

        if (s is AuthRequirePasswordChange) {
          if (location != '/change-password') return '/change-password';
          return null;
        }

        if (s is AuthAuthenticated) {
          if (location == '/login' || location == '/forgot-password' || location == '/') {
            return '/home';
          }
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
        GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordPage()),
        GoRoute(
          path: '/recovery',
          builder: (_, state) {
            final userId = state.uri.queryParameters['userId'] ?? '';
            final secret = state.uri.queryParameters['secret'] ?? '';
            return ResetPasswordPage(userId: userId, secret: secret);
          },
        ),
        GoRoute(
          path: '/verify',
          builder: (_, state) {
            final userId = state.uri.queryParameters['userId'] ?? '';
            final secret = state.uri.queryParameters['secret'] ?? '';
            return EmailVerificationPage(userId: userId, secret: secret);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) {
            final s = authGuard.authState;
            if (s is AuthAuthenticated) return HomePage(user: s.user);
            if (s is AuthUsuarioCreado && s.sessionRestored) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0D2137)),
                      SizedBox(height: 16),
                      Text('Restaurando sesión...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            return const LoginPage();
          },
        ),
      ],
      errorBuilder: (_, __) => const LoginPage(),
    );
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
      _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
    } catch (_) {}
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'recovery' || uri.pathSegments.contains('recovery')) {
      final userId = uri.queryParameters['userId'] ?? '';
      final secret = uri.queryParameters['secret'] ?? '';
      if (userId.isNotEmpty && secret.isNotEmpty) {
        _router.go('/recovery?userId=$userId&secret=$secret');
      }
    } else if (uri.host == 'verify' || uri.pathSegments.contains('verify')) {
      final userId = uri.queryParameters['userId'] ?? '';
      final secret = uri.queryParameters['secret'] ?? '';
      if (userId.isNotEmpty && secret.isNotEmpty) {
        _router.go('/verify?userId=$userId&secret=$secret');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(widget.authRepository),
            forgotPasswordUseCase: ForgotPasswordUseCase(widget.authRepository),
            changePasswordUseCase: ChangePasswordUseCase(widget.authRepository),
            crearUsuarioUseCase: CrearUsuarioUseCase(widget.authRepository),
            checkAuthUseCase: CheckAuthUseCase(widget.authRepository),
            logoutUseCase: LogoutUseCase(widget.authRepository),
            completeRecoveryUseCase: CompleteRecoveryUseCase(widget.authRepository),
            completeVerificationUseCase: CompleteVerificationUseCase(widget.authRepository),
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => ActaBloc(
            crearActa: CrearActa(widget.actaRepository),
            obtenerActas: ObtenerActas(widget.actaRepository),
            actualizarActa: ActualizarActa(widget.actaRepository),
          )..add(CargarActasEvent()),
        ),
        BlocProvider(
          create: (_) => RecintoBloc(
            crearRecinto: CrearRecinto(widget.recintoRepository),
            obtenerRecintos: ObtenerRecintos(widget.recintoRepository),
            asignarCoordinador: AsignarCoordinador(widget.recintoRepository),
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (_, state) => authGuard.update(state),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Sistema Electoral',
          theme: appTheme,
          routerConfig: _router,
        ),
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
        if (state is AuthInitial) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.how_to_vote, size: 22, color: Color(0xFFD4A843)),
              const SizedBox(width: 8),
              Text('Sistema Electoral'),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D2137), Color(0xFF1A3A6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user!.nombreCompleto,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              tooltip: 'Cerrar sesión',
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthLogoutRequested()),
            ),
          ],
        ),
        body: role == UserRole.coordinatorProvincial
            ? _buildProvincialPanel(context)
            : role == UserRole.coordinatorRecinto
                ? CoordinadorRecintoPage(
                    recintoId: user?.recintoId ?? user?.id ?? '',
                    userId: user?.id ?? '',
                    currentUser: user,
                  )
                : _VeedorPanel(user: user),
      ),
    );
  }

  Widget _buildProvincialPanel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _headerCard(
          icon: Icons.admin_panel_settings,
          title: 'Panel Provincial',
          subtitle: 'Gestión completa del proceso electoral',
        ),
        const SizedBox(height: 16),
        _navCard(
          icon: Icons.bar_chart,
          iconColor: const Color(0xFFD4A843),
          title: 'Dashboard de Votos',
          subtitle: 'Votos consolidados por candidato y recinto',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
        ),
        const SizedBox(height: 12),
        _navCard(
          icon: Icons.location_city,
          iconColor: const Color(0xFF27AE60),
          title: 'Gestión de Recintos',
          subtitle: 'Crear y administrar recintos electorales',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<RecintoBloc>(),
                child: const ListarRecintosPage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _navCard(
          icon: Icons.person_add,
          iconColor: const Color(0xFF2980B9),
          title: 'Crear Coordinador de Recinto',
          subtitle: 'Crear cuenta y asignar a un recinto',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<RecintoBloc>(),
                child: CrearCoordinadorPage(currentUser: user!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _navCard(
          icon: Icons.people,
          iconColor: const Color(0xFFE67E22),
          title: 'Gestión de Usuarios (Coordinadores de Recinto)',
          subtitle: 'Ver, desasignar coordinadores de recinto',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GestionCoordinadoresPage()),
          ),
        ),
        const SizedBox(height: 12),
        _navCard(
          icon: Icons.description,
          iconColor: const Color(0xFF8E44AD),
          title: 'Ver todas las actas',
          subtitle: 'Actas registradas con coordenadas GPS y estado',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ActaBloc>(),
                child: ListActasPage(currentUser: user, readOnly: true),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _navCard(
          icon: Icons.sync,
          iconColor: const Color(0xFFD4A843),
          title: 'Sincronizar datos pendientes',
          subtitle: 'Forzar sincronización de actas offline',
          onTap: () async {
            await syncService.syncPendingActas();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronización completada'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _headerCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A3A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2137).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD4A843), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF0D2137),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VeedorPanel extends StatefulWidget {
  final AppUser? user;
  const _VeedorPanel({this.user});

  @override
  State<_VeedorPanel> createState() => _VeedorPanelState();
}

class _VeedorPanelState extends State<_VeedorPanel> {
  Map<String, dynamic>? _recinto;
  List<Map<String, dynamic>> _asignaciones = [];
  List<int> _mesas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = widget.user;
    if (user?.recintoId == null || user?.authUserId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        RecintoDatasource(databases).obtenerRecinto(user!.recintoId!),
        AsignacionDatasource(databases).obtenerPorVeedor(user.authUserId),
      ]);
      if (mounted) {
        setState(() {
          _recinto = results[0] as Map<String, dynamic>?;
          _asignaciones = results[1] as List<Map<String, dynamic>>;
          _mesas = _asignaciones.map((e) => e['mesa'] as int).toList()..sort();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _veedorHeader(),
        const SizedBox(height: 16),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF0D2137)),
            ),
          )
        else ...[
          if (_recinto != null)
            _recintoCard(),
          const SizedBox(height: 12),
          _navCard(
            icon: Icons.add_circle,
            iconColor: const Color(0xFF27AE60),
            title: 'Registrar Acta',
            subtitle: 'Tomar foto y registrar votos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormActaPage(currentUser: widget.user),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _navCard(
            icon: Icons.list_alt,
            iconColor: const Color(0xFF2980B9),
            title: 'Ver mis actas',
            subtitle: 'Actas registradas y su estado',
            onTap: () {
              context.read<ActaBloc>().add(CargarActasEvent());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListActasPage(currentUser: widget.user),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _veedorHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A6B), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2137).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.visibility, color: Color(0xFFD4A843), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel del Veedor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra las actas de tus mesas asignadas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recintoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A843).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFD4A843), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recinto?['nombre'] as String? ?? 'Recinto',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF0D2137),
                      ),
                    ),
                    Text(
                      '${_recinto?['canton'] ?? ''} / ${_recinto?['parroquia'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_mesas.length} mesa${_mesas.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4A843),
                  ),
                ),
              ),
            ],
          ),
          if (_mesas.isNotEmpty) ...[
            const Divider(height: 20),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _mesas.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2137),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mesa $m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _navCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF0D2137),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
