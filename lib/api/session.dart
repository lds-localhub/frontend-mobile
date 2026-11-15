import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sessão do utilizador: o token, guardado no armazenamento seguro do
/// dispositivo e em memória, e se a sessão foi terminada pelo servidor.
///
/// O router ouve-a para voltar a aplicar as guardas quando a sessão começa ou
/// acaba.
class Session extends ChangeNotifier {
  Session._();

  /// A sessão da aplicação.
  static final instance = Session._();

  static const _key = 'token';
  final _storage = const FlutterSecureStorage();

  /// Token da sessão; `null` sem sessão (Visitante).
  String? token;

  /// A sessão foi terminada pelo servidor (401): o início de sessão mostra a
  /// mensagem de sessão terminada.
  bool expired = false;

  /// Lê o token guardado, no arranque, antes de a aplicação ser desenhada.
  Future<void> load() async => token = await _storage.read(key: _key);

  /// Começa a sessão com o token devolvido pelo início de sessão.
  Future<void> start(String newToken) async {
    token = newToken;
    expired = false;
    await _storage.write(key: _key, value: newToken);
    notifyListeners();
  }

  /// Termina a sessão e apaga o token do dispositivo; `expired` indica que foi
  /// o servidor a terminá-la.
  Future<void> end({bool expired = false}) async {
    token = null;
    this.expired = expired;
    await _storage.delete(key: _key);
    notifyListeners();
  }
}
