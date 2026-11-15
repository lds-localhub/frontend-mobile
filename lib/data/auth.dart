import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/api/session.dart';
import 'package:localhub/models/user.dart';

/// Sessão da aplicação, para os providers recalcularem quando a sessão começa
/// ou acaba.
///
/// Só ouve a sessão: um `ChangeNotifierProvider` libertaria o
/// `Session.instance` quando o provider fosse descartado (ex.: entre testes).
final sessionProvider = Provider<Session>((ref) {
  final session = Session.instance;
  void notify() => ref.notifyListeners();
  session.addListener(notify);
  ref.onDispose(() => session.removeListener(notify));
  return session;
});

/// Utilizador autenticado (E04), ou `null` sem sessão.
///
/// Sem `autoDispose` e sem observar o regresso à aplicação: o utilizador só
/// muda por ações do próprio, por isso é pedido uma vez em cada sessão.
final meProvider = FutureProvider<Me?>((ref) async {
  ref.watch(sessionProvider);
  // Sem token não há sessão: o Visitante não pede o utilizador autenticado
  if (Session.instance.token == null) {
    return null;
  }
  final json = await api('/auth/me');
  return Me.fromJson(json! as Map<String, dynamic>);
});
