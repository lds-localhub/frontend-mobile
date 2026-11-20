import 'dart:convert';

import 'package:http/http.dart' as http;

import 'accounts.dart';

// Preparação de categorias pela API documentada (E09, E11), como Administrador
// e com a sessão da aplicação web (o backend recusa o Administrador na
// aplicação mobile). Não altera as categorias dos dados de referência.

/// E02 + E09 + E11: cria uma categoria com um nome único e desativa-a;
/// devolve o nome.
Future<String> createInactiveCategory() async {
  final admin = await login(adminEmail, adminPassword, client: 'WEB');
  final name = 'Desativada ${uniqueId()}';

  final created = await http.post(
    apiUri('/api/categories'),
    headers: jsonHeaders(token: admin.token),
    body: jsonEncode({'name': name}),
  );
  failIfNot(created, 201);
  final id =
      (jsonDecode(created.body) as Map<String, dynamic>)['serviceCategoryId']
          as int;

  final deactivated = await http.post(
    apiUri('/api/categories/$id/deactivate'),
    headers: jsonHeaders(token: admin.token),
  );
  failIfNot(deactivated, 200);
  return name;
}
