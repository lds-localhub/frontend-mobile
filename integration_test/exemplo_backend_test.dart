// Teste de sistema de exemplo (I093): verifica o ambiente dos testes de
// sistema de ponta a ponta, isto é, o emulador Android, a aplicação, o backend
// real, a base de dados de referência criada pelos scripts e o geocodificador
// simulado. Serve de modelo aos testes de sistema das funcionalidades.
//
// Executar com o emulador ligado e o backend a correr (README, secção Testes
// de sistema):
//   flutter test integration_test
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:localhub/main.dart';
import 'package:localhub/router/router.dart';

import 'support/api.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // O router é global e partilhado entre testes: cada teste começa nas
  // boas-vindas
  setUp(() => router.go('/boas-vindas'));

  testWidgets(
    'a aplicação comunica com o backend real, a base de dados de referência '
    'e o geocodificador simulado',
    (tester) async {
      final api = ApiTestes();
      addTearDown(api.fechar);

      // Preparação dos dados pela API documentada (sem acesso direto à base
      // de dados)
      final cliente = await registarConta(api, Papel.cliente);
      final utilizador = await definirLocalizacao(
        api,
        cliente.token,
        'Rua de Santa Catarina 74, Porto',
      );
      expect(utilizador['address'], 'Rua de Santa Catarina 74, Porto');

      // A aplicação abre no emulador
      await tester.pumpWidget(const LocalHubApp());
      await tester.pumpAndSettle();
      expect(find.text('Pesquisar Prestadores'), findsOneWidget);

      // Pedidos feitos a partir do emulador ao backend real
      final categorias = await api.pedido('GET', '/api/categories');
      expect(categorias.estado, 200);
      expect(categorias.corpo.toString(), contains('Canalização'));
      expect(categorias.corpo.toString(), contains('Eletricidade'));

      final conta = await obterUtilizador(api, cliente.token);
      expect(conta['email'], cliente.email);
      expect(conta['role'], 'CLIENT');
      expect(conta['address'], 'Rua de Santa Catarina 74, Porto');
    },
  );
}
