import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/utils/format.dart';

void main() {
  test('as datas sem hora não mudam de dia com o fuso horário', () {
    expect(formatDay('2026-10-13'), '13/10/2026');
    expect(formatDay('2026-01-01'), '01/01/2026');
  });

  test('o mês do relatório aparece por extenso, com maiúscula', () {
    expect(formatMonth('2026-07'), 'Julho 2026');
    expect(formatMonth('2026-12'), 'Dezembro 2026');
  });
}
