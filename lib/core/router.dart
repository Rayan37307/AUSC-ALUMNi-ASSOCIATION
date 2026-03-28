import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/alumni_list/alumni_list_screen.dart';
import '../presentation/screens/alumni_detail/alumni_detail_screen.dart';
import '../presentation/screens/add_alumni/add_alumni_screen.dart';
import '../presentation/screens/test_connection/test_connection_screen.dart';

class AppPageTransitions {
  static CustomTransitionPage<void> fadeTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<void> slideTransition({
    required Widget child,
    required GoRouterState state,
    bool slideFromRight = true,
  }) {
    final offset = slideFromRight
        ? const Offset(1.0, 0.0)
        : const Offset(-1.0, 0.0);

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<void> slideUpTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
        child: const AlumniListScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/alumni/:id',
      name: 'alumniDetail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return AppPageTransitions.slideTransition(
          child: AlumniDetailScreen(alumniId: id),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/add-alumni',
      name: 'addAlumni',
      pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
        child: const AddAlumniScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/test-connection',
      name: 'testConnection',
      pageBuilder: (context, state) => AppPageTransitions.slideTransition(
        child: const TestConnectionScreen(),
        state: state,
        slideFromRight: false,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Page not found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.path,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  ),
);
