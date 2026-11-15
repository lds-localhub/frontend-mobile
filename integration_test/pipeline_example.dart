import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localhub/main.dart';
import 'package:localhub/router/router.dart';

import 'helpers/providers.dart';

/// Teste de sistema de exemplo da pipeline (I093): prova a cadeia completa do
/// ambiente de testes. Os dados são preparados pela API (backend + base de
/// dados + stub do Nominatim) e a aplicação é aberta no emulador Android 16.
void pipelineExampleTests() {
  setUp(() => router.go('/boas-vindas'));

  testWidgets(
    'exemplo: Prestador preparado pela API e aplicação aberta no emulador',
    (tester) async {
      debugPrint(
        'criar um Prestador com perfil pela API (morada convertida pelo stub)',
      );
      final provider = await createProviderWithProfile(addressKey: 'maia');
      expect(provider.account.user['role'], 'PROVIDER');
      expect(provider.professionalProfileId, greaterThan(0));

      debugPrint('abrir a aplicação nas boas-vindas');
      await tester.pumpWidget(const LocalHubApp());
      await tester.pumpAndSettle();
      expect(find.text('Pesquisar Prestadores'), findsOneWidget);
    },
  );
}
