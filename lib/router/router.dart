import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/session.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/screens/account/account_screen.dart';
import 'package:localhub/screens/account/change_password_screen.dart';
import 'package:localhub/screens/client/client_report_screen.dart';
import 'package:localhub/screens/client/create_service_screen/create_service_screen.dart';
import 'package:localhub/screens/client/my_location_screen.dart';
import 'package:localhub/screens/client/provider_profile_screen.dart';
import 'package:localhub/screens/client/service_detail_screen/service_detail_screen.dart';
import 'package:localhub/screens/placeholder_screen.dart';
import 'package:localhub/screens/provider/create_profile_screen.dart';
import 'package:localhub/screens/provider/edit_profile_screen.dart';
import 'package:localhub/screens/provider/my_profile_screen.dart';
import 'package:localhub/screens/provider/no_profile_screen.dart';
import 'package:localhub/screens/provider/provider_report_screen.dart';
import 'package:localhub/screens/public/login_screen.dart';
import 'package:localhub/screens/public/not_found_screen.dart';
import 'package:localhub/screens/public/provider_search_screen/provider_search_screen.dart';
import 'package:localhub/screens/public/register_screen.dart';
import 'package:localhub/screens/public/starting_screen.dart';
import 'package:localhub/screens/public/welcome_screen.dart';
import 'package:localhub/widgets/layout/role_shell.dart';

const _starting = '/a-iniciar';
const _visitorOnly = ['/boas-vindas', '/login', '/registar', '/pesquisa'];
const _protectedPrefixes = ['/cliente', '/prestador', '/conta'];
const _noProfileAllowed = [
  '/prestador/sem-perfil',
  '/prestador/criar-perfil',
  '/conta/palavra-passe',
];

// Compara o segmento completo: /conta e /conta/... são protegidas, /contactos não
bool _isUnder(String location, String prefix) =>
    location == prefix || location.startsWith('$prefix/');

/// Primeiro ecrã de cada papel; sem sessão, as boas-vindas.
String homeOf(Me? me) {
  if (me == null) {
    return '/boas-vindas';
  }
  if (me.needsProfile) {
    return '/prestador/sem-perfil';
  }
  return switch (me.role) {
    Role.provider => '/prestador/solicitacoes',
    // O backend recusa o Administrador na aplicação mobile: nunca chega aqui com sessão
    Role.client || Role.admin => '/cliente/pesquisa',
  };
}

/// Decide para onde vai a navegação, a partir da sessão e do utilizador
/// autenticado. Serve só a interface: a segurança é sempre do backend.
String? guard(
  AsyncValue<Me?> me,
  String location, {
  required bool hasToken,
  bool expired = false,
}) {
  if (!hasToken) {
    final isProtected =
        location == _starting ||
        _protectedPrefixes.any((prefix) => _isUnder(location, prefix));
    if (isProtected) {
      // Depois de terminar sessão, ou numa rota protegida sem sessão, vai para o
      // início de sessão (RF-F001-04); o arranque sem sessão abre as boas-vindas
      return location == _starting && !expired ? '/boas-vindas' : '/login';
    }
    return null;
  }

  // Com token, enquanto o utilizador carrega ou se o pedido falhou, fica no arranque
  final user = me.value;
  if (user == null) {
    return location == _starting ? null : _starting;
  }

  final home = homeOf(user);
  if (location == _starting || _visitorOnly.contains(location)) {
    return home;
  }
  if (user.needsProfile) {
    return _noProfileAllowed.contains(location) ? null : home;
  }
  if (location == '/prestador/sem-perfil' ||
      location == '/prestador/criar-perfil') {
    return home;
  }
  final otherRolePrefix = user.role == Role.provider
      ? '/cliente'
      : '/prestador';
  if (_isUnder(location, otherRolePrefix)) {
    return home;
  }
  return null;
}

