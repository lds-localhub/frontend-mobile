import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';

// Passos comuns à pesquisa de Prestadores (M05/M05b) e ao criar serviço
// (M08/M11/M17).

/// Escolhe a categoria [name] no seletor de categorias do ecrã.
Future<void> chooseCategory(WidgetTester tester, String name) async {
  await pumpUntil(
    tester,
    () => find.text('Escolha uma categoria').evaluate().isNotEmpty,
    description: 'o seletor de categorias',
  );
  // Toca no próprio seletor; num ecrã pequeno, desliza primeiro até ele
  final dropdown = find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<int?>,
  );
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

/// Carrega em «Pesquisar» na pesquisa de Prestadores (o botão, não o
/// separador da barra inferior com o mesmo nome).
Future<void> tapSearch(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('search'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Desliza os resultados (e carrega em «Ver mais») até aparecer o Prestador
/// [name]: os dados dos testes acumulam-se e há outros Prestadores na zona.
Future<void> findResult(WidgetTester tester, String name) async {
  for (var i = 0; i < 40 && find.text(name).evaluate().isEmpty; i++) {
    if (find.text('Ver mais').evaluate().isNotEmpty) {
      await tapText(tester, 'Ver mais');
      await pumpUntil(
        tester,
        () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
        description: 'a página seguinte',
      );
    } else {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  }
  expect(find.text(name), findsOneWidget, reason: 'Prestador $name');
  await tester.ensureVisible(find.text(name));
  await tester.pumpAndSettle();
}

/// Escolhe hoje no campo de data com a chave [field].
Future<void> pickToday(WidgetTester tester, String field) async {
  final finder = find.byKey(ValueKey(field));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  final dialog = find.byType(DatePickerDialog);
  final l10n = MaterialLocalizations.of(tester.element(dialog));
  await tester.tap(find.text(l10n.okButtonLabel));
  await tester.pumpAndSettle();
}
