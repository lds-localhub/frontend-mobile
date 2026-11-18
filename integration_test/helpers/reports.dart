import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/widgets/ui/stat_card.dart';

import 'app.dart';

// Passos comuns aos relatórios do Cliente (M14) e do Prestador (M25).

/// Escolhe [date] no campo de data com a chave [field] («startDate» ou
/// «endDate»), escrevendo-a no calendário em vez de tocar no dia: «ontem»
/// pode estar noutro mês.
Future<void> pickDate(WidgetTester tester, String field, DateTime date) async {
  await _scrollToFilter(tester);
  await tester.tap(find.byKey(ValueKey(field)));
  await tester.pumpAndSettle();
  final dialog = find.byType(DatePickerDialog);
  final l10n = MaterialLocalizations.of(tester.element(dialog));
  await tester.tap(find.byTooltip(l10n.inputDateModeButtonLabel));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    l10n.formatCompactDate(date),
  );
  await tester.tap(find.text(l10n.okButtonLabel));
  await tester.pumpAndSettle();
}

/// Limpa a data do campo com a dica [tooltip] («Limpar data inicial»).
Future<void> clearDate(WidgetTester tester, String tooltip) async {
  await _scrollToFilter(tester);
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}

// Depois de ver o fim do relatório, o filtro do período está acima do ecrã
// (e, numa lista longa, ainda não construído): sobe até ele
Future<void> _scrollToFilter(WidgetTester tester) async {
  final filter = find.byKey(const ValueKey('startDate'));
  if (filter.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      filter,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(filter);
  await tester.pumpAndSettle();
}

/// Desliza o relatório até o texto [text] estar construído e visível.
Future<void> showText(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(find.text(text).first);
  await tester.pumpAndSettle();
}

/// Verifica o número [value] do cartão com a legenda [label].
Future<void> expectStat(WidgetTester tester, String label, String value) async {
  await showText(tester, label);
  expect(
    find.descendant(
      of: find.widgetWithText(StatCard, label),
      matching: find.text(value),
    ),
    findsOneWidget,
    reason: '«$label» devia ser $value',
  );
}

/// Carrega em «Aplicar período» e espera pela resposta do relatório.
Future<void> applyPeriod(WidgetTester tester, String expectedText) async {
  await tapText(tester, 'Aplicar período');
  await waitForText(tester, expectedText);
}
