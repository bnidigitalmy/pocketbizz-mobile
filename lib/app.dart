import ' + 'package:flutter/material.dart';
import ' + 'package:go_router/go_router.dart';
import ' + 'package:flutter_riverpod/flutter_riverpod.dart';
import ' + 'features/auth/controller/auth_controller.dart';
import ' + 'features/auth/presentation/login_page.dart';
import ' + 'features/auth/presentation/register_page.dart';
import ' + 'features/auth/presentation/splash_page.dart';
import ' + 'features/subscription/presentation/subscription_page.dart';
import ' + 'features/dashboard/presentation/dashboard_page.dart';

class PocketBizzApp extends ConsumerWidget {
  const PocketBizzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.stream)),
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionPage()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
      ],
      redirect: (context, state) {
        final isAuth = authState.valueOrNull != null;
        final public = state.subloc == '/login' || state.subloc == '/register' || state.subloc == '/splash';
        if (!isAuth && !public) return '/login';
        if (isAuth && (state.subloc == '/login' || state.subloc == '/register')) return '/dashboard';
        return null;
      },
    );

    return MaterialApp.router(
      title: 'PocketBizz',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    );
  }
}
