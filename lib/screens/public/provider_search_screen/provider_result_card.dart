import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/radius_badge.dart';
import 'package:localhub/widgets/ui/rating_text.dart';

/// Um Prestador nos resultados da pesquisa, com a distância, a classificação e
/// se a localização de referência está dentro do raio; o ecrã decide o destino.
class ProviderResultCard extends StatelessWidget {
  const ProviderResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  final ProviderSearchItem result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              InitialsAvatar(name: result.name, radius: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      result.serviceCategories.map((c) => c.name).join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              formatDistance(result.distanceKm),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        RatingText(
                          averageRating: result.averageRating,
                          reviewCount: result.reviewCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RadiusBadge(
                      withinServiceRadius: result.withinServiceRadius,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
