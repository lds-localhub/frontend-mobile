import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';

/// Um Prestador nos resultados da seleção (M17): a caixa de seleção, a
/// classificação, a distância, o raio e «Ver perfil».
class ProviderOptionTile extends StatelessWidget {
  const ProviderOptionTile({
    super.key,
    required this.result,
    required this.selected,
    required this.onToggle,
    required this.onViewProfile,
    this.enabled = true,
  });

  final ProviderSearchItem result;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onViewProfile;
  final bool enabled;

  String get _details {
    final rating = result.averageRating;
    final parts = [
      rating == null ? 'Sem avaliações' : '★ ${formatAverageRating(rating)}',
      formatDistance(result.distanceKm),
      'raio ${result.serviceRadiusKm} km',
    ];
    final outside = result.withinServiceRadius ? '' : ' (fora do raio)';
    return '${parts.join(' · ')}$outside';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: enabled ? (_) => onToggle() : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.name, style: theme.textTheme.titleSmall),
                Text(_details, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(onPressed: onViewProfile, child: const Text('Ver perfil')),
        ],
      ),
    );
  }
}
