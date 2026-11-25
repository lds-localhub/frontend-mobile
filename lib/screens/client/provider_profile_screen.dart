import 'package:material_ui/material_ui.dart';

import 'package:localhub/widgets/profiles/provider_profile_view.dart';

/// Perfil de um Prestador visto pelo Cliente (M07), com a distância da
/// pesquisa e «Fazer solicitação direta»; aberto a partir da seleção de
/// Prestadores do criar serviço ([fromSelection]), não tem esse botão.
class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({
    super.key,
    required this.professionalProfileId,
    this.distanceKm,
    this.serviceCategoryId,
    this.fromSelection = false,
  });

  final int professionalProfileId;
  final double? distanceKm;
  final int? serviceCategoryId;
  final bool fromSelection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Prestador')),
      body: ProviderProfileView(
        professionalProfileId: professionalProfileId,
        isOwn: false,
        distanceKm: distanceKm,
        serviceCategoryId: serviceCategoryId,
        showDirectRequest: !fromSelection,
      ),
    );
  }
}
