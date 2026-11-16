import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/api/session.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';

/// TS-MOB-01 — Registo, início e fim de sessão
/// (RF-F001-01, RF-F001-02, RF-F001-04).
void tsMob01Tests() {
  testWidgets(
    'regista um Cliente, inicia sessão e termina a sessão (RF-F001-01, RF-F001-02, RF-F001-04)',
    (tester) async {
      final id = uniqueId();
      final email = uniqueEmail('cliente', id);
      final existing = await registerAndLogin('CLIENT');
      final app = await pumpApp(tester);

      // RF-F001-01: registo, com o erro do e-mail repetido junto ao campo
      await tapText(tester, 'Criar conta');
      expect(find.text('Leva menos de um minuto.'), findsOneWidget);
      await fillField(tester, 'name', 'Cliente $id');
      await fillField(tester, 'email', existing.email.toUpperCase());
      await fillField(tester, 'password', testPassword);
      await tapText(tester, 'Criar conta');
      await waitForText(tester, 'Já existe uma conta com este e-mail.');

      await fillField(tester, 'email', email);
      await tapText(tester, 'Criar conta');
      await waitForText(tester, 'Conta criada. Inicie sessão.');

      // RF-F001-02: início de sessão com o papel da conta
      await loginThroughUi(tester, email, testPassword);
      await waitForLocation(tester, app, '/cliente/pesquisa');
      expect(find.text('Serviços'), findsOneWidget);

      // RF-F001-04: terminar sessão apaga o token e fecha os ecrãs protegidos
      await tapText(tester, 'Conta');
      expect(find.text('Cliente · $email'), findsOneWidget);
      await tapText(tester, 'Terminar sessão');
      await waitForText(tester, 'Serviços para o lar, perto de si');
      expect(Session.instance.token, isNull);

      app.router.go('/cliente/conta');
      await tester.pumpAndSettle();
      expect(app.router.state.matchedLocation, '/boas-vindas');
    },
  );
}
