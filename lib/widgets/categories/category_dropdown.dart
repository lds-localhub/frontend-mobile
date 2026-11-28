import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/categories.dart';
import 'package:localhub/models/category.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Seletor das categorias ativas, com «Todas» ([allowAll], valor `null`) ou
/// limitado às categorias de [onlyIds].
///
/// A validação é do ecrã: um `FormField` à volta passa o erro em [errorText].
class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Categoria',
    this.allowAll = false,
    this.onlyIds,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;
  final bool allowAll;
  final List<int>? onlyIds;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  Widget _buildDropdown(List<Category> categories) {
    final ids = onlyIds;
    final options = [
      for (final category in categories)
        if (ids == null || ids.contains(category.serviceCategoryId)) category,
    ];
    // Um valor que já não está nas opções (ex.: categoria desativada) não fica escolhido
    final selected = options.any((c) => c.serviceCategoryId == value)
        ? value
        : null;

    return DropdownButtonFormField<int?>(
      // O valor inicial só é lido ao criar o campo: muda quando o ecrã o muda
      key: ValueKey((selected, ids?.join(','))),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Escolha uma categoria',
        helperText: helperText,
        helperMaxLines: 2,
        errorText: errorText,
      ),
      items: [
        if (allowAll) const DropdownMenuItem<int?>(child: Text('Todas')),
        for (final category in options)
          DropdownMenuItem<int?>(
            value: category.serviceCategoryId,
            child: Text(category.name),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return LabeledField(
      label: label,
      child: switch (categories) {
        AsyncValue(value: final items?) => _buildDropdown(items),
        AsyncValue(:final error?) => ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        _ => const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}
