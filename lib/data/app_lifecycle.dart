import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conta as vezes que a aplicação voltou ao primeiro plano; os providers de
/// leitura observam-no para voltarem a pedir os dados.
final appResumedProvider = NotifierProvider<AppResumed, int>(AppResumed.new);

/// Estado do [appResumedProvider].
class AppResumed extends Notifier<int> {
  @override
  int build() => 0;

  /// Avisa que a aplicação voltou ao primeiro plano.
  void resumed() => state++;
}
