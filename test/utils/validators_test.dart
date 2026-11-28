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

  group('valor da proposta', () {
    final validate = amount();
    const tooLow = 'O valor tem de ser maior que 0.';
    const tooHigh = 'O valor não pode ser superior a 100 000,00 €.';
    const format = 'Indique um valor com, no máximo, duas casas decimais.';

    test('tem de ser maior que 0', () {
      expect(validate('0'), tooLow);
      expect(validate('0,00'), tooLow);
      expect(validate('0,01'), isNull);
    });

    test('pode ir até 100 000,00, com o limite incluído', () {
      expect(validate('100000'), isNull);
      expect(validate('100000,00'), isNull);
      expect(validate('100000,01'), tooHigh);
      expect(validate('250000'), tooHigh);
    });

    test('aceita a vírgula e o ponto, com até duas casas decimais', () {
      expect(validate('80,00'), isNull);
      expect(validate('80.5'), isNull);
      expect(validate(' 80 '), isNull);
      expect(validate('80,005'), format);
      expect(validate('-5'), format);
      expect(validate('oitenta'), format);
      expect(validate(''), format);
    });

    test('converte o texto para número', () {
      expect(parseAmount('80,50'), 80.5);
      expect(parseAmount('100000.00'), 100000);
      expect(parseAmount('abc'), isNull);
    });
  });
}
