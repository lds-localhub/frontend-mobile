import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:localhub/api/session.dart';
import 'package:localhub/screens/account/change_password_screen.dart';
import 'package:localhub/screens/public/login_screen.dart';
import 'package:localhub/screens/public/not_found_screen.dart';
import 'package:localhub/screens/public/provider_search_screen.dart';
import 'package:localhub/screens/public/register_screen.dart';
import 'package:localhub/screens/public/welcome_screen.dart';

const _protectedPrefixes = ['/cliente', '/prestador', '/conta'];

/// Decide para onde vai a navegação: sem sessão, as rotas com sessão levam ao
/// início de sessão, se foi o servidor a terminá-la, ou às boas-vindas.
/// A segurança é sempre do backend.
String? guard(
  String location, {
  required bool hasSession,
  bool expired = false,
}) {
  // Compara o segmento completo: /conta e /conta/... são protegidas, /contactos não
  final isProtected = _protectedPrefixes.any(
    (prefix) => location == prefix || location.startsWith('$prefix/'),
  );
  if (isProtected && !hasSession) {
    return expired ? '/login' : '/boas-vindas';
  }
  return null;
}

/// Rotas da aplicação: públicas, com sessão e rota inexistente. As guardas
/// voltam a ser aplicadas sempre que a sessão começa ou acaba.
final routerProvider = Provider<GoRouter>((ref) {
  final session = Session.instance;
  final router = GoRouter(
    initialLocation: '/boas-vindas',
    refreshListenable: session,
    redirect: (context, state) => guard(
      state.matchedLocation,
      hasSession: session.token != null,
      expired: session.expired,
    ),
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
  ref.onDispose(router.dispose);
  return router;
});
