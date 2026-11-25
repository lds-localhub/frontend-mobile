import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/screens/client/create_service_screen/provider_option_tile.dart';

import 'helpers/accounts.dart';
import 'helpers/addresses.dart';
import 'helpers/app.dart';
import 'helpers/create_service.dart';
import 'helpers/providers.dart';

/// Morada da posição fixada no emulador, como o backend a compõe a partir do
/// E35 («{rua} {número}, {código postal} {localidade}»).
const _positionAddress = 'Rua das Flores Fictícia 12, 4050-001 Porto';

const _positionUnavailable =
    'Não foi possível obter a posição. Introduza o endereço.';

/// Os dois Prestadores das pré-condições, em Canalização: Vila Nova de Gaia
/// (2,9 km da Rua das Flores) e Maia (9,6 km).
Future<({String gaia, String maia})> _createProviders() async {
  final gaia = await createProviderWithProfile(addressKey: 'gaia');
  final maia = await createProviderWithProfile(addressKey: 'maia');
  return (
    gaia: gaia.account.user['name'] as String,
    maia: maia.account.user['name'] as String,
  );
}

/// Verifica que o Prestador [first] aparece antes do [second] nos
/// resultados, com as distâncias indicadas.
Future<void> _expectOrder(
  WidgetTester tester,
  String first,
  String firstDistance,
  String second,
  String secondDistance,
) async {
  await findResult(tester, first);
  expect(
    find.descendant(
      of: find.ancestor(of: find.text(first), matching: find.byType(Card)),
      matching: find.text(firstDistance),
    ),
    findsOneWidget,
  );
  final firstTop = tester.getTopLeft(find.text(first)).dy;
  // Só se desliza para baixo: se o segundo estivesse antes, não seria encontrado
  final visibleBefore = find.text(second).evaluate().isNotEmpty;
  await findResult(tester, second);
  expect(
    find.descendant(
      of: find.ancestor(of: find.text(second), matching: find.byType(Card)),
      matching: find.text(secondDistance),
    ),
    findsOneWidget,
  );
  if (visibleBefore) {
    expect(tester.getTopLeft(find.text(second)).dy, greaterThan(firstTop));
  }
}

