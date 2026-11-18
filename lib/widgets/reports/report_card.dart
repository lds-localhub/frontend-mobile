import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Secção de um relatório: cartão com o título e o conteúdo.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
