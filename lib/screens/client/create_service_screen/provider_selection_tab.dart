import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/categories.dart';
import 'package:localhub/data/search.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/load_more_button.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

import 'create_service_screen.dart';
import 'provider_option_tile.dart';

/// Separador «Prestadores» do criar serviço (M17): pesquisa por nome dos
/// Prestadores da categoria, pela distância ao local de realização, e a
/// seleção, devolvida em [onChanged].
///
/// Só pesquisa enquanto está aberto ([active]): fechado, o local ainda pode
/// estar a ser escrito no separador «Detalhes».
class ProviderSelectionTab extends ConsumerStatefulWidget {
  const ProviderSelectionTab({
    super.key,
    required this.serviceCategoryId,
    required this.location,
    required this.selected,
    required this.onChanged,
    required this.active,
    this.errorText,
    this.enabled = true,
  });

  final int? serviceCategoryId;
  final String location;
  final List<SelectedProvider> selected;
  final String? errorText;
  final ValueChanged<List<SelectedProvider>> onChanged;
  final bool active;
  final bool enabled;

  @override
  ConsumerState<ProviderSelectionTab> createState() =>
      _ProviderSelectionTabState();
}

class _ProviderSelectionTabState extends ConsumerState<ProviderSelectionTab> {
  final _nameController = TextEditingController();
  String _name = '';
  Timer? _debounce;
  int _pages = 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // Espera que se pare de escrever, para não pesquisar a cada letra
  void _handleNameChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _name = value.trim();
          _pages = 1;
        });
      }
    });
  }

  void _handleToggle(ProviderSearchItem result) {
    final id = result.professionalProfileId;
    final isSelected = widget.selected.any(
      (p) => p.professionalProfileId == id,
    );
    widget.onChanged(
      isSelected
          ? [
              for (final p in widget.selected)
                if (p.professionalProfileId != id) p,
            ]
          : [
              ...widget.selected,
              (
                professionalProfileId: id,
                name: result.name,
                serviceCategoryIds: [
                  for (final c in result.serviceCategories) c.serviceCategoryId,
                ],
              ),
            ],
    );
  }

  void _handleViewProfile(ProviderSearchItem result) {
    context.push(
      '/cliente/criar/prestadores/${result.professionalProfileId}',
      extra: (
        distanceKm: result.distanceKm,
        serviceCategoryId: widget.serviceCategoryId,
      ),
    );
  }

  SearchProvidersParams _params(int categoryId, String location, int page) => (
    serviceCategoryId: categoryId,
    address: location,
    name: _name.isEmpty ? null : _name,
    page: page,
  );

  List<Widget> _buildResults(int categoryId, String location) {
    final pages = [
      for (var page = 1; page <= _pages; page++)
        ref.watch(searchProvidersProvider(_params(categoryId, location, page))),
    ];
    final first = pages.first;
    if (first.hasError && !first.isLoading) {
      return [
        ErrorStateView(
          error: first.error!,
          onRetry: () => ref.invalidate(
            searchProvidersProvider(_params(categoryId, location, 1)),
          ),
        ),
      ];
    }
    final firstPage = first.value;
    if (firstPage == null) {
      return const [LoadingView()];
    }
    if (firstPage.total == 0) {
      return const [
        EmptyStateView(
          message:
              'Não foram encontrados Prestadores para esta categoria e '
              'localização.',
        ),
      ];
    }

    final last = pages.last;
    return [
      for (final page in pages)
        for (final result in page.value?.items ?? const <ProviderSearchItem>[])
          ProviderOptionTile(
            result: result,
            selected: widget.selected.any(
              (p) => p.professionalProfileId == result.professionalProfileId,
            ),
            enabled: widget.enabled,
            onToggle: () => _handleToggle(result),
            onViewProfile: () => _handleViewProfile(result),
          ),
      if (last.hasError && !last.isLoading)
        ErrorStateView(
          error: last.error!,
          onRetry: () => ref.invalidate(
            searchProvidersProvider(_params(categoryId, location, _pages)),
          ),
        )
      else if (!last.hasValue)
        LoadMoreButton(loading: true, onPressed: () {})
      else if (last.value!.hasMore)
        LoadMoreButton(
          loading: false,
          onPressed: () => setState(() => _pages++),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryId = widget.serviceCategoryId;
    final location = widget.location.trim();
    final canSearch = categoryId != null && location.isNotEmpty;
    final categoryName = ref
        .watch(categoriesProvider)
        .value
        ?.where((c) => c.serviceCategoryId == categoryId)
        .firstOrNull
        ?.name;
    final errorText = widget.errorText;
    final sectionStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSearch && categoryName != null)
          Text(
            '$categoryName · distância a $location',
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _nameController,
          enabled: canSearch && widget.enabled,
          decoration: const InputDecoration(
            hintText: 'Pesquisar por nome',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _handleNameChanged,
        ),
        if (!canSearch) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Escolha a categoria e o local de realização em «Detalhes» para '
            'pesquisar Prestadores.',
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('SELECIONADOS (${widget.selected.length})', style: sectionStyle),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final provider in widget.selected)
              InputChip(
                label: Text(provider.name),
                isEnabled: widget.enabled,
                onDeleted: () => widget.onChanged([
                  for (final p in widget.selected)
                    if (p.professionalProfileId !=
                        provider.professionalProfileId)
                      p,
                ]),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (canSearch && widget.active) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'RESULTADOS · DO MAIS PRÓXIMO AO MAIS DISTANTE',
            style: sectionStyle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildResults(categoryId, location),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
