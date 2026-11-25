import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/services/service_history.dart';
import 'package:localhub/widgets/services/service_meta.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

/// Cartão de cima do detalhe do serviço: título, estado, modalidade, dados,
/// descrição e histórico.
class ServiceOverview extends StatelessWidget {
  const ServiceOverview({
    super.key,
    required this.service,
    required this.currentUserId,
  });

  final ServiceDetail service;
  final int currentUserId;

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
            ),
          ],
        ),
      ),
    );
  }
}
