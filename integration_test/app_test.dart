// Testes de sistema automáticos (QG-07 do regulamento interno).
// Executar com um emulador ou dispositivo ligado:
//   flutter test integration_test
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:localhub/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a aplicação abre na página inicial', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('LocalHub'), findsOneWidget);
  });
}
