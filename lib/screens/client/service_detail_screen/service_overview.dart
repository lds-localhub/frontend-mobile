import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/services/service_history.dart';
import 'package:localhub/widgets/services/service_meta.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

/// Cartão de cima do detalhe do serviço: título, estado, modalidade, as ações
/// do Cliente, a faixa do serviço cancelado, dados, descrição e histórico. As
/// confirmações e a avaliação são abertas pelo ecrã.
class ServiceOverview extends StatelessWidget {
  const ServiceOverview({
    super.key,
    required this.service,
    required this.currentUserId,
    required this.acceptedProviderName,
    required this.onCancel,
    required this.onComplete,
    required this.onReview,
    this.enabled = true,
  });

  final ServiceDetail service;
  final int currentUserId;

  /// Prestador da proposta aceite, se houver.
  final String? acceptedProviderName;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback onReview;

  /// Falso enquanto uma ação decorre.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusChip(
                  label: service.status.label,
                  tone: service.status.tone,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  service.proposalModel.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _ServiceActions(
              status: service.status,
              reviewed: service.reviewed,
              onCancel: onCancel,
              onComplete: onComplete,
              onReview: onReview,
              enabled: enabled,
            ),
            _CancelledBanner(history: service.history),
            const SizedBox(height: AppSpacing.sm),
            ServiceMeta(
              category: service.serviceCategory,
              // Só os serviços abertos a propostas são publicados
              publishedAt: service.proposalModel == ProposalModel.public
                  ? service.creationDate
                  : null,
              location: service.location,
              requestedStartDate: service.requestedStartDate,
              requestedEndDate: service.requestedEndDate,
              description: service.description,
            ),
            const Divider(height: AppSpacing.lg),
            Text('Histórico do serviço', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            ServiceHistory(
              history: service.history,
              createdAt: service.creationDate,
              viewerRole: Role.client,
              currentUserId: currentUserId,
              clientName: service.clientName,
              acceptedProviderName: acceptedProviderName,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ações conforme o estado: aberto, cancelar; atribuído, marcar como realizado
/// e cancelar; realizado e sem avaliação, avaliar; avaliado ou cancelado,
/// nenhuma.
class _ServiceActions extends StatelessWidget {
  const _ServiceActions({
    required this.status,
    required this.reviewed,
    required this.onCancel,
    required this.onComplete,
    required this.onReview,
    required this.enabled,
  });

  final ServiceStatus status;
  final bool reviewed;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback onReview;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).colorScheme.error;
    final canCancel =
        status == ServiceStatus.open || status == ServiceStatus.assigned;
    final canReview = status == ServiceStatus.completed && !reviewed;
    if (!canCancel && !canReview) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (status == ServiceStatus.assigned)
            FilledButton(
              onPressed: enabled ? onComplete : null,
              child: const Text('Marcar como realizado'),
            ),
          if (canReview)
            FilledButton.icon(
              onPressed: enabled ? onReview : null,
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text('Avaliar serviço'),
            ),
          if (canCancel)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: danger,
                side: BorderSide(color: danger.withValues(alpha: 0.4)),
              ),
              onPressed: enabled ? onCancel : null,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancelar serviço'),
            ),
        ],
      ),
    );
  }
}

/// Faixa do serviço cancelado, a partir da última alteração do histórico.
class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.history});

  final List<ServiceStatusChange> history;

  @override
  Widget build(BuildContext context) {
    final change = history.lastOrNull;
    if (change == null || change.newStatus != ServiceStatus.cancelled) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final date = formatDate(change.changedAt);
    final text = change.changedByRole == Role.provider
        ? 'Cancelado pelo Prestador (${change.changedByName}) a $date.'
        : change.previousStatus == ServiceStatus.open
        ? 'Cancelou este serviço a $date, quando ainda estava aberto.'
        : 'Cancelou este serviço a $date.';

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
