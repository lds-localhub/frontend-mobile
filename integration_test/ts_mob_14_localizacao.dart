import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/accounts.dart';
import 'helpers/addresses.dart';
import 'helpers/app.dart';

/// Morada da posição fixada no emulador, como o backend a compõe a partir do
/// E35 («{rua} {número}, {código postal} {localidade}»).
const _positionAddress = 'Rua das Flores Fictícia 12, 4050-001 Porto';

/// Inicia sessão como um Cliente novo, sem localização, e abre o M15.
Future<void> _openMyLocation(WidgetTester tester) async {
  final client = await registerAndLogin('CLIENT');
  final app = await pumpApp(tester);
  await tapText(tester, 'Iniciar sessão');
  await loginThroughUi(tester, client.email, testPassword);
  await waitForLocation(tester, app, '/cliente/pesquisa');
  await tapText(tester, 'Conta');
  await tapText(tester, 'Localização');
  await waitForLocation(tester, app, '/cliente/conta/localizacao');
}

/// TS-MOB-14, caso 1 — Definir a localização do Cliente com a posição do
/// dispositivo, com a permissão concedida (RF-F015-02, RF-F015-06; RNF-26,
/// RNF-08).
///
/// A pipeline dá a permissão de localização e fixa a posição do emulador na
/// Rua das Flores (Porto) antes de correr este caso.
void tsMob14Tests() {
  testWidgets(
    'caso 1 — com a permissão, a posição preenche o endereço e fica registada '
    'ao guardar (RF-F015-02, RF-F015-06, RNF-26)',
    (tester) async {
      // 1. Separador «Conta» → «Localização» → M15 vazio, sem pedir a posição
      await _openMyLocation(tester);
      expect(fieldText(tester, 'address'), isEmpty);
      expect(
        find.text(
          'Ainda não definiu a sua localização. Indique um endereço e guarde.',
        ),
        findsOneWidget,
      );

      // 2. «Usar a minha posição atual» → o campo fica com a morada da posição,
      // sem a janela M06, porque a permissão já foi dada
      await tapText(tester, 'Usar a minha posição atual');
      await pumpUntil(
        tester,
        () => fieldText(tester, 'address') == _positionAddress,
        description: 'a morada da posição no campo',
      );
      expect(find.text('Permitir acesso à localização?'), findsNothing);

      // 3. «Guardar» → «Localização atualizada.» e a dica da localização atual
      await tapText(tester, 'Guardar');
      await waitForText(tester, 'Localização atualizada.');
      await waitForText(
        tester,
        'É a sua localização atual. Altere e guarde para a substituir.',
      );
      expect(fieldText(tester, 'address'), _positionAddress);

      // 4. Morada desconhecida → «Guardar» → erro do backend junto ao campo
      await fillField(tester, 'address', unknownAddress);
      await tapText(tester, 'Guardar');
      await waitForText(tester, addressNotFound);

      // 5. Reabrir o M15 → continua a morada da posição
      // Seta ‹ do M15 (o pageBack procura a dica em inglês, «Back», e a
      // aplicação está em português)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapText(tester, 'Localização');
      await pumpUntil(
        tester,
        () => find.byKey(const ValueKey('address')).evaluate().isNotEmpty,
        description: 'o M15',
      );
      expect(fieldText(tester, 'address'), _positionAddress);
    },
  );
}

/// TS-MOB-14, caso 2 — Permissão recusada na janela M06 (RF-F015-06).
///
/// Corre à parte (`ts_mob_14_permissao_recusada.dart`), com a aplicação
/// acabada de instalar e ainda sem a permissão de localização.
void tsMob14DeniedPermissionTests() {
  testWidgets('caso 2 — ao recusar a permissão, o endereço é escrito à mão '
      '(RF-F015-06)', (tester) async {
    // 1. Separador «Conta» → «Localização» → «Usar a minha posição atual» →
    // janela M06
    await _openMyLocation(tester);
    await tapText(tester, 'Usar a minha posição atual');
    await waitForText(tester, 'Permitir acesso à localização?');
    expect(find.text('Permitir'), findsOneWidget);
    expect(find.text('Recusar'), findsOneWidget);

    // 2. «Recusar» → mensagem junto ao campo; o endereço continua editável
    await tapText(tester, 'Recusar');
    await waitForText(
      tester,
      'Não foi possível obter a posição. Introduza o endereço.',
    );
    await fillField(tester, 'address', testAddresses['carla']!);
    expect(fieldText(tester, 'address'), testAddresses['carla']);
  });
}
