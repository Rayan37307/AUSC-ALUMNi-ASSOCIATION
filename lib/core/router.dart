import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/alumni_list/alumni_list_screen.dart';
import '../presentation/screens/alumni_detail/alumni_detail_screen.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/add_alumni/add_alumni_screen.dart';
import '../presentation/screens/auth/auth_screens.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/school/school_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/shell/main_shell.dart';
import '../presentation/screens/teachers/teachers_screen.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

StatefulShellBranch _tab(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: screen),
      ),
    ],
  );
}

/// Pages that need a signed-in account. Everything else is public.
const Set<String> _protectedPaths = {'/add-alumni'};

GoRouter createRouter(AuthProvider auth) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  debugLogDiagnostics: true,
  refreshListenable: auth,
  redirect: (context, state) {
    if (auth.isSignedIn || !_protectedPaths.contains(state.uri.path)) {
      return null;
    }
    return Uri(
      path: '/login',
      queryParameters: {'from': state.uri.toString()},
    ).toString();
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        _tab('/home', const HomeScreen()),
        _tab('/alumni', const AlumniListScreen()),
        _tab('/school', const SchoolScreen()),
        _tab('/teachers', const TeachersScreen()),
        _tab('/settings', const SettingsScreen()),
      ],
    ),
    // Full-screen routes that cover the bottom navigation bar.
    GoRoute(
      path: '/alumni/:id',
      name: 'alumniDetail',
      parentNavigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
        child: const AddAlumniScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
        child: LoginScreen(from: state.uri.queryParameters['from']),
        state: state,
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
        child: SignUpScreen(from: state.uri.queryParameters['from']),
        state: state,
      ),
    ),
    GoRoute(
      path: '/test-connection',
      name: 'testConnection',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.slideTransition(
        child: const TestConnectionScreen(),
        state: state,
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
