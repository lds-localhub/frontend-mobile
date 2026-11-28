import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Filtro de uma lista por um valor (ex.: «Estado: Todos»); `null` é «Todos».
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> options;
  final String Function(T option) optionLabel;
  final ValueChanged<T?> onChanged;

  String get _valueLabel {
    final current = value;
    return current == null ? 'Todos' : optionLabel(current);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // As opções são escolhidas pela posição: «Todos» (-1) não pode ser `null`,
    // porque o menu devolve `null` quando é fechado sem escolha
    return PopupMenuButton<int>(
      tooltip: label,
      onSelected: (index) => onChanged(index < 0 ? null : options[index]),
      itemBuilder: (context) => [
        const PopupMenuItem(value: -1, child: Text('Todos')),
        for (final (index, option) in options.indexed)
          PopupMenuItem(value: index, child: Text(optionLabel(option))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(AppRadius.card * 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $_valueLabel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}
