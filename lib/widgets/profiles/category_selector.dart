import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/category.dart';
import 'package:localhub/theme/app_theme.dart';

/// Etiquetas de seleção das categorias do perfil profissional.
///
/// Com [lockLastSelected], a etiqueta da única categoria selecionada fica
/// desativada, porque o perfil não pode ficar sem categorias.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
    this.lockLastSelected = false,
    this.enabled = true,
    this.errorText,
  });

  final List<Category> categories;
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;
  final bool lockLastSelected;
  final bool enabled;
  final String? errorText;

  void _handleSelected(int serviceCategoryId, bool isSelected) => onChanged(
    isSelected
        ? [...selected, serviceCategoryId]
        : [
            for (final id in selected)
              if (id != serviceCategoryId) id,
          ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in categories)
              _CategoryChip(
                label: category.name,
                selected: selected.contains(category.serviceCategoryId),
                locked:
                    lockLastSelected &&
                    selected.length == 1 &&
                    selected.first == category.serviceCategoryId,
                onSelected: enabled
                    ? (isSelected) => _handleSelected(
                        category.serviceCategoryId,
                        isSelected,
                      )
                    : null,
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool locked;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: locked ? null : onSelected,
      showCheckmark: true,
      checkmarkColor: colors.onPrimary,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? colors.primary : colors.outline),
      shape: const StadiumBorder(),
    );
  }
}
