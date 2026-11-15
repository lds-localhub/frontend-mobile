import 'dart:convert';

import 'package:http/http.dart' as http;

import 'accounts.dart';
import 'addresses.dart';

// Preparação de Prestadores pela API documentada (E08, E12), sem acesso
// direto à base de dados.
// Regra para os testes de pesquisa: a BD não é reposta entre testes, por isso
// há sempre outros Prestadores na mesma zona (o Hugo dos dados de referência
// e os de outros testes). Um teste procura o seu Prestador pelo nome
// (user['name'], único) e nunca depende do total de resultados.

/// Prestador criado pelos testes, com sessão iniciada e perfil profissional.
class TestProvider {
  const TestProvider({
    required this.account,
    required this.professionalProfileId,
  });

  final TestAccount account;
  final int professionalProfileId;
}

/// E08: identificadores das categorias ativas com os nomes indicados.
Future<List<int>> categoryIds(List<String> names) async {
  final response = await http.get(apiUri('/api/categories'));
  failIfNot(response, 200);
  final items =
      (jsonDecode(response.body) as Map<String, dynamic>)['items']
          as List<dynamic>;
  return names.map((name) {
    final category = items.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['name'] == name,
      orElse: () => throw StateError('Categoria ativa inexistente: $name'),
    );
    return category['serviceCategoryId'] as int;
  }).toList();
}

/// E01 + E02 + E12: regista um Prestador, inicia sessão e cria o perfil.
Future<TestProvider> createProviderWithProfile({
  String addressKey = 'maia',
  int serviceRadiusKm = 25,
  List<String> categoryNames = const ['Canalização'],
}) async {
  final account = await registerAndLogin('PROVIDER');

  final response = await http.post(
    apiUri('/api/profiles'),
    headers: jsonHeaders(token: account.token),
    body: jsonEncode({
      'introduction': 'Prestador criado pelos testes de sistema.',
      'contactDetails': 'Telefone 220 000 000',
      'experience': 'Experiência fictícia para os testes.',
      'serviceCategoryIds': await categoryIds(categoryNames),
      'address': testAddresses[addressKey],
      'serviceRadiusKm': serviceRadiusKm,
    }),
  );
  failIfNot(response, 201);
  final body = jsonDecode(response.body) as Map<String, dynamic>;

  return TestProvider(
    account: account,
    professionalProfileId: body['professionalProfileId'] as int,
  );
}
