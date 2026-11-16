import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:localhub/api/session.dart';
import 'package:localhub/config/api_config.dart';

/// Erro devolvido pela API no formato Problem Details.
class ApiError implements Exception {
  const ApiError(this.status, this.type, this.detail, [this.errors]);

  /// Código HTTP (400, 401, 403, 404, 409, 500, 503).
  final int status;

  /// URI do tipo de erro (ex.: `https://localhub.local/erros/transicao-invalida`).
  final String type;

  /// Mensagem em português, apresentável ao utilizador.
  final String detail;

  /// Erros por campo: nos 400 e no 409 do e-mail já registado.
  final Map<String, List<String>>? errors;

  @override
  String toString() => 'ApiError($status, $type, $detail)';
}

/// Faz um pedido à API e devolve o JSON da resposta (`null` num 204).
///
/// Lança [ApiError] em qualquer resposta 4xx ou 5xx. Sem resposta do servidor
/// (sem rede, servidor desligado, tempo limite), lança o erro de rede.
Future<Object?> api(String path, {String method = 'GET', Object? body}) async {
  final token = Session.instance.token;
  final request = http.Request(method, Uri.parse('$apiBaseUrl/api$path'))
    ..headers['Content-Type'] = 'application/json'
    ..headers.addAll({if (token != null) 'Authorization': 'Bearer $token'});
  if (body != null) {
    request.body = jsonEncode(body);
  }

  final response = await http.Response.fromStream(
    await request.send().timeout(const Duration(seconds: 15)),
  );

  if (response.statusCode == 204) {
    return null;
  }
  // Lido como UTF-8 para não perder os acentos das mensagens em português
  final json = response.body.isEmpty
      ? null
      : jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return json;
  }

  final problem = json is Map<String, dynamic>
      ? json
      : const <String, dynamic>{};
  // O 401 do início de sessão são credenciais erradas, não uma sessão terminada
  if (response.statusCode == 401 && path != '/auth/login') {
    await Session.instance.end(expired: true);
  }
  throw ApiError(
    response.statusCode,
    problem['type'] as String? ?? '',
    problem['detail'] as String? ?? 'Ocorreu um erro inesperado.',
    (problem['errors'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    ),
  );
}

/// Monta os parâmetros de query (ex.: `status=PENDING&page=2`); ignora os
/// valores `null`.
String toQueryString(Map<String, Object?> params) => Uri(
  queryParameters: {
    for (final entry in params.entries)
      if (entry.value != null) entry.key: '${entry.value}',
  },
).query;
