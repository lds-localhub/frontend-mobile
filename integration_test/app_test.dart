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
import 'ts_mob_04_pesquisa_solicitacao.dart';
import 'ts_mob_05_publicar.dart';
import 'ts_mob_06_solicitacoes_recebidas.dart';
import 'ts_mob_11_relatorio_cliente.dart';
import 'ts_mob_12_relatorio_prestador.dart';
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
  group(
    'TS-MOB-04 — Pesquisar prestadores e criar solicitações diretas',
    tsMob04Tests,
  );
  group('TS-MOB-05 — Publicar trabalho', tsMob05Tests);
  group('TS-MOB-06 — Responder a solicitações diretas', tsMob06Tests);
  group('TS-MOB-11 — Relatório do cliente', tsMob11Tests);
  group('TS-MOB-12 — Relatório do prestador', tsMob12Tests);
  group('TS-MOB-13 — Alterar a palavra-passe', tsMob13Tests);
  // O caso 2 corre à parte, antes da permissão (ts_mob_14_permissao_recusada.dart)
  group('TS-MOB-14 — Definir a localização do cliente', tsMob14Tests);
  // O TS-MOB-15 corre à parte, com o modo de avião (ts_mob_15_rede_indisponivel.dart)
}
