import 'package:material_ui/material_ui.dart';

/// Ecrã provisório de uma rota cujo ecrã ainda não foi implementado: mostra só
/// o nome do ecrã.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}
