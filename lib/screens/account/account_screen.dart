import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/auth.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

/// Conta do Cliente (M16) e do Prestador (M16b): dados do utilizador, atalhos
/// do papel e fim de sessão.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _submitting = false;

  // Sem confirmação nem mensagem: a sessão termina no telemóvel mesmo que o pedido falhe
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
    // Ao terminar sessão, o ecrã ainda é desenhado uma vez antes de o router mudar de rota
    if (me == null) {
      return const Scaffold(body: LoadingView());
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isClient = me.role == Role.client;

    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  InitialsAvatar(name: me.name),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(me.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${me.role.label} · ${me.email}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (isClient) ...[
                  const _AccountOption(
                    icon: Icons.location_on_outlined,
                    label: 'Localização',
                    location: '/cliente/conta/localizacao',
                  ),
                  const _AccountOption(
                    icon: Icons.bar_chart,
                    label: 'Relatório de atividade',
                    location: '/cliente/conta/relatorio',
                  ),
                ] else ...[
                  const _AccountOption(
                    icon: Icons.badge_outlined,
                    label: 'O meu perfil',
                    location: '/prestador/conta/perfil',
                  ),
                  const _AccountOption(
                    icon: Icons.bar_chart,
                    label: 'Relatório de atividade',
                    location: '/prestador/conta/relatorio',
                  ),
                ],
                const _AccountOption(
                  icon: Icons.lock_outline,
                  label: 'Alterar palavra-passe',
                  location: '/conta/palavra-passe',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
            ),
            onPressed: _submitting ? null : _handleLogoutPressed,
            icon: const Icon(Icons.logout),
            label: const Text('Terminar sessão'),
          ),
        ],
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.icon,
    required this.label,
    required this.location,
  });

  final IconData icon;
  final String label;
  final String location;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(location),
    );
  }
}
