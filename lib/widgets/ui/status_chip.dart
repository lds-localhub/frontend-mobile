import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/tone.dart';
import 'package:localhub/theme/app_theme.dart';

/// Etiqueta de um estado, com o texto e a cor do tom.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final color = ToneColors.of(context, tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
