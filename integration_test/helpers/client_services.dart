import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/utils/format.dart';

import 'app.dart';

// Passos comuns aos testes dos serviços do Cliente: os botões e os estados
// procuram-se dentro do cartão do serviço, do Prestador ou da proposta, porque
// o mesmo texto aparece em vários cartões.

/// Data de hoje, como os ecrãs a mostram.
String today() => formatDate(DateTime.now().toUtc().toIso8601String());

/// O texto [text] dentro do cartão que tem o texto [cardText] (ex.: o nome do
/// Prestador ou o título do serviço).
Finder inCard(String cardText, String text) => find.descendant(
  of: find.ancestor(of: find.text(cardText), matching: find.byType(Card)).first,
  matching: find.text(text),
);

/// Desliza até ao cartão com o texto [cardText], que pode estar acima ou
/// abaixo do que está à vista (ex.: depois de ver o último cartão da lista).
Future<void> scrollToCard(WidgetTester tester, String cardText) async {
  if (find.text(cardText).evaluate().isEmpty) {
    try {
      await scrollToText(tester, cardText, up: true);
    } on StateError {
      // Chegou ao topo sem o encontrar: está abaixo
      await scrollToText(tester, cardText);
    }
  }
  await scrollToText(tester, cardText);
}

/// Desliza até ao cartão com o texto [cardText] e toca em [label] dentro dele.
Future<void> tapInCard(
  WidgetTester tester,
  String cardText,
  String label,
) async {
  // A mensagem da ação anterior fica 4 s por cima dos botões de baixo
  if (find.byType(SnackBar).evaluate().isNotEmpty) {
    await pumpUntil(
      tester,
      () => find.byType(SnackBar).evaluate().isEmpty,
      description: 'a mensagem fechar',
    );
  }
  await scrollToCard(tester, cardText);
  final finder = inCard(cardText, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Verifica a janela de confirmação aberta: o [title], o nome [subject] a
/// negrito e, com [message], parte das consequências.
void expectConfirmation({
  required String title,
  required String subject,
  String? message,
}) {
  final dialog = find.byType(AlertDialog);
  expect(
    find.descendant(of: dialog, matching: find.text(title)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: dialog, matching: find.text(subject)),
    findsOneWidget,
  );
  if (message != null) {
    expect(
      find.descendant(of: dialog, matching: find.textContaining(message)),
      findsOneWidget,
    );
  }
}

/// Confirma a janela aberta e espera pela mensagem [message].
Future<void> confirmAndWait(WidgetTester tester, String message) async {
  await tapText(tester, 'Confirmar');
  await waitForText(tester, message);
}

/// O detalhe do serviço sem nenhuma das ações do Cliente.
void expectNoServiceActions() {
  expect(find.text('Marcar como realizado'), findsNothing);
  expect(find.text('Avaliar serviço'), findsNothing);
  expect(find.text('Cancelar serviço'), findsNothing);
}
