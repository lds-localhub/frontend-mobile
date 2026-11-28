import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';

/// Classificação média com uma estrela e o número de avaliações (ex.:
/// «★ 4,6 (12)»), ou «Sem avaliações».
class RatingText extends StatelessWidget {
  const RatingText({
    super.key,
    required this.averageRating,
    required this.reviewCount,
  });

  final double? averageRating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = averageRating;
    if (rating == null) {
      return Text('Sem avaliações', style: theme.textTheme.bodySmall);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 16, color: theme.colorScheme.tertiary),
        const SizedBox(width: AppSpacing.xs),
        Text.rich(
          TextSpan(
            style: theme.textTheme.bodySmall,
            children: [
              TextSpan(
                text: formatAverageRating(rating),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' ($reviewCount)'),
            ],
          ),
        ),
      ],
    );
  }
}
