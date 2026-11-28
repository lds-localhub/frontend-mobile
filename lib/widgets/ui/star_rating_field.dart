import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Classificação de 1 a 5 estrelas, uma escolha única, com o significado da
/// escolhida ao lado.
///
/// Cada estrela tem um nome com o número e o significado (ex.: «5 estrelas:
/// Muito satisfeito»), que os testes usam para a encontrar.
class StarRatingField extends StatelessWidget {
  const StarRatingField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.meanings,
    this.errorText,
    this.enabled = true,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  /// Texto de cada classificação, de 1 a 5.
  final Map<int, String> meanings;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    final errorText = this.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var n = 1; n <= 5; n++)
              IconButton(
                tooltip:
                    '$n ${n == 1 ? 'estrela' : 'estrelas'}: ${meanings[n]}',
                onPressed: enabled ? () => onChanged(n) : null,
                icon: Icon(
                  value != null && n <= value ? Icons.star : Icons.star_outline,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (value != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  meanings[value]!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (errorText != null)
          Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}
