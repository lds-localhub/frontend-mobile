import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/router/router.dart';

void main() {
  test('sem sessão, as rotas com sessão vão para as boas-vindas', () {
    expect(guard('/conta/palavra-passe', hasSession: false), '/boas-vindas');
    expect(guard('/cliente/pesquisa', hasSession: false), '/boas-vindas');
    expect(guard('/prestador/solicitacoes', hasSession: false), '/boas-vindas');
  });

  test('as rotas públicas abrem sem sessão', () {
    expect(guard('/boas-vindas', hasSession: false), isNull);
    expect(guard('/login', hasSession: false), isNull);
    expect(guard('/pesquisa', hasSession: false), isNull);
  });

  test('com sessão, as rotas com sessão abrem', () {
    expect(guard('/conta/palavra-passe', hasSession: true), isNull);
  });
}
