import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/addresses.dart';
import 'helpers/app.dart';
import 'helpers/categories.dart';

/// TS-MOB-03 — Criar, consultar e editar o perfil profissional
/// (RF-F003-04, RF-F004-01, RF-F004-02, RF-F004-03, RF-F004-04, RF-F015-01;
/// RNF-08).
void tsMob03Tests() {
  testWidgets(
    'cria o perfil, consulta-o e acrescenta uma categoria (RF-F003-04, '
    'RF-F004-01 a 04, RF-F015-01, RNF-08)',
    (tester) async {
      final provider = await registerAndLogin('PROVIDER');
      final inactiveCategory = await createInactiveCategory();
      const introduction =
          'Canalizador com equipa própria na área do Grande Porto.';
      final app = await pumpApp(tester);

      // 1. Iniciar sessão como o Prestador → M04
      await tapText(tester, 'Iniciar sessão');
      await loginThroughUi(tester, provider.email, testPassword);
      await waitForLocation(tester, app, '/prestador/sem-perfil');
      expect(find.text('Olá, Prestador'), findsOneWidget);
      expect(find.text('Crie o seu perfil profissional'), findsOneWidget);

      // 2. «Criar perfil» → M27 com os campos vazios
      await tapText(tester, 'Criar perfil');
      await waitForLocation(tester, app, '/prestador/criar-perfil');
      await waitForText(tester, 'Canalização');
      for (final field in [
        'introduction',
        'contactDetails',
        'experience',
        'address',
        'serviceRadiusKm',
      ]) {
        expect(fieldText(tester, field), isEmpty, reason: field);
      }

      // 3. «Criar perfil» com o formulário vazio → erros junto a cada campo
      // obrigatório, sem pedido
      await tapText(tester, 'Criar perfil');
      for (final error in [
        'Indique a apresentação.',
        'Indique os contactos.',
        'Indique a experiência.',
        'Indique pelo menos uma categoria de serviços.',
        'Indique a morada.',
        'Indique o raio de atuação.',
      ]) {
        expect(find.text(error), findsOneWidget, reason: error);
      }
      expect(app.router.state.matchedLocation, '/prestador/criar-perfil');

      // 4. Raio 101 e morada desconhecida → erro da aplicação junto ao raio,
      // sem pedido; com o raio 25, erro do backend junto à morada
      await fillField(tester, 'introduction', introduction);
      await fillField(tester, 'contactDetails', 'Telefone 220 000 000');
      await fillField(
        tester,
        'experience',
        '15 anos em reparação de fugas e instalação de sanitários.',
      );
      await tapText(tester, 'Canalização');
      await fillField(tester, 'address', unknownAddress);
      await fillField(tester, 'serviceRadiusKm', '101');
      await tapText(tester, 'Criar perfil');
      expect(
        find.text('O raio de atuação tem de estar entre 1 e 100 km.'),
        findsOneWidget,
      );
      // Sem pedido ao backend: a morada desconhecida ainda não foi recusada
      expect(find.text(addressNotFound), findsNothing);

      await fillField(tester, 'serviceRadiusKm', '25');
      await tapText(tester, 'Criar perfil');
      await waitForText(tester, addressNotFound);
      expect(app.router.state.matchedLocation, '/prestador/criar-perfil');

      // 5. Morada da Maia (só aparecem categorias ativas) → M20 com
      // «Perfil criado.»
      expect(find.textContaining(inactiveCategory), findsNothing);
      await fillField(tester, 'address', testAddresses['maia']!);
      await tapText(tester, 'Criar perfil');
      await waitForLocation(tester, app, '/prestador/solicitacoes');
      await waitForText(tester, 'Perfil criado.');

      // 6. Separador «Conta» → «O meu perfil» → M26
      await tapText(tester, 'Conta');
      await tapText(tester, 'O meu perfil');
      await waitForLocation(tester, app, '/prestador/conta/perfil');
      await waitForText(tester, introduction);
      expect(find.text('Canalização'), findsOneWidget);
      await scrollToText(tester, 'Raio de atuação: 25 km');
      expect(find.text('Raio de atuação: 25 km'), findsOneWidget);

      // 7. «Editar perfil» (M27b) → desmarcar «Canalização», a única
      // categoria → guardar → erro junto às categorias, sem pedido
      await scrollToText(tester, 'Editar perfil', up: true);
      await tapText(tester, 'Editar perfil');
      await waitForLocation(tester, app, '/prestador/conta/perfil/editar');
      await waitForText(tester, 'Eletricidade');
      await tapText(tester, 'Canalização');
      await tapText(tester, 'Guardar alterações');
      expect(
        find.text('Indique pelo menos uma categoria de serviços.'),
        findsOneWidget,
      );
      expect(
        app.router.state.matchedLocation,
        '/prestador/conta/perfil/editar',
      );

      // 8. Voltar a marcar «Canalização» e acrescentar «Eletricidade» →
      // guardar → M26 com «Perfil atualizado.» e as duas categorias
      await tapText(tester, 'Canalização');
      await tapText(tester, 'Eletricidade');
      await tapText(tester, 'Guardar alterações');
      await waitForLocation(tester, app, '/prestador/conta/perfil');
      await waitForText(tester, 'Perfil atualizado.');
      expect(find.text('Canalização'), findsOneWidget);
      expect(find.text('Eletricidade'), findsOneWidget);
    },
  );
}
