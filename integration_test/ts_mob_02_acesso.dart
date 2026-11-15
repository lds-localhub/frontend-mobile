import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/api/session.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';
import 'helpers/providers.dart';

/// TS-MOB-02 — Credenciais inválidas, administrador recusado e acesso por
/// papel (RF-F001-02, RF-F001-03, RF-F001-06; RF-F002-04).
void tsMob02Tests() {
  testWidgets(
    'recusa credenciais erradas, a conta desativada e o Administrador (RF-F001-02, RF-F001-06)',
    (tester) async {
      final client = await registerAndLogin('CLIENT');
      final inactive = await registerAndLogin('CLIENT');
      await deactivateAccount(inactive.user['userId'] as int);
      await pumpApp(tester);
      await tapText(tester, 'Iniciar sessão');

      // A ligação mostra o contacto do suporte, sem pedido ao backend
      await tapText(tester, 'Esqueci-me da palavra-passe');
      expect(
        find.textContaining('Para recuperar o acesso, contacte'),
        findsOneWidget,
      );

      // E-mail inexistente e palavra-passe errada: a mesma mensagem
      const wrong = 'O e-mail ou a palavra-passe estão incorretos.';
      await loginThroughUi(tester, uniqueEmail('inexistente'), testPassword);
      expect(find.text(wrong), findsOneWidget);
      await loginThroughUi(tester, client.email, 'Errada2026');
      expect(find.text(wrong), findsOneWidget);

      await loginThroughUi(tester, inactive.email, testPassword);
      expect(
        find.textContaining('A sua conta foi desativada.'),
        findsOneWidget,
      );

      await loginThroughUi(tester, adminEmail, adminPassword);
      expect(find.textContaining('aplicação web'), findsOneWidget);
      expect(Session.instance.token, isNull);
    },
  );

  testWidgets(
    'cada papel só vê os seus ecrãs e o Prestador sem perfil vai para o M04 (RF-F001-03)',
    (tester) async {
      final noProfile = await registerAndLogin('PROVIDER');
      final provider = await createProviderWithProfile();
      final app = await pumpApp(tester);

      await tapText(tester, 'Iniciar sessão');
      await loginThroughUi(tester, noProfile.email, testPassword);
      expect(app.router.state.matchedLocation, '/prestador/sem-perfil');
      expect(find.text('Crie o seu perfil profissional'), findsOneWidget);
      app.router.go('/cliente/conta');
      await tester.pumpAndSettle();
      expect(app.router.state.matchedLocation, '/prestador/sem-perfil');
      await tapText(tester, 'Terminar sessão');

      await tapText(tester, 'Iniciar sessão');
      await loginThroughUi(tester, provider.account.email, testPassword);
      expect(app.router.state.matchedLocation, '/prestador/solicitacoes');
      expect(find.text('Propostas'), findsOneWidget);
      app.router.go('/cliente/criar');
      await tester.pumpAndSettle();
      expect(app.router.state.matchedLocation, '/prestador/solicitacoes');
    },
  );
}
