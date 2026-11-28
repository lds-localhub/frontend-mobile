import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/client_services.dart';
import 'helpers/providers.dart';
import 'helpers/services.dart';

/// TS-MOB-10 — Cancelar serviços (Cliente)
void tsMob10Tests() {
  testWidgets('caso 1 — serviço com solicitações diretas, aberto, a partir da '
      'lista', (tester) async {
    final client = await registerAndLogin('CLIENT');
    final provider = await createProviderWithProfile();
    final title = 'Trocar a torneira ${uniqueId()}';
    final serviceId = await createDirectRequestService(
      client,
      provider,
      title: title,
    );

    final app = await pumpApp(tester, token: client.token);
    await waitForLocation(tester, app, '/cliente/pesquisa');
    await tapText(tester, 'Serviços');
    await waitForLocation(tester, app, '/cliente/servicos');
    await waitForText(tester, title);

    // 1. No M09, «× Cancelar serviço» no cartão do serviço
    await tapInCard(tester, title, 'Cancelar serviço');
    expectConfirmation(
      title: 'Cancelar serviço?',
      subject: title,
      message:
          'As solicitações e propostas pendentes ficam sem efeito. Esta '
          'ação não pode ser anulada.',
    );

    // 2. «Confirmar»
    await confirmAndWait(tester, 'Serviço cancelado.');
    await pumpUntil(
      tester,
      () => inCard(title, 'Cancelado').evaluate().isNotEmpty,
      description: 'o cartão com «Cancelado»',
    );
    expect(inCard(title, 'Cancelar serviço'), findsNothing);

    // 3. Tocar no serviço
    await tapText(tester, title);
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId');
    await waitForText(
      tester,
      'Cancelou este serviço a ${today()}, quando ainda estava aberto.',
    );
    expectNoServiceActions();
    const voided = 'Ficou sem efeito quando cancelou o serviço.';
    await scrollToText(tester, voided);
    expect(find.text(voided), findsOneWidget);
  });

  testWidgets('caso 2 — serviço aberto a propostas, atribuído, a partir do '
      'detalhe', (tester) async {
    final client = await registerAndLogin('CLIENT');
    final provider = await createProviderWithProfile();
    final title = 'Montar um armário ${uniqueId()}';
    final serviceId = await createPublicService(client, title: title);
    final proposalId = await submitProposal(provider, serviceId);
    await acceptProposal(client, proposalId);

    final app = await pumpApp(tester, token: client.token);
    await waitForLocation(tester, app, '/cliente/pesquisa');
    await tapText(tester, 'Serviços');
    await waitForLocation(tester, app, '/cliente/servicos');
    await waitForText(tester, title);

    // 1. Tocar no serviço → «× Cancelar serviço»
    await tapText(tester, title);
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId');
    await waitForText(tester, 'Cancelar serviço');
    await tapText(tester, 'Cancelar serviço');
    expectConfirmation(
      title: 'Cancelar serviço?',
      subject: title,
      message:
          'O serviço passa a cancelado e o cancelamento fica registado no '
          'histórico. Esta ação não pode ser anulada.',
    );

    // 2. «Confirmar»
    await confirmAndWait(tester, 'Serviço cancelado.');
    await waitForText(tester, 'Cancelou este serviço a ${today()}.');
    expectNoServiceActions();
  });
}
