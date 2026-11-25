import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/utils/format.dart';

void main() {
  test('as datas sem hora não mudam de dia com o fuso horário', () {
    expect(formatDay('2026-10-13'), '13/10/2026');
    expect(formatDay('2026-01-01'), '01/01/2026');
  });

  test('a disponibilidade é uma data ou um intervalo', () {
    expect(formatAvailability('2026-10-08', null), '08/10/2026');
    expect(formatAvailability('2026-10-08', '2026-10-08'), '08/10/2026');
    expect(
      formatAvailability('2026-10-13', '2026-10-19'),
      '13/10 a 19/10/2026',
    );
    expect(
      formatAvailability('2026-12-28', '2027-01-03'),
      '28/12/2026 a 03/01/2027',
    );
  });

  test('o mês do relatório aparece por extenso, com maiúscula', () {
    expect(formatMonth('2026-07'), 'Julho 2026');
    expect(formatMonth('2026-12'), 'Dezembro 2026');
  });
}
