import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/proposals/proposal_terms.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/rating_text.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

/// Uma proposta a um serviço aberto a propostas: o Prestador, o estado, as
/// datas e os termos.
class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key, required this.proposal});

  final ServiceProposal proposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = proposal.professionalProfile;
    final decisionDate = proposal.decisionDate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InitialsAvatar(name: provider.name, radius: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: theme.textTheme.titleMedium),
                      RatingText(
                        averageRating: provider.averageRating,
                        reviewCount: provider.reviewCount,
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: proposal.status.label,
                  tone: proposal.status.tone,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              decisionDate == null
                  ? 'Enviada ${formatDate(proposal.creationDate)}'
                  : 'Enviada ${formatDate(proposal.creationDate)} · '
                        'Decidida a ${formatDate(decisionDate)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: ProposalTerms(proposal: proposal),
            ),
          ],
        ),
      ),
    );
  }
}
