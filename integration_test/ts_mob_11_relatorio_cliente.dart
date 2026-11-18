import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/providers.dart';
import 'helpers/reports.dart';
import 'helpers/services.dart';

/// TS-MOB-11 — Relatório do cliente (RF-F013-01, RF-F013-02; RNF-08).
void tsMob11Tests() {
  testWidgets('apresenta o relatório do Cliente e filtra por período '
      '(RF-F013-01, RF-F013-02, RNF-08)', (tester) async {
    final client = await registerAndLogin('CLIENT');
    final provider = await createProviderWithProfile();
    await createCompletedService(client, provider);
    final providerName = provider.account.user['name'] as String;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final app = await pumpApp(tester);
    await tapText(tester, 'Iniciar sessão');
    await loginThroughUi(tester, client.email, testPassword);
    await waitForLocation(tester, app, '/cliente/pesquisa');

    // 1. Separador «Conta» → «Relatório de atividade» (M14)
    await tapText(tester, 'Conta');
    await tapText(tester, 'Relatório de atividade');
    await waitForText(tester, 'Serviços contratados');
    expect(
      find.text(
        'O período considera a data de criação de cada serviço. '
        'Sem período, inclui toda a atividade.',
      ),
      findsOneWidget,
    );
    Future<void> expectReport() async {
      await expectStat(tester, 'Serviços contratados', '1');
      await expectStat(tester, 'Propostas aceites', '80,00 €');
      await showText(tester, 'Por categoria');
      expect(find.text('Canalização'), findsWidgets);
      await showText(tester, 'Realizado');
      await showText(tester, providerName);
    }

    await expectReport();

    // 2. Só a data inicial = hoje → «Aplicar período»
    await pickDate(tester, 'startDate', today);
    await applyPeriod(tester, 'Serviços contratados');
    await expectReport();

    // 3. Limpar a data inicial; só a data final = ontem → «Aplicar período»
    await clearDate(tester, 'Limpar data inicial');
    await pickDate(tester, 'endDate', yesterday);
    await applyPeriod(tester, 'Sem atividade no período escolhido.');

    // 4. Data inicial = hoje e data final = ontem → «Aplicar período»
    await pickDate(tester, 'startDate', today);
    await tapText(tester, 'Aplicar período');
    expect(
      find.text('A data final não pode ser anterior à data inicial.'),
      findsOneWidget,
    );
    // O relatório que estava no ecrã mantém-se: não houve pedido ao E33
    expect(find.text('Sem atividade no período escolhido.'), findsOneWidget);
  });
}
