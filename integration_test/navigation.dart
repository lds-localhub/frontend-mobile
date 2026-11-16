import 'package:flutter_test/flutter_test.dart';

import 'helpers/app.dart';

/// Navegação base: ecrã inicial, guarda das rotas com sessão e página de erro.
void navigationTests() {
  testWidgets('a aplicação abre nas boas-vindas', (tester) async {
    await pumpApp(tester);

    expect(find.text('LocalHub'), findsOneWidget);
    expect(find.text('Pesquisar Prestadores'), findsOneWidget);
  });

  testWidgets('uma rota com sessão sem sessão volta às boas-vindas', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    app.router.go('/conta/palavra-passe');
    await tester.pumpAndSettle();

    expect(find.text('Serviços para o lar, perto de si'), findsOneWidget);
  });

  testWidgets('uma rota inexistente mostra a página de erro', (tester) async {
    final app = await pumpApp(tester);
    app.router.go('/rota-que-nao-existe');
    await tester.pumpAndSettle();

    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
