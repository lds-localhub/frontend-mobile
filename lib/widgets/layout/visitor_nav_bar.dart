import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Barra inferior do Visitante na pesquisa de Prestadores: «Pesquisar» e
/// «Iniciar sessão».
class VisitorNavBar extends StatelessWidget {
  const VisitorNavBar({super.key});

  void _handleDestinationSelected(BuildContext context, int index) {
    if (index == 1) {
      context.push('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) =>
          _handleDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Pesquisar'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Iniciar sessão',
        ),
      ],
    );
  }
}
