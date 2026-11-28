import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

/// Cartão de um serviço do Cliente: título, estado, categoria e data, a
/// modalidade e o número de propostas, e as ações «Cancelar serviço» (nos
/// abertos e atribuídos) e «Abrir».
class ServiceListCard extends StatelessWidget {
  const ServiceListCard({
    super.key,
    required this.service,
    required this.onOpen,
    required this.onCancel,
    this.enabled = true,
  });

  final ServiceItem service;
  final VoidCallback onOpen;
  final VoidCallback onCancel;

  /// Falso enquanto a lista atualiza ou um cancelamento decorre.
  final bool enabled;

  // Só os serviços abertos e atribuídos podem ser cancelados
  bool get _cancellable =>
      service.status == ServiceStatus.open ||
      service.status == ServiceStatus.assigned;

  // Modalidade; nas solicitações diretas, com o número de Prestadores a quem
  // foi pedida
  String get _summary {
    final model = service.proposalModel == ProposalModel.directRequest
        ? '${service.proposalModel.label} (${service.directRequestsCount})'
        : service.proposalModel.label;
    final count = service.proposalsCount;
    return '$model · $count ${count == 1 ? 'proposta' : 'propostas'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = theme.colorScheme.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Um título longo fica em duas linhas; o completo está no
                  // detalhe
                  Expanded(
                    child: Text(
                      service.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(
                    label: service.status.label,
                    tone: service.status.tone,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${service.serviceCategory.name} · '
                '${formatDate(service.creationDate)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(_summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              // Os botões ficam lado a lado, alinhados à esquerda
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (_cancellable)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: danger,
                        side: BorderSide(color: danger.withValues(alpha: 0.4)),
                      ),
                      onPressed: enabled ? onCancel : null,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancelar serviço'),
                    ),
                  OutlinedButton(onPressed: onOpen, child: const Text('Abrir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
