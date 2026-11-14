import 'package:material_ui/material_ui.dart';

import 'package:localhub/widgets/layout/visitor_nav_bar.dart';

class ProviderSearchScreen extends StatelessWidget {
  const ProviderSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Prestadores')),
      bottomNavigationBar: const VisitorNavBar(),
    );
  }
}
