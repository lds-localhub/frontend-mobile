// TS-MOB-15 — Rede indisponível antes do pedido (RNF-23).
//
// Corre à parte, depois dos outros testes, com o modo de avião ligado
// (integration_test/ci/run-system-tests.sh). Sem rede o teste não consegue
// preparar dados, por isso a pipeline cria antes o Cliente pela API e passa:
//   --dart-define=TS_MOB_15_TOKEN=<token> --dart-define=TS_MOB_15_EMAIL=<e-mail>
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/accounts.dart';
import 'helpers/app.dart';

const _token = String.fromEnvironment('TS_MOB_15_TOKEN');
const _email = String.fromEnvironment('TS_MOB_15_EMAIL');
const _noNetwork = 'Não foi possível contactar o servidor. Tente novamente.';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'TS-MOB-15 — sem rede, a consulta e a ação mostram a indisponibilidade '
    '(RNF-23)',
    (tester) async {
      expect(
        _token.isNotEmpty && _email.isNotEmpty,
        isTrue,
        reason: 'Faltam o TS_MOB_15_TOKEN e o TS_MOB_15_EMAIL da pipeline.',
      );

      // 1. Consulta: guardar o token como sessão e arrancar a aplicação
      final app = await pumpApp(tester, token: _token);
      await waitForText(tester, _noNetwork);
      expect(find.text('Tentar outra vez'), findsOneWidget);
      expect(find.text('Terminar sessão'), findsOneWidget);

      // 2. «Tentar outra vez»
      await tapText(tester, 'Tentar outra vez');
      await waitForText(tester, _noNetwork);

      // 3. «Terminar sessão»
      await tapText(tester, 'Terminar sessão');
      await waitForLocation(tester, app, '/login');

      // 4. Ação: iniciar sessão com as credenciais do Cliente
      await loginThroughUi(tester, _email, testPassword);
      await waitForText(tester, _noNetwork);
      expect(app.router.state.matchedLocation, '/login');
    },
  );
}
