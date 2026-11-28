import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide Page;

import 'package:localhub/data/services.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/services/service_confirm_texts.dart';
import 'package:localhub/widgets/ui/confirm_dialog.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/filter_dropdown.dart';
import 'package:localhub/widgets/ui/load_more_button.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

import 'service_list_card.dart';

/// Todos os serviços do Cliente, com o filtro do estado e o cancelamento dos
/// abertos e atribuídos.
class MyServicesScreen extends ConsumerStatefulWidget {
  const MyServicesScreen({super.key});

  @override
  ConsumerState<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends ConsumerState<MyServicesScreen> {
  ServiceStatus? _status;
  int _pages = 1;
  bool _cancelling = false;

  ServicesParams _params(int page) => (status: _status, page: page);

  void _handleStatusChanged(ServiceStatus? status) => setState(() {
    _status = status;
    _pages = 1;
  });

  Future<void> _refresh() {
    for (var page = 2; page <= _pages; page++) {
      ref.invalidate(servicesProvider(_params(page)));
    }
    return ref.refresh(servicesProvider(_params(1)).future);
  }

  // A janela recebe o serviço do cartão em que se tocou: é modal, por isso a
  // lista não muda enquanto está aberta
  Future<void> _handleCancelPressed(ServiceItem service) async {
    final confirmed = await confirmAction(
      context,
      title: 'Cancelar serviço?',
      subject: service.title,
      message: cancelServiceText(service.status),
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _cancelling = true);
    try {
      await cancelService(ref, serviceId: service.serviceId);
      if (mounted) {
        showMessage('Serviço cancelado.');
      }
    } catch (e) {
      if (mounted) {
        await handleActionError(e, onConflict: _refresh);
      }
    } finally {
      if (mounted) {
        setState(() => _cancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      for (var page = 1; page <= _pages; page++)
        ref.watch(servicesProvider(_params(page))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Os meus serviços')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FilterDropdown<ServiceStatus>(
                label: 'Estado',
                value: _status,
                options: ServiceStatus.values,
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
                  onRetry: () => ref.invalidate(servicesProvider(_params(1))),
                ),
              ],
              data: (first) => first.total == 0
                  ? [
                      EmptyStateView(
                        message: _status == null
                            ? 'Ainda não criou serviços.'
                            : 'Não tem serviços neste estado.',
                      ),
                    ]
                  : _buildItems(pages),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<AsyncValue<Page<ServiceItem>>> pages) {
    final last = pages.last;
    // «Cancelar serviço» fica desativado enquanto a lista atualiza ou o
    // cancelamento decorre
    final busy = _cancelling || pages.any((page) => page.isLoading);

    return [
      for (final page in pages)
        for (final service in page.value?.items ?? const <ServiceItem>[])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ServiceListCard(
              service: service,
              enabled: !busy,
              onOpen: () =>
                  context.push('/cliente/servicos/${service.serviceId}'),
              onCancel: () => _handleCancelPressed(service),
            ),
          ),
      if (last.hasError && !last.hasValue)
        ErrorStateView(
          error: last.error!,
          onRetry: () => ref.invalidate(servicesProvider(_params(_pages))),
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
