import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/session.dart';
import 'package:localhub/main.dart';
import 'package:localhub/router/router.dart';

/// Aplicação aberta num teste, com os seus providers.
class TestApp {
  const TestApp(this.container);

  final ProviderContainer container;

  GoRouter get router => container.read(routerProvider);
}

/// Abre a aplicação sem sessão (o token de um teste anterior fica no
/// armazenamento do emulador), com providers próprios para este teste.
Future<TestApp> pumpApp(WidgetTester tester) async {
  // Teclado simulado: o teclado do Android tapa metade de um ecrã pequeno e
  // muda o layout a meio dos toques; o texto entra nos campos da mesma forma
  tester.testTextInput.register();
  addTearDown(tester.testTextInput.unregister);
  await Session.instance.end();
  final container = ProviderContainer(retry: retryReads);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LocalHubApp()),
  );
  await tester.pumpAndSettle();
  return TestApp(container);
}

/// Escreve [text] no campo do formulário com a chave [field].
Future<void> fillField(WidgetTester tester, String field, String text) async {
  await tester.enterText(find.byKey(ValueKey(field)), text);
  await tester.pump();
}

/// Toca no botão ou ligação com o texto [label], depois de o tornar visível.
Future<void> tapText(WidgetTester tester, String label) async {
  // Num ecrã pequeno, uma lista só constrói o que está à vista: desliza até o texto existir
  if (find.text(label).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(label),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  // Com um título igual ao botão (ex.: «Criar conta» no registo), o botão vem depois
  final finder = find.text(label).last;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Espera, com tempo limite, que [condition] se verifique.
///
/// O `pumpAndSettle` não espera pelos pedidos ao backend: sem isto, num
/// emulador lento, o teste verifica o ecrã antes de a resposta chegar.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String description,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Tempo esgotado à espera de $description.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Espera que o texto [text] apareça no ecrã.
Future<void> waitForText(WidgetTester tester, String text) => pumpUntil(
  tester,
  () => find.textContaining(text).evaluate().isNotEmpty,
  description: '«$text»',
);

/// Espera que a aplicação esteja na rota [location].
Future<void> waitForLocation(
  WidgetTester tester,
  TestApp app,
  String location,
) => pumpUntil(
  tester,
  () => app.router.state.matchedLocation == location,
  description: 'a rota $location',
);

/// Texto do campo do formulário com a chave [field].
String fieldText(WidgetTester tester, String field) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(ValueKey(field)),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

/// Inicia sessão pelo ecrã de início de sessão (M03), já aberto.
Future<void> loginThroughUi(
  WidgetTester tester,
  String email,
  String password,
) async {
  await fillField(tester, 'email', email);
  await fillField(tester, 'password', password);
  await tapText(tester, 'Entrar');
}
