// Testes de sistema automáticos (QG-07 do regulamento interno).
//
// Entrada única: importa todos os testes, para a aplicação ser compilada e
// instalada no emulador uma só vez. Executar com um emulador ligado e o
// backend e o stub do Nominatim a correr:
//   flutter test integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'navigation.dart';
import 'pipeline_example.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navegação', navigationTests);
  group('Exemplo da pipeline', pipelineExampleTests);
}
