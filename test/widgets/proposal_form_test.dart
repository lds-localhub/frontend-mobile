import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/proposal.dart';
import 'package:localhub/widgets/proposals/proposal_form.dart';

void main() {
  late List<ProposalInput> sent;

  Future<void> pumpForm(WidgetTester tester) async {
    sent = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProposalForm(onSubmit: (body) async => sent.add(body)),
          ),
        ),
      ),
    );
  }

  Future<void> submit(WidgetTester tester, String amount) async {
    await tester.enterText(find.byKey(const ValueKey('amount')), amount);
    await tester.enterText(
      find.byKey(const ValueKey('conditions')),
      'Inclui material e deslocação.',
    );
    await tester.ensureVisible(find.text('Enviar proposta'));
    await tester.tap(find.text('Enviar proposta'));
    await tester.pumpAndSettle();
  }

  testWidgets('um valor fora dos limites fica junto ao campo, sem pedido', (
    tester,
  ) async {
    await pumpForm(tester);

    await submit(tester, '0');
    expect(find.text('O valor tem de ser maior que 0.'), findsOneWidget);
    expect(sent, isEmpty);

    await submit(tester, '100000,01');
    expect(
      find.text('O valor não pode ser superior a 100 000,00 €.'),
      findsOneWidget,
    );
    expect(sent, isEmpty);
  });

  testWidgets('um valor válido é enviado, sem a observação vazia', (
    tester,
  ) async {
    await pumpForm(tester);

    await submit(tester, '80,00');

    expect(sent, hasLength(1));
    expect(sent.single.toJson(), {
      'amount': 80.0,
      'conditions': 'Inclui material e deslocação.',
    });
  });

  testWidgets('«Recusar solicitação» só aparece quando o ecrã o pede', (
    tester,
  ) async {
    await pumpForm(tester);

    expect(find.text('Recusar solicitação'), findsNothing);
  });
}
