// TS-MOB-14, caso 2 — Permissão de localização recusada (RF-F015-06).
//
// Corre à parte, antes dos outros testes, com a aplicação acabada de instalar e
// ainda sem a permissão de localização (integration_test/ci/run-system-tests.sh):
// só assim a janela M06 aparece. Os restantes testes correm depois, com a
// permissão dada.
//   flutter test integration_test/ts_mob_14_permissao_recusada.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'ts_mob_14_localizacao.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'TS-MOB-14 — Definir a localização do cliente (permissão recusada)',
    tsMob14DeniedPermissionTests,
  );
}
