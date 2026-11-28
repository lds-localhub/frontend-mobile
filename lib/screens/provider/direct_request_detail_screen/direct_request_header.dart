import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/services/service_history.dart';
import 'package:localhub/widgets/services/service_meta.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

/// Cabeçalho do detalhe de uma solicitação: Cliente, estado, serviço, morada,
/// disponibilidade, data de receção e histórico do serviço.
class DirectRequestHeader extends StatelessWidget {
  const DirectRequestHeader({super.key, required this.data});

  final DirectRequestDetail data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = data.service;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: service.clientName, radius: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação de', style: theme.textTheme.bodySmall),
                      Text(
                        service.clientName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                StatusChip(label: data.status.label, tone: data.status.tone),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Text(
              '${service.serviceCategory.name} · «${service.title}»',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: Text(
                '«${service.description}»',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ServiceMeta(
              location: service.location,
              distanceKm: service.distanceKm,
              requestedStartDate: service.requestedStartDate,
              requestedEndDate: service.requestedEndDate,
            ),
            Text(
              'Solicitação recebida a ${formatDate(data.creationDate)}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Histórico do serviço',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusChip(
                  label: service.status.label,
                  tone: service.status.tone,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ServiceHistory(
              history: service.history,
              createdAt: service.creationDate,
              viewerRole: Role.provider,
              clientName: service.clientName,
            ),
          ],
        ),
      ),
    );
  }
}
