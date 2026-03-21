import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/alumni_repository.dart';
import 'data/sources/local/local_cache_source.dart';
import 'data/sources/remote/remote_data_source.dart';
import 'presentation/providers/alumni_list_provider.dart';
import 'presentation/providers/alumni_detail_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await _initializeSupabase();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
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

  const MyApp({super.key, required this.prefs});

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
        // Theme provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        // Alumni list provider
        ChangeNotifierProvider(
          create: (_) => AlumniListProvider(repository),
        ),
        // Alumni detail provider (created on demand)
        ProxyProvider0<AlumniDetailProvider>(
          update: (_, previous) => AlumniDetailProvider(repository),
          dispose: (_, provider) => provider.dispose(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'AUSC Alumni',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
