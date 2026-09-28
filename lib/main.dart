import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/alumni_repository.dart';
import 'data/sources/local/local_cache_source.dart';
import 'data/sources/remote/remote_data_source.dart';
import 'data/sources/remote/school_api.dart';
import 'presentation/providers/alumni_list_provider.dart';
import 'presentation/providers/alumni_detail_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/teachers_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await _initializeSupabase();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Created once so the router and the widget tree share the same session.
  final auth = AuthProvider();
  final router = createRouter(auth);

  runApp(MyApp(prefs: prefs, auth: auth, router: router));
}

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // Continue without Supabase for development/testing
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthProvider auth;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.prefs,
    required this.auth,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    // Create repository instances
    final remoteDataSource = RemoteDataSource();
    final localCacheSource = LocalCacheSource(prefs);
    final repository = AlumniRepository(
      remoteDataSource: remoteDataSource,
      localCacheSource: localCacheSource,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        // Teacher directory from ausc.edu.bd
        ChangeNotifierProvider(
          create: (_) => TeachersProvider(SchoolApi(), prefs),
        ),
        // Theme provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        // Alumni list provider
        ChangeNotifierProvider(
          create: (_) => AlumniListProvider(repository),
        ),
        // Alumni detail provider (created on demand)
        ChangeNotifierProvider(
          create: (_) => AlumniDetailProvider(repository),
          lazy: true,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'AUSC Alumni Association',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
            // Keep a phone-width column on wide screens (web/desktop).
            builder: (context, child) => ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
