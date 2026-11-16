import 'package:flutter_test/flutter_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';

/// TS-MOB-13 — Alterar a palavra-passe (RF-F001-07).
void tsMob13Tests() {
  testWidgets(
    'valida a palavra-passe atual e a confirmação e altera a palavra-passe (RF-F001-07)',
    (tester) async {
      final account = await registerAndLogin('CLIENT');
      const newPassword = 'Jardim2027';
      final app = await pumpApp(tester);
      await tapText(tester, 'Iniciar sessão');
      await loginThroughUi(tester, account.email, testPassword);
      await waitForLocation(tester, app, '/cliente/pesquisa');
      await tapText(tester, 'Conta');
      await tapText(tester, 'Alterar palavra-passe');

      // A confirmação é verificada no telemóvel, antes do pedido
      await fillField(tester, 'currentPassword', testPassword);
      await fillField(tester, 'newPassword', newPassword);
      await fillField(tester, 'confirmation', 'Outra2027');
      await tapText(tester, 'Guardar');
      expect(
        find.text('A confirmação não corresponde à nova palavra-passe.'),
        findsOneWidget,
      );

      // A palavra-passe atual errada aparece junto ao campo
      await fillField(tester, 'currentPassword', 'Errada2026');
      await fillField(tester, 'confirmation', newPassword);
      await tapText(tester, 'Guardar');
      await waitForText(tester, 'A palavra-passe atual está incorreta.');
      expect(await canLogin(account.email, testPassword), isTrue);

      await fillField(tester, 'currentPassword', testPassword);
      await tapText(tester, 'Guardar');
      await waitForText(tester, 'Palavra-passe alterada.');
      expect(await canLogin(account.email, newPassword), isTrue);
      expect(await canLogin(account.email, testPassword), isFalse);
    },
  );
}
