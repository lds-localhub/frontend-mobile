import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/main.dart';
import 'package:localhub/router/router.dart';

/// Navegação base: ecrã inicial, guarda das rotas com sessão e página de erro.
void navigationTests() {
  // O router é global e partilhado entre testes: cada teste começa nas boas-vindas
  setUp(() => router.go('/boas-vindas'));

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
