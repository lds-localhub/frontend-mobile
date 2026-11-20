import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/data/profiles.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/profiles/profile_form.dart';
import 'package:localhub/widgets/ui/messages.dart';

/// Criação do perfil profissional do Prestador sem perfil (M27).
class CreateProfileScreen extends ConsumerWidget {
  const CreateProfileScreen({super.key});

  // Os erros voltam a ser lançados para o formulário pôr os do backend nos campos
  Future<void> _handleSubmit(WidgetRef ref, ProfileInput body) async {
    try {
      await createProfile(ref, body: body);
    } catch (e) {
      await handleActionError(e);
      rethrow;
    }
    showMessage('Perfil criado.');
    // Com o utilizador já com perfil, as guardas levam ao início do Prestador;
    // até lá o botão continua desativado e não há segundo envio
    try {
      await ref.read(meProvider.future);
    } catch (_) {
      // O perfil já foi criado: uma falha a recarregar o utilizador não é um erro do envio
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar perfil profissional')),
      body: SafeArea(
        child: ProfileForm(
          submitLabel: 'Criar perfil',
          onSubmit: (body) => _handleSubmit(ref, body),
        ),
      ),
    );
  }
}
