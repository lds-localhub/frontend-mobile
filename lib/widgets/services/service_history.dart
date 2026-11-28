import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';

/// Histórico de um serviço: a criação e as alterações de estado, com quem as
/// fez conforme quem vê.
///
/// O Cliente ([viewerRole] `client`) vê os nomes, com «(você)» nas suas
/// alterações; o Prestador vê o Cliente pelo nome e o Prestador só pelo papel.
class ServiceHistory extends StatelessWidget {
  const ServiceHistory({
    super.key,
    required this.history,
    required this.createdAt,
    required this.viewerRole,
    this.currentUserId,
    this.clientName,
  });

  final List<ServiceStatusChangeSummary> history;
  final String createdAt;
  final Role viewerRole;
  final int? currentUserId;
  final String? clientName;

  String get _creatorText {
    final name = clientName ?? '';
    // A criação não é uma alteração de estado: quem a fez é sempre o Cliente
    return switch (viewerRole) {
      Role.client => '$name (você)',
      _ => '$name (Cliente)',
    };
  }

  String _authorText(ServiceStatusChangeSummary change) {
    if (change is ServiceStatusChange) {
      final mine = change.changedByUserId == currentUserId;
      final suffix = mine
          ? ' (você)'
          : change.changedByRole == Role.provider
          ? ' (Prestador)'
          : '';
      return '${change.changedByName}$suffix';
    }
    // Sem o nome de quem fez a alteração, o Prestador pode não ser o próprio
    return change.changedByRole == Role.client
        ? '${clientName ?? ''} (Cliente)'
        : 'Prestador';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HistoryLine(
          title: 'Aberto · Serviço criado',
          subtitle: '${formatDate(createdAt)} · $_creatorText',
        ),
        for (final change in history)
          _HistoryLine(
            title: change.newStatus.label,
            subtitle:
                '${formatDate(change.changedAt)} · ${_authorText(change)}',
          ),
      ],
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.title, required this.subtitle});

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
              size: 8,
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
