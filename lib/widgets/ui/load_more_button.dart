import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

/// «Ver mais» no fim de uma lista paginada; com [loading], mostra o
/// carregamento da página seguinte.
class LoadMoreButton extends StatelessWidget {
  const LoadMoreButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: onPressed,
                child: const Text('Ver mais'),
              ),
      ),
    );
  }
}
