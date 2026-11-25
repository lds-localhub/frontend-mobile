import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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

/// Detalhe de um serviço do Cliente, nas duas modalidades (M10 e M12): os
/// dados, o histórico e as solicitações diretas ou as propostas.
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
        error: (e, _) => ErrorStateView(
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
