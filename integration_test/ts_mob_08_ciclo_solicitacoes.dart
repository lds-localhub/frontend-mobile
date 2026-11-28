import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/client_services.dart';
import 'helpers/providers.dart';
import 'helpers/services.dart';

/// TS-MOB-08 — Ciclo de um serviço com solicitações diretas
void tsMob08Tests() {
  testWidgets('recusa uma proposta, aceita a outra, marca o serviço como '
      'realizado e avalia-o', (tester) async {
    final client = await registerAndLogin('CLIENT');
    final declined = await createProviderWithProfile();
    final accepted = await createProviderWithProfile();
    final silent = await createProviderWithProfile();
    final declinedName = declined.account.user['name'] as String;
    final acceptedName = accepted.account.user['name'] as String;
    final silentName = silent.account.user['name'] as String;
    final title = 'Reparar o esquentador ${uniqueId()}';
    final serviceId = await createDirectRequestService(
      client,
      declined,
      title: title,
      otherProviders: [accepted, silent],
    );
    await submitProposal(declined, serviceId);
    await submitProposal(accepted, serviceId, amount: 90);

    final app = await pumpApp(tester, token: client.token);
    await waitForLocation(tester, app, '/cliente/pesquisa');

    // 1. Separador «Serviços» (M09) → tocar no serviço
    await tapText(tester, 'Serviços');
    await waitForLocation(tester, app, '/cliente/servicos');
    await waitForText(tester, title);
    await tapText(tester, title);
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId');
    await waitForText(tester, 'Solicitações (3)');
    await scrollToText(tester, declinedName);
    expect(inCard(declinedName, 'Pendente'), findsOneWidget);
    await scrollToText(tester, acceptedName);
    expect(inCard(acceptedName, 'Pendente'), findsOneWidget);
    await scrollToText(tester, silentName);
    expect(
      inCard(silentName, 'A aguardar resposta do Prestador.'),
      findsOneWidget,
    );

    // 2. «Recusar» numa proposta → «Recusar proposta?» (nome do Prestador a
    // negrito) → «Confirmar»
    await tapInCard(tester, declinedName, 'Recusar');
    expectConfirmation(title: 'Recusar proposta?', subject: declinedName);
    await confirmAndWait(tester, 'Proposta recusada.');

    // 3. «Aceitar» na outra → «Aceitar proposta?» (com «…as solicitações
    // ainda sem resposta ficam sem efeito. Esta ação não pode ser
    // anulada.») → «Confirmar»
    await tapInCard(tester, acceptedName, 'Aceitar');
    expectConfirmation(
      title: 'Aceitar proposta?',
      subject: acceptedName,
      message:
          'as solicitações ainda sem resposta ficam sem efeito. Esta ação '
          'não pode ser anulada.',
    );
    await confirmAndWait(tester, 'Proposta aceite.');
    await scrollToText(tester, title, up: true);
    await waitForText(tester, 'Atribuído');

    // 4. Ver a solicitação sem resposta
    final voided =
        'Ficou sem efeito quando aceitou a proposta de $acceptedName.';
    await scrollToText(tester, voided);
    expect(find.text(voided), findsOneWidget);

    // 5. «Marcar como realizado» → «Marcar como realizado?» → «Confirmar»
    await scrollToText(tester, 'Marcar como realizado', up: true);
    await tapText(tester, 'Marcar como realizado');
    expectConfirmation(title: 'Marcar como realizado?', subject: title);
    await confirmAndWait(tester, 'Serviço marcado como realizado.');
    await waitForText(tester, 'Avaliar serviço');

    // 6. «Avaliar serviço» → ecrã M13 → 5 estrelas e o comentário → submeter
    await tapText(tester, 'Avaliar serviço');
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId/avaliar');
    await waitForText(tester, 'Submeter avaliação');
    await tester.tap(find.byTooltip('5 estrelas: Muito satisfeito'));
    await tester.pumpAndSettle();
    await fillField(tester, 'comment', 'Rápido e cuidadoso.');
    await tapText(tester, 'Submeter avaliação');
    await waitForText(tester, 'Avaliação registada.');
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId');
    await pumpUntil(
      tester,
      () => find.text('Avaliar serviço').evaluate().isEmpty,
      description: 'o detalhe sem «Avaliar serviço»',
    );
    expectNoServiceActions();
  });
}
