import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
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
    final distance = service.distanceKm;

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
              '${service.serviceCategory.name} · ${service.title}',
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
            _InfoLine(
              icon: Icons.place_outlined,
              text: distance == null
                  ? service.location
                  : '${service.location} (${formatDistance(distance)})',
            ),
            _InfoLine(
              icon: Icons.calendar_today_outlined,
              text:
                  'Disponibilidade: ${formatAvailability(service.requestedStartDate, service.requestedEndDate)}',
            ),
            const SizedBox(height: AppSpacing.xs),
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
            // A criação não vem no histórico, que só tem as alterações de estado
            _HistoryEntry(
              title: '${ServiceStatus.open.label} · Serviço criado',
              subtitle:
                  '${formatDate(service.creationDate)} · ${service.clientName} (Cliente)',
            ),
            for (final change in service.history)
              _HistoryEntry(
                title: change.newStatus.label,
                // O Prestador não vê o nome de quem fez a alteração do lado do
                // Prestador: pode ter sido o Prestador contratado e não ele
                subtitle:
                    '${formatDate(change.changedAt)} · '
                    '${change.changedByRole == Role.client ? '${service.clientName} (Cliente)' : 'Prestador'}',
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 10,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
