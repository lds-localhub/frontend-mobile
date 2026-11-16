import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';

/// Arranque com sessão: carrega o utilizador autenticado (E04); se o pedido
/// falhar, mostra o erro com «Tentar outra vez» e «Terminar sessão».
class StartingScreen extends ConsumerStatefulWidget {
  const StartingScreen({super.key});

  @override
  ConsumerState<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends ConsumerState<StartingScreen> {
  bool _submitting = false;

  void _handleRetryPressed() => ref.invalidate(meProvider);

  // Quem não consegue chegar ao servidor não pode ficar preso neste ecrã
  Future<void> _handleLogoutPressed() async {
    setState(() => _submitting = true);
    await logout();
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: me.hasError && !me.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorStateView(
                    error: me.error!,
                    onRetry: _handleRetryPressed,
                  ),
                  TextButton(
                    onPressed: _submitting ? null : _handleLogoutPressed,
                    child: const Text('Terminar sessão'),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('LocalHub', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.lg),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    );
  }
}
