import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/utils/validators.dart';

void main() {
  test('a palavra-passe precisa de 8 caracteres, uma letra e um algarismo', () {
    final validate = password();

    expect(validate('abcdefgh'), isNotNull);
    expect(validate('1234567'), isNotNull);
    expect(validate('casa202'), isNotNull);
    expect(validate('casa2026'), isNull);
  });

  test('os campos obrigatórios e os tamanhos ignoram os espaços', () {
    final name = all([notEmpty('vazio'), maxLength(3, 'longo')]);

    expect(name('   '), 'vazio');
    expect(name(' abc '), isNull);
    expect(name('abcd'), 'longo');
  });

  test('o raio é um número inteiro de 1 a 100, com os limites incluídos', () {
    final radius = intRange(1, 100, 'fora');

    expect(radius(''), 'fora');
    expect(radius('0'), 'fora');
    expect(radius('1'), isNull);
    expect(radius('100'), isNull);
    expect(radius('101'), 'fora');
    expect(radius('dez'), 'fora');
    expect(radius(' 25 '), isNull);
  });
}
