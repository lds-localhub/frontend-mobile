import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
  await Session.instance.end();
  final container = ProviderContainer(retry: retryReads);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LocalHubApp()),
  );
  await tester.pumpAndSettle();
  return TestApp(container);
}
