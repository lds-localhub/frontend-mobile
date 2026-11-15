import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';

/// Erro de uma leitura no lugar do conteúdo, com a mensagem e «Tentar outra
/// vez».
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              getErrorMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar outra vez'),
            ),
          ],
        ),
      ),
    );
  }
}
