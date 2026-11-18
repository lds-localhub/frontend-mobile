import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Número em destaque com a sua legenda, num cartão; [highlighted] pinta o
/// cartão com a cor principal.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = highlighted ? theme.colorScheme.onPrimary : null;

    return Card(
      color: highlighted ? theme.colorScheme.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(color: foreground),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
