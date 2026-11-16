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

/// Regista uma conta de Cliente ou de Prestador (E01); não inicia sessão.
Future<void> register(RegisterInput body) async {
  await api('/auth/register', method: 'POST', body: body.toJson());
}

/// Inicia sessão (E02); o router leva depois ao início do papel.
Future<void> login(LoginInput body) async {
  final json = await api('/auth/login', method: 'POST', body: body.toJson());
  final result = LoginResult.fromJson(json! as Map<String, dynamic>);
  await Session.instance.start(result.token);
}

/// Termina a sessão (E03) e apaga o token do dispositivo, mesmo que o pedido
/// falhe.
Future<void> logout() async {
  try {
    await api('/auth/logout', method: 'POST');
  } catch (_) {
    // Sem rede ou com a sessão já terminada no servidor, a sessão termina na mesma no telemóvel
  } finally {
    await Session.instance.end();
  }
}

/// Altera a palavra-passe do utilizador autenticado (E40); a sessão atual
/// mantém-se.
Future<void> changePassword(ChangePasswordInput body) async {
  await api('/users/me/password', method: 'PUT', body: body.toJson());
}
