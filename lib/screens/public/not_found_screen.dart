import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  void _handleHomePressed(BuildContext context) => context.go('/boas-vindas');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Página não encontrada',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => _handleHomePressed(context),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
