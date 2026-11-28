import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/data/services.dart';
import 'package:localhub/models/proposal.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

import 'direct_request_card.dart';
import 'proposal_card.dart';
import 'service_overview.dart';

/// Detalhe de um serviço do Cliente, nas duas modalidades: os dados, o
/// histórico e as solicitações diretas ou as propostas.
///
/// Um serviço que não existe ou que é de outro Cliente mostra que não foi
/// encontrado, com o caminho para a lista: «Tentar outra vez» não o resolve.
class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final int serviceId;

  String? _acceptedProviderName(ServiceDetail service) {
    for (final request in service.directRequests) {
      if (request.proposal?.status == ProposalStatus.accepted) {
        return request.professionalProfile.name;
      }
    }
    return null;
  }

  List<Widget> _buildRequests(ThemeData theme, ServiceDetail service) {
    if (service.proposalModel == ProposalModel.directRequest) {
      final acceptedProviderName = _acceptedProviderName(service);
      return [
        Text(
          'Solicitações (${service.directRequests.length})',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final request in service.directRequests)
          DirectRequestCard(
            request: request,
            acceptedProviderName: acceptedProviderName,
          ),
      ];
    }
    return [
      Text(
        'Propostas (${service.proposals.length})',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: AppSpacing.sm),
      if (service.proposals.isEmpty)
        const EmptyStateView(message: 'Ainda não recebeu propostas.')
      else
        for (final proposal in service.proposals)
          ProposalCard(proposal: proposal),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(serviceProvider(serviceId));
    final currentUserId = ref.watch(meProvider).value?.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do serviço')),
      body: service.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        error: (e, _) => e is ApiError && (e.status == 404 || e.status == 403)
            ? const _ServiceNotFound()
            : ErrorStateView(
                error: e,
                onRetry: () => ref.invalidate(serviceProvider(serviceId)),
              ),
        // Ao terminar sessão, o ecrã ainda é desenhado uma vez sem utilizador
        data: (data) => currentUserId == null
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: () => ref.refresh(serviceProvider(serviceId).future),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    ServiceOverview(
                      service: data,
                      currentUserId: currentUserId,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ..._buildRequests(theme, data),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ServiceNotFound extends StatelessWidget {
  const _ServiceNotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Serviço não encontrado', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              'O serviço que procura não existe ou não é um dos seus serviços.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.go('/cliente/servicos'),
              child: const Text('Os meus serviços'),
            ),
          ],
        ),
      ),
    );
  }
}
