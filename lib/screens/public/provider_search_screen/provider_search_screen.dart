import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/data/search.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/categories/category_dropdown.dart';
import 'package:localhub/widgets/layout/visitor_nav_bar.dart';
import 'package:localhub/widgets/location/address_field.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/load_more_button.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

import 'provider_result_card.dart';

/// Pesquisa de Prestadores por categoria e localização de referência, do
/// Cliente (M05) e do Visitante (M05b).
///
/// O Cliente começa com a morada registada; o Visitante indica um endereço ou
/// usa a posição do dispositivo e, ao tocar num resultado, vai iniciar sessão.
class ProviderSearchScreen extends ConsumerWidget {
  const ProviderSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).value;

    // O campo começa com a morada registada: muda quando o Cliente a altera
    return _ProviderSearchView(
      key: ValueKey(me?.address),
      isVisitor: me == null,
      registeredAddress: me?.address,
    );
  }
}

class _ProviderSearchView extends ConsumerStatefulWidget {
  const _ProviderSearchView({
    super.key,
    required this.isVisitor,
    required this.registeredAddress,
  });

  final bool isVisitor;
  final String? registeredAddress;

  @override
  ConsumerState<_ProviderSearchView> createState() =>
      _ProviderSearchViewState();
}

class _ProviderSearchViewState extends ConsumerState<_ProviderSearchView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;
  var _autovalidateMode = AutovalidateMode.disabled;
  int? _categoryId;
  String? _positionError;
  SearchProvidersParams? _params;
  int _pages = 1;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(text: widget.registeredAddress ?? '');
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  SearchProvidersParams _page(SearchProvidersParams params, int page) => (
    serviceCategoryId: params.serviceCategoryId,
    address: params.address,
    name: params.name,
    page: page,
  );

  void _handleSearchPressed() {
    setState(() => _autovalidateMode = AutovalidateMode.always);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final address = _address.text.trim();
    final SearchProvidersParams params = (
      serviceCategoryId: _categoryId!,
      // Com a morada registada sem alterações, o backend usa as coordenadas já registadas
      address: address == widget.registeredAddress ? null : address,
      name: null,
      page: 1,
    );
    if (params == _params) {
      ref.invalidate(searchProvidersProvider(params));
    }
    setState(() {
      _params = params;
      _pages = 1;
    });
  }

  void _handleResultTap(ProviderSearchItem result) {
    if (widget.isVisitor) {
      context.push('/login');
      return;
    }
    context.push(
      '/cliente/pesquisa/prestadores/${result.professionalProfileId}',
      extra: (
        distanceKm: result.distanceKm,
        serviceCategoryId: _params!.serviceCategoryId,
      ),
    );
  }

  Future<void> _refresh() async {
    final params = _params;
    if (params == null) {
      return;
    }
    await Future.wait([
      for (var page = 1; page <= _pages; page++)
        ref.refresh(searchProvidersProvider(_page(params, page)).future),
    ]);
  }

  List<Widget> _buildResults(ThemeData theme) {
    final params = _params;
    if (params == null) {
      return const [
        EmptyStateView(
          message:
              'Escolha uma categoria e a localização e carregue em '
              '«Pesquisar».',
        ),
      ];
    }

    final pages = [
      for (var page = 1; page <= _pages; page++)
        ref.watch(searchProvidersProvider(_page(params, page))),
    ];
    final first = pages.first;
    if (first.hasError && !first.isLoading) {
      return [
        ErrorStateView(
          error: first.error!,
          onRetry: () => ref.invalidate(searchProvidersProvider(params)),
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
    final lastParams = _page(params, _pages);
    return [
      Text(
        '${firstPage.total} '
        '${firstPage.total == 1 ? 'Prestador' : 'Prestadores'} · do mais '
        'próximo ao mais distante',
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: AppSpacing.sm),
      for (final page in pages)
        for (final result in page.value?.items ?? const <ProviderSearchItem>[])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ProviderResultCard(
              result: result,
              onTap: () => _handleResultTap(result),
            ),
          ),
      if (last.hasError && !last.isLoading)
        ErrorStateView(
          error: last.error!,
          onRetry: () => ref.invalidate(searchProvidersProvider(lastParams)),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Prestadores'),
        actions: [
          if (widget.isVisitor)
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Entrar'),
            ),
        ],
      ),
      bottomNavigationBar: widget.isVisitor ? const VisitorNavBar() : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Encontrar um Prestador',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormField<void>(
                        validator: (_) => _categoryId == null
                            ? 'Escolha uma categoria.'
                            : null,
                        builder: (field) => CategoryDropdown(
                          value: _categoryId,
                          errorText: field.errorText,
                          onChanged: (id) {
                            setState(() => _categoryId = id);
                            field.didChange(null);
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AddressField(
                        label: 'Localização de referência',
                        requiredMessage:
                            'Indique um endereço ou use a sua posição atual.',
                        maxLengthMessage:
                            'O endereço tem, no máximo, 255 caracteres.',
                        controller: _address,
                        positionError: _positionError,
                        onChanged: () {
                          if (_positionError != null) {
                            setState(() => _positionError = null);
                          }
                        },
                        onPositionError: (error) =>
                            setState(() => _positionError = error),
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.icon(
                        key: const ValueKey('search'),
                        onPressed: _handleSearchPressed,
                        icon: const Icon(Icons.search),
                        label: const Text('Pesquisar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._buildResults(theme),
            if (widget.isVisitor) ...[
              const SizedBox(height: AppSpacing.md),
              const _SignInBanner(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignInBanner extends StatelessWidget {
  const _SignInBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Inicie sessão para ver o perfil e solicitar serviços.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('Iniciar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
