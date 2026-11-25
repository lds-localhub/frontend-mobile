import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/confirm_dialog.dart';

void main() {
  Future<bool?> openAndTap(WidgetTester tester, String button) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await confirmAction(
                context,
                title: 'Recusar solicitação?',
                subject: 'Reparar fuga na torneira',
                message: 'Esta ação não pode ser anulada.',
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Recusar solicitação?'), findsOneWidget);
    expect(find.text('Reparar fuga na torneira'), findsOneWidget);
    expect(find.text('Esta ação não pode ser anulada.'), findsOneWidget);

    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    expect(find.text('Recusar solicitação?'), findsNothing);
    return result;
  }

  testWidgets('«Confirmar» devolve true', (tester) async {
    expect(await openAndTap(tester, 'Confirmar'), isTrue);
  });

  testWidgets('«Voltar» devolve false', (tester) async {
    expect(await openAndTap(tester, 'Voltar'), isFalse);
  });
}
