import 'package:material_ui/material_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localhub/data/profile.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/ui/messages.dart';

class CreateProfileScreen extends ConsumerWidget {
  const CreateProfileScreen({super.key});

  Future<void> _handleSubmit(WidgetRef ref, ProfileInput body) async {
    try {
      await createProfile(ref, body: body);
      showMessage("Perfil criado");
    } catch (e) {
      await handleActionError(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar perfil")),
      body: ProfileForm(
        submitLabel: "Criar perfil",
        onSubmit: (body) => _handleSubmit(ref, body),
      ),
    );
  }
}
