import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/addresses.dart';
import 'helpers/app.dart';
import 'helpers/create_service.dart';

/// TS-MOB-05 — Publicar trabalho
void tsMob05Tests() {
  testWidgets('o Cliente cria um serviço aberto a propostas (RF-F010-01)', (
    tester,
  ) async {
    final client = await registerClientWithLocation(testAddresses['carla']!);
    final app = await pumpApp(tester, token: client.token);
    await waitForLocation(tester, app, '/cliente/pesquisa');

    // 1. Separador «Criar» → «Aberto a propostas» → formulário sem a
    // escolha de Prestadores
    await tapText(tester, 'Criar');
    await waitForLocation(tester, app, '/cliente/criar');
    await tapText(tester, 'Aberto a propostas');
    expect(find.textContaining('Prestadores ('), findsNothing);
    expect(find.text('Publicar serviço'), findsOneWidget);

    // 2. Título, categoria, descrição e disponibilidade → «Publicar serviço»
    // → «Serviço criado.» e o detalhe, aberto e sem propostas
    const title = 'Substituir o autoclismo';
    await fillField(tester, 'title', title);
    await chooseCategory(tester, 'Canalização');
    await fillField(
      tester,
      'description',
      'Autoclismo da casa de banho com a descarga avariada.',
    );
    await pickToday(tester, 'requestedStartDate');
    await tapText(tester, 'Publicar serviço');
    await waitForText(tester, 'Serviço criado.');
    await pumpUntil(
      tester,
      () => app.router.state.matchedLocation.startsWith('/cliente/servicos/'),
      description: 'o detalhe do serviço',
    );
    await waitForText(tester, title);
    expect(find.text('Aberto a propostas'), findsOneWidget);
    expect(find.text('Aberto'), findsOneWidget);
    await scrollToText(tester, 'Ainda não recebeu propostas.');
  });
}
