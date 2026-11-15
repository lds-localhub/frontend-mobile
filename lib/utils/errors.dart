import 'package:localhub/api/api_client.dart';
import 'package:localhub/widgets/ui/messages.dart';

/// Mensagem a mostrar para qualquer erro: o `detail` da API ou, sem resposta
/// do servidor, a mensagem de indisponibilidade.
String getErrorMessage(Object error) => error is ApiError
    ? error.detail
    : 'Não foi possível contactar o servidor. Tente novamente.';

/// Indica se o erro é da API e, com [type], se é desse tipo próprio do
/// LocalHub (ex.: `credenciais-invalidas`).
bool isApiError(Object error, [String? type]) =>
    error is ApiError && (type == null || error.type.endsWith('/$type'));

/// Mostra o erro de uma ação; num 409 sem `errors`, atualiza o ecrã com
/// [onConflict].
Future<void> handleActionError(
  Object error, {
  Future<void> Function()? onConflict,
}) async {
  // 401: a sessão já terminou; com `errors` ou 400: vão para o formulário
  if (error is ApiError &&
      (error.status == 401 || error.status == 400 || error.errors != null)) {
    return;
  }
  showMessage(getErrorMessage(error));
  if (error is ApiError && error.status == 409) {
    // O estado no servidor é diferente do que o ecrã mostra
    await onConflict?.call();
  }
}

/// Primeira mensagem de cada campo com erro do backend; [renames] traduz
/// nomes do backend para nomes do formulário.
Map<String, String> serverFieldErrors(
  ApiError error, [
  Map<String, String> renames = const {},
]) => {
  for (final entry in (error.errors ?? const <String, List<String>>{}).entries)
    renames[entry.key] ?? entry.key: entry.value.first,
};
