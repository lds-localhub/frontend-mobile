import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/screens/client/review_service_screen/review_form.dart';

void main() {
  late List<ReviewInput> sent;

  Future<void> pumpForm(WidgetTester tester) async {
    sent = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewForm(
              providerName: 'Ana',
              onSubmit: (body) async => sent.add(body),
              onCancel: () {},
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Submeter avaliação'));
    await tester.tap(find.text('Submeter avaliação'));
    await tester.pumpAndSettle();
  }

  testWidgets('sem classificação, o erro fica junto às estrelas, sem pedido', (
    tester,
  ) async {
    await pumpForm(tester);

    await submit(tester);

    expect(find.text('Escolha a classificação.'), findsOneWidget);
    expect(sent, isEmpty);
  });

  testWidgets('um comentário com mais de 500 caracteres não é enviado', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.tap(find.byTooltip('4 estrelas: Satisfeito'));
    await tester.pump();

    await tester.enterText(find.byKey(const ValueKey('comment')), 'a' * 501);
    await submit(tester);
    expect(
      find.text('O comentário tem, no máximo, 500 caracteres.'),
      findsOneWidget,
    );
    expect(sent, isEmpty);

    await tester.enterText(find.byKey(const ValueKey('comment')), 'a' * 500);
    await submit(tester);
    expect(sent, hasLength(1));
  });

  testWidgets('a classificação escolhida mostra o significado e é enviada', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.tap(find.byTooltip('5 estrelas: Muito satisfeito'));
    await tester.pump();
    expect(find.text('Muito satisfeito'), findsOneWidget);

    await submit(tester);

    // Sem comentário, o campo não é enviado
    expect(sent.single.toJson(), {'rating': 5});
  });
}
