import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/tone.dart';
import 'package:localhub/theme/app_theme.dart';

/// Uma barra: o texto, o número e o tom (sem tom, a cor principal).
typedef BarItem = ({String label, int value, Tone? tone});

/// Barras horizontais dos relatórios, proporcionais ao maior valor.
class BarList extends StatelessWidget {
  const BarList({super.key, required this.items});

  final List<BarItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = items.fold(
      0,
      (max, item) => item.value > max ? item.value : max,
    );

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 104,
                  child: Text(item.label, style: theme.textTheme.bodyMedium),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : item.value / max,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      color: item.tone == null
                          ? theme.colorScheme.primary
                          : ToneColors.of(context, item.tone!),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${item.value}',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
