import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/utils/format.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/providers.dart';
import 'helpers/services.dart';

/// Etiqueta [status] dentro do cartão da solicitação com o título [title].
Finder _statusInCard(String title, String status) => find.descendant(
  of: find.ancestor(of: find.text(title), matching: find.byType(Card)),
  matching: find.text(status),
);

/// TS-MOB-06 — Responder a solicitações diretas (RF-F007-09, RF-F007-01,
/// RF-F007-02; RNF-08).
void tsMob06Tests() {
  testWidgets('apresenta uma proposta e recusa uma solicitação (RF-F007-09, '
      'RF-F007-01, RF-F007-02, RNF-08)', (tester) async {
    final provider = await createProviderWithProfile();
    final client = await registerAndLogin('CLIENT');
    final firstTitle = 'Reparar torneira ${uniqueId()}';
    final secondTitle = 'Substituir autoclismo ${uniqueId()}';
    // A lista vem da mais recente para a mais antiga: a primeira é a criada
    // em último lugar
    await createDirectRequestService(client, provider, title: secondTitle);
    await createDirectRequestService(client, provider, title: firstTitle);

    final app = await pumpApp(tester);

    // 1. Iniciar sessão como o Prestador → M20 com as duas solicitações
    // «Pendente»
    await tapText(tester, 'Iniciar sessão');
    await loginThroughUi(tester, provider.account.email, testPassword);
    await waitForLocation(tester, app, '/prestador/solicitacoes');
    await waitForText(tester, firstTitle);
    await waitForText(tester, secondTitle);
    expect(_statusInCard(firstTitle, 'Pendente'), findsOneWidget);
    expect(_statusInCard(secondTitle, 'Pendente'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(firstTitle)).dy,
      lessThan(tester.getTopLeft(find.text(secondTitle)).dy),
    );

    // 2. Tocar na primeira → M21 com o formulário da proposta
    await tapText(tester, firstTitle);
    await waitForText(tester, 'Apresentar proposta');

    // 3. Valor 0 e as condições → «Enviar proposta» → erro junto ao valor,
    // sem pedido: o formulário continua aberto e não há mensagem de sucesso
    await fillField(tester, 'amount', '0');
    await fillField(tester, 'conditions', 'Inclui material e deslocação.');
    await tapText(tester, 'Enviar proposta');
    expect(find.text('O valor tem de ser maior que 0.'), findsOneWidget);
    expect(find.text('Proposta enviada.'), findsNothing);
    expect(find.text('Apresentar proposta'), findsOneWidget);

    // 4. Valor 80,00 → «Enviar proposta» → «Proposta enviada.», estado
    // «Proposta apresentada» e «Ver proposta» no lugar do formulário
    await fillField(tester, 'amount', '80,00');
    await tapText(tester, 'Enviar proposta');
    await waitForText(tester, 'Proposta enviada.');
    await waitForText(tester, 'Ver proposta');
    expect(find.text('Proposta apresentada'), findsOneWidget);
    expect(find.text('Apresentar proposta'), findsNothing);

    // 5. Voltar ao M20 → o cartão da primeira passa a «Proposta apresentada»
    await tester.pageBack();
    await tester.pumpAndSettle();
    await waitForLocation(tester, app, '/prestador/solicitacoes');
    await pumpUntil(
      tester,
      () => _statusInCard(
        firstTitle,
        'Proposta apresentada',
      ).evaluate().isNotEmpty,
      description: 'a primeira solicitação com «Proposta apresentada»',
    );
    expect(_statusInCard(secondTitle, 'Pendente'), findsOneWidget);

    // 6. Tocar na segunda → «Recusar solicitação» → janela «Recusar
    // solicitação?» → «Confirmar» → «Solicitação recusada.» e «Recusou esta
    // solicitação a <data>.»
    await tapText(tester, secondTitle);
    await waitForText(tester, 'Apresentar proposta');
    await tapText(tester, 'Recusar solicitação');
    expect(find.text('Recusar solicitação?'), findsOneWidget);
    await tapText(tester, 'Confirmar');
    await waitForText(tester, 'Solicitação recusada.');
    final today = formatDate(DateTime.now().toUtc().toIso8601String());
    await waitForText(tester, 'Recusou esta solicitação a $today.');
    expect(find.text('Recusar solicitação'), findsNothing);
  });
}
