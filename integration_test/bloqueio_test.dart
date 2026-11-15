// Teste intencionalmente falhado (I093): evidência de que uma falha nos testes
// de sistema faz a pipeline falhar e bloqueia o merge. Esta branch nunca é
// integrada na master.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:localhub/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('teste de exemplo intencionalmente falhado', (tester) async {
    await tester.pumpWidget(const LocalHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Título que não existe'), findsOneWidget);
  });
}
