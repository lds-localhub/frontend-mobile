import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/category.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';

/// Dados de um serviço: categoria e data de publicação, local e distância,
/// disponibilidade, Cliente e descrição; os que forem `null` não aparecem.
class ServiceMeta extends StatelessWidget {
  const ServiceMeta({
    super.key,
    required this.requestedStartDate,
    this.requestedEndDate,
    this.category,
    this.location,
    this.distanceKm,
    this.publishedAt,
    this.clientName,
    this.description,
  });

  final CategoryRef? category;
  final String? location;
  final double? distanceKm;
  final String requestedStartDate;
  final String? requestedEndDate;
  final String? publishedAt;
  final String? clientName;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = this.category;
    final location = this.location;
    final distanceKm = this.distanceKm;
    final publishedAt = this.publishedAt;
    final clientName = this.clientName;
    final description = this.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (category != null)
          _MetaRow(
            icon: Icons.build_outlined,
            text: publishedAt == null
                ? category.name
                : '${category.name} · Publicado a ${formatDate(publishedAt)}',
          ),
        if (location != null)
          _MetaRow(
            icon: Icons.location_on_outlined,
            text: distanceKm == null
                ? location
                : '$location · ${formatDistance(distanceKm)}',
          ),
        _MetaRow(
          icon: Icons.calendar_today_outlined,
          text:
              'Disponibilidade: '
              '${formatAvailability(requestedStartDate, requestedEndDate)}',
        ),
        if (clientName != null)
          _MetaRow(icon: Icons.person_outline, text: 'Cliente: $clientName'),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
