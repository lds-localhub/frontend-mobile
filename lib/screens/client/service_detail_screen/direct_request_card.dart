import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/proposal.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/proposals/proposal_terms.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/rating_text.dart';
import 'package:localhub/widgets/ui/status_chip.dart';

import 'proposal_decision.dart';

/// Uma solicitação direta do serviço: o Prestador, o estado, as datas e a
/// proposta ou, sem proposta, a frase do estado. Com a proposta pendente e o
/// serviço aberto ([decision]), «Aceitar» e «Recusar».
class DirectRequestCard extends StatelessWidget {
  const DirectRequestCard({
    super.key,
    required this.request,
    this.acceptedProviderName,
    this.voidedByCancellationAt,
    this.decision,
  });

  final ServiceDirectRequest request;

  /// Prestador com a proposta aceite no serviço, para explicar porque a
  /// solicitação ficou sem efeito.
  final String? acceptedProviderName;

  /// Data do cancelamento, se o serviço foi cancelado ainda aberto.
  final String? voidedByCancellationAt;

  /// Só com o serviço aberto.
  final ProposalDecisionHandlers? decision;

  // Ao lado do estado da proposta: quando foi aceite ou quando ficou sem efeito
  // por causa do cancelamento
  String? _statusNote(ProposalSummary proposal) {
    final decisionDate = proposal.decisionDate;
    final cancelledAt = voidedByCancellationAt;
    if (proposal.status == ProposalStatus.accepted && decisionDate != null) {
      return 'Aceite a ${formatDate(decisionDate)}';
    }
    if (proposal.status == ProposalStatus.voided && cancelledAt != null) {
      return 'Sem efeito a ${formatDate(decisionDate ?? cancelledAt)} '
          '(serviço cancelado)';
    }
    return null;
  }

  String get _statusText => switch (request.status) {
    DirectRequestStatus.pending => 'A aguardar resposta do Prestador.',
    DirectRequestStatus.declined => 'O Prestador recusou a solicitação.',
    // Com proposta apresentada, o cartão mostra a proposta e não esta frase
    DirectRequestStatus.proposalSubmitted => '',
    DirectRequestStatus.voided =>
      acceptedProviderName == null
          ? 'Ficou sem efeito quando cancelou o serviço.'
          : 'Ficou sem efeito quando aceitou a proposta de '
                '$acceptedProviderName.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = request.professionalProfile;
    final proposal = request.proposal;
    final responseDate = request.responseDate;
    final decision = this.decision;
    final statusNote = proposal == null ? null : _statusNote(proposal);

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
                  label: request.status.label,
                  tone: request.status.tone,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              responseDate == null
                  ? 'Enviada ${formatDate(request.creationDate)}'
                  : 'Enviada ${formatDate(request.creationDate)} · '
                        'Respondida ${formatDate(responseDate)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (proposal == null)
              Text(_statusText, style: theme.textTheme.bodyMedium)
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Proposta',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        StatusChip(
                          label: proposal.status.label,
                          tone: proposal.status.tone,
                        ),
                      ],
                    ),
                    if (statusNote != null)
                      Text(statusNote, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    ProposalTerms(proposal: proposal),
                  ],
                ),
              ),
            if (decision != null &&
                proposal != null &&
                proposal.status == ProposalStatus.pending)
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
