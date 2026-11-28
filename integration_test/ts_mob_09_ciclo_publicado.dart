import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/client_services.dart';
import 'helpers/providers.dart';
import 'helpers/services.dart';

/// TS-MOB-09 — Ciclo de um trabalho publicado
void tsMob09Tests() {
  testWidgets('recusa uma proposta, aceita a outra e marca o serviço como '
      'realizado', (tester) async {
    final client = await registerAndLogin('CLIENT');
    final declined = await createProviderWithProfile();
    final accepted = await createProviderWithProfile();
    final declinedName = declined.account.user['name'] as String;
    final acceptedName = accepted.account.user['name'] as String;
    final title = 'Pintar a sala ${uniqueId()}';
    final serviceId = await createPublicService(client, title: title);
    await submitProposal(declined, serviceId);
    await submitProposal(accepted, serviceId, amount: 120);

    final app = await pumpApp(tester, token: client.token);
    await waitForLocation(tester, app, '/cliente/pesquisa');

    // 1. Separador «Serviços» (M09) → tocar no serviço
    await tapText(tester, 'Serviços');
    await waitForLocation(tester, app, '/cliente/servicos');
    await waitForText(tester, title);
    await tapText(tester, title);
    await waitForLocation(tester, app, '/cliente/servicos/$serviceId');
    // O cartão de cima é alto e a lista só constrói o que está à vista: num
    // ecrã pequeno, a secção das respostas ainda não existe até se deslizar
    await waitForText(tester, title);
    await scrollToText(tester, 'Propostas (2)');
    await scrollToText(tester, declinedName);
    expect(inCard(declinedName, 'Pendente'), findsOneWidget);
    await scrollToText(tester, acceptedName);
    expect(inCard(acceptedName, 'Pendente'), findsOneWidget);

    // 2. «Recusar» numa → «Recusar proposta?» → «Confirmar»
    await tapInCard(tester, declinedName, 'Recusar');
    expectConfirmation(title: 'Recusar proposta?', subject: declinedName);
    await confirmAndWait(tester, 'Proposta recusada.');

    // 3. «Aceitar» na outra → «Aceitar proposta?» → «Confirmar»
    await tapInCard(tester, acceptedName, 'Aceitar');
    expectConfirmation(title: 'Aceitar proposta?', subject: acceptedName);
    await confirmAndWait(tester, 'Proposta aceite.');
    await scrollToText(tester, title, up: true);
    await waitForText(tester, 'Atribuído');

    // 4. «Marcar como realizado» → «Marcar como realizado?» → «Confirmar»
    await tapText(tester, 'Marcar como realizado');
    expectConfirmation(title: 'Marcar como realizado?', subject: title);
    await confirmAndWait(tester, 'Serviço marcado como realizado.');
    await waitForText(tester, 'Realizado');
  });
}
