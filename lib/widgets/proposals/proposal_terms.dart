import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/ui/expandable_text.dart';

/// Valor, condições e observações de uma proposta, com os textos longos
/// cortados.
class ProposalTerms extends StatelessWidget {
  const ProposalTerms({super.key, required this.proposal});

  final ProposalSummary proposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obs = proposal.obs;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Valor', style: labelStyle),
        Text(
          formatCurrency(proposal.amount),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Condições', style: labelStyle),
        ExpandableText(proposal.conditions),
        if (obs != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Observações', style: labelStyle),
          ExpandableText(obs),
        ],
      ],
    );
  }
}
