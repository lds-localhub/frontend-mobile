import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/widgets/profiles/provider_profile_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

/// O próprio perfil do Prestador, como os Clientes o veem, com «Editar
/// perfil» e as avaliações (M26).
class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // As guardas só deixam chegar aqui um Prestador com perfil; ao terminar
    // sessão, o ecrã ainda é desenhado uma vez sem utilizador
    final professionalProfileId = ref
        .watch(meProvider)
        .value
        ?.professionalProfileId;

    return Scaffold(
      appBar: AppBar(title: const Text('O meu perfil')),
      body: professionalProfileId == null
          ? const LoadingView()
          : ProviderProfileView(
              professionalProfileId: professionalProfileId,
              isOwn: true,
            ),
    );
  }
}
