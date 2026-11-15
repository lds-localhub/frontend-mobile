import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/models/user.dart';
import 'package:localhub/router/router.dart';

Me user(Role role, {int? professionalProfileId}) => Me(
  userId: 1,
  name: 'Ana Martins',
  email: 'ana@localhub.test',
  role: role,
  address: null,
  professionalProfileId: professionalProfileId,
);

void main() {
  const visitor = AsyncData<Me?>(null);
  final client = AsyncData<Me?>(user(Role.client));
  final provider = AsyncData<Me?>(
    user(Role.provider, professionalProfileId: 7),
  );
  final noProfile = AsyncData<Me?>(user(Role.provider));

  test('sem sessão, as rotas com sessão vão para as boas-vindas', () {
    expect(guard(visitor, '/cliente/conta', hasToken: false), '/boas-vindas');
    expect(
      guard(visitor, '/conta/palavra-passe', hasToken: false),
      '/boas-vindas',
    );
    expect(guard(visitor, '/a-iniciar', hasToken: false), '/boas-vindas');
    expect(guard(visitor, '/contactos', hasToken: false), isNull);
  });

  test('com a sessão terminada pelo servidor, vão para o início de sessão', () {
    expect(
      guard(visitor, '/cliente/conta', hasToken: false, expired: true),
      '/login',
    );
  });

  test('com token, fica no arranque enquanto o utilizador carrega', () {
    expect(
      guard(const AsyncLoading<Me?>(), '/cliente/conta', hasToken: true),
      '/a-iniciar',
    );
    expect(
      guard(const AsyncLoading<Me?>(), '/a-iniciar', hasToken: true),
      isNull,
    );
  });

  test('com sessão, as rotas do Visitante levam ao início do papel', () {
    expect(guard(client, '/login', hasToken: true), '/cliente/pesquisa');
    expect(
      guard(provider, '/a-iniciar', hasToken: true),
      '/prestador/solicitacoes',
    );
  });

  test('o Prestador sem perfil só vê o M04, o M27 e o M19', () {
    expect(
      guard(noProfile, '/prestador/solicitacoes', hasToken: true),
      '/prestador/sem-perfil',
    );
    expect(guard(noProfile, '/prestador/criar-perfil', hasToken: true), isNull);
    expect(guard(noProfile, '/conta/palavra-passe', hasToken: true), isNull);
    expect(
      guard(provider, '/prestador/sem-perfil', hasToken: true),
      '/prestador/solicitacoes',
    );
  });

  test('cada papel só abre as suas rotas', () {
    expect(
      guard(client, '/prestador/conta', hasToken: true),
      '/cliente/pesquisa',
    );
    expect(
      guard(provider, '/cliente/conta', hasToken: true),
      '/prestador/solicitacoes',
    );
    expect(guard(client, '/cliente/conta', hasToken: true), isNull);
  });
}
