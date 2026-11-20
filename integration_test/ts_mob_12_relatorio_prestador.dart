import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/utils/format.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/providers.dart';
import 'helpers/reports.dart';
import 'helpers/services.dart';

/// TS-MOB-12 — Relatório do prestador (RF-F014-01, RF-F014-02).
void tsMob12Tests() {
  testWidgets('apresenta o relatório do Prestador e filtra por período '
      '(RF-F014-01, RF-F014-02)', (tester) async {
    final provider = await createProviderWithProfile();
    final client = await registerAndLogin('CLIENT');
    await createCompletedService(client, provider, rating: 5);
    final declinedServiceId = await createDirectRequestService(
      client,
      provider,
    );
    final declinedProposalId = await submitProposal(
      provider,
      declinedServiceId,
    );
    await declineProposal(client, declinedProposalId);
    // A evolução usa o mês da avaliação em UTC
    final currentMonth = formatMonth(todayUtc().substring(0, 7));
    // Hoje e ontem em UTC, como as datas de criação dos serviços no backend
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final app = await pumpApp(tester);
    await tapText(tester, 'Iniciar sessão');
    await loginThroughUi(tester, provider.account.email, testPassword);
    await waitForLocation(tester, app, '/prestador/solicitacoes');

    // 1. Separador «Conta» → «Relatório de atividade» (M25)
    await tapText(tester, 'Conta');
    await tapText(tester, 'Relatório de atividade');
    await waitForText(tester, 'Serviços realizados');
    Future<void> expectReport() async {
      await expectStat(tester, 'Serviços realizados', '1');
      await expectStat(tester, 'Propostas aceites', '1');
      await expectStat(tester, 'Propostas recusadas', '1');
      await expectStat(tester, 'Valor das propostas aceites', '80,00 €');
      await showText(tester, 'Evolução da classificação média');
      await showText(tester, currentMonth);
      expect(find.text('1 avaliação'), findsOneWidget);
      expect(find.text('5,0'), findsOneWidget);
    }

    await expectReport();

    // 2. Só a data inicial = hoje → «Aplicar período»
    await pickDate(tester, 'startDate', today);
    await applyPeriod(tester, 'Serviços realizados');
    await expectReport();

    // 3. Limpar a data inicial; só a data final = ontem → «Aplicar período»
    await clearDate(tester, 'Limpar data inicial');
    await pickDate(tester, 'endDate', yesterday);
    await applyPeriod(tester, 'Sem atividade no período escolhido.');
  });
}
