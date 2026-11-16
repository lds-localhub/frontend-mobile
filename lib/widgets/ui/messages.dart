import 'package:material_ui/material_ui.dart';

/// Chave do ScaffoldMessenger da aplicação, para mostrar mensagens mesmo
/// depois de mudar de ecrã.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Mostra uma mensagem curta (SnackBar) no fundo do ecrã.
void showMessage(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}
