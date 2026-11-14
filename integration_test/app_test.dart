// Testes de sistema automáticos (QG-07 do regulamento interno).
// Executar com um emulador ou dispositivo ligado:
//   flutter test integration_test
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:localhub/main.dart';
import 'package:localhub/router/router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a aplicação abre nas boas-vindas', (tester) async {
    await tester.pumpWidget(const LocalHubApp());
    await tester.pumpAndSettle();

    expect(find.text('LocalHub'), findsOneWidget);
    expect(find.text('Pesquisar Prestadores'), findsOneWidget);
  });

  testWidgets('uma rota com sessão sem sessão volta às boas-vindas', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalHubApp());
    router.go('/conta/palavra-passe');
    await tester.pumpAndSettle();

    expect(find.text('Serviços para o lar, perto de si'), findsOneWidget);
  });

  testWidgets('uma rota inexistente mostra a página de erro', (tester) async {
    await tester.pumpWidget(const LocalHubApp());
    router.go('/rota-que-nao-existe');
    await tester.pumpAndSettle();

    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
