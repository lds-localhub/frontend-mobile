import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide Page;

import 'package:localhub/data/direct_requests.dart';
import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/filter_dropdown.dart';
import 'package:localhub/widgets/ui/load_more_button.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

import 'direct_request_list_card.dart';

/// Todas as solicitações diretas recebidas pelo Prestador, com o filtro do
/// estado.
class DirectRequestsScreen extends ConsumerStatefulWidget {
  const DirectRequestsScreen({super.key});

  @override
  ConsumerState<DirectRequestsScreen> createState() =>
      _DirectRequestsScreenState();
}

class _DirectRequestsScreenState extends ConsumerState<DirectRequestsScreen> {
  DirectRequestStatus? _status;
  int _pages = 1;

  DirectRequestsParams _params(int page) => (status: _status, page: page);

  void _handleStatusChanged(DirectRequestStatus? status) => setState(() {
    _status = status;
    _pages = 1;
  });

  Future<void> _refresh() {
    for (var page = 2; page <= _pages; page++) {
      ref.invalidate(directRequestsProvider(_params(page)));
    }
    return ref.refresh(directRequestsProvider(_params(1)).future);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      for (var page = 1; page <= _pages; page++)
        ref.watch(directRequestsProvider(_params(page))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações recebidas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FilterDropdown<DirectRequestStatus>(
                label: 'Estado',
                value: _status,
                options: DirectRequestStatus.values,
                optionLabel: (status) => status.label,
                onChanged: _handleStatusChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...pages.first.when(
              skipLoadingOnReload: true,
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: LoadingView(),
                ),
              ],
              error: (e, _) => [
                ErrorStateView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(directRequestsProvider(_params(1))),
                ),
              ],
              data: (first) => first.total == 0
                  ? [
                      EmptyStateView(
                        message: _status == null
                            ? 'Não tem solicitações.'
                            : 'Não tem solicitações neste estado.',
                      ),
                    ]
                  : _buildItems(pages),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<AsyncValue<Page<DirectRequestItem>>> pages) {
    final last = pages.last;
    return [
      for (final page in pages)
        for (final item in page.value?.items ?? const <DirectRequestItem>[])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DirectRequestListCard(
              item: item,
              onTap: () => context.push(
                '/prestador/solicitacoes/${item.directRequestId}',
              ),
            ),
          ),
      if (last.hasError && !last.hasValue)
        ErrorStateView(
          error: last.error!,
          onRetry: () =>
              ref.invalidate(directRequestsProvider(_params(_pages))),
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
}