GoRoute _placeholder(
  String path,
  String title, {
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  builder: (context, state) => PlaceholderScreen(title: title),
  routes: routes,
);

/// Identificador numérico de um parâmetro da rota; um valor inválido abre a
/// página de rota inexistente.
Widget _withId(GoRouterState state, String name, Widget Function(int) build) {
  final id = int.tryParse(state.pathParameters[name] ?? '');
  return id == null ? const NotFoundScreen() : build(id);
}

/// Perfil do Prestador (M07), com a distância e a categoria da pesquisa de
/// onde foi aberto (sem elas, depois de reiniciar, mostra só o raio), e as
/// avaliações por baixo.
GoRoute _providerProfileRoute({required bool fromSelection}) => GoRoute(
  path: 'prestadores/:professionalProfileId',
  builder: (context, state) =>
      _withId(state, 'professionalProfileId', (professionalProfileId) {
        final extra = state.extra;
        final search = extra is ({double distanceKm, int? serviceCategoryId})
            ? extra
            : null;
        return ProviderProfileScreen(
          professionalProfileId: professionalProfileId,
          distanceKm: search?.distanceKm,
          serviceCategoryId: search?.serviceCategoryId,
          fromSelection: fromSelection,
        );
      }),
  routes: [_placeholder('avaliacoes', 'Avaliações')],
);

/// Rotas da aplicação, com as barras inferiores do Cliente e do Prestador.
/// As guardas voltam a ser aplicadas quando a sessão começa ou acaba e quando
/// o utilizador autenticado termina de carregar.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(meProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: _starting,
    refreshListenable: refresh,
    redirect: (context, state) => guard(
      ref.read(meProvider),
      state.matchedLocation,
      hasToken: Session.instance.token != null,
      expired: Session.instance.expired,
    ),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: _starting,
        builder: (context, state) => const StartingScreen(),
      ),
      GoRoute(
        path: '/boas-vindas',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/registar',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(notice: state.extra as String?),
      ),
      GoRoute(
        path: '/pesquisa',
        builder: (context, state) => const ProviderSearchScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RoleShell(
          navigationShell: navigationShell,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Pesquisar'),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Serviços',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              label: 'Criar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Conta',
            ),
          ],
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cliente/pesquisa',
                builder: (context, state) => const ProviderSearchScreen(),
                routes: [_providerProfileRoute(fromSelection: false)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _placeholder(
                '/cliente/servicos',
                'Os meus serviços',
                routes: [
                  GoRoute(
                    path: ':serviceId',
                    builder: (context, state) => _withId(
                      state,
                      'serviceId',
                      (serviceId) => ServiceDetailScreen(serviceId: serviceId),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cliente/criar',
                builder: (context, state) {
                  final query = state.uri.queryParameters;
                  // Cada «Fazer solicitação direta» (endereço e marca no
                  // extra) recomeça o formulário com esse Prestador
                  return CreateServiceScreen(
                    key: ValueKey((state.uri.query, state.extra)),
                    providerId: int.tryParse(
                      query['professionalProfileId'] ?? '',
                    ),
                    categoryId: int.tryParse(query['serviceCategoryId'] ?? ''),
                  );
                },
                routes: [_providerProfileRoute(fromSelection: true)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cliente/conta',
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'localizacao',
                    builder: (context, state) => const MyLocationScreen(),
                  ),
                  GoRoute(
                    path: 'relatorio',
                    builder: (context, state) => const ClientReportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RoleShell(
          navigationShell: navigationShell,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              label: 'Solicitações',
            ),
            NavigationDestination(
              icon: Icon(Icons.request_quote_outlined),
              label: 'Propostas',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Pesquisar'),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Conta',
            ),
          ],
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              _placeholder('/prestador/solicitacoes', 'Solicitações recebidas'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _placeholder('/prestador/propostas', 'As minhas propostas'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _placeholder('/prestador/pesquisa', 'Serviços perto de si'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prestador/conta',
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'perfil',
                    builder: (context, state) => const MyProfileScreen(),
                    routes: [
                      _placeholder('avaliacoes', 'Avaliações'),
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => const EditProfileScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'relatorio',
                    builder: (context, state) => const ProviderReportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/prestador/sem-perfil',
        builder: (context, state) => const NoProfileScreen(),
      ),
      GoRoute(
        path: '/prestador/criar-perfil',
        builder: (context, state) => const CreateProfileScreen(),
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
