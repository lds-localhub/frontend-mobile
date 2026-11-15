// Preparação dos dados de teste através da API documentada do backend
// (RNF-12).
//
// Os testes de sistema não acedem diretamente à base de dados. A base de
// referência é criada e reposta pelos scripts do backend (RNF-19) e é só de
// leitura para os testes; cada teste cria pela API os dados de que precisa,
// com e-mails únicos, para que os testes sejam independentes uns dos outros.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/config/api_config.dart';

/// Palavra-passe das contas criadas pelos testes (cumpre a regra do registo).
const palavraPasseTeste = 'Teste2026';

/// Contas da base de dados de referência (README dos scripts da base de dados
/// do backend). As palavras-passe não ficam no repositório: são passadas com
/// `--dart-define` (GitHub Secrets no CI).
const emailAdministrador = 'ana.almeida@localhub.test';
const emailClienteReferencia = 'carla.costa@localhub.test';
const emailPrestadorReferencia = 'hugo.henriques@localhub.test';
const palavraPasseAdministrador = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const palavraPasseReferencia = String.fromEnvironment('E2E_DEMO_PASSWORD');

enum Papel {
  cliente('CLIENT'),
  prestador('PROVIDER');

  const Papel(this.valor);

  /// Valor do papel na API.
  final String valor;
}

/// Resposta de um pedido à API: código HTTP e corpo JSON (ou null).
class RespostaApi {
  const RespostaApi(this.estado, this.corpo);

  final int estado;
  final Object? corpo;

  Map<String, dynamic> get objeto => corpo! as Map<String, dynamic>;
}

/// Conta criada por um teste, com o token da sessão.
class Conta {
  const Conta({
    required this.userId,
    required this.email,
    required this.password,
    required this.role,
    required this.token,
  });

  final int userId;
  final String email;
  final String password;
  final String role;
  final String token;
}

/// Cliente HTTP para o backend real (o mesmo endereço usado pela aplicação).
class ApiTestes {
  final HttpClient _cliente = HttpClient();

  Future<RespostaApi> pedido(
    String metodo,
    String caminho, {
    Object? corpo,
    String? token,
  }) async {
    final req = await _cliente.openUrl(
      metodo,
      Uri.parse('$apiBaseUrl$caminho'),
    );
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (corpo != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(corpo));
    }
    final res = await req.close();
    final texto = await res.transform(utf8.decoder).join();
    return RespostaApi(
      res.statusCode,
      texto.isEmpty ? null : jsonDecode(texto),
    );
  }

  void fechar() => _cliente.close(force: true);
}

final _aleatorio = Random();

/// E-mail fictício e único (domínio reservado .test, RNF-20).
String emailUnico([String prefixo = 'teste']) {
  final sufixo = _aleatorio.nextInt(1 << 32).toRadixString(16);
  return '$prefixo.${DateTime.now().microsecondsSinceEpoch}.$sufixo@localhub.test';
}

/// POST /api/auth/login; devolve o token da sessão. Por omissão, como a
/// aplicação MOBILE.
Future<String> iniciarSessao(
  ApiTestes api,
  String email,
  String password, {
  String aplicacao = 'MOBILE',
}) async {
  final resposta = await api.pedido(
    'POST',
    '/api/auth/login',
    corpo: {'email': email, 'password': password, 'client': aplicacao},
  );
  expect(resposta.estado, 200, reason: 'Início de sessão de $email');
  return resposta.objeto['token'] as String;
}

/// Inicia sessão com o administrador da base de dados de referência. O
/// administrador só usa a aplicação web, por isso a sessão é WEB.
Future<String> iniciarSessaoAdministrador(ApiTestes api) {
  if (palavraPasseAdministrador.isEmpty) {
    throw StateError(
      'Indique --dart-define=E2E_ADMIN_PASSWORD=<palavra-passe>.',
    );
  }
  return iniciarSessao(
    api,
    emailAdministrador,
    palavraPasseAdministrador,
    aplicacao: 'WEB',
  );
}

/// POST /api/auth/register e início de sessão; devolve a conta com o token.
Future<Conta> registarConta(
  ApiTestes api,
  Papel papel, {
  String? nome,
  String? email,
  String password = palavraPasseTeste,
}) async {
  final cliente = papel == Papel.cliente;
  final emailConta = email ?? emailUnico(cliente ? 'cliente' : 'prestador');
  final resposta = await api.pedido(
    'POST',
    '/api/auth/register',
    corpo: {
      'name': nome ?? (cliente ? 'Cliente de Teste' : 'Prestador de Teste'),
      'email': emailConta,
      'password': password,
      'role': papel.valor,
    },
  );
  expect(resposta.estado, 201, reason: 'Registo de $emailConta');

  final token = await iniciarSessao(api, emailConta, password);
  final utilizador = await obterUtilizador(api, token);
  return Conta(
    userId: utilizador['userId'] as int,
    email: emailConta,
    password: password,
    role: utilizador['role'] as String,
    token: token,
  );
}

/// GET /api/auth/me
Future<Map<String, dynamic>> obterUtilizador(
  ApiTestes api,
  String token,
) async {
  final resposta = await api.pedido('GET', '/api/auth/me', token: token);
  expect(resposta.estado, 200, reason: 'Consulta da conta com sessão iniciada');
  return resposta.objeto;
}

/// PUT /api/users/me/location (só Cliente). A morada é convertida pelo
/// geocodificador simulado.
Future<Map<String, dynamic>> definirLocalizacao(
  ApiTestes api,
  String token,
  String morada,
) async {
  final resposta = await api.pedido(
    'PUT',
    '/api/users/me/location',
    corpo: {'address': morada},
    token: token,
  );
  expect(resposta.estado, 200, reason: 'Definição da localização "$morada"');
  return resposta.objeto;
}
