import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Decisão do Cliente sobre uma proposta pendente: só com o serviço aberto.
typedef ProposalDecisionHandlers = ({
  ValueChanged<int> onAccept,
  ValueChanged<int> onDecline,
  bool enabled,
});

/// «Aceitar» e «Recusar», lado a lado no fundo do cartão; a confirmação é
/// aberta pelo ecrã.
class ProposalDecision extends StatelessWidget {
  const ProposalDecision({
    super.key,
    required this.proposalId,
    required this.handlers,
  });

  final int proposalId;
  final ProposalDecisionHandlers handlers;

  @override
  Widget build(BuildContext context) {
    final enabled = handlers.enabled;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: enabled ? () => handlers.onAccept(proposalId) : null,
              child: const Text('Aceitar'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton(
              onPressed: enabled ? () => handlers.onDecline(proposalId) : null,
              child: const Text('Recusar'),
            ),
          ),
        ],
      ),
    );
  }
}
