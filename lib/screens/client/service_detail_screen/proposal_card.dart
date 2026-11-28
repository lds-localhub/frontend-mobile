import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/proposal.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/proposals/proposal_terms.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/rating_text.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

import 'proposal_decision.dart';

/// Uma proposta a um serviço aberto a propostas: o Prestador, o estado, as
/// datas e os termos. Pendente e com o serviço aberto ([decision]), «Aceitar»
/// e «Recusar».
class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.proposal,
    this.voidedByCancellationAt,
    this.decision,
  });

  final ServiceProposal proposal;

  /// Data do cancelamento, se o serviço foi cancelado ainda aberto.
  final String? voidedByCancellationAt;

  /// Só com o serviço aberto.
  final ProposalDecisionHandlers? decision;

  String get _dates {
    final sent = 'Enviada ${formatDate(proposal.creationDate)}';
    final decisionDate = proposal.decisionDate;
    final cancelledAt = voidedByCancellationAt;
    if (proposal.status == ProposalStatus.voided && cancelledAt != null) {
      return '$sent · Sem efeito a ${formatDate(decisionDate ?? cancelledAt)} '
          '(serviço cancelado)';
    }
    return decisionDate == null
        ? sent
        : '$sent · Decidida a ${formatDate(decisionDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = proposal.professionalProfile;
    final decision = this.decision;

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
            Text(_dates, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: ProposalTerms(proposal: proposal),
            ),
            if (decision != null && proposal.status == ProposalStatus.pending)
              ProposalDecision(
                proposalId: proposal.proposalId,
                handlers: decision,
              ),
          ],
        ),
      ),
    );
  }
}
