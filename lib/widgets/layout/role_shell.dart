import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Barra inferior do Cliente e do Prestador, com os separadores que o router
/// lhe passa; cada separador mantém a sua pilha de ecrãs.
class RoleShell extends StatelessWidget {
  const RoleShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  // Tocar no separador que já está aberto volta ao primeiro ecrã dele
  void _handleDestinationSelected(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _handleDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
