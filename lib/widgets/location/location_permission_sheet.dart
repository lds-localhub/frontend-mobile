import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Janela que sobe do fundo e explica o pedido de acesso à localização (M06),
/// antes do pedido do sistema.
class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({super.key});

  /// Mostra a janela e devolve `true` se o utilizador escolher «Permitir».
  static Future<bool> show(BuildContext context) async {
    final allowed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => const LocationPermissionSheet(),
    );
    return allowed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 28,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Permitir acesso à localização?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A posição é obtida uma única vez, só quando o pedir, e só '
              'preenche o endereço.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Permitir'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Recusar'),
            ),
          ],
        ),
      ),
    );
  }
}
