import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/alumni_list/alumni_list_screen.dart';
import '../presentation/screens/alumni_detail/alumni_detail_screen.dart';
import '../presentation/screens/add_alumni/add_alumni_screen.dart';
import '../presentation/screens/test_connection/test_connection_screen.dart';

/// Go Router configuration
final GoRouter router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    // Home/Alumni List
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const AlumniListScreen(),
    ),
    // Alumni Detail
    GoRoute(
      path: '/alumni/:id',
      name: 'alumniDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AlumniDetailScreen(alumniId: id);
      },
    ),
    // Add Alumni
    GoRoute(
      path: '/add-alumni',
      name: 'addAlumni',
      builder: (context, state) => const AddAlumniScreen(),
    ),
    // Test Connection
    GoRoute(
      path: '/test-connection',
      name: 'testConnection',
      builder: (context, state) => const TestConnectionScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
