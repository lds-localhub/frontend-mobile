import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:localhub/config/api_config.dart';

// Preparação de contas pela API documentada (E01, E02), sem acesso direto à
// base de dados. Os pedidos vão para o mesmo backend que a aplicação usa
// (apiBaseUrl: http://10.0.2.2:5041 no emulador).

/// Palavra-passe fictícia das contas criadas pelos testes
/// (regra do E01: 8+ caracteres, com letra e algarismo).
const String testPassword = 'Teste2026';

/// Conta criada pelos testes, com a sessão iniciada.
class TestAccount {
  const TestAccount({
    required this.email,
    required this.password,
    required this.token,
    required this.user,
  });

  final String email;
  final String password;
  final String token;
  final Map<String, dynamic> user;
}

final Random _random = Random();

/// Identificador único por conta: `<instante><sufixo aleatório>`.
String uniqueId() =>
    '${DateTime.now().millisecondsSinceEpoch}'
    '${_random.nextInt(1 << 20).toRadixString(36)}';

/// E-mail único por teste: `<prefixo>.<identificador>@localhub.test`.
String uniqueEmail(String prefix, [String? id]) =>
    '$prefix.${id ?? uniqueId()}@localhub.test';

Uri apiUri(String path) => Uri.parse('$apiBaseUrl$path');

Map<String, String> jsonHeaders({String? token}) => {
  'Content-Type': 'application/json',
  if (token != null) 'Authorization': 'Bearer $token',
};

/// Falha com o endereço, o código e a resposta do backend, se o código não
/// for o esperado.
void failIfNot(http.Response response, int status) {
  if (response.statusCode != status) {
    throw StateError(
      '${response.request?.url} devolveu ${response.statusCode} '
      '(esperado $status): ${response.body}',
    );
  }
}

/// E02: inicia sessão como a aplicação mobile (`client = MOBILE`).
Future<({String token, Map<String, dynamic> user})> login(
  String email,
  String password, {
  String client = 'MOBILE',
}) async {
  final response = await http.post(
    apiUri('/api/auth/login'),
    headers: jsonHeaders(),
    body: jsonEncode({'email': email, 'password': password, 'client': client}),
  );
  failIfNot(response, 200);
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return (
    token: body['token'] as String,
    user: body['user'] as Map<String, dynamic>,
  );
}

/// E01 + E02: regista uma conta nova com um e-mail único e inicia sessão.
Future<TestAccount> registerAndLogin(String role, {String? prefix}) async {
  // O nome também é único: a BD só é reposta uma vez por execução e os dados
  // dos testes acumulam-se, por isso um teste identifica as suas contas pelo
  // nome (ex.: filtro name da pesquisa E18)
  final id = uniqueId();
  final email = uniqueEmail(
    prefix ?? (role == 'CLIENT' ? 'cliente' : 'prestador'),
    id,
  );
  final name = '${role == 'CLIENT' ? 'Cliente' : 'Prestador'} $id';

  final response = await http.post(
    apiUri('/api/auth/register'),
    headers: jsonHeaders(),
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': testPassword,
      'role': role,
    }),
  );
  failIfNot(response, 201);

  final session = await login(email, testPassword);
  return TestAccount(
    email: email,
    password: testPassword,
    token: session.token,
    user: session.user,
  );
}

/// Administrador dos dados de referência do backend (só de leitura).
const String adminEmail = 'ana.almeida@localhub.test';
const String adminPassword = 'Admin2026';
