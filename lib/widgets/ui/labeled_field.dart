import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Campo de formulário com o rótulo a negrito por cima da caixa, como no
/// protótipo.
///
/// O rótulo e o campo são lidos juntos pelo leitor de ecrã, como o
/// `labelText` de um campo.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
