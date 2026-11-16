import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';

/// TS-MOB-13 — Alterar a palavra-passe (RF-F001-07).
void tsMob13Tests() {
  testWidgets(
    'altera a palavra-passe, termina a sessão e entra com a nova (RF-F001-07)',
    (tester) async {
      final account = await registerAndLogin('CLIENT');
      const newPassword = 'Jardim2027';
      final app = await pumpApp(tester);
      await tapText(tester, 'Iniciar sessão');
      await loginThroughUi(tester, account.email, testPassword);
      await waitForLocation(tester, app, '/cliente/pesquisa');

      // Alterar a palavra-passe (M19)
      await tapText(tester, 'Conta');
      await tapText(tester, 'Alterar palavra-passe');
      await fillField(tester, 'currentPassword', testPassword);
      await fillField(tester, 'newPassword', newPassword);
      await fillField(tester, 'confirmation', newPassword);
      await tapText(tester, 'Guardar');
      await waitForText(tester, 'Palavra-passe alterada.');

      // Voltar à Conta, terminar sessão e entrar com a nova palavra-passe
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapText(tester, 'Terminar sessão');
      await waitForLocation(tester, app, '/login');
      await loginThroughUi(tester, account.email, newPassword);
      await waitForLocation(tester, app, '/cliente/pesquisa');
    },
  );
}
