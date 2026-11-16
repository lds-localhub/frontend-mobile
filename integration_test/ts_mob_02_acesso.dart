import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/api/session.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/providers.dart';

/// TS-MOB-02 — Credenciais inválidas, administrador recusado e acesso por
/// papel (RF-F001-03, RF-F001-06).
void tsMob02Tests() {
  testWidgets(
    'recusa credenciais erradas e o Administrador (RF-F001-03, RF-F001-06)',
    (tester) async {
      final client = await registerAndLogin('CLIENT');
      await pumpApp(tester);
      await tapText(tester, 'Iniciar sessão');

      // E-mail inexistente e palavra-passe errada: a mesma mensagem
      const wrong = 'O e-mail ou a palavra-passe estão incorretos.';
      await loginThroughUi(tester, uniqueEmail('inexistente'), testPassword);
      await waitForText(tester, wrong);
      await loginThroughUi(tester, client.email, 'Errada2026');
      await waitForText(tester, wrong);

      // RF-F001-06: o Administrador é recusado na aplicação mobile, sem sessão
      await loginThroughUi(tester, adminEmail, adminPassword);
      await waitForText(tester, 'aplicação web');
      expect(Session.instance.token, isNull);
    },
  );

  testWidgets(
    'o Visitante e o Prestador não abrem ecrãs que não são seus (RF-F001-03)',
    (tester) async {
      final provider = await createProviderWithProfile();
      final app = await pumpApp(tester);

      // Visitante numa rota protegida: vai para o início de sessão
      app.router.go('/cliente/conta');
      await tester.pumpAndSettle();
      expect(app.router.state.matchedLocation, '/login');

      // Prestador numa rota de Cliente: volta ao seu início
      await loginThroughUi(tester, provider.account.email, testPassword);
      await waitForLocation(tester, app, '/prestador/solicitacoes');
      expect(find.text('Propostas'), findsOneWidget);
      app.router.go('/cliente/criar');
      await tester.pumpAndSettle();
      expect(app.router.state.matchedLocation, '/prestador/solicitacoes');
    },
  );
}
