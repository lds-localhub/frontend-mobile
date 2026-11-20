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
import 'ts_mob_01_registo_sessao.dart';
import 'ts_mob_02_acesso.dart';
import 'ts_mob_03_perfil.dart';
import 'ts_mob_13_palavra_passe.dart';
import 'ts_mob_14_localizacao.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navegação', navigationTests);
  group('Exemplo da pipeline', pipelineExampleTests);
  group('TS-MOB-01 — Registo, início e fim de sessão', tsMob01Tests);
  group('TS-MOB-02 — Credenciais e acesso por papel', tsMob02Tests);
  group(
    'TS-MOB-03 — Criar, consultar e editar o perfil profissional',
    tsMob03Tests,
  );
  group('TS-MOB-13 — Alterar a palavra-passe', tsMob13Tests);
  // O caso 2 corre à parte, antes da permissão (ts_mob_14_permissao_recusada.dart)
  group('TS-MOB-14 — Definir a localização do cliente', tsMob14Tests);
}