/// TS-MOB-04 — Pesquisar prestadores e criar solicitações diretas
/// (RF-F005-01, RF-F005-02, RF-F004-03, RF-F009-01, RF-F009-02, RF-F009-03,
/// RF-F015-06).
void tsMob04Tests() {
  testWidgets(
    'caso 1 — o Visitante pesquisa com a posição do dispositivo e, ao tocar '
    'num resultado, vai iniciar sessão (RF-F005-01, RF-F005-02, RF-F015-06)',
    (tester) async {
      final providers = await _createProviders();
      final app = await pumpApp(tester);

      // 1. No M01, «Pesquisar Prestadores» → M05b, com a barra do Visitante
      await tapText(tester, 'Pesquisar Prestadores');
      await waitForLocation(tester, app, '/pesquisa');
      expect(find.byType(NavigationBar), findsOneWidget);

      // 2. «Canalização» e «Pesquisar» sem endereço → a pesquisa não é feita
      // e a aplicação pede o endereço ou a posição
      await chooseCategory(tester, 'Canalização');
      await tapSearch(tester);
      expect(
        find.text('Indique um endereço ou use a sua posição atual.'),
        findsOneWidget,
      );
      expect(find.textContaining('do mais próximo'), findsNothing);

      // 3. «Usar a minha posição atual» → o endereço fica com a morada da
      // posição do emulador (E35)
      await tapText(tester, 'Usar a minha posição atual');
      await pumpUntil(
        tester,
        () =>
            fieldText(tester, 'address') == _positionAddress ||
            find.text(_positionUnavailable).evaluate().isNotEmpty,
        description: 'a morada da posição no campo',
        timeout: const Duration(seconds: 40),
      );
      expect(
        find.text(_positionUnavailable),
        findsNothing,
        reason: 'O dispositivo não devolveu a posição.',
      );

      // 4. «Pesquisar» → resultados por distância: Gaia antes da Maia
      await tapSearch(tester);
      await waitForText(tester, 'do mais próximo ao mais distante');
      await _expectOrder(
        tester,
        providers.gaia,
        '2,9 km',
        providers.maia,
        '9,6 km',
      );

      // 5. Tocar num resultado → início de sessão (M03)
      await tapText(tester, providers.maia);
      await waitForLocation(tester, app, '/login');
    },
  );

  testWidgets(
    'caso 2 — o Cliente pesquisa, abre o perfil e cria um serviço com '
    'solicitações diretas a dois Prestadores (RF-F005-01, RF-F004-03, '
    'RF-F009-01 a 03)',
    (tester) async {
      final providers = await _createProviders();
      final client = await registerClientWithLocation(testAddresses['carla']!);
      final app = await pumpApp(tester, token: client.token);

      // 1. Separador «Pesquisar» (M05) → o campo começa com a morada
      // registada → «Canalização» → «Pesquisar» → os dois por distância
      await waitForLocation(tester, app, '/cliente/pesquisa');
      expect(fieldText(tester, 'address'), testAddresses['carla']);
      await chooseCategory(tester, 'Canalização');
      await tapSearch(tester);
      await waitForText(tester, 'do mais próximo ao mais distante');
      await _expectOrder(
        tester,
        providers.gaia,
        '2,9 km',
        providers.maia,
        '9,6 km',
      );

      // 2. Tocar no Prestador de Vila Nova de Gaia → perfil (M07)
      await scrollToText(tester, providers.gaia, up: true);
      await tapText(tester, providers.gaia);
      await pumpUntil(
        tester,
        () => app.router.state.matchedLocation.startsWith(
          '/cliente/pesquisa/prestadores/',
        ),
        description: 'o perfil do Prestador',
      );
      await waitForText(tester, 'Apresentação');
      await scrollToText(tester, 'Fazer solicitação direta');

      // 3. «Fazer solicitação direta» → M08 com esse Prestador selecionado
      await tapText(tester, 'Fazer solicitação direta');
      await waitForLocation(tester, app, '/cliente/criar');
      await waitForText(tester, 'Pedido iniciado no perfil de');
      expect(find.text('Prestadores (1)'), findsOneWidget);

      // 4. Juntar o Prestador da Maia, preencher e enviar → «Serviço
      // criado.» e o detalhe (M10) com os dois Prestadores a aguardar
      const title = 'Reparar fuga na torneira';
      await fillField(tester, 'title', title);
      await fillField(
        tester,
        'description',
        'Torneira da cozinha com fuga de água junto à base.',
      );
      await pickToday(tester, 'requestedStartDate');
      await tapText(tester, 'Seguinte: Prestadores (1) ›');
      await tester.enterText(
        find.widgetWithText(TextField, 'Pesquisar por nome'),
        providers.maia,
      );
      await pumpUntil(
        tester,
        () => find
            .widgetWithText(ProviderOptionTile, providers.maia)
            .evaluate()
            .isNotEmpty,
        description: 'o Prestador da Maia nos resultados',
      );
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ProviderOptionTile, providers.maia),
          matching: find.byType(Checkbox),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Enviar solicitações (2)');
      await waitForText(tester, 'Serviço criado.');
      await pumpUntil(
        tester,
        () => app.router.state.matchedLocation.startsWith('/cliente/servicos/'),
        description: 'o detalhe do serviço',
      );
      await waitForText(tester, title);
      expect(find.text('Aberto'), findsOneWidget);
      // Cada solicitação no seu cartão, com o Prestador e a frase do estado
      for (final name in [providers.gaia, providers.maia]) {
        await scrollToText(tester, name);
        expect(
          find.descendant(
            of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
            matching: find.text('A aguardar resposta do Prestador.'),
          ),
          findsOneWidget,
          reason: name,
        );
      }
    },
  );
}
