import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/theme/app_theme.dart';

/// Início do Prestador sem perfil profissional (M04): explica o que é preciso
/// e dá acesso à criação do perfil e ao fim de sessão.
class NoProfileScreen extends ConsumerStatefulWidget {
  const NoProfileScreen({super.key});

  @override
  ConsumerState<NoProfileScreen> createState() => _NoProfileScreenState();
}

class _NoProfileScreenState extends ConsumerState<NoProfileScreen> {
  bool _submitting = false;

  Future<void> _handleLogoutPressed() async {
    setState(() => _submitting = true);
    await logout();
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider).value;
    final firstName = (me?.name ?? '').trim().split(RegExp(r'\s+')).first;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      // «Olá» e não «Bem-vinda»/«Bem-vindo», que supõem o género
      appBar: AppBar(title: Text('Olá, $firstName')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Icon(
                        Icons.badge_outlined,
                        size: 36,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Crie o seu perfil profissional',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sem perfil, não aparece aos Clientes nem pode pesquisar '
                      'serviços ou apresentar propostas.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O que vai precisar',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _Step(
                      number: 1,
                      text:
                          'Uma apresentação, os contactos e a sua experiência',
                    ),
                    const _Step(
                      number: 2,
                      text: 'As categorias em que trabalha',
                    ),
                    const _Step(
                      number: 3,
                      text: 'A morada de onde parte e o raio de atuação',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.push('/prestador/criar-perfil'),
              child: const Text('Criar perfil'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _submitting ? null : _handleLogoutPressed,
              child: const Text('Terminar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
            child: Text(
              '$number',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
