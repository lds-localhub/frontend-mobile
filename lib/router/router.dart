import 'package:go_router/go_router.dart';

import 'package:localhub/screens/account/change_password_screen.dart';
import 'package:localhub/screens/public/login_screen.dart';
import 'package:localhub/screens/public/not_found_screen.dart';
import 'package:localhub/screens/public/provider_search_screen.dart';
import 'package:localhub/screens/public/register_screen.dart';
import 'package:localhub/screens/public/welcome_screen.dart';

const _protectedPrefixes = ['/cliente', '/prestador', '/conta'];

/// Decide para onde vai a navegação: as rotas com sessão levam às boas-vindas
/// enquanto não houver sessão. A segurança é sempre do backend.
String? guard(String location, {required bool hasSession}) {
  final isProtected = _protectedPrefixes.any(location.startsWith);
  if (isProtected && !hasSession) {
    return '/boas-vindas';
  }
  return null;
}

/// Rotas da aplicação: públicas, com sessão e rota inexistente.
final router = GoRouter(
  initialLocation: '/boas-vindas',
  // A aplicação ainda não guarda sessão: até lá, quem a usa é sempre Visitante
  redirect: (context, state) => guard(state.matchedLocation, hasSession: false),
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/boas-vindas',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/registar',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/pesquisa',
      builder: (context, state) => const ProviderSearchScreen(),
    ),
    GoRoute(
      path: '/conta/palavra-passe',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);
