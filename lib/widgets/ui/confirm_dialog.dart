import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// Pede confirmação de uma ação que não pode ser anulada; devolve `true` se o
/// utilizador carregar em «Confirmar».
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String subject,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) =>
        ConfirmDialog(title: title, subject: subject, message: message),
  );
  return confirmed ?? false;
}

/// Janela de confirmação: ícone de aviso, título em pergunta, o nome do que é
/// afetado a negrito, as consequências e os botões «Voltar» e «Confirmar».
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.subject,
    required this.message,
  });

  final String title;
  final String subject;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = theme.colorScheme.error;

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
        decoration: BoxDecoration(
          color: danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Icon(Icons.warning_amber_rounded, color: danger),
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          // Os botões ficam no conteúdo e não nas ações da janela: as ações
          // não dão largura limitada aos botões, que ocupam metade cada um
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: danger),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
