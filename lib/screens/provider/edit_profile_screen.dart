import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/data/profiles.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/profiles/profile_form.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

/// Edição do perfil profissional do Prestador, com os valores atuais (M27b).
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  // Os erros voltam a ser lançados para o formulário pôr os do backend nos campos
  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    int professionalProfileId,
    ProfileInput body,
  ) async {
    try {
      await updateProfile(ref, body: body);
    } catch (e) {
      await handleActionError(e);
      rethrow;
    }
    // O ecrã do perfil, por baixo, tem de já mostrar os dados novos quando este fecha
    try {
      await ref.read(profileProvider(professionalProfileId).future);
    } catch (_) {
      // O perfil já foi guardado: o ecrã do perfil mostra o erro da leitura e deixa tentar outra vez
    }
    if (context.mounted) {
      showMessage('Perfil atualizado.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // As guardas só deixam chegar aqui um Prestador com perfil
    final professionalProfileId = ref
        .watch(meProvider)
        .value
        ?.professionalProfileId;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: professionalProfileId == null
            ? const LoadingView()
            : ref
                  .watch(profileProvider(professionalProfileId))
                  .when(
                    skipLoadingOnReload: true,
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorStateView(
                      error: e,
                      onRetry: () => ref.invalidate(
                        profileProvider(professionalProfileId),
                      ),
                    ),
                    // O formulário só é criado com os dados, que preenchem os campos uma vez
                    data: (profile) => ProfileForm(
                      initialValues: profile,
                      submitLabel: 'Guardar alterações',
                      onSubmit: (body) => _handleSubmit(
                        context,
                        ref,
                        professionalProfileId,
                        body,
                      ),
                      onCancel: () => context.pop(),
                    ),
                  ),
      ),
    );
  }
}
