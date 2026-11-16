import 'package:material_ui/material_ui.dart';

/// Indicador de carregamento no lugar do conteúdo de uma leitura.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
