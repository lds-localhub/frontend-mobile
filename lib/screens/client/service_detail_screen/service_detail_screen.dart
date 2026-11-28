import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/data/services.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/services/service_confirm_texts.dart';
import 'package:localhub/widgets/ui/confirm_dialog.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

import 'direct_request_card.dart';
import 'proposal_card.dart';
import 'proposal_decision.dart';
import 'service_overview.dart';

/// Nome do Prestador de uma proposta, para a confirmação.
String _providerOfProposal(ServiceDetail service, int proposalId) {
  for (final request in service.directRequests) {
    if (request.proposal?.proposalId == proposalId) {
      return request.professionalProfile.name;
    }
  }
  for (final proposal in service.proposals) {
    if (proposal.proposalId == proposalId) {
      return proposal.professionalProfile.name;
    }
  }
  return '';
}

/// Detalhe do serviço do Cliente, nas duas modalidades: a modalidade escolhe a
/// secção de baixo (solicitações ou propostas). As decisões pedem confirmação;
/// a avaliação abre o seu ecrã.
///
/// Um serviço que não existe ou que é de outro Cliente mostra que não foi
/// encontrado, com o caminho para a lista: «Tentar outra vez» não o resolve.
class ServiceDetailScreen extends ConsumerStatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final int serviceId;

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  bool _busy = false;

  // Pede a confirmação e, depois de confirmada, faz a ação e mostra a mensagem
  Future<void> _confirmAndRun({
    required String title,
    required String subject,
    required String message,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final confirmed = await confirmAction(
      context,
      title: title,
      subject: subject,
      message: message,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        showMessage(successMessage);
      }
    } catch (e) {
      if (mounted) {
        _showActionError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  // Mensagem de qualquer erro da ação, exceto o 401 (sessão terminada, tratado
  // no cliente da API). As decisões não têm formulário, por isso um 400 ou
  // erros de campo também aparecem aqui.
  void _showActionError(Object e) {
    if (e is ApiError && e.status == 401) {
      return;
    }
    showMessage(getErrorMessage(e));
    // Estado diferente no servidor (ex.: o Prestador cancelou entretanto):
    // atualiza o ecrã
    if (e is ApiError && e.status == 409) {
      refreshServicesAndReports(ref);
    }
  }

  void _handleAccept(ServiceDetail service, int proposalId) => _confirmAndRun(
    title: 'Aceitar proposta?',
    subject: _providerOfProposal(service, proposalId),
    message: acceptProposalText(service.proposalModel),
    action: () => acceptProposal(ref, proposalId: proposalId),
    successMessage: 'Proposta aceite.',
  );

  void _handleDecline(ServiceDetail service, int proposalId) => _confirmAndRun(
    title: 'Recusar proposta?',
    subject: _providerOfProposal(service, proposalId),
    message: declineProposalText,
    action: () => declineProposal(ref, proposalId: proposalId),
    successMessage: 'Proposta recusada.',
  );

  void _handleComplete(ServiceDetail service) => _confirmAndRun(
    title: 'Marcar como realizado?',
    subject: service.title,
    message: completeServiceText,
    action: () => completeService(ref, serviceId: service.serviceId),
    successMessage: 'Serviço marcado como realizado.',
  );

  // O texto depende do estado do serviço quando se carregou em «Cancelar»
  void _handleCancel(ServiceDetail service) => _confirmAndRun(
    title: 'Cancelar serviço?',
    subject: service.title,
    message: cancelServiceText(service.status),
    action: () => cancelService(ref, serviceId: service.serviceId),
    successMessage: 'Serviço cancelado.',
  );

  List<Widget> _buildResponses(
    ThemeData theme,
    ServiceDetail service, {
    required String? acceptedProviderName,
    required bool enabled,
  }) {
    // As propostas só ficam sem efeito por causa do cancelamento se o serviço
    // foi cancelado ainda aberto; cancelado depois de atribuído, as outras já
    // tinham ficado sem efeito quando aceitou uma. Não trazem data: a data é a
    // do cancelamento, a última alteração do histórico.
    final last = service.history.lastOrNull;
    final voidedByCancellationAt =
        last != null &&
            last.newStatus == ServiceStatus.cancelled &&
            last.previousStatus == ServiceStatus.open
        ? last.changedAt
        : null;
    // Só com o serviço aberto se aceitam ou recusam propostas
    final ProposalDecisionHandlers? decision =
        service.status == ServiceStatus.open
        ? (
            onAccept: (proposalId) => _handleAccept(service, proposalId),
            onDecline: (proposalId) => _handleDecline(service, proposalId),
            enabled: enabled,
          )
        : null;

    if (service.proposalModel == ProposalModel.directRequest) {
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
            voidedByCancellationAt: voidedByCancellationAt,
            decision: decision,
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
          ProposalCard(
            proposal: proposal,
            voidedByCancellationAt: voidedByCancellationAt,
            decision: decision,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceId = widget.serviceId;
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
        data: (data) {
          if (currentUserId == null) {
            return const LoadingView();
          }
          final acceptedProviderName = data.acceptedProviderName;
          // As ações ficam desativadas enquanto uma decorre ou o detalhe
          // atualiza
          final enabled = !_busy && !service.isLoading;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(serviceProvider(serviceId).future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                ServiceOverview(
                  service: data,
                  currentUserId: currentUserId,
                  acceptedProviderName: acceptedProviderName,
                  onCancel: () => _handleCancel(data),
                  onComplete: () => _handleComplete(data),
                  onReview: () =>
                      context.push('/cliente/servicos/$serviceId/avaliar'),
                  enabled: enabled,
                ),
                const SizedBox(height: AppSpacing.lg),
                ..._buildResponses(
                  theme,
                  data,
                  acceptedProviderName: acceptedProviderName,
                  enabled: enabled,
                ),
              ],
            ),
          );
        },
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
